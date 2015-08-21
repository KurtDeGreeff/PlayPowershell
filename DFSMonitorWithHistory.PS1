<# 
.SYNOPSIS
	Monitor your DFS Replication Backlog with a graphical history.
.DESCRIPTION
	Use the DFSMonitorWithHistory.ps1 script to monitor your DFS backlog.  It
	contains a graphical history chart as well as detailed information from
	each run.  I recommend running from a scheduled task every hour to get the
	best information.
	
	Make sure to edit the PARAM section and update it for your environment.
	
	Graphical history chart is a Google visualization that requires Flash to run 
	(it's the same chart you see on Google Finance).  Historical data is saved
	in an XML file.
.PARAMETER DFSServers
	Array of computers to be processed.  For backwards compatibility this parameter
	will also accept a comma seperated list, i.e.: "server1,server2,server3" and
	will automatically split it into an array.  Otherwise you can use the 
	standard array syntax:  server1,server2,server3 (without quotes), or
	"server1","server2","server3"
.PARAMETER DaysToSaveData
	How much of a history do you want the script to keep.  I recommend no more then 2
	weeks, but 1 week is probably better for larger DFS implementations.
.PARAMETER DataLocation
	The full path, or UNC, to where you want the script to keep the historic
	data. Logs kept by the script will also be stored here.
.PARAMETER OutputLocation
	The full path, or UNC, to where you want the script to save the HTML files
	the script creates.  I recommend you make this the root folder for a web
	server.  For IIS, the default location would be:  \\servername\c$\inetpub\wwwroot
.PARAMETER MaxThreads
	This scripts uses multithreading to improve performance for gathering the
	DFS information.  You can alter the number of threads that it uses based on 
	the server you have.  In testing I found 10 to about the sweet spot for my 
	server (less or more was slower).  You should not need to modify this
	amount.
.INPUTS
	Historical data file:  $DataLocation\DFSData.XML
.OUTPUTS
	Log:  $DataLocation\debugMMddyyyyHHmm.log
	Data File:  $DataLocation\DFSData.XML
	Primary HTML Page (use this):  $OutputLocation\DFSMonitorGrid.HTML
	Placeholder HTML for Detailed Reports (contains iFrame):  $OutputLocation\DFSDetailIndex.HTML
	Detailed Reports (displayed in iFrame):  $OutputLocation\DFSDetailsMMddyyyyHHmm.HTML
.EXAMPLE
	.\pathtoscript\DFSMonitorWithHistory.PS1
	Runs the script while accepting all default values.  Edit PARAM section
	of this script to match your environment.
.EXAMPLE
	.\pathtoscript\DFSMonitorWithHistory.PS1 -DFSServes server1,server2 -DaysToSave 7 -DataLocation c:\scripts\dfs -OutputLocation \\webserver\c$\inetpub\wwwroot
	Runs the script using the servers server1 and server2, it will save the data for 7 days and keep
	the logs and datafile (DFSData.XML) at c:\scripts\dfs.  All of the HTML pages will be stored on 
	a server called webserver on the c: drive in \inetpub\wwwroot (the default web root directory
	on an IIS server).  It will accept the default of 10 threads.
.NOTES
	Author:            Martin Pugh
    Twitter:           @thesurlyadm1n
    Spiceworks:        Martin9700
    Blog:              www.thesurlyadmin.com
	
	Change Log:
    2.63 - Improved error reporting in primary script and in multithreaded sub-scripts.  Converted
           sub-script output to object for better data handling, and changed the "All Groups" variable
           from a string array to hashtable for better performance.  Fixed some debug messages that worked
           fine in ISE but not on command line.  Fixed bug with Alerts not showing up on the 
           DFSMonitorGrid.HTML start page.
    2.62 - Bug when using $DupeCheck to make sure script doesn't check the same group/folder pair
           more then once.  Added Cmdletbinding to support -Verbose output.  
    2.61 - Bug found by Bhopper577 where test-path was still looking for the old CSV data file.
	2.6  - Changed saving from a CSV file to an XML which will preserve date/time without having
	       to convert in script.
	2.51 - Increased the # of PING's to 4 so remote server detection over WAN will be a little
	       more reliable.  This required a change in the string detection so 0% loss, 25% loss and
		   75% loss would all be acceptable.  I fudged on the RegEx a bit so technically 20%, 55%
		   and 70% are OK too, but if you only ping 4 times you can't get those percentages!
.LINK
	http://community.spiceworks.com/scripts/show/1536-dfs-monitor-with-history
.LINK
	http://www.thesurlyadmin.com/2012/08/03/dfs-replication-monitoring/
#>
[CmdletBinding()]
Param (
	[array]$DFSServers = "mffile1,fdfile2,gbfile1",
	[int]$DaysToSaveData = 5,
	[string]$DataLocation = "C:\Dropbox\Scripts\PS Scripts\DFS Replication Monitor",
	[string]$OutputLocation = "C:\Dropbox\Scripts\PS Scripts\DFS Replication Monitor",
	[int]$MaxThreads = 10
)

#region Functions
Function IsAvailable($Server)
{	If ($GoodServers -contains $Server)
	{	Return $true
	}
	Else
	{	If ($BadServers -contains $Server)
		{	Return $false
		}
		$Result = PING $Server -n 4
		Switch -regex ($Result)
		{	"\(0% loss" { $Found = "Yes"; Break }
			"\([257][50]% loss" { $Found = "Yes"; Break }
			"% loss" { $Found = "Failed to respond to PING"; Break }
			"Destination host unreachable" { $Found = "Destination host unreachable"; Break }
			"could not find host" { $Found = "Server Not Found"; Break }
			default { $Found = "Unknown Error" }
		}
		If ($Found -eq "Yes")
		{	$Running = $true
			$Service = Get-Service dfsr -ComputerName $Server
			If ($Service.Status -ne "Running")
			{	$Service = Get-Service dfs -ComputerName $Server
				If ($Service.Status -ne "Running")
				{	$Running = $false
				}
			}
			If ($Running) 
			{	$global:GoodServers += $Server
				Return $true
			}
			Else
			{	Write-Debug "$Server`: DFSr or DFS Service Not Running"
                $global:BadServers += $Server
				$global:AlertReport += "$Server`: DFSr or DFS Service Not Running"
			}
		}
		Else
		{	Write-Debug "$Server`: $Found"
            $global:BadServers += $Server
			$global:AlertReport += "$Server`: $Found"
		}
	}
}

Function GetWMI
{	Param ([String]$WMIQuery,
	[String]$Computer)
	
	$ErrorCount = 0
	Do
	{	$WMIObject = Get-WmiObject -computerName $Computer -Namespace "root\MicrosoftDFS" -Query $WMIQuery -Debug
		If ($WMIObject -eq $null)
		{	$ErrorCount ++
		}
		Else
		{	Return $WMIObject
		}
	}
	While ($ErrorCount -le 2)
	$WMIObject = "WMI Error on $Computer"
	Return $WMIObject
}
#endregion

#Here we go!
cls

#Setup the environment and start the log file
$DebugPreference = "Continue"

#Validate Data path exists, since this is where the log file exists we'll use Write-Host to notify.
If (-not (Test-Path $DataLocation -PathType Container))
{   Write-Host "Data Path: $DataLocation does not exist!  Stopping script." -ForegroundColor Red
    Exit
}

#Setup the log
[DateTime]$ScriptRunDate = (Get-Date).DateTime
$SaveFormatDate = Get-Date $ScriptRunDate -format yyyyMMddHHmm
Start-Transcript -Path $DataLocation\debug$SaveFormatDate.log

#Validate Output/Report location exists
If (-not (Test-Path $OutputLocation -PathType Container))
{   Write-Debug "Output Path: $OutputLocation does not exist!  Stopping script."
    Exit
}

#Set some global variables
$NewData = @()
$Global:AlertReport = @()
$Global:GoodServers = @()
$Global:BadServers = @()
$AllGroupNames = @{}
$DupeCheck = @()
$Servers = @()

#Display parameters
Write-Debug "Servers to be scanned: $DFSServers"
Write-Debug "Days to Save Data:  $DaysToSaveData"
Write-Debug "Data Path: $DataLocation"
Write-Debug "HTML Path: $OutputLocation"
Write-Debug "Maximum Threads: $MaxThreads"

Write-Debug "Loading data..."

#Parse DFSServers and make a good array
ForEach ($Item in $DFSServers)
{	If ($Item.Contains(","))
	{	$Servers += $Item.Split(",")
	}
	Else
	{	$Servers += $Item
	}
}
[DateTime]$SaveDate = (Get-Date).Date.AddDays(-$DaysToSaveData)

#Check if Data file exists, if so import it, if not create it.
If ((Test-Path $DataLocation\DFSData.xml) -eq $False)
{	$Data = @()
}
Else
{	$Data = Import-Clixml $DataLocation\DFSData.xml
	If ($Data.Count -gt 0) 
	{	$Data = $Data | Where {$_.RunDate -ge $SaveDate}
	}
	Else
	{	$Data = @()
	}
}

#Start the main loop.  
ForEach ($FileServer in $Servers) 
{	Write-Debug "Now working on $FileServer..."
    $FileServer = $FileServer.ToUpper()
	If (-not (IsAvailable $FileServer))
	{	Continue
	}
	
	$WMIQuery = "SELECT * FROM DfsrReplicationGroupConfig"
	$GroupGUIDs = GetWMI -WMIQuery $WMIQuery -Computer $FileServer
	If ($GroupGUIDs -like "*WMI Error*")
	{	$AlertReport += $GroupGUIDs
		Continue
	}
	
	$WMIQuery = "SELECT * FROM DfsrConnectionConfig WHERE InBound=True"
	$RGConnections = GetWMI -WMIQuery $WMIQuery -Computer $FileServer
	If ($RGConnections -like "*WMI Error*")
	{	$AlertReport += $RGConnections
		Continue
	}

	$WMIQuery = "SELECT * FROM DfsrReplicatedFolderConfig"
	$RGFolders = GetWMI -WMIQuery $WMIQuery -Computer $FileServer
	If ($RGFolders -like "*WMI Error*")
	{	$AlertReport += $RGFolders
		Continue
	}

	ForEach ($Group in $GroupGUIDs)
	{	#If (($AllGroupNames -match $Group.ReplicationGroupGuid).count -eq 0 -or $AllGroupNames.Count -eq 0)
        If (-not $AllGroupNames.ContainsKey($Group.ReplicationGroupGuid))
		{	#$temp = $Group.ReplicationGroupGUID + ":" + $Group.ReplicationGroupName
			#$AllGroupNames += $temp
            $AllGroupNames.Add($Group.ReplicationGroupGUID,$Group.ReplicationGroupName)
		}
		$GFolders = $RGFolders | Where {$_.ReplicationGroupGUID -eq $Group.ReplicationGroupGUID}
		ForEach ($Folder in $GFolders)
		{	$GConnection = $RGConnections | Where {$_.ReplicationGroupGUID -eq $Group.ReplicationGroupGUID}
			ForEach ($Connection in $GConnection)
			{	$InServer = $FileServer
				$OutServer = $Connection.PartnerName
				
				#Check if we've already done this
				$Found = "No"
				ForEach ($Line in $DupeCheck)
				{	If ($Line[0].ToUpper() -eq $Group.ReplicationGroupName.ToUpper() -and
						$Line[1].ToUpper() -eq $Folder.ReplicatedFolderName.ToUpper() -and
						$Line[2].ToUpper() -eq $InServer.ToUpper() -and
						$Line[3].ToUpper() -eq $OutServer.ToUpper())
					{	$Found = "Yes"
						Break
					}
				}
				If ($Found -eq "No")
				{	$DupeCheck += ,@($Group.ReplicationGroupName,$Folder.ReplicatedFolderName,$InServer,$OutServer)
					$DupeCheck += ,@($Group.ReplicationGroupName,$Folder.ReplicatedFolderName,$OutServer,$InServer)
				}
				Else
				{	Continue
				}
				
				#Now check if partner server is available
				If (-not (IsAvailable $OutServer))
				{	Continue
				}
	
				For ($i = 1; $i -le 2; $i++)
				{	While ($(Get-Job -state "Running").count -ge $MaxThreads)
					{	Write-Debug "Thread count hit max of $MaxThreads, waiting for threads to finish..."
       					Start-Sleep -Milliseconds 5000
   					}
					Start-Job -ArgumentList $InServer,$OutServer,$Group,$Folder.ReplicatedFolderName -ScriptBlock {
                        Param (
                            [string]$InServer,
							[string]$OutServer,
							[object]$Group,
							[string]$ReplicationFolder
                        )
						
                        Function GetWMI
						{	Param (
                                [String]$WMIQuery,
							    [String]$Computer
                            )
	
							$ErrorCount = 0
							While ($ErrorCount -le 2)
							{	$WMIObject = Get-WmiObject -Namespace "root\MicrosoftDFS" -Query $WMIQuery -ComputerName $Computer -Debug
								If ($WMIObject)
								{	$Status = "Success"
                                    $ErrorDetail = ""
                                    Break
								}
								Else
								{	$ErrorCount ++
                                    $Status = "Error"
                                    $ErrorDetail = $Error[0]
								}
							}
							New-Object PSObject -Property @{
                                Status = $Status
                                Object = $WMIObject
                                Error = $ErrorDetail
                            }
						}
						$ErrorCount = 0
						$BacklogConnCount = 0
                        $ErrorDetail = ""
                        
						$WMIQuery = "SELECT * FROM DfsrReplicatedFolderConfig WHERE ReplicationGroupGUID = '" + $Group.ReplicationGroupGUID + "' AND ReplicatedFolderName = '" + $ReplicationFolder + "'"
						$WMIObject = GetWMI -WMIQuery $WMIQuery -Computer $InServer
						If ($WMIObject.Status -eq "Error")
						{	$Status = "Error"
							$BacklogFiles = "WMI Error"
							$ErrorReport = "WMI Error on $InServer"
                            $ErrorDetail = $WMIObject.Error
						}
						ElseIf ($WMIObject.Object.Enabled)
						{	$WMIQuery = "SELECT * FROM DfsrReplicatedFolderConfig WHERE ReplicationGroupGUID = '" + $Group.ReplicationGroupGUID + "' AND ReplicatedFolderName = '" + $ReplicationFolder + "'"
							$WMIObject = GetWMI -WMIQuery $WMIQuery -Computer $OutServer
							If ($WMIObject.Status -eq "Error")
							{	$Status = "Error"
							    $BacklogFiles = "WMI Error"
							    $ErrorReport = "WMI Error on $OutServer"
                                $ErrorDetail = $WMIObject.Error
							}
							ElseIf ($WMIObject.Object.Enabled)
							{	#Get the version vector of the partner
								$WMIQuery = "SELECT * FROM DfsrReplicatedFolderInfo WHERE ReplicationGroupGUID = '" + $Group.ReplicationGroupGUID + "' AND ReplicatedFolderName = '" + $ReplicationFolder + "'"
								$WMIObject = GetWMI -WMIQuery $WMIQuery -Computer $OutServer
								If ($WMIObject.Status -eq "Error")
								{	$Status = "Error"
									$BacklogFiles = "WMI Error"
									$ErrorReport = "WMI Error occurred on $OutServer"
									$ErrorDetail = $WMIObject.Error
								}
                                Else
                                {   $Vv = $WMIObject.Object.GetVersionVector().VersionVector
								    #Get the backlog count from the partner
								    $WMIQuery = "SELECT * FROM DfsrReplicatedFolderInfo WHERE ReplicationGroupGUID = '" + $Group.ReplicationGroupGUID + "' AND ReplicatedFolderName = '" + $ReplicationFolder + "'"
								    $WMIObject = GetWMI -WMIQuery $WMIQuery -Computer $InServer
								    If ($WMIObject.Status -eq "Error")
								    {	$Status = "WMI Error"
									    $BacklogFiles = "WMI Error"
									    $ErrorReport = "WMI Error occurred on $OutServer"
                                        $ErrorDetail = $WMIObject.Error
								    }
                                    Else
                                    {   $BacklogConnCount = $WMIObject.Object.GetOutboundBacklogFileCount($Vv).BacklogFileCount
								        $arrFiles = $WMIObject.Object.GetOutboundBacklogFileIDRecords($Vv).BacklogIdRecords
								        If ($BacklogConnCount -eq 0)
								        {	$Files = "&nbsp;"
								        }
								        Else	
								        {	$Files = ""
									        ForEach ($FileLine in $arrFiles) 
									        {	$Files += $FileLine.FileName + "<br>"
									        }
								        }
								        $Status = "Success"
								        $BacklogFiles = $Files
								        $ErrorReport = ""
                                    }
						        }
                            }
							Else
							{	$Status = "Disabled"
								$BacklogFiles = "Disabled"
								$ErrorReport = "Folder $($Group.ReplicationGroupName)/$ReplicationFolder disabled on $OutServer"
							}
						}
						Else
						{	$Status = "Disabled"
							$BacklogFiles = "Disabled"
							$ErrorReport = "Folder $($Group.ReplicationGroupName)/$ReplicationFolder disabled on $InServer"
						}
                        New-Object PSObject -Property @{
                            Status = $Status
                            BacklogFiles = $BacklogFiles
                            ErrorReport = $ErrorReport
                            ErrorDetail = $ErrorDetail
                            GroupObject = $Group.ReplicationGroupGUID
                            Folder = $ReplicationFolder
                            InServer = $InServer
                            OutServer = $OutServer
                            BacklogCount = $BacklogConnCount
                        }
                    } | Out-Null
					$InServer = $Connection.PartnerName
					$OutServer = $FileServer
				}
			}
		}	
	}
}

#Wait for all the jobs to finish
While (@(Get-Job -State "Running").count -gt 0)
{	Write-Debug "All threads submitted, waiting for them to finish..."
	Start-Sleep -Milliseconds 5000
}

#Now read the job data into data
Write-Debug "All threads completed.  Threads run: $(@(Get-Job).Count)"
$Output = @()
ForEach ($Job in Get-Job)
{	$ErrorCount = 0
	Do
	{	Write-Debug "Receiving job number: $($Job.Id)"
		$Result = Receive-Job $Job
		If ($Result -eq $null)
		{	$ErrorCount ++
			If ($ErrorCount -eq 4)
			{	Write-Debug "Unable to retrieve job: $($Job.id)"
				$Result = "Fail"
			}
			Else
			{	Write-Debug "Problem retrieving job: $($Job.id), Retry: $ErrorCount"
				Start-Sleep -Seconds 3
			}
		}
		Else
		{	$ErrorCount = 4
		}
	} While ($ErrorCount -lt 4)
	If ($Result -eq "Fail")
	{	Remove-Job $Job
		Continue
	}
	#$GroupName = ($AllGroupNames | Where {$_ -match $Result.Group}).Split(":")
	$NewData += ,@($AllGroupNames[$Result.GroupObject],$Result.Folder,$Result.InServer,$Result.OutServer,$Result.BacklogCount,$Result.BacklogFiles)
	$Output += New-Object PSCustomObject -Property @{
		GroupName = $AllGroupNames[$Result.GroupObject]
		GroupGUID = $Result.GroupObject
		Folder = $Result.Folder
		InServer = $Result.InServer
		OutServer = $Result.OutServer
		Backlog = $Result.BacklogCount
		BackLogFiles = $Result.BacklogFiles
	}
	If ($Result.Status -ne "Success")
	{	If ($AlertReport -notcontains $Result.ErrorReport)
		{	$AlertReport += $Result.ErrorReport
            Write-Debug $Result.ErrorDetail
		}
	}
	Remove-Job $Job
}

#Now add the new data
ForEach ($GroupName in $AllGroupNames.Values)
{	#$GroupName = ($Group.Split(":"))[1]
	$UniqueReplFolders = $Output | Where {$_.GroupName -eq $GroupName} | Select Folder -Unique
	ForEach ($Folder in $UniqueReplFolders)
	{	$BacklogCount = ($Output | Where {$_.GroupName -eq $GroupName -and $_.Folder -eq $Folder.Folder} | Measure-Object Backlog -sum).Sum
		$NewRGName = $Folder.Folder + ":" + $GroupName
		$Data += New-Object PSCustomObject -Property @{
			RFName = $Folder.Folder
			RGGUID = $NewRGName
			BacklogCount = $BacklogCount
			RunDate = $ScriptRunDate
		}
	}
}

If ($Data -eq $Null)
{	#Something went horribly wrong!
	Write-Debug "No data found!"
	Throw
}
Else
{	#Delete oldest detail and debug files
	Get-ChildItem $OutputLocation\dfsdetails*.html | Where {$_.CreationTime -lt $SaveDate} | Remove-Item
	Get-ChildItem $DataLocation\debug*.log | Where {$_.CreationTime -lt $SaveDate} | Remove-Item
	
	##
	## Now build the detailed DFS monitor page
	##
	Write-Debug "--Creating detailed monitoring page..."
	$html = @()
	$html = "<html><head>`n"
	$html += "<style type='text/css'>`n"
	$html += "table, th, td { border:1px solid black;border-collapse:collapse;padding-left:5px;padding-right:5px;}`n"
	$html += "table { width:95%;}`n"
	$html += "th { background-color:#000080;color:#FFFFFF;font:bold 18px arial,sans-serif;}`n"
	$html += "tr.d0 {background-color:#4682b4;color:black;font:15px arial,sans-serif;}`n"
	$html += "tr.d1 {background-color:#B0C4DE;color:black;font:15px arial,sans-serif;}`n"
	$html += "</style></head><body>`n"
	$html += "<div style=""width:95%;text-align:right;"">Report Date: $ScriptRunDate</div><br>"
	If ($AlertReport)
	{	$html += "<B>Alerts:</B><br>`n"
		ForEach ($Line in $AlertReport)
		{	$html += "<img src=""error_event.png"">" + $Line + "<br>`n"
		}
	}
	$html += "<table border=""1"">`n"
	$html += "<th>Replication Group</th><th>Replication Folder</th><th>Sending Partner</th><th>Receiving Partner</th><th>Backlog</th><th>Files</th>`n"
	$TRDomain = "d1"
	$NewData = $NewData | Sort
	ForEach ($Line in $NewData)
	{	If ($TRDomain -eq "d1")
		{$TRDomain = "d0"
		}
		Else
		{	$TRDomain = "d1"
		}
		$html += "<tr class=""$TRdomain"">"
		$html += "<td>" + $Line[0] + "</td>"
		$html += "<td>" + $Line[1] + "</td>"
		$html += "<td>" + $Line[2] + "</td>"
		$html += "<td>" + $Line[3] + "</td>"
		If ($Line[4] -eq 0)
		{	$html += "<td>0</td>"
		}
		Else
		{	$html += "<td style=""background-color:red"">" + $Line[4] + "</td>"
		}
		If ($Line[5] -like "*Disabled*" -or $Line[5] -like "*WMI Error*")
		{	$html += "<td style=""background-color:red"">" + $Line[5] + "</td>"
		}
		Else
		{	$html += "<td>" + $Line[5] + "</td>"
		}
		$html += "</tr>`n"
	}
	$html += "</table></body></html>"
	$html | Out-File $OutputLocation\DFSDetails$SaveFormatDate.html
	
	# Now create the detail launch page
	$html = @()
	$html = "<html>`n"
	$html += "<head><title>DFS Replication Details</title>`n"
	$html += "<script type=""text/javascript"">`n"
	$html += "function open_win() `n"
 	$html += "{	var myEle=document.getElementById('gopage');`n"
	$html += "	var myiFrame=document.getElementById('iframe');`n"
	$html += "	var myPage=myEle.options[myEle.selectedIndex].value;`n"
	$html += "	if (myPage != '') `n"
	$html += "	{	myiFrame.src=myPage;`n"
	$html += "	}`n"
	$html += "}`n"
	$html += "</script></head>`n"
	$html += "<body>`n"
	$html += "<iframe id=""iframe"" width=""95%"" height=""95%"" src=""DFSDetails$SaveFormatDate.html""></iframe>`n"
	$html += "<br>Show Report from: &nbsp;<select id=""gopage"" onChange=""open_win()"">`n"
	$html += "	<option value="""" selected></option>`n"
	$Files = Get-ChildItem $OutputLocation\dfsdetails*.html | Sort CreationTime -Descending
	ForEach ($File in $Files)
	{	$FileName = $File.Name.Substring(14,2) + "/" + $File.Name.Substring(16,2) + "/" + $File.Name.Substring(10,4) + " " + $File.Name.Substring(18,2) + ":" + $File.Name.Substring(20,2)
		$html += "	<option value=""" + $File.Name + """>" + $FileName +"</option>`n"
	}
	$html += "</select></body></html>`n"
	$html | Out-File $OutputLocation\DFSDetailIndex.html
	
	##
	##  Now create the Google visualization
	##
	Write-Debug "--Now for the Annotated Timeline..."
	$html = "<html>`n"
	$html += "<head>`n"
	$html += "<script type='text/javascript' src='http://www.google.com/jsapi'></script>`n"
	$html += "<script type='text/javascript'>`n"
	$html += "google.load('visualization', '1', {'packages':['annotatedtimeline']});`n"
	$html += "google.setOnLoadCallback(drawChart);`n"
	$html += "function drawChart() {`n"
	$html += "var data = new google.visualization.DataTable();`n"
	$html += "data.addColumn('datetime', 'Date');`n"
	
	#Define the columns
	$UniqueReplGroups = $Data | Select RGGUID -Unique | Sort -Property RGGUID
	$UniqueReplGroups = $UniqueReplGroups | Where {$_.RFName -ne ""}
	ForEach ($Group in $UniqueReplGroups)
	{	$Data | Where {$_.RGGUID -eq $Group.RGGUID} | Select RFName -First 1 | ForEach {
			$html += "data.addColumn('number', '" + $_.RFName + "');`n"
			$html += "data.addColumn('string', '" + $_.RFName + "Status');`n"
			$html += "data.addColumn('string', '" + $_.RFName + "ErrorMsg');`n"
		}
	}
	$html += "data.addRows([`n"
	
	$UniqueRunDates = $Data | Select RunDate -Unique | Sort -Property RunDate
	$rec = 0
	ForEach ($distDate in $UniqueRunDates)
	{	$NewLine = "[new Date(" + $distDate.RunDate.Year + "," + (($distDate.RunDate.Month) - 1) + "," + $distDate.RunDate.Day + "," + $distDate.RunDate.Hour + "," + $distDate.RunDate.Minute + "," + $distDate.RunDate.Second + ")"
		$DatabyRunDate = $Data | Where {$_.RunDate -eq $distDate.RunDate}
		ForEach ($Group in $UniqueReplGroups)
		{	$Line = $DatabyRunDate | Where {$_.RGGUID -eq $Group.RGGUID}
			If ($Line.RFName)
			{	$NewLine += ", " + $Line.BacklogCount + ",undefined, undefined"
			}
			Else
			{	$NewLine += ", 0,undefined, undefined"
			}
		}
		If ($rec -ge ($UniqueRunDates.Count - 1)) 
		{	$html += $NewLine + "]`n"
		}
		Else 
		{	$html += $NewLine + "],`n"
			$rec ++
		}
	}
	$html += "]);`n"
	$html += "var chart = new google.visualization.AnnotatedTimeLine(document.getElementById('chart_div'));`n"
	$html += "chart.draw(data, {displayAnnotations: false, legendPosition: 'newRow'});`n"
	$html += "}`n"
	$html += "</script></head>`n"
	$html += "<META HTTP-EQUIV=""REFRESH"" CONTENT=""1800"">`n"
	$html += "<body>`n"
	If ($AlertReport)
	{	$html += "<B>Alerts:</B><br>`n"
		ForEach ($Line in $AlertReport)
		{	$html += "<img src=""error_event.png"">" + $Line + "<br>`n"
		}
	}
	$html += "<div id=""chart_div"" style=""height: 400px;width:95%;""></div>`n"
	$html += "<a href=""DFSDetailIndex.html"" target=""_blank"">Details from last run ($ScriptRunDate)</a>`n"
	$html += "</body></html>"
	$html | Out-File $OutputLocation\DFSMonitorGrid.html
}

#And Save the data
Write-Debug "--Saving the data..."
$Data = $Data | Where {$_.RFName -ne ""}
$Data | Export-Clixml $DataLocation\DFSData.xml

#All done!
Write-Debug "Done!"
Stop-Transcript