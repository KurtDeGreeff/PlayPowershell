# Channel9 Session Downloader 1.81
# Updated to include Build 2015 and Ignite 2015 sessions
# 1.9: Added session tag as destination filename prefix
# Original: https://gallery.technet.microsoft.com/sessions-from-Channel-9-543a6501
#
#----------------------------------------------
#region Application Functions
#----------------------------------------------

function OnApplicationLoad
{
    #Note: This function is not called in Projects
    #Note: This function runs before the form is created
    #Note: To get the script directory in the Packager use: Split-Path $hostinvocation.MyCommand.path
    #Note: To get the console output in the Packager (Windows Mode) use: $ConsoleOutput (Type: System.Collections.ArrayList)
    #Important: Form controls cannot be accessed in this function
    #TODO: Add modules and custom code to validate the application load
	
    
    
    return $true #return true for success or false for failure
}

function OnApplicationExit
{
    #Note: This function is not called in Projects
    #Note: This function runs after the form is closed
    #TODO: Add custom code to clean up and unload modules when the application exits
    
    $script:ExitCode = 0 #Set the exit code for the Packager
}

#endregion Application Functions

#----------------------------------------------
# Generated Form Function
#----------------------------------------------
function Call-TechEd1_7_psf {

	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load('mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.Xml, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.Core, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.ServiceProcess, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	#endregion Import Assemblies

	#----------------------------------------------
	#region Define SAPIEN Types
	#----------------------------------------------
	try{
		$local:type = [ProgressBarOverlay]
	}
	catch
	{
		Add-Type -ReferencedAssemblies ('System.Windows.Forms', 'System.Drawing') -TypeDefinition  @" 
		using System;
		using System.Windows.Forms;
		using System.Drawing;
        namespace SAPIENTypes
        {
		    public class ProgressBarOverlay : System.Windows.Forms.ProgressBar
	        {
	            protected override void WndProc(ref Message m)
	            { 
	                base.WndProc(ref m);
	                if (m.Msg == 0x000F)// WM_PAINT
	                {
	                    if (Style != System.Windows.Forms.ProgressBarStyle.Marquee || !string.IsNullOrEmpty(this.Text))
                        {
                            using (Graphics g = this.CreateGraphics())
                            {
                                using (StringFormat stringFormat = new StringFormat(StringFormatFlags.NoWrap))
                                {
                                    stringFormat.Alignment = StringAlignment.Center;
                                    stringFormat.LineAlignment = StringAlignment.Center;
                                    if (!string.IsNullOrEmpty(this.Text))
                                        g.DrawString(this.Text, this.Font, Brushes.Black, this.ClientRectangle, stringFormat);
                                    else
                                    {
                                        int percent = (int)(((double)Value / (double)Maximum) * 100);
                                        g.DrawString(percent.ToString() + "%", this.Font, Brushes.Black, this.ClientRectangle, stringFormat);
                                    }
                                }
                            }
                        }
	                }
	            }
              
                public string TextOverlay
                {
                    get
                    {
                        return base.Text;
                    }
                    set
                    {
                        base.Text = value;
                        Invalidate();
                    }
                }
	        }
        }
"@ | Out-Null
	}
	#endregion Define SAPIEN Types

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$formGetChannel9VidoesSli = New-Object 'System.Windows.Forms.Form'
	$labelChooseEvent = New-Object 'System.Windows.Forms.Label'
	$combobox1 = New-Object 'System.Windows.Forms.ComboBox'
	$tabcontrol1 = New-Object 'System.Windows.Forms.TabControl'
	$Main = New-Object 'System.Windows.Forms.TabPage'
	$FilterLabel = New-Object 'System.Windows.Forms.Label'
	$CatFilterTextbox = New-Object 'System.Windows.Forms.TextBox'
	$buttonSelectNone = New-Object 'System.Windows.Forms.Button'
	$buttonSelectAll = New-Object 'System.Windows.Forms.Button'
	$buttonDownload = New-Object 'System.Windows.Forms.Button'
	$Catcheckedlistbox = New-Object 'System.Windows.Forms.CheckedListBox'
	$labelCategories = New-Object 'System.Windows.Forms.Label'
	$ByAuthor = New-Object 'System.Windows.Forms.TabPage'
	$labelFilter = New-Object 'System.Windows.Forms.Label'
	$AutFiltertextbox = New-Object 'System.Windows.Forms.TextBox'
	$AutNoneButton = New-Object 'System.Windows.Forms.Button'
	$Autcheckedlistbox = New-Object 'System.Windows.Forms.CheckedListBox'
	$AutAllButton = New-Object 'System.Windows.Forms.Button'
	$AutDownloadButton = New-Object 'System.Windows.Forms.Button'
	$labelSpeakers = New-Object 'System.Windows.Forms.Label'
	$Log = New-Object 'System.Windows.Forms.TabPage'
	$Logtextbox = New-Object 'System.Windows.Forms.RichTextBox'
	$Credits = New-Object 'System.Windows.Forms.TabPage'
	$richtextbox1 = New-Object 'System.Windows.Forms.RichTextBox'
	$progressbaroverlay1 = New-Object 'SAPIENTypes.ProgressBarOverlay'
	$groupbox1 = New-Object 'System.Windows.Forms.GroupBox'
	$radiobuttonVideoesOnly = New-Object 'System.Windows.Forms.RadioButton'
	$radiobuttonVideoSlides = New-Object 'System.Windows.Forms.RadioButton'
	$radiobuttonSlidesOnly = New-Object 'System.Windows.Forms.RadioButton'
	$buttonLoadCategories = New-Object 'System.Windows.Forms.Button'
	$labelDownloadPath = New-Object 'System.Windows.Forms.Label'
	$buttonBrowse = New-Object 'System.Windows.Forms.Button'
	$textbox1 = New-Object 'System.Windows.Forms.TextBox'
	$folderbrowserdialog1 = New-Object 'System.Windows.Forms.FolderBrowserDialog'
	$timer1 = New-Object 'System.Windows.Forms.Timer'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
	
	
	
	
	
	
	$formGetChannel9VidoesSli_Load = {
	    #TODO: Initialize Form Controls here
	    # Grab the RSS feed for the MP4 downloads
	    $radiobuttonVideoSlides.Checked = $true
	    # TechEd 2014 Videos and slides
	    #$script:Videos = ([xml]$rss.downloadstring("http://channel9.msdn.com/Events/TechEd/NorthAmerica/2014/RSS/mp4high"))
	    #$Script:Slides = ([xml]$rss.downloadstring("http://channel9.msdn.com/Events/TechEd/NorthAmerica/2014/RSS/slides"))
	    
	}
	
	#region Control Helper Functions
	function Load-ComboBox
	{
	<#
		.SYNOPSIS
			This functions helps you load items into a ComboBox.
	
		.DESCRIPTION
			Use this function to dynamically load items into the ComboBox control.
	
		.PARAMETER  ComboBox
			The ComboBox control you want to add items to.
	
		.PARAMETER  Items
			The object or objects you wish to load into the ComboBox's Items collection.
	
		.PARAMETER  DisplayMember
			Indicates the property to display for the items in this control.
		
		.PARAMETER  Append
			Adds the item(s) to the ComboBox without clearing the Items collection.
		
		.EXAMPLE
			Load-ComboBox $combobox1 "Red", "White", "Blue"
		
		.EXAMPLE
			Load-ComboBox $combobox1 "Red" -Append
			Load-ComboBox $combobox1 "White" -Append
			Load-ComboBox $combobox1 "Blue" -Append
		
		.EXAMPLE
			Load-ComboBox $combobox1 (Get-Process) "ProcessName"
	#>
	    Param (
	        [ValidateNotNull()]
	        [Parameter(Mandatory = $true)]
	        [System.Windows.Forms.ComboBox]$ComboBox,
	        [ValidateNotNull()]
	        [Parameter(Mandatory = $true)]
	        $Items,
	        [Parameter(Mandatory = $false)]
	        [string]$DisplayMember,
	        [switch]$Append
	    )
	    
	    if (-not $Append)
	    {
	        $ComboBox.Items.Clear()
	    }
	    
	    if ($Items -is [Object[]])
	    {
	        $ComboBox.Items.AddRange($Items)
	    }
	    elseif ($Items -is [Array])
	    {
	        $ComboBox.BeginUpdate()
	        foreach ($obj in $Items)
	        {
	            $ComboBox.Items.Add($obj)
	        }
	        $ComboBox.EndUpdate()
	    }
	    else
	    {
	        $ComboBox.Items.Add($Items)
	    }
	    
	    $ComboBox.DisplayMember = $DisplayMember
	}
	
	function Set-ModuleStatus
	{
	    [CmdletBinding(SupportsShouldProcess = $True)]
	    param (
	        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true, HelpMessage = "No module name specified!")]
	        [string]$name
	    )
	    if (!(Get-Module -name "$name"))
	    {
	        if (Get-Module -ListAvailable | ? { $_.name -eq "$name" })
	        {
	            Import-Module -Name "$name"
	            # module was imported
	            return $true
	        }
	        else
	        {
	            # module was not available
	            return $false
	        }
	    }
	    else
	    {
	        # module was already imported
	        # Write-Host "$name module already imported"
	        return $true
	    }
	} # end function Set-ModuleStatus
	
	
	Function Remove-InvalidFileNameChars
	{
	    param (
	        [Parameter(Mandatory = $true,
	                   Position = 0,
	                   ValueFromPipeline = $true,
	                   ValueFromPipelineByPropertyName = $true)]
	        [String]$Name
	    )
	    
	    $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
	    $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
	    return ($Name -replace $re, ' ')
	}
	
	function New-FileDownload
	{
	    [CmdletBinding(SupportsShouldProcess = $True)]
	    param (
	        [parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
	        [ValidateNotNullOrEmpty()]
	        [string]$SourceFile,
	        [parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
	        [string]$DestFolder,
	        [parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
	        [string]$DestFile
	    )
	    [System.Windows.Forms.Application]::DoEvents()
	    [bool] $HasInternetAccess = ([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet)
	    # I should switch this to using a param block and pipelining from property name - just for consistency
	    # I should clean up the display text to be consistent with other functions
	    $error.clear()
	    if (!($DestFolder)) { $DestFolder = $TargetFolder }
	    Set-ModuleStatus -name BitsTransfer
	    if (!($DestFile)) { [string] $DestFile = $SourceFile.Substring($SourceFile.LastIndexOf("/") + 1) }
	    if (Test-Path $DestFolder)
	    {
	        $Logtextbox.Text += "Folder: `"$DestFolder`" exists. `n"
	        
	    }
	    else
	    {
	        $Logtextbox.Text += "Folder: `"$DestFolder`" does not exist, creating... "
	        New-Item $DestFolder -type Directory | Out-Null
	        $Logtextbox.Text += "Done! "
	    }
        # Include session name
        $DestFilename= "$DestFolder\$([io.path]::GetFileNameWithoutExtension( $Sourcefile)) $DestFile"
	    if (Test-Path $DestFilename)
	    {
	        $Logtextbox.Text += "File: $DestFilename exists. `n"
	    }
	    else
	    {
	        if ($HasInternetAccess)
	        {
	            $Logtextbox.Text += "File: $DestFilename does not exist, downloading..."
	            Start-BitsTransfer -Source "$SourceFile" -Destination $DestFilename
	            $Logtextbox.Text += "Done! "
	        }
	        else
	        {
	            $Logtextbox.Text += " `n `n Internet access not detected. Please resolve and try again. `n `n"
	        }
	    }
	} # end function New-FileDownload
	
	function Load-ListBox
	{
	<#
		.SYNOPSIS
			This functions helps you load items into a ListBox or CheckedListBox.
	
		.DESCRIPTION
			Use this function to dynamically load items into the ListBox control.
	
		.PARAMETER  ListBox
			The ListBox control you want to add items to.
	
		.PARAMETER  Items
			The object or objects you wish to load into the ListBox's Items collection.
	
		.PARAMETER  DisplayMember
			Indicates the property to display for the items in this control.
		
		.PARAMETER  Append
			Adds the item(s) to the ListBox without clearing the Items collection.
		
		.EXAMPLE
			Load-ListBox $ListBox1 "Red", "White", "Blue"
		
		.EXAMPLE
			Load-ListBox $listBox1 "Red" -Append
			Load-ListBox $listBox1 "White" -Append
			Load-ListBox $listBox1 "Blue" -Append
		
		.EXAMPLE
			Load-ListBox $listBox1 (Get-Process) "ProcessName"
	#>
	    Param (
	        [ValidateNotNull()]
	        [Parameter(Mandatory = $true)]
	        [System.Windows.Forms.ListBox]$ListBox,
	        [ValidateNotNull()]
	        [Parameter(Mandatory = $true)]
	        $Items,
	        [Parameter(Mandatory = $false)]
	        [string]$DisplayMember,
	        [switch]$Append
	    )
	    
	    if (-not $Append)
	    {
	        $listBox.Items.Clear()
	    }
	    
	    if ($Items -is [System.Windows.Forms.ListBox+ObjectCollection])
	    {
	        $listBox.Items.AddRange($Items)
	    }
	    elseif ($Items -is [Array])
	    {
	        $listBox.BeginUpdate()
	        foreach ($obj in $Items)
	        {
	            $listBox.Items.Add($obj)
	        }
	        $listBox.EndUpdate()
	    }
	    else
	    {
	        $listBox.Items.Add($Items)
	    }
	    
	    $listBox.DisplayMember = $DisplayMember
	}
	
	function Test-ResponseHeader
	{
	    param (
	        $URL
	    )
	    [System.Windows.Forms.Application]::DoEvents()
	    Start-Job -ScriptBlock {
	        $HTTP_Request = [System.Net.WebRequest]::Create($args[0])
	        $HTTP_Request.AllowAutoRedirect = $false
	        
	        # We then get a response from the site.
	        $HTTP_Response = $HTTP_Request.GetResponse()
	        
	        # We then get the HTTP code as an integer.
	        [int]$HTTP_Response.StatusCode
	        
	        
	    } -ArgumentList $URL | Wait-Job | Receive-Job
	}
	
	function Get-RssFeed
	{
	    
	    
	    param ($urlin)
	    [System.Windows.Forms.Application]::DoEvents()
	    Start-Job -ScriptBlock {
	        $rss = (new-object net.webclient)
	        ([xml]$rss.downloadstring($args[0]))
	    } -ArgumentList $urlIn | Wait-Job | Receive-Job
	    
	    
	}
	
	Function Get-RSSXML
	{
	    param (
	        $InputURL
	    )
	    $xmls = @()
        $XMLOutput= @()
	    $i = 1
	    do
	    {
	        $url = "$($InputURL)?page=$i"
	        $URL
	        $Logtextbox.Text += " PageURL: $url "
	        $res = Test-ResponseHeader -URL $url
	        $res
	        $Logtextbox.Text += "Response : $res `n "
	        If ($res -eq 200) { "Download: $url"; $xmls += Get-RssFeed -URL $url }
	        
	        $i++
	    }
	    while ($res -eq 200)
	    Foreach ($xml in $xmls)
	    {
	        $XMLOutput += $xml.rss.channel.item
	    }
	    $XMLOutput
	}
	
	function Disable-FormItems
	{
	    $buttonDownload.Enabled = $false
	    $combobox1.Enabled = $false
	    $groupbox1.Enabled = $false
	    $buttonBrowse.Enabled = $false
	    $buttonSelectAll.Enabled = $false
	    $buttonSelectNone.Enabled = $false
	    $textbox1.Enabled = $false
	    $AutAllButton.Enabled = $false
	    $AutNoneButton.Enabled = $false
	    $tabcontrol1.Enabled = $false
	}
	
	function Enable-FormItems
	{
	    $buttonDownload.Enabled = $true
	    $combobox1.Enabled = $true
	    $groupbox1.Enabled = $true
	    $buttonBrowse.Enabled = $true
	    $buttonSelectAll.Enabled = $true
	    $buttonSelectNone.Enabled = $true
	    $textbox1.Enabled = $true
	    $AutAllButton.Enabled = $true
	    $AutNoneButton.Enabled = $true
	    $tabcontrol1.Enabled = $true
	}
	
	#endregion
	
	$buttonLoadCategories_Click = {
	    #TODO: Place custom script here
	    [System.Windows.Forms.Application]::DoEvents()
	    Start-Job { $Script:Categories = $script:Videos.rss.channel.item | where { $_.category -ne "" } | select -ExpandProperty Category -Unique -ErrorAction SilentlyContinue }
	    
	    Load-ListBox -ListBox $Catcheckedlistbox -Items $Script:Categories
	}
	
	$radiobuttonVideoSlides_CheckedChanged = {
	    #TODO: Place custom script here
	    
	}
	
	$buttonDownload_Click = {
	    #TODO: Place custom script here
	    Disable-FormItems
	    $progressbaroverlay1.Visible = $true
	    $progressbaroverlay1.Style = 'Marquee'
	    if ($radiobuttonVideoesOnly.Checked)
	    {
	        $Logtextbox.Text += "Vidoes only Selected `n"
	        foreach ($item in $Catcheckedlistbox.CheckedItems)
	        {
	            $Logtextbox.Text += "Selected item: $Item `n"
	            $Sessions = $script:Videos | where { $_.Category -match "$item" }
	            
	            foreach ($Session in $Sessions)
	            {
	                $Logtextbox.Text += "$($Session.Title) `n"
	                $url = $Session | select -ExpandProperty Enclosure | Select -ExpandProperty URL
	                $SesionTitle = "$(Remove-InvalidFileNameChars $($Session.Creator)) - $(Remove-InvalidFileNameChars $($Session.Title)).mp4"
	                New-FileDownload -SourceFile $url -DestFolder $textbox1.Text -DestFile $SesionTitle
	                
	            }
	        }
	        
	    }
	    
	    if ($radiobuttonSlidesOnly.Checked)
	    {
	        $Logtextbox.Text += "Slides only Selected `n"
	        foreach ($item in $Catcheckedlistbox.CheckedItems)
	        {
	            $Logtextbox.Text += "Selected item: $Item `n"
	            $Sessions = $script:Slides | where { $_.Category -match "$item" }
	            [System.Windows.Forms.Application]::DoEvents()
	            
	            foreach ($Session in $Sessions)
	            {
	                [System.Windows.Forms.Application]::DoEvents()
	                $Logtextbox.Text += "$($Session.Title) `n"
	                $url = $Session | select -ExpandProperty Enclosure | Select -ExpandProperty URL
	                $SesionTitle = "$(Remove-InvalidFileNameChars $($Session.Creator)) - $(Remove-InvalidFileNameChars $($Session.Title)).pptx"
	                New-FileDownload -SourceFile $url -DestFolder $textbox1.Text -DestFile $SesionTitle
	                
	            }
	        }
	    }
	    
	    if ($radiobuttonVideoSlides.Checked)
	    {
	        $Logtextbox.Text += "Vidoes & Slides  Selected `n"
	        foreach ($item in $Catcheckedlistbox.CheckedItems)
	        {
	            $Logtextbox.Text += "Selected item: $Item `n"
	            
	            $Sessions = $script:Slides | where { $_.Category -match "$item" }
	            
	            foreach ($Session in $Sessions)
	            {
	                $Logtextbox.Text += "$($Session.Title) `n"
	                $url = $Session | select -ExpandProperty Enclosure | Select -ExpandProperty URL
	                $SesionTitle = "$(Remove-InvalidFileNameChars $($Session.Creator)) - $(Remove-InvalidFileNameChars $($Session.Title)).pptx"
	                New-FileDownload -SourceFile $url -DestFolder $textbox1.Text -DestFile $SesionTitle
	                
	            }
	            $Logtextbox.Text += "Selected item: $Item `n"
	            $Sessions = $script:Videos | where { $_.Category -match "$item" }
	            
	            foreach ($Session in $Sessions)
	            {
	                $Logtextbox.Text += "$($Session.Title) `n"
	                $url = $Session | select -ExpandProperty Enclosure | Select -ExpandProperty URL
	                $SesionTitle = "$(Remove-InvalidFileNameChars $($Session.Creator)) - $(Remove-InvalidFileNameChars $($Session.Title)).mp4"
	                New-FileDownload -SourceFile $url -DestFolder $textbox1.Text -DestFile $SesionTitle
	                
	            }
	        }
	        
	    }
	    Enable-FormItems
	    $progressbaroverlay1.Visible = $false
	    
	}
	
	$folderbrowserdialog1_HelpRequest = {
	    #TODO: Place custom script here
	    
	}
	
	$buttonBrowse_Click = {
	    #TODO: Place custom script here
	    $folderbrowserdialog1.ShowDialog()
	    $textbox1.Text = $folderbrowserdialog1.SelectedPath
	    $Logtextbox.Text += "Selected Path $($folderbrowserdialog1.SelectedPath) `n"
	}
	
	$combobox1_SelectedIndexChanged = {
	    #TODO: Place custom script here
	    $Catcheckedlistbox.Items.Clear()
	    $Autcheckedlistbox.Items.Clear()
	    Disable-FormItems
	    $progressbaroverlay1.Visible = $true
	    $progressbaroverlay1.Style = 'Marquee'
	    
	    
	    
	    $Logtextbox.Text += " BaseURL: $($combobox1.Text) `n"
	    
	    $Link = $combobox1.Text
	    [System.Windows.Forms.Application]::DoEvents()
	    $script:Videos = Get-RSSXML -InputURL $Link
	    [System.Windows.Forms.Application]::DoEvents()
	    $SlideLink = $link -replace "mp4high", "Slides"
	    $script:Slides = Get-RSSXML -InputURL $SlideLink
	    [System.Windows.Forms.Application]::DoEvents()
	    $Script:Categories = $script:Videos | where { $_.category -ne "" } | select -ExpandProperty Category -Unique -ErrorAction SilentlyContinue | sort
	    $Script:Speakers += (($script:Videos.creator -split ",").trim()) -replace '[^a-zA-Z -\.]', "" | where { $_ -match '\w' } | select -Unique | sort
	    [System.Windows.Forms.Application]::DoEvents()
	    $Logtextbox.Text += "Loading Categories `n"
	    Load-ListBox -ListBox $Catcheckedlistbox -Items $Script:Categories
	    
	    $Logtextbox.Text += "Loading Speakers `n"
	    Load-ListBox -ListBox $Autcheckedlistbox -Items $Script:Speakers
	    
	    $progressbaroverlay1.Visible = $false
	    Enable-FormItems
	    $CatFilterTextbox.Focus()
	}
	
	$labelChooseEvent_Click = {
	    #TODO: Place custom script here
	    
	}
	
	$buttonSelectAll_Click = {
	    #TODO: Place custom script here
	    for ($i = 0; $i -lt $Catcheckedlistbox.Items.Count; $i++)
	    {
	        $Catcheckedlistbox.SetItemChecked($i, $true)
	    }
	}
	
	$buttonSelectNone_Click = {
	    #TODO: Place custom script here
	    for ($i = 0; $i -lt $Catcheckedlistbox.Items.Count; $i++)
	    {
	        $Catcheckedlistbox.SetItemChecked($i, $false)
	    }
	}
	
	$timer1_Tick = {
	    #TODO: Place custom script here
	    
	}
	
	$button1_Click = {
	    #TODO: Place custom script here
	    $Logtextbox.Text += ($tabcontrol1.SelectedTab).ToString()
	    $AutFiltertextbox.Focus()
	    
	    
	}
	
	$groupbox1_Enter = {
	    #TODO: Place custom script here
	    
	}
	
	$AutAllButton_Click = {
	    #TODO: Place custom script here
	    for ($i = 0; $i -lt $Autcheckedlistbox.Items.Count; $i++)
	    {
	        $Autcheckedlistbox.SetItemChecked($i, $true)
	    }
	}
	
	
	$AutNoneButton_Click = {
	    #TODO: Place custom script here
	    for ($i = 0; $i -lt $Autcheckedlistbox.Items.Count; $i++)
	    {
	        $Autcheckedlistbox.SetItemChecked($i, $false)
	    }
	}
	
	$AutDownloadButton_Click = {
	    #TODO: Place custom script here
	    Disable-FormItems
	    $progressbaroverlay1.Visible = $true
	    $progressbaroverlay1.Style = 'Marquee'
	    if ($radiobuttonVideoesOnly.Checked)
	    {
	        $Logtextbox.Text += "Vidoes only Selected (Speaker) `n"
	        foreach ($item in $Autcheckedlistbox.CheckedItems)
	        {
	            $Logtextbox.Text += "Selected item: $Item `n"
	            $Sessions = $script:Videos | where { $_.Creator -match "$item" }
	            
	            foreach ($Session in $Sessions)
	            {
	                $Logtextbox.Text += "$($Session.Title) (Speaker) `n"
	                $url = $Session | select -ExpandProperty Enclosure | Select -ExpandProperty URL
	                $SesionTitle = "$(Remove-InvalidFileNameChars $($Session.Creator)) - $(Remove-InvalidFileNameChars $($Session.Title)).mp4"
	                New-FileDownload -SourceFile $url -DestFolder $textbox1.Text -DestFile $SesionTitle
	                
	            }
	        }
	        
	    }
	    
	    if ($radiobuttonSlidesOnly.Checked)
	    {
	        $Logtextbox.Text += "Slides only Selected `n"
	        foreach ($item in $Autcheckedlistbox.CheckedItems)
	        {
	            $Logtextbox.Text += "Selected item: $Item `n"
	            $Sessions = $script:Slides | where { $_.Creator -match "$item" }
	            [System.Windows.Forms.Application]::DoEvents()
	            
	            foreach ($Session in $Sessions)
	            {
	                [System.Windows.Forms.Application]::DoEvents()
	                $Logtextbox.Text += "$($Session.Title) `n"
	                $url = $Session | select -ExpandProperty Enclosure | Select -ExpandProperty URL
	                $SesionTitle = "$(Remove-InvalidFileNameChars $($Session.Creator)) - $(Remove-InvalidFileNameChars $($Session.Title)).pptx"
	                New-FileDownload -SourceFile $url -DestFolder $textbox1.Text -DestFile $SesionTitle
	                
	            }
	        }
	    }
	    
	    if ($radiobuttonVideoSlides.Checked)
	    {
	        $Logtextbox.Text += "Vidoes & Slides  Selected `n"
	        foreach ($item in $Autcheckedlistbox.CheckedItems)
	        {
	            $Logtextbox.Text += "Selected item: $Item `n"
	            
	            $Sessions = $script:Slides | where { $_.Creator -match "$item" }
	            
	            foreach ($Session in $Sessions)
	            {
	                $Logtextbox.Text += "$($Session.Title) `n"
	                $url = $Session | select -ExpandProperty Enclosure | Select -ExpandProperty URL
	                $SesionTitle = "$(Remove-InvalidFileNameChars $($Session.Creator)) - $(Remove-InvalidFileNameChars $($Session.Title)).pptx"
	                New-FileDownload -SourceFile $url -DestFolder $textbox1.Text -DestFile $SesionTitle
	                
	            }
	            $Logtextbox.Text += "Selected item: $Item (Author) `n"
	            $Sessions = $script:Videos | where { $_.Creator -match "$item" }
	            
	            foreach ($Session in $Sessions)
	            {
	                $Logtextbox.Text += "$($Session.Title) (Author) `n"
	                $url = $Session | select -ExpandProperty Enclosure | Select -ExpandProperty URL
	                $SesionTitle = "$(Remove-InvalidFileNameChars $($Session.Creator)) - $(Remove-InvalidFileNameChars $($Session.Title)).mp4"
	                New-FileDownload -SourceFile $url -DestFolder $textbox1.Text -DestFile $SesionTitle
	                
	            }
	        }
	        
	    }
	    Enable-FormItems
	    $progressbaroverlay1.Visible = $false
	}
	
	$CatFilterTextbox_TextChanged = {
	    #TODO: Place custom script here
	    $Catcheckedlistbox.BeginUpdate()
	    $Catcheckedlistbox.Items.Clear()
	    
	    if (-not ([string]::IsNullOrEmpty($CatFilterTextbox.Text)))
	    {
	        foreach ($Cat in $Script:Categories)
	        {
	            
	            If ($Cat -match $CatFilterTextbox.Text)
	            {
	                $Catcheckedlistbox.Items.Add("$Cat")
	            }
	        }
	    }
	    Else
	    {
	        Load-ListBox $Catcheckedlistbox -Items $Script:Categories
	    }
	    $Catcheckedlistbox.EndUpdate()
	}
	
	$AutFiltertextbox_TextChanged = {
	    #TODO: Place custom script here
	    #TODO: Place custom script here
	    $Autcheckedlistbox.BeginUpdate()
	    $Autcheckedlistbox.Items.Clear()
	    
	    
	    if (-not ([string]::IsNullOrEmpty($AutFilterTextbox.Text)))
	    {
	        foreach ($Aut in $Script:Speakers)
	        {
	            
	            If ($Aut -match $AutFilterTextbox.Text)
	            {
	                $Autcheckedlistbox.Items.Add("$Aut")
	            }
	        }
	    }
	    Else
	    {
	        Load-ListBox $Autcheckedlistbox -Items $Script:Speakers
	    }
	    $Autcheckedlistbox.EndUpdate()
	}
	
	$tabcontrol1_Selected = [System.Windows.Forms.TabControlEventHandler]{
	    #Event Argument: $_ = [System.Windows.Forms.TabControlEventArgs]
	    #TODO: Place custom script here
	    
	}
	
	
	
	
	
	$tabcontrol1_SelectedIndexChanged={
		#TODO: Place custom script here
	    Switch -regex (($tabcontrol1.SelectedTab).ToString())
	    {
	        "speaker" { $AutFiltertextbox.Focus() }
	        "category" { $CatFilterTextbox.Focus() }
	    }
	}
	
	# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$formGetChannel9VidoesSli.WindowState = $InitialFormWindowState
	}
	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$combobox1.remove_SelectedIndexChanged($combobox1_SelectedIndexChanged)
			$CatFilterTextbox.remove_TextChanged($CatFilterTextbox_TextChanged)
			$buttonSelectNone.remove_Click($buttonSelectNone_Click)
			$buttonSelectAll.remove_Click($buttonSelectAll_Click)
			$buttonDownload.remove_Click($buttonDownload_Click)
			$AutFiltertextbox.remove_TextChanged($AutFiltertextbox_TextChanged)
			$AutNoneButton.remove_Click($AutNoneButton_Click)
			$AutAllButton.remove_Click($AutAllButton_Click)
			$AutDownloadButton.remove_Click($AutDownloadButton_Click)
			$tabcontrol1.remove_SelectedIndexChanged($tabcontrol1_SelectedIndexChanged)
			$radiobuttonVideoSlides.remove_CheckedChanged($radiobuttonVideoSlides_CheckedChanged)
			$groupbox1.remove_Enter($groupbox1_Enter)
			$buttonLoadCategories.remove_Click($buttonLoadCategories_Click)
			$buttonBrowse.remove_Click($buttonBrowse_Click)
			$formGetChannel9VidoesSli.remove_Load($formGetChannel9VidoesSli_Load)
			$folderbrowserdialog1.remove_HelpRequest($folderbrowserdialog1_HelpRequest)
			$timer1.remove_Tick($timer1_Tick)
			$formGetChannel9VidoesSli.remove_Load($Form_StateCorrection_Load)
			$formGetChannel9VidoesSli.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch [Exception]
		{ }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	$formGetChannel9VidoesSli.SuspendLayout()
	$tabcontrol1.SuspendLayout()
	$Main.SuspendLayout()
	$ByAuthor.SuspendLayout()
	$Log.SuspendLayout()
	$Credits.SuspendLayout()
	$groupbox1.SuspendLayout()
	#
	# formGetChannel9VidoesSli
	#
	$formGetChannel9VidoesSli.Controls.Add($labelChooseEvent)
	$formGetChannel9VidoesSli.Controls.Add($combobox1)
	$formGetChannel9VidoesSli.Controls.Add($tabcontrol1)
	$formGetChannel9VidoesSli.Controls.Add($progressbaroverlay1)
	$formGetChannel9VidoesSli.Controls.Add($groupbox1)
	$formGetChannel9VidoesSli.Controls.Add($buttonLoadCategories)
	$formGetChannel9VidoesSli.Controls.Add($labelDownloadPath)
	$formGetChannel9VidoesSli.Controls.Add($buttonBrowse)
	$formGetChannel9VidoesSli.Controls.Add($textbox1)
	$formGetChannel9VidoesSli.ClientSize = '831, 610'
	$formGetChannel9VidoesSli.Name = "formGetChannel9VidoesSli"
	$formGetChannel9VidoesSli.Text = "Get Channel 9 Vidoes\Slides  1.8"
	$formGetChannel9VidoesSli.add_Load($formGetChannel9VidoesSli_Load)
	#
	# labelChooseEvent
	#
	$labelChooseEvent.Location = '16, 9'
	$labelChooseEvent.Name = "labelChooseEvent"
	$labelChooseEvent.Size = '100, 15'
	$labelChooseEvent.TabIndex = 16
	$labelChooseEvent.Text = "Choose Event"
	#
	# combobox1
	#
	$combobox1.DropDownStyle = 'DropDownList'
	$combobox1.FormattingEnabled = $True
	[void]$combobox1.Items.Add("http://s.ch9.ms/Events/Ignite/2015/RSS/mp4high")
	[void]$combobox1.Items.Add("http://s.ch9.ms/Events/Build/2015/RSS/mp4high")
	[void]$combobox1.Items.Add("http://s.ch9.ms/Events/TechEd/Europe/2014/RSS/mp4high")
	[void]$combobox1.Items.Add("http://s.ch9.ms/Events/TechEd/NorthAmerica/2014/RSS/mp4high")
	[void]$combobox1.Items.Add("http://s.ch9.ms/Events/Lync-Conference/Lync-Conference-2014/RSS/mp4high")
	[void]$combobox1.Items.Add("http://s.ch9.ms/Events/SharePoint-Conference/2014/RSS/mp4high")
	[void]$combobox1.Items.Add("http://s.ch9.ms/Events/Build/2014/RSS/mp4high")
	[void]$combobox1.Items.Add("http://s.ch9.ms/Events/TechEd/Europe/2013/RSS/mp4high")
	[void]$combobox1.Items.Add("http://s.ch9.ms/Events/TechEd/NorthAmerica/2013/RSS/mp4high")
	[void]$combobox1.Items.Add("http://s.ch9.ms/Events/TechEd/NewZealand/2013/RSS/mp4high")
	[void]$combobox1.Items.Add("http://s.ch9.ms/Events/Build/2013/RSS/mp4high")
	[void]$combobox1.Items.Add("http://s.ch9.ms/Events/TechEd/NorthAmerica/2012/RSS/mp4high")
	[void]$combobox1.Items.Add("http://s.ch9.ms/Events/Build/2012/RSS/mp4high")
	[void]$combobox1.Items.Add("http://s.ch9.ms/Events/TechEd/Europe/2012/RSS/mp4high")
	$combobox1.Location = '16, 27'
	$combobox1.Name = "combobox1"
	$combobox1.Size = '561, 21'
	$combobox1.TabIndex = 15
	$combobox1.add_SelectedIndexChanged($combobox1_SelectedIndexChanged)
	#
	# tabcontrol1
	#
	$tabcontrol1.Controls.Add($Main)
	$tabcontrol1.Controls.Add($ByAuthor)
	$tabcontrol1.Controls.Add($Log)
	$tabcontrol1.Controls.Add($Credits)
	$tabcontrol1.Location = '12, 56'
	$tabcontrol1.Name = "tabcontrol1"
	$tabcontrol1.SelectedIndex = 0
	$tabcontrol1.Size = '627, 438'
	$tabcontrol1.TabIndex = 14
	$tabcontrol1.add_SelectedIndexChanged($tabcontrol1_SelectedIndexChanged)
	#
	# Main
	#
	$Main.Controls.Add($FilterLabel)
	$Main.Controls.Add($CatFilterTextbox)
	$Main.Controls.Add($buttonSelectNone)
	$Main.Controls.Add($buttonSelectAll)
	$Main.Controls.Add($buttonDownload)
	$Main.Controls.Add($Catcheckedlistbox)
	$Main.Controls.Add($labelCategories)
	$Main.Location = '4, 22'
	$Main.Name = "Main"
	$Main.Padding = '3, 3, 3, 3'
	$Main.Size = '619, 412'
	$Main.TabIndex = 0
	$Main.Text = "By Category"
	$Main.UseVisualStyleBackColor = $True
	#
	# FilterLabel
	#
	$FilterLabel.Location = '251, 348'
	$FilterLabel.Name = "FilterLabel"
	$FilterLabel.Size = '100, 14'
	$FilterLabel.TabIndex = 17
	$FilterLabel.Text = "Filter"
	#
	# CatFilterTextbox
	#
	$CatFilterTextbox.Location = '21, 345'
	$CatFilterTextbox.Name = "CatFilterTextbox"
	$CatFilterTextbox.Size = '224, 20'
	$CatFilterTextbox.TabIndex = 16
	$CatFilterTextbox.add_TextChanged($CatFilterTextbox_TextChanged)
	#
	# buttonSelectNone
	#
	$buttonSelectNone.Location = '102, 383'
	$buttonSelectNone.Name = "buttonSelectNone"
	$buttonSelectNone.Size = '75, 23'
	$buttonSelectNone.TabIndex = 15
	$buttonSelectNone.Text = "Select None"
	$buttonSelectNone.UseVisualStyleBackColor = $True
	$buttonSelectNone.add_Click($buttonSelectNone_Click)
	#
	# buttonSelectAll
	#
	$buttonSelectAll.Location = '21, 383'
	$buttonSelectAll.Name = "buttonSelectAll"
	$buttonSelectAll.Size = '76, 23'
	$buttonSelectAll.TabIndex = 14
	$buttonSelectAll.Text = "Select All"
	$buttonSelectAll.UseVisualStyleBackColor = $True
	$buttonSelectAll.add_Click($buttonSelectAll_Click)
	#
	# buttonDownload
	#
	$buttonDownload.Location = '480, 383'
	$buttonDownload.Name = "buttonDownload"
	$buttonDownload.Size = '133, 23'
	$buttonDownload.TabIndex = 7
	$buttonDownload.Text = "Download"
	$buttonDownload.UseVisualStyleBackColor = $True
	$buttonDownload.add_Click($buttonDownload_Click)
	#
	# Catcheckedlistbox
	#
	$Catcheckedlistbox.CheckOnClick = $True
	$Catcheckedlistbox.FormattingEnabled = $True
	$Catcheckedlistbox.HorizontalScrollbar = $True
	$Catcheckedlistbox.Location = '21, 33'
	$Catcheckedlistbox.Name = "Catcheckedlistbox"
	$Catcheckedlistbox.ScrollAlwaysVisible = $True
	$Catcheckedlistbox.Size = '561, 304'
	$Catcheckedlistbox.TabIndex = 0
	#
	# labelCategories
	#
	$labelCategories.Location = '21, 15'
	$labelCategories.Name = "labelCategories"
	$labelCategories.Size = '100, 22'
	$labelCategories.TabIndex = 1
	$labelCategories.Text = "Categories"
	#
	# ByAuthor
	#
	$ByAuthor.Controls.Add($labelFilter)
	$ByAuthor.Controls.Add($AutFiltertextbox)
	$ByAuthor.Controls.Add($AutNoneButton)
	$ByAuthor.Controls.Add($Autcheckedlistbox)
	$ByAuthor.Controls.Add($AutAllButton)
	$ByAuthor.Controls.Add($AutDownloadButton)
	$ByAuthor.Controls.Add($labelSpeakers)
	$ByAuthor.Location = '4, 22'
	$ByAuthor.Name = "ByAuthor"
	$ByAuthor.Padding = '3, 3, 3, 3'
	$ByAuthor.Size = '619, 412'
	$ByAuthor.TabIndex = 3
	$ByAuthor.Text = "By Speaker"
	$ByAuthor.UseVisualStyleBackColor = $True
	#
	# labelFilter
	#
	$labelFilter.Location = '252, 361'
	$labelFilter.Name = "labelFilter"
	$labelFilter.Size = '100, 14'
	$labelFilter.TabIndex = 22
	$labelFilter.Text = "Filter"
	#
	# AutFiltertextbox
	#
	$AutFiltertextbox.Location = '22, 358'
	$AutFiltertextbox.Name = "AutFiltertextbox"
	$AutFiltertextbox.Size = '224, 20'
	$AutFiltertextbox.TabIndex = 21
	$AutFiltertextbox.add_TextChanged($AutFiltertextbox_TextChanged)
	#
	# AutNoneButton
	#
	$AutNoneButton.Location = '103, 384'
	$AutNoneButton.Name = "AutNoneButton"
	$AutNoneButton.Size = '75, 23'
	$AutNoneButton.TabIndex = 20
	$AutNoneButton.Text = "Select None"
	$AutNoneButton.UseVisualStyleBackColor = $True
	$AutNoneButton.add_Click($AutNoneButton_Click)
	#
	# Autcheckedlistbox
	#
	$Autcheckedlistbox.CheckOnClick = $True
	$Autcheckedlistbox.FormattingEnabled = $True
	$Autcheckedlistbox.HorizontalScrollbar = $True
	$Autcheckedlistbox.Location = '19, 32'
	$Autcheckedlistbox.Name = "Autcheckedlistbox"
	$Autcheckedlistbox.ScrollAlwaysVisible = $True
	$Autcheckedlistbox.Size = '578, 319'
	$Autcheckedlistbox.TabIndex = 2
	#
	# AutAllButton
	#
	$AutAllButton.Location = '22, 384'
	$AutAllButton.Name = "AutAllButton"
	$AutAllButton.Size = '75, 23'
	$AutAllButton.TabIndex = 19
	$AutAllButton.Text = "Select All"
	$AutAllButton.UseVisualStyleBackColor = $True
	$AutAllButton.add_Click($AutAllButton_Click)
	#
	# AutDownloadButton
	#
	$AutDownloadButton.Location = '464, 384'
	$AutDownloadButton.Name = "AutDownloadButton"
	$AutDownloadButton.Size = '133, 23'
	$AutDownloadButton.TabIndex = 18
	$AutDownloadButton.Text = "Download"
	$AutDownloadButton.UseVisualStyleBackColor = $True
	$AutDownloadButton.add_Click($AutDownloadButton_Click)
	#
	# labelSpeakers
	#
	$labelSpeakers.Location = '19, 10'
	$labelSpeakers.Name = "labelSpeakers"
	$labelSpeakers.Size = '100, 22'
	$labelSpeakers.TabIndex = 3
	$labelSpeakers.Text = "Speakers"
	#
	# Log
	#
	$Log.Controls.Add($Logtextbox)
	$Log.Location = '4, 22'
	$Log.Name = "Log"
	$Log.Padding = '3, 3, 3, 3'
	$Log.Size = '619, 412'
	$Log.TabIndex = 1
	$Log.Text = "Log"
	$Log.UseVisualStyleBackColor = $True
	#
	# Logtextbox
	#
	$Logtextbox.Location = '18, 20'
	$Logtextbox.Name = "Logtextbox"
	$Logtextbox.Size = '793, 435'
	$Logtextbox.TabIndex = 0
	$Logtextbox.Text = ""
	#
	# Credits
	#
	$Credits.Controls.Add($richtextbox1)
	$Credits.Location = '4, 22'
	$Credits.Name = "Credits"
	$Credits.Padding = '3, 3, 3, 3'
	$Credits.Size = '619, 412'
	$Credits.TabIndex = 2
	$Credits.Text = "Credits"
	$Credits.UseVisualStyleBackColor = $True
	#
	# richtextbox1
	#
	$richtextbox1.BackColor = 'Menu'
	$richtextbox1.Location = '19, 20'
	$richtextbox1.Name = "richtextbox1"
	$richtextbox1.Size = '793, 434'
	$richtextbox1.TabIndex = 0
	$richtextbox1.Text = "

Script: Download Videos and Slides from Channel 9

Version: 1.9 - May 4th, 2015
Modified to include Ignite 2015 and Build 2015 sessions by Michel de Rooij (eightwone.com)
Original author: Claus T N (PS MVP, blog: www.xipher.dk)

Based on code from Peter Schmidt (Exchange MVP, blog: www.msdigest.net)

Originally published as a SharePoint Conf script by: Vlad Catrinescu (http://absolute-sharepoint.com/2014/03/ultimate-script-download-sharepoint-conference-2014-videos-slides.html)
 

Modified for Teched 2013 NA by Tom Arbuthnot lyncdup.com
    
Original provided by blog.SCOMfaq.ch / Stefan Roth
    
Credit http://blog.scomfaq.ch/2012/06/13/teched-2012-orlando-download-sessions-offline-viewing/
    
Credit: Pat Richard for New-Download Function http://www.ehloworld.com

"
	#
	# progressbaroverlay1
	#
	$progressbaroverlay1.Location = '16, 572'
	$progressbaroverlay1.MarqueeAnimationSpeed = 500
	$progressbaroverlay1.Maximum = 10
	$progressbaroverlay1.Name = "progressbaroverlay1"
	$progressbaroverlay1.Size = '623, 23'
	$progressbaroverlay1.Style = 'Continuous'
	$progressbaroverlay1.TabIndex = 13
	$progressbaroverlay1.Visible = $False
	#
	# groupbox1
	#
	$groupbox1.Controls.Add($radiobuttonVideoesOnly)
	$groupbox1.Controls.Add($radiobuttonVideoSlides)
	$groupbox1.Controls.Add($radiobuttonSlidesOnly)
	$groupbox1.Location = '663, 111'
	$groupbox1.Name = "groupbox1"
	$groupbox1.Size = '139, 141'
	$groupbox1.TabIndex = 6
	$groupbox1.TabStop = $False
	$groupbox1.Text = "Select Download Type"
	$groupbox1.add_Enter($groupbox1_Enter)
	#
	# radiobuttonVideoesOnly
	#
	$radiobuttonVideoesOnly.Location = '22, 37'
	$radiobuttonVideoesOnly.Name = "radiobuttonVideoesOnly"
	$radiobuttonVideoesOnly.Size = '104, 24'
	$radiobuttonVideoesOnly.TabIndex = 3
	$radiobuttonVideoesOnly.TabStop = $True
	$radiobuttonVideoesOnly.Text = "Videoes Only"
	$radiobuttonVideoesOnly.UseVisualStyleBackColor = $True
	#
	# radiobuttonVideoSlides
	#
	$radiobuttonVideoSlides.Location = '22, 97'
	$radiobuttonVideoSlides.Name = "radiobuttonVideoSlides"
	$radiobuttonVideoSlides.Size = '104, 24'
	$radiobuttonVideoSlides.TabIndex = 5
	$radiobuttonVideoSlides.TabStop = $True
	$radiobuttonVideoSlides.Text = "Video && Slides"
	$radiobuttonVideoSlides.UseVisualStyleBackColor = $True
	$radiobuttonVideoSlides.add_CheckedChanged($radiobuttonVideoSlides_CheckedChanged)
	#
	# radiobuttonSlidesOnly
	#
	$radiobuttonSlidesOnly.Location = '22, 67'
	$radiobuttonSlidesOnly.Name = "radiobuttonSlidesOnly"
	$radiobuttonSlidesOnly.Size = '104, 24'
	$radiobuttonSlidesOnly.TabIndex = 4
	$radiobuttonSlidesOnly.TabStop = $True
	$radiobuttonSlidesOnly.Text = "Slides Only"
	$radiobuttonSlidesOnly.UseVisualStyleBackColor = $True
	#
	# buttonLoadCategories
	#
	$buttonLoadCategories.Location = '663, 29'
	$buttonLoadCategories.Name = "buttonLoadCategories"
	$buttonLoadCategories.Size = '112, 23'
	$buttonLoadCategories.TabIndex = 2
	$buttonLoadCategories.Text = "Load Categories"
	$buttonLoadCategories.UseVisualStyleBackColor = $True
	$buttonLoadCategories.Visible = $False
	$buttonLoadCategories.add_Click($buttonLoadCategories_Click)
	#
	# labelDownloadPath
	#
	$labelDownloadPath.Location = '16, 510'
	$labelDownloadPath.Name = "labelDownloadPath"
	$labelDownloadPath.Size = '190, 23'
	$labelDownloadPath.TabIndex = 10
	$labelDownloadPath.Text = "Download Path"
	#
	# buttonBrowse
	#
	$buttonBrowse.Location = '433, 534'
	$buttonBrowse.Name = "buttonBrowse"
	$buttonBrowse.Size = '120, 23'
	$buttonBrowse.TabIndex = 9
	$buttonBrowse.Text = "Browse"
	$buttonBrowse.UseVisualStyleBackColor = $True
	$buttonBrowse.add_Click($buttonBrowse_Click)
	#
	# textbox1
	#
	$textbox1.Location = '16, 536'
	$textbox1.Name = "textbox1"
	$textbox1.Size = '388, 20'
	$textbox1.TabIndex = 8
	$textbox1.Text = "c:\CH9Download"
	#
	# folderbrowserdialog1
	#
	$folderbrowserdialog1.add_HelpRequest($folderbrowserdialog1_HelpRequest)
	#
	# timer1
	#
	$timer1.add_Tick($timer1_Tick)
	$groupbox1.ResumeLayout()
	$Credits.ResumeLayout()
	$Log.ResumeLayout()
	$ByAuthor.ResumeLayout()
	$Main.ResumeLayout()
	$tabcontrol1.ResumeLayout()
	$formGetChannel9VidoesSli.ResumeLayout()
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $formGetChannel9VidoesSli.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$formGetChannel9VidoesSli.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$formGetChannel9VidoesSli.add_FormClosed($Form_Cleanup_FormClosed)
	#Show the Form
	return $formGetChannel9VidoesSli.ShowDialog()

} #End Function

#Call OnApplicationLoad to initialize
if((OnApplicationLoad) -eq $true)
{
	#Call the form
	Call-TechEd1_7_psf | Out-Null
	#Perform cleanup
	OnApplicationExit
}
