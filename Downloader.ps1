# Downloader v2.4.1003          #
# Copyright 2013 Microsoft      #
# A TED Sample Solution         #
# Created by Rob Willis         #
# Rob.Willis@microsoft.com      #

Param
(
    [Parameter(Mandatory=$false,Position=0)]
    [String]$Path = (Get-Location),

    [Parameter(Mandatory=$false)]
    [Switch]$DeploymentOnly = $false
)

$host.UI.RawUI.BackgroundColor = "Black"; Clear-Host

# Elevate
Write-Host "Checking for elevation... " -NoNewline
$CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
if (($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) -eq $false)  {
    $ArgumentList = "-noprofile -noexit -file `"{0}`" -Path `"$Path`""
    If ($DeploymentOnly) {$ArgumentList = $ArgumentList + " -DeploymentOnly"}
    Write-Host "elevating"
    Start-Process powershell.exe -Verb RunAs -ArgumentList ($ArgumentList -f ($myinvocation.MyCommand.Definition))
    Exit
}

$Host.UI.RawUI.BackgroundColor = "Black"; Clear-Host
$StartTime = Get-Date
$Validate = $true

# Check PS host
If ($Host.Name -ne 'ConsoleHost') {
    $Validate = $false
    Write-Host "Downloader.ps1 should not be run from ISE" -ForegroundColor Red
}

# Check OS version
If ((Get-WmiObject -Class Win32_OperatingSystem).Version -ne "6.2.9200") {
    $Validate = $false
    Write-Host "Downloader.ps1 should be run from Windows Server 2012 or Windows 8" -ForegroundColor Red
}

# Change to path
If (Test-Path $Path -PathType Container) {
    Set-Location $Path
} Else {
    $Validate = $false
    Write-Host "Invalid path" -ForegroundColor Red
}

Write-Host ""
Write-Host "Start time:" (Get-Date)

# Read input files
If (Test-Path "$Path\Workflow.xml") {
    try {$Workflow = [XML] (Get-Content "$Path\Workflow.xml")} catch {$Validate = $false;Write-Host "Invalid Workflow.xml" -ForegroundColor Red}
} Else {
    $Validate = $false
    Write-Host "Missing Workflow.xml" -ForegroundColor Red
}
If ($DeploymentOnly) {
    If (Test-Path "$Path\Variable.xml") {
        try {$Variable = [XML] (Get-Content "$Path\Variable.xml")} catch {$Validate = $false;Write-Host "Invalid Variable.xml" -ForegroundColor Red}
    } Else {
        $Validate = $false
        Write-Host "Missing Variable.xml" -ForegroundColor Red
    }
}

If ($Validate) {

    If ($DeploymentOnly) {
        $Servers = @($Variable.Installer.Roles.Role | Where-Object {($_.Existing -ne "True") -and ($_.SQLCluster -ne "True")} | Sort-Object {$_.Server} -Unique | ForEach-Object {$_.Server})
        $SQLClusters = @($Variable.Installer.Roles.Role | Where-Object {($_.Existing -ne "True") -and ($_.SQLCluster -eq "True")} | ForEach-Object {$_.Server})
        $SQLClusters | ForEach-Object {
            $SQLCluster = $_
            $SQLClusterNodes = $Variable.Installer.SQL.Cluster | Where-Object {$_.Cluster -eq $SQLCluster} | ForEach-Object {$_.Node.Server}
            $Servers += $SQLClusterNodes
        }

        # Get SQL versions
        $Installables = @("Windows Server 2012")
        $Servers | ForEach-Object {
            $Server = $_
            $Variable.Installer.Roles.Role | Where-Object {($_.Server -eq $Server) -and ($_.Instance -ne $null)} | ForEach-Object {$_.Instance} | Sort-Object -Unique | ForEach-Object {
                $Instance = $_
                $Variable.Installer.SQL.Instance | Where-Object {($_.Server -eq $Server) -and ($_.Instance -eq $Instance)} | ForEach-Object {
                    $Installables += $_.Version
                }
            }
        }

        # Get roles
        $MRoles = @()
        $Servers | ForEach-Object {
        $Server = $_

        # Get roles for this server
        $MRoles += @($Variable.Installer.Roles.Role | Where-Object {$_.Server -eq $Server} | Where-Object {$_.Existing -ne "True"} | ForEach-Object {$_.Name})

        # Get SQL cluster roles for this server
        $Variable.Installer.SQL.Cluster | ForEach-Object {
            $SQLCluster = $_.Cluster
            $_.Node | Where-Object {$_.Server -eq $Server} | ForEach-Object {
                $SQLClusterNode = $_.Server
                $SQLClusterNodes = $Variable.Installer.Roles.Role | Where-Object {$_.Server -eq $SQLCluster} | ForEach-Object {$_.Name}
                $MRoles += $SQLClusterNodes
            }
        }

        # Get integrations for this server
        # For each role on this server...
        $MRoles | ForEach-Object {
            $Role = $_
            $Integration = $false
            # ...find integrations targeted at that role
            $Workflow.Installer.Integrations.Integration | Where-Object {$_.Target -eq $Role} | ForEach-Object {
                $ThisIntegration = $_.Name
                $Integration = $true
                # Check that all integration dependencies exist in this deployment
                $_.Dependency | ForEach-Object {
                    $Dependency = $_
                    If (!($Variable.Installer.Roles.Role | Where-Object {$_.Name -eq $Dependency})) {
                        $Integration = $false
                    }
                }
                If ($Integration) {
                    $MRoles += $ThisIntegration
                }
            }
        }
        }
        $MRoles = $MRoles | Sort-Object -Unique

        # Get installables
        $MRoles | ForEach-Object {
            $Role = $_
            $Workflow.Installer.Roles.Role | Where-Object {$_.Name -eq $Role} | ForEach-Object {
                $_.Prerequisites | ForEach-Object {
                    $_.Prerequisite | ForEach-Object {
                        $Prerequisite = $_.Name
                        If (!($Workflow.Installer.Roles.Role | Where-Object {$_.Name -eq $Prerequisite})) {
                            $Workflow.Installer.Installables.Installable | ForEach-Object {
                                $InstallableName = $_.Name
                                If ($_.Install | Where-Object {$_.Name -eq $Prerequisite}) {
                                    $Installables += $InstallableName
                                }
                            }
                        }
                    }
                }
                $_.Install | ForEach-Object {
                    $Installables += $_.Installable
                }
            }
        }
        $Installables = $Installables | Sort-Object -Unique

        # Get additional installables
        $Installables | ForEach-Object {
            $Installable = $_
            $Workflow.Installer.Installables.Installable | Where-Object {$_.Name -eq $Installable} | ForEach-Object {
                If ($_.AdditionalDownload) {
                    $_.AdditionalDownload | ForEach-Object {
                        $Installables += $_
                    }
                }
            }
        }
        $Installables = $Installables | Sort-Object -Unique
    } Else {
        $Installables = $Workflow.Installer.Installables.Installable | ForEach-Object {$_.Name}
    }

    $InstallablesData = @()
    $Workflow.Installer.Installables.Installable | ForEach-Object {
        $Installable = $_
        $InstallableName = $_.Name
        If ($Installables | Where-Object {$_ -eq $InstallableName}) {
            $InstallablesData += $Installable
        }
    }

    $WebClient = New-Object System.Net.WebClient

    If (Test-Path '.\Variable.xml') {$Variable = [XML] (Get-Content '.\Variable.xml')}
    $SystemDrive = $env:SystemDrive
    $Workflow.Installer.Variable | Where-Object {$_.Name -eq "Download"} | ForEach-Object {
        Invoke-Expression ("`$Download = " + "`"" + $_.Value + "`"")
    }
    If ($Variable) {
        $Variable.Installer.Variable | Where-Object {$_.Name -eq "Download"} | ForEach-Object {
            Invoke-Expression ("`$Download = " + "`"" + $_.Value + "`"")
        }
    }

    # Count items to download
    $DownloadCount = 0
    $RunCount = 0
    $ZipCount = 0
    $ISOCount = 0
    $RARCount = 0
    $InstallablesData | ForEach-Object {
        If ($_.Download) {
            $_.Download | ForEach-Object {
                If ($_.Type -eq "DownloadRun") {$RunCount++}
                If ($_.URL -ne $null) {
                    $DownloadCount++
                    If ($_.Type -eq "DownloadExtract") {
                        Switch ($_.Extract.Type) {
                            "Zip" {$ZipCount++}
                            "ISO" {$ISOCount++}
                            "RAR" {$RARCount++}
                        }
                    }
                }
            }
        }
    }

    # Calculate total download size
    $i = 0
    $DownloadSizeTotal = 0
    $DownloadNeeded = 0
    $InstallablesData | ForEach-Object {
        If ($_.Download) {
            $DownloadName = $_.Name
            $_.Variable | ForEach-Object {
                If (Get-Variable $_.Name -ErrorAction SilentlyContinue) {
                    Set-Variable -Name $_.Name -Value $_.Value
                } Else {        
                    New-Variable -Name $_.Name -Value $_.Value
                }
            }
            $DownloadFolder = Invoke-Expression ($_.SourceFolder)
            $_.Download | ForEach-Object {
                If ($_.URL -ne $null) {
                    $i++
                    $DownloadItem = $_
                    $DownloadType = $_.Type
                    $DownloadURL = $_.URL
                    $DownloadFile = $_.File
        
                    Switch ($DownloadType) {
                        "DownloadExtract" {
                            $ExistingFile = $DownloadItem.Extract.ExistingFile
                            $Skip = Test-Path "$Download\$DownloadFolder\$ExistingFile"
                            $DownloadPath = "$Download\Download\$DownloadFolder\$DownloadFile"
                        }
                        "DownloadRun" {
                            $ExistingFile = @($DownloadItem.Run.ExistingFile)[0]
                            $Skip = Test-Path "$Download\$DownloadFolder\$ExistingFile"
                            $DownloadPath = "$Download\Download\$DownloadFolder\$DownloadFile"
                        }
                        Default {
                            $DownloadPath = "$Download\$DownloadFolder\$DownloadFile"
                            $Skip = $false
                        }
                    }

                    Write-Progress -id 1 -Activity 'Calculating Total Download Size' -Status "Item $i of $DownloadCount - $DownloadName" -PercentComplete (($i/$DownloadCount) * 100)

                    # Get item download size
                    $WebRequest = [net.WebRequest]::Create($DownloadURL)
                    $WebResponse = $WebRequest.GetResponse()
                    $DownloadSize = $WebResponse.ContentLength
                    $WebResponse.Close()
                    $WebRequest.Abort()

                    # Delete current item if it is not the correct size
                    If (!($Skip)) {
                        If (Test-Path $DownloadPath) {
                            If ((Get-Item $DownloadPath).Length -ne $DownloadSize) {
                                Remove-Item $DownloadPath
                                $DownloadSizeTotal = $DownloadSizeTotal + $DownloadSize
                                $DownloadNeeded++
                            }
                        } Else {
                            If (!(Test-Path "$Download\$DownloadFolder")) {New-Item -Path "$Download\$DownloadFolder" -ItemType Directory | Out-Null}
                            $DownloadSizeTotal = $DownloadSizeTotal + $DownloadSize
                            $DownloadNeeded++
                        }
                    }
                }
            }
        }
    }
    $DownloadSizeTotalinMB = [System.Math]::Round(($DownloadSizeTotal/1024/1024),2)

    If ($DownloadSizeTotalInMB -ne 0) {
        # Download item
        $i = 0
        $DownloadedSize = 0
        Write-Progress -id 2 -Activity 'Starting Download'
        $InstallablesData | ForEach-Object {
            If ($_.Download) {
                $DownloadName = $_.Name
                $ShortDownloadFolder = Invoke-Expression ($_.SourceFolder)
                $_.Download | ForEach-Object {
                    If ($_.URL -ne $null) {
                        $DownloadItem = $_
                        $DownloadFolder = $ShortDownloadFolder
                        $DownloadType = $_.Type
                        $DownloadURL = $_.URL
                        $DownloadFile = $_.File
        
                        If ($WebClient.IsBusy) {Start-Sleep 1}

                        Switch ($DownloadType) {
                            "DownloadExtract" {
                                $ExistingFile = $DownloadItem.Extract.ExistingFile
                                $Skip = Test-Path "$Download\$DownloadFolder\$ExistingFile"
                                $DownloadPath = "$Download\Download\$DownloadFolder\$DownloadFile"
                                $DownloadFolder = "$Download\Download\$DownloadFolder"
                            }
                            "DownloadRun" {
                                $ExistingFile = @($DownloadItem.Run.ExistingFile)[0]
                                $Skip = Test-Path "$Download\$DownloadFolder\$ExistingFile"
                                $DownloadPath = "$Download\Download\$DownloadFolder\$DownloadFile"
                                $DownloadFolder = "$Download\Download\$DownloadFolder"
                            }
                            Default {
                                $DownloadPath = "$Download\$DownloadFolder\$DownloadFile"
                                $DownloadFolder = "$Download\$DownloadFolder"
                                $Skip = $false
                            }
                        }
                        # If current item does not exist
                        If (!(Test-Path $DownloadPath) -and !($Skip)) {
                            $i++

                            $DownloadCurrentTotal = 0
                            $DownloadCurrentTotalinMB = 0

                            # Get item download size
                            $WebRequest = [net.WebRequest]::Create($DownloadURL)
                            $WebResponse = $WebRequest.GetResponse()
                            $DownloadSize = $WebResponse.ContentLength
                            $WebResponse.Close()
                            $WebRequest.Abort()
                            $DownloadSizeInMB = [System.Math]::Round(($DownloadSize/1024/1024),2)
        
                            # Create folder for item
                            If (!(Test-Path $DownloadFolder)) {
                                New-Item -Path $DownloadFolder -ItemType Directory | Out-Null
                            }

                            # Download item
                            try {
                                $WebCLient.DownloadFileAsync($DownloadURL,$DownloadPath)
                            } Catch {
                                Write-Host $Error
                            }
                            While (!(Test-Path $DownloadPath)) {Start-Sleep 1}
                            While ((Get-Item $DownloadPath).Length -lt $DownloadSize) {
                                $DownloadCurrentSize = (Get-Item $DownloadPath).Length
                                $DownloadCurrentSizeinMB = [System.Math]::Round(($DownloadCurrentSize/1024/1024),2)
                                $DownloadCurrentTotal = $DownloadedSize + $DownloadCurrentSize
                                $DownloadCurrentTotalinMB = [System.Math]::Round(($DownloadCurrentTotal/1024/1024),2)
                                Write-Progress -id 1 -Activity "Downloading Item $i of $DownloadNeeded" -Status "$DownloadCurrentTotalinMB of $DownloadSizeTotalinMB MB" -PercentComplete (($DownloadCurrentTotal/$DownloadSizeTotal) * 100)
                                Write-Progress -id 2 -Activity "Downloading $DownloadName" -Status "$DownloadCurrentSizeinMB of $DownloadSizeInMB MB" -PercentComplete (((Get-Item $DownloadPath).Length / $DownloadSize)*100)
                            }
                            $DownloadedSize = $DownloadedSize + (Get-Item $DownloadPath).Length
                        }
                    }
                }
            }
        }
    }

    # Zip Extract
    If ($ZipCount -ge 1) {
        Write-Progress -id 1 -Activity 'Starting Zip Extract'
        $i = 0
        $Shell = New-Object -ComObject shell.application
        $InstallablesData | ForEach-Object {
            If ($_.Download -and ($_.Download.Type -eq "DownloadExtract") -and ($_.Download.Extract.Type -eq "Zip")) {
                $DownloadName = $_.Name
                $DownloadFolder = Invoke-Expression ($_.SourceFolder)
                $_.Download | ForEach-Object {
                    $i++
                    $DownloadFile = $_.File
                    $ExistingFile = $_.Extract.ExistingFile
                    Write-Progress -id 1 -Activity "Extracting zip $i of $ZipCount" -PercentComplete ((($i-1)/$ZipCount) * 100)
                    Write-Progress -id 2 -Activity "Extracting zip $DownloadName" -PercentComplete ((($i-1)/$ZipCount) * 100)
                    If (!(Test-Path "$Download\$DownloadFolder\$ExistingFile")) {
                        $Zip = $Shell.Namespace("$Download\Download\$DownloadFolder\$DownloadFile")
                        $Unzip = $Shell.Namespace("$Download\$DownloadFolder")
                        $Unzip.CopyHere($Zip.Items(),16)
                    }
                }
            }
        }
    }

    # ISO Extract
    If ($ISOCount -ge 1) {
        Write-Progress -id 1 -Activity 'Starting ISO Extract'
        $i = 0
        $InstallablesData | ForEach-Object {
            If ($_.Download -and ($_.Download.Type -eq "DownloadExtract") -and ($_.Download.Extract.Type -eq "ISO")) {
                $DownloadName = $_.Name
                $DownloadFolder = Invoke-Expression ($_.SourceFolder)
                $_.Download | ForEach-Object {
                    $i++
                    $DownloadFile = $_.File
                    $ExistingFile = $_.Extract.ExistingFile
                    Write-Progress -id 1 -Activity "Extracting ISO $i of $ISOCount" -PercentComplete ((($i-1)/$ISOCount) * 100)
                    Write-Progress -id 2 -Activity "Extracting ISO $DownloadName" -PercentComplete ((($i-1)/$ISOCount) * 100)
                    If (!(Test-Path "$Download\$DownloadFolder\$ExistingFile")) {
                        $ExtractSize = (Mount-DiskImage -ImagePath "$Download\Download\$DownloadFolder\$DownloadFile" -PassThru).Size
                        $ExtractDrive = (Get-Volume | Where-Object {($_.DriveType -eq 'CD-ROM') -and ($_.Size -eq $ExtractSize)}).DriveLetter
                        $ExtractDrive = $ExtractDrive + ":"
                        If ($_.Extract.Files) {
                            $_.Extract.Files.File | ForEach-Object {
                                Start-Process -FilePath 'robocopy.exe' -ArgumentList "$ExtractDrive $Download\$DownloadFolder $_" -Wait -WindowStyle Hidden
                            }
                        } Else {
                            Start-Process -FilePath 'robocopy.exe' -ArgumentList "$ExtractDrive $Download\$DownloadFolder /e" -Wait -WindowStyle Hidden
                        }
                        Dismount-DiskImage -ImagePath "$Download\Download\$DownloadFolder\$DownloadFile"
                    }
                }
            }
        }
    }

    # RAR Extract
    If ($RARCount -ge 1) {
        If (Test-Path "C:\Program Files\WinRAR\WinRAR.exe") {
            Write-Progress -id 1 -Activity 'Starting RAR Extract'
            $i = 0
            $InstallablesData | ForEach-Object {
                If ($_.Download -and ($_.Download.Type -eq "DownloadExtract") -and ($_.Download.Extract.Type -eq "RAR")) {
                    $DownloadName = $_.Name
                    $DownloadFolder = Invoke-Expression ($_.SourceFolder)
                    $_.Download | ForEach-Object {
                        $i++
                        $DownloadFile = $_.File
                        $ExistingFile = $_.Extract.ExistingFile
                        Write-Progress -id 1 -Activity "Extracting RAR $i of $RARCount" -PercentComplete ((($i-1)/$RARCount) * 100)
                        Write-Progress -id 2 -Activity "Extracting RAR $DownloadName" -PercentComplete ((($i-1)/$RARCount) * 100)
                        If (!(Test-Path "$Download\$DownloadFolder")) {
                            New-Item -Path "$Download\$DownloadFolder" -ItemType Directory | Out-Null
                        }
                        If (!(Test-Path "$Download\$DownloadFolder\$ExistingFile")) {
                            Start-Process -FilePath 'C:\Program Files\WinRAR\WinRAR.exe' -ArgumentList "x $Download\Download\$DownloadFolder\$DownloadFile $Download\$DownloadFolder" -Wait -WindowStyle Hidden
                        }
                    }
                }
            }
        } Else {
            Write-Host "WinRAR not found"
        }
    }

    # Run
    If ($RunCount -ge 1) {
        Write-Progress -id 1 -Activity 'Starting Run'
        $i = 0
        $InstallablesData | ForEach-Object {
            If ($_.Download -and ($_.Download.Type -eq "DownloadRun")) {
                $DownloadName = $_.Name
                $DownloadFolder = Invoke-Expression ($_.SourceFolder)
                $_.Download | ForEach-Object {
                    $i++
                    $DownloadFile = $_.File
                    $_.Run | ForEach-Object {
                        $DownloadCommand = $_.Command
                        $DownloadArgument = $_.Argument
                        $ExistingFile = $_.ExistingFile
                        Write-Progress -id 1 -Activity "Running $i of $RunCount" -PercentComplete ((($i-1)/$RunCount) * 100)
                        Write-Progress -id 2 -Activity "Running $DownloadName" -PercentComplete ((($i-1)/$RunCount) * 100)
                        If (($ExistingFile -eq $null) -or !(Test-Path "$Download\$DownloadFolder\$ExistingFile")) {
                            Invoke-Expression ("`$DownloadCommand" + " = `"" + $DownloadCommand + "`"")
                            Invoke-Expression ("`$DownloadArgument" + " = `"" + $DownloadArgument + "`"")
                            If ($DownloadArgument -eq "") {
                                Start-Process -FilePath $DownloadCommand -Wait -WindowStyle Hidden
                            } Else {
                                Start-Process -FilePath $DownloadCommand -ArgumentList $DownloadArgument -Wait -WindowStyle Hidden
                            }
                        }
                    }
                }
            }
        }
    }
}

Write-Host "End time:" (Get-Date)
Write-Host ""