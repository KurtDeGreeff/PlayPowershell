function Load-Form {
    $Form.Controls.AddRange(@($MainTabControl, $ButtonStart, $ButtonValidate, $SBStatus, $OutputBox, $GBOutputBox))
    $MainTabControl.Controls.AddRange(@($TabPageSetup, $TabPageMDT, $TabPageWSUS, $TabPageApplications, $TabPageOS))
	$TabPageSetup.Controls.AddRange(@($CMBGeneralOptionModeOS, $CMBGeneralOptionMode, $LabelGeneralOption, $LabelGeneralSF, $TBSFMDT, $TBSFADK, $ButtonSFMDTBrowse, $ButtonSFADKBrowse, $GBGeneralOptionMode, $GBGeneralOptionOS, $GBSFMDT, $GBSFADK, $GBGeneralSF, $GBGeneralOption))
    $TabPageMDT.Controls.AddRange(@($LabelMDTUP, $LabelMDTDSPath, $LabelMDTDSName, $LabelMDTBIFeatures, $LabelMDTBIScratchSpace, $TBMDTDSPath, $TBMDTDSName, $TBMDTUserName, $TBMDTPassword, $CMBMDTScratchSpace, $CBMDTFeatures, $GBMDTDSPath, $GBMDTDSName, $GBMDTDS, $GBMDTBIFeatures, $GBMDTBIScratchSpace, $GBMDTBI, $GBMDTUP))
    $TabPageWSUS.Controls.AddRange(@($CBWSUSCriticalUpdates, $CBWSUSSecurityUpdates, $CBWSUSUpdates, $CBWSUSDefinitionUpdates, $TBWSUSContentFolder, $LabelWSUSProducts, $LabelWSUSLanguages, $LabelWSUSContentFolder, $LabelWSUSUpdateClassification, $ButtonWSUSProducts, $ButtonWSUSLanguages, $CMBWSUSLanguageSelection, $CMBWSUSProductSelection, $DGVWSUSProducts, $DGVWSUSLanguages, $GBWSUSProducts, $GBWSUSLanguages, $GBWSUSContentFolder, $GBWSUSUpdateClassification))
    $TabPageApplications.Controls.AddRange(@($ButtonAppBrowse, $LabelApp, $TBAppPath, $DGVApp, $GBApp))
    $TabPageOS.Controls.AddRange(@($ButtonOSBrowse, $LabelOS, $TBOSPath, $DGVOS, $GBOS))
    $Form.Add_Shown({Validate-Startup})
    $Form.Add_Shown({$Form.Activate()})
    $Form.Add_Shown({Set-GlobalVariables})
	[void]$Form.ShowDialog()
}

function Load-FormOSSelection {
    $FormOS.Controls.AddRange(@($DGVOSSelection, $ButtonSelect, $TBOSSelection))
    $FormOS.Add_Shown({$FormOS.Activate()})
    $FormOS.ShowDialog()
}

function Set-GlobalVariables {
    $Global:MDTServer = $env:COMPUTERNAME
    $Global:MDTDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() | Select-Object -ExpandProperty Name
    $Global:MDTUserName = $TBMDTUserName.Text
    $Global:MDTPassword = $TBMDTPassword.Text
    $Global:MDTDSName = $TBMDTDSName.Text
    $Global:MDTDSPath = $TBMDTDSPath.Text
    $Global:WSUSContentFolder = $TBWSUSContentFolder.Text
    $Global:OSPathObjects = $null
    $Global:OSSelectedObject = $null
    $Global:ApplicationPathObjects = $null
    $Global:GeneralModeOS = New-Object System.Collections.ArrayList
}

function Get-OSObjects {
    param(
    [parameter(Mandatory=$true)]
    $Path
    )
    $DGVOSSelection.Rows.Add($Path)
}

function Get-SetupFilePath {
    param(
    [parameter(Mandatory=$true)]
    [ValidateSet("MDT","ADK")]
    $Option,
    [parameter(Mandatory=$true)]
    [ValidateSet("EXE","MSI")]
    $Extension
    )
    if ($Option -like "MDT") {
        if ($Extension -like "MSI") {
            $OpenFileDialogMSI.ShowDialog() | Out-Null
            if ($OpenFileDialogMSI.FileName.Length -ge 1) {
                $TBSFMDT.Text = $OpenFileDialogMSI.FileName
            }
        }
    }
    if ($Option -like "ADK") {
        if ($Extension -like "EXE") {
            $OpenFileDialogEXE.ShowDialog() | Out-Null
            if ($OpenFileDialogEXE.FileName.Length -ge 1) {
                $TBSFADK.Text = $OpenFileDialogEXE.FileName
            }
        }
    }
}

function Get-CSVFile {
    param(
    [parameter(Mandatory=$true)]
    [ValidateSet("App","OS")]
    $Option,
    [parameter(Mandatory=$true)]
    $Object
    )
    Begin {
        if ($Object.RowCount -ge 1) {
            $Object.Rows.Clear()
            $GeneralModeOS.Clear()
            $CMBGeneralOptionModeOS.Items.Clear()
        }
    }
    Process {
        if ($Option -like "App") {
            $OpenFileDialogCSV.ShowDialog() | Out-Null
            if ($OpenFileDialogCSV.FileName.Length -ge 1) {
                $TBAppPath.Text = $OpenFileDialogCSV.FileName
                $Global:ApplicationPathObjects = Import-Csv -Path $OpenFileDialogCSV.FileName
                $AppObjects = Import-Csv -Path $OpenFileDialogCSV.FileName
                foreach ($AppObject in $AppObjects) {
                    if (Validate-AppPath -AppName $AppObject.Name -AppPath $AppObject.SourcePath) {
                        $DGVApp.Rows.Add($AppObject.Name, $AppObject.CmdLine, $AppObject.ShortName, $AppObject.SourcePath)
                    }
                }
            }
        }
        if ($Option -like "OS") {
            $OpenFileDialogCSV.ShowDialog() | Out-Null
            if ($OpenFileDialogCSV.FileName.Length -ge 1) {
                $TBOSPath.Text = $OpenFileDialogCSV.FileName
                $Global:OSPathObjects = Import-Csv -Path $OpenFileDialogCSV.FileName
                $OSObjects = Import-Csv -Path $OpenFileDialogCSV.FileName
                foreach ($OSObject in $OSObjects) {
                    if (Validate-OSPath -OSName $OSObject.Name -OSPath $OSObject.SourcePath) {
                        $DGVOS.Rows.Add($OSObject.Name, $OSObject.ID, $OSObject.SourcePath, $OSObject.FullName, $OSObject.OrgName, $OSObject.HomePage, $OSObject.AdminPassword)
                    }
                }
                for ($OSCount = 0; $OSCount -lt $DGVOS.RowCount; $OSCount++) {
                    $CurrentOSName = $DGVOS.Rows[$OSCount].Cells["Name"].Value
                    $GeneralModeOS.Add($CurrentOSName)
                }
                if (($CMBGeneralOptionMode.SelectedItem -like "Automatic") -and ($DGVOS.RowCount -ge 1)) {
                    foreach ($OS in $GeneralModeOS) {
                        $CMBGeneralOptionModeOS.Items.Add($OS)
                    }
                    $CMBGeneralOptionModeOS.SelectedIndex = 0
                }
            }
        }
    }
}

function Get-DGVRowData {
    param(
    [parameter(Mandatory=$true)]
    [ValidateSet("Product","Language")]
    $Type,
    [parameter(Mandatory=$true)]
    $Object,
    [parameter(Mandatory=$true)]
    $Data
    )
    for ($RowCount = 0; $RowCount -lt $Object.RowCount; $RowCount++) {
        if ($Object.Rows[$RowCount].Cells["$($Type)"].Value -eq $Data) {
            return $true
        }
    }    
}

function Add-WSUSProduct {
    param(
    [parameter(Mandatory=$false)]
    $Product,
    [parameter(Mandatory=$true)]
    [ValidateSet("Add")]
    $Method
    )
    if ($Method -eq "Add") {
        $WSUSProducts.GetEnumerator() | ForEach-Object {
            if ($_.Value -like $Product) {
                if ($DGVWSUSProducts.RowCount -ge 1) {
                    if (Get-DGVRowData -Data $Product -Object $DGVWSUSProducts -Type Product) {
                        Write-OutputBox -OutputBoxMessage "'$($Product)' is already added" -Type INFO
                    }
                    if (-not(Get-DGVRowData -Data $Product -Object $DGVWSUSProducts -Type Product)) {
                        $DGVWSUSProducts.Rows.Add($_.Value, $_.Key)
                    }
                }
                if ($DGVWSUSProducts.RowCount -eq 0) {
                    $DGVWSUSProducts.Rows.Add($_.Value, $_.Key)
                }
            }
        }
    }
}

function Get-WSUSProduct {
    param(
    [parameter(Mandatory=$true)]
    $ID
    )
    $WSUSProducts.GetEnumerator() | ForEach-Object {
        if ($_.Key -like "$($ID)") {
            return $_.Value
        }
    }
}

function Add-WSUSLanguage {
    param(
    [parameter(Mandatory=$false)]
    $Language,
    [parameter(Mandatory=$true)]
    [ValidateSet("Add")]
    $Method
    )
    if ($Method -eq "Add") {
        $WSUSLanguages.GetEnumerator() | ForEach-Object {
            if ($_.Value -like $Language) {
                if ($DGVWSUSLanguages.RowCount -ge 1) {
                    if (Get-DGVRowData -Data $Language -Object $DGVWSUSLanguages -Type Language) {
                        Write-OutputBox -OutputBoxMessage "'$($Language)' is already added" -Type INFO
                    }
                    if (-not(Get-DGVRowData -Data $Language -Object $DGVWSUSLanguages -Type Language)) {
                        $DGVWSUSLanguages.Rows.Add($_.Value, $_.Key)
                    }
                }
                if ($DGVWSUSLanguages.RowCount -eq 0) {
                    $DGVWSUSLanguages.Rows.Add($_.Value, $_.Key)
                }
            }
        }
    }
}

function Get-WSUSUpdateClassificationID {
    param(
    [parameter(Mandatory=$true)]
    [string]$Classification
    )
    $WSUSUpdateClassifications = @{
        "Critical Updates" = "e6cf1350-c01b-414d-a61f-263d14d133b4"
        "Security Updates" = "0fa1201d-4330-4fa8-8ae9-b877473b6441"
        "Updates" = "cd5ffd1e-e932-4e3a-bf74-18bf0b1bbd83"
        "Definition Updates" = "e0789628-ce08-4437-be74-2495b842f43b"
    }
    $WSUSUpdateClassifications.GetEnumerator() | ForEach-Object {
        if ($Classification -like "$($_.Key)") {
            return $_.Value
        }
    }
}

function Write-OutputBox {
	param(
	[parameter(Mandatory=$true)]
	[string]$OutputBoxMessage,
	[ValidateSet("WARNING","ERROR","INFO","FAILED", "PASSED")]
	[string]$Type
	)
	Process {
		if ($OutputBox.Text.Length -eq 0) {
			$OutputBox.Text = "$($Type): $($OutputBoxMessage)"
            $OutputBox.ScrollToCaret()
            [System.Windows.Forms.Application]::DoEvents()
            
		}
		else {
			$OutputBox.AppendText("`n$($Type): $($OutputBoxMessage)")
            $OutputBox.ScrollToCaret()
            [System.Windows.Forms.Application]::DoEvents()
		}
	}
}

function Interactive-TabPages {
    param(
    [parameter(Mandatory=$true)]
    [ValidateSet("Enable","Disable")]
    $Option,
    [parameter(Mandatory=$false)]
    [switch]$IncludeButtons
    )
    if ($Option -like "Enable") {
        foreach ($TabPage in $MainTabControl.TabPages) {
            $TabPage.Enabled = $true
        }
    }
    if ($Option -like "Disable") {
        foreach ($TabPage in $MainTabControl.TabPages) {
            $TabPage.Enabled = $false
        }
    }
    if ($IncludeButtons) {
        switch ($Option) {
            "Disable" { $ButtonStart.Enabled = $false; $ButtonValidate.Enabled = $false }
            "Enable" { $ButtonStart.Enabled = $true; $ButtonValidate.Enabled = $true }
        }
    }
}

function Validate-Startup {
    if (-not(Validate-Elevated)) {
        Write-OutputBox -OutputBoxMessage "Elevation check failed, make sure that you've elevated the PowerShell console and that the user account is a member of the local Administrators group" -Type ERROR
        Interactive-TabPages -Option Disable -IncludeButtons
    }
    if (-not(Validate-RebootPendingCheck)) {
        Write-OutputBox -OutputBoxMessage "A reboot is pending, please restart the system" -Type ERROR
        Interactive-TabPages -Option Disable -IncludeButtons
    }
}

function Validate-Elevated {
    $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent() 
    $WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($CurrentUser)
    if (-not($WindowsPrincipal.IsInRole("S-1-5-32-544"))) {
        return $false
    }
    elseif ($WindowsPrincipal.IsInRole("S-1-5-32-544")) {
        return $true
    }
    else {
        return $false
    }
}

function Validate-TextboxLength {
    param(
    [parameter(Mandatory=$true)]
    $Object,
    [parameter(Mandatory=$true)]
    $Text
    )
    if ($Object.Text.Length -gt 255) {
        Write-OutputBox -OutputBoxMessage "$($Text)" -Type WARNING
    }
}

function Validate-Apps {
    if (($Global:ApplicationPathObjects | Measure-Object).Count -eq 0) {
        return $false
    }
    if (($Global:ApplicationPathObjects | Measure-Object).Count -ge 1) {
        return $true
    }    
}

function Validate-OS {
    if (($Global:OSPathObjects | Measure-Object).Count -ge 1) {
        return $true
    }
    else {
        return $false
    }
}

function Validate-MDTPassword {
    if (($TBMDTPassword.Text -match ([RegEx]"[A-Z]")) -and ($TBMDTPassword.Text -match ([RegEx]"[a-z]")) -and ($TBMDTPassword.Text -match ([RegEx]"[0-9]")) -and ($TBMDTPassword.Text -match ([RegEx]"[^A-Za-z0-9]"))) {
        return $true
    }
    else {
        return $false
    }
}

function Validate-MDTUserName {
    if ($TBMDTUserName.Text -match "^(?=.{4,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$") {
        return $true
    }
    else {
        return $false
    }
}

function Validate-OSPath {
    param(
    [parameter(Mandatory=$true)]
    $OSName,
    [parameter(Mandatory=$true)]
    $OSPath
    )
    if (-not(Test-Path -Path $OSPath -ErrorAction SilentlyContinue)) {
        Write-OutputBox -OutputBoxMessage "SourcePath not found for '$($OSName), skipping import'" -Type WARNING
        return $false
    }
    else {
        return $true
    }
}

function Validate-AppPath {
    param(
    [parameter(Mandatory=$true)]
    $AppName,
    [parameter(Mandatory=$true)]
    $AppPath
    )
    if (-not(Test-Path -Path $AppPath -ErrorAction SilentlyContinue)) {
        Write-OutputBox -OutputBoxMessage "SourcePath not found for '$($AppName), skipping import'" -Type WARNING
        return $false
    }
    else {
        return $true
    }
}

function Validate-RebootPending {
	param(
	[parameter(Mandatory=$true)]
	$ComputerName
	)
	$RebootPendingCBS = $null
	$RebootPendingWUAU = $null
	$GetOS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $ComputerName
	$ConnectRegistry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"LocalMachine",$ComputerName)   
	if ($GetOS.BuildNumber -ge 6001) {
		$RegistryCBS = $ConnectRegistry.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\").GetSubKeyNames() 
		$RebootPendingCBS = $RegistryCBS -contains "RebootPending"
	}
	$RegistryWUAU = $ConnectRegistry.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\").GetSubKeyNames()
	$RebootPendingWUAU = $RegistryWUAU -contains "RebootRequired" 
	$RegistryPFRO = $ConnectRegistry.OpenSubKey("SYSTEM\CurrentControlSet\Control\Session Manager\") 
	$RegistryValuePFRO = $RegistryPFRO.GetValue("PendingFileRenameOperations",$null) 
	if ($RegistryValuePFRO) {
		$RebootPendingPFRO = $true
	}
	if (($RebootPendingCBS) -or ($RebootPendingWUAU) -or ($RebootPendingPFRO)) {
		return $true
	}
	else {
		return $false
	}	
}

function Validate-RebootPendingCheck {
	$GetComputerName = $env:COMPUTERNAME
	$ValidateRebootPending = Validate-RebootPending -ComputerName $GetComputerName
	if ($ValidateRebootPending) {
        return $false
	}
	else {
        return $true
	}
}

function Validate-Installation {
    $OutputBox.Clear()
    $ValidationFailed = 0
    Write-OutputBox -OutputBoxMessage "Running validation checks before installation:" -Type INFO
    if ($TBSFMDT.Text.Length -ge 1) {
        Write-OutputBox -OutputBoxMessage "Validate path for MDT setup file" -Type PASSED
    }
    else {
        Write-OutputBox -OutputBoxMessage "A setup file for Microsoft Deployment Toolkit have not been specified" -Type FAILED
        $ValidationFailed++
    }
    if ($TBSFADK.Text.Length -ge 1) {
        Write-OutputBox -OutputBoxMessage "Validate path for Windows ADK setup file" -Type PASSED
    }
    else {
        Write-OutputBox -OutputBoxMessage "A setup file for Windows Assessment Deployment Kit have not been specified" -Type FAILED
        $ValidationFailed++
    }
    if ($TBMDTDSPath.Text.Length -gt 4) {
        if ($TBMDTDSPath.Text.SubString(0,3) -match '^[A-Z]:\\$') {
            if (-not(Test-Path -Path $TBMDTDSPath.Text)) {
                Write-OutputBox -OutputBoxMessage "Validate path for Deployment Share path" -Type PASSED
            }
            else {
                Write-OutputBox -OutputBoxMessage "Invalid Deployment Share path, folder exists" -Type FAILED
                $ValidationFailed++
            }
        }
        else {
            Write-OutputBox -OutputBoxMessage "Invalid Deployment Share path drive letter characters" -Type FAILED
            $ValidationFailed++
        }
    }
    else {
        Write-OutputBox -OutputBoxMessage "Invalid Deployment Share path" -Type FAILED
        $ValidationFailed++
    }
    if ($TBMDTDSName.Text.Length -ge 3) {
        Write-OutputBox -OutputBoxMessage "Validate Deployment Share name" -Type PASSED
    }
    else {
        Write-OutputBox -OutputBoxMessage "Invalid Deployment Share name" -Type FAILED
        $ValidationFailed++
    }
    if ($TBMDTUserName.Text.Length -ge 1) {
        if (Validate-MDTUserName) {
            Write-OutputBox -OutputBoxMessage "Validate MDT user account name" -Type PASSED
        }
        else {
            Write-OutputBox -OutputBoxMessage "Invalid MDT user account name characters" -Type FAILED
            $ValidationFailed++
        }
    }
    else {
        Write-OutputBox -OutputBoxMessage "Invalid MDT user account name length" -Type FAILED
        $ValidationFailed++
    }
    if (Validate-MDTPassword) {
        Write-OutputBox -OutputBoxMessage "Validate MDT user account password complexity" -Type PASSED
    }
    else {
        Write-OutputBox -OutputBoxMessage "Password for MDT user account does not meet the complexity requirements" -Type FAILED
        $ValidationFailed++
    }
    if ($DGVWSUSProducts.RowCount -ge 1) {
        Write-OutputBox -OutputBoxMessage "Validate WSUS Products selections" -Type PASSED
    }
    else {
        Write-OutputBox -OutputBoxMessage "WSUS Products have not been specified" -Type FAILED
    }
    if ($DGVWSUSLanguages.RowCount -ge 1) {
        Write-OutputBox -OutputBoxMessage "Validate WSUS Language selections" -Type PASSED
    }
    else {
        Write-OutputBox -OutputBoxMessage "WSUS Languages have not been specified" -Type FAILED
    }
    if ($TBWSUSContentFolder.Text.Length -gt 4) {
        if ($TBWSUSContentFolder.Text.SubString(0,3) -match '^[A-Z]:\\$') {
            if (-not(Test-Path -Path $TBWSUSContentFolder.Text)) {
                Write-OutputBox -OutputBoxMessage "Validate path for WSUS content path" -Type PASSED
            }
            else {
                Write-OutputBox -OutputBoxMessage "Invalid WSUS content path, folder exists" -Type FAILED
                $ValidationFailed++
            }
        }
        else {
            Write-OutputBox -OutputBoxMessage "Invalid WSUS content path drive letter characters" -Type FAILED
            $ValidationFailed++
        }
    }

    if ((($TabPageWSUS.Controls | Where-Object { $_.Checked -eq $true }) | Measure-Object).Count -ge 1) {
        Write-OutputBox -OutputBoxMessage "Validate WSUS update classification selections" -Type PASSED
    }
    else {
        Write-OutputBox -OutputBoxMessage "Invalid WSUS update classfication selections, atleast select one" -Type FAILED
    }
    if (Validate-OS) {
        Write-OutputBox -OutputBoxMessage "Validate imported Operating Systems" -Type PASSED
    }
    else {
        Write-OutputBox -OutputBoxMessage "No Operating Systems have been imported" -Type FAILED
        $ValidationFailed++
    }
    if ($ValidationFailed -eq 0) {
        Write-OutputBox -OutputBoxMessage "All validation checks passed successfully" -Type PASSED
        $ButtonStart.Enabled = $true
    }
    else {
        Write-OutputBox -OutputBoxMessage "One or more validation checks failed" -Type ERROR
    }
}

function Set-StatusBarText {
    param(
    [parameter(Mandatory=$true)]
    [ValidateSet("Ready","Running","Done","Error")]
    $State,
    [parameter(Mandatory=$false)]
    $Message
    )
    if ($Message.Length -eq 0) {
        $SBPStatus.Text = "$($State)"
        $SBPProcessingStatus.Text = ""
    }
    else {
        $SBPStatus.Text = "$($State)"
        $SBPProcessingStatus.Text = "$($Message)"
    }
}

function Interactive-TextLoop {
    param(
    [parameter(Mandatory=$true)]
    [string]$Text,
    [parameter(Mandatory=$true)]
    [int]$Count
    )
    Set-StatusBarText -State Running -Message "$($Text)"
    $LoopCount = 0
    $StatusTextLength = $SBPProcessingStatus.Text.Length
    $TotalStatusTextLength = ($StatusTextLength + $Count)
    do {
        Start-Sleep -Seconds 1
        $LoopCount++
        if ($LoopCount -le $Count) {
            $SBPProcessingStatus.Text = $SBPProcessingStatus.Text + "."   
        }
        [System.Windows.Forms.Application]::DoEvents()
    }
    until ($LoopCount -ge $Count)
}

function New-CustomSettingsFile {
    $CSFile = @"
[Settings]
Priority=Default
Properties=MyCustomProperty

[Default]
OSInstall=Y
DeploymentType=NEWCOMPUTER
UserID=$($MDTUserName)
UserDomain=$($MDTServer)
UserPassword=$($MDTPassword)
SkipBDDWelcome=YES
SkipDeploymentType=YES
SkipDomainMembership=YES
SkipApplications=NO
SkipSummary=YES
SkipUserData=YES
SkipComputerName=YES
SkipTaskSequence=NO
SkipLocaleSelection=YES
SkipTimeZone=YES
SkipAppsOnUpgrade=YES
SkipAdminPassword=YES
SkipProductKey=YES
SkipComputerBackup=YES
SkipBitLocker=YES
SkipCapture=YES
SkipFinalSummary=YES
ComputerName=WINREF001
UILanguage=en-US
UserLocale=en-US
KeyboardLocale=en-US
TimeZoneName=Central Standard Time
WSUSServer=http://$($MDTServer).$($MDTDomain):8530
DoCapture=YES
ComputerBackupLocation=NETWORK
BackupShare=\\$($MDTServer).$($MDTDomain)\$($MDTDSName)$\Captures
BackupDir=ReferenceImages
BackupFile=%TASKSEQUENCEID%-#year(date) & "-" & month(date) & "-" & day(date)#.wim
_SMSTSOrgName=$($MDTDomain) - Reference Image Creation
FinishAction=SHUTDOWN
"@ # The closing part of the here-string needs to be the first characters on the line
    return $CSFile
}

function New-BootStrapFile {
    $BootstrapFile = @"
[Settings]
Priority=Default

[Default]
DeployRoot=\\$($MDTServer).$($MDTDomain)\$($MDTDSName)$

SkipBDDWelcome=Yes
UserID=$($MDTUserName)
UserDomain=$($MDTServer)
UserPassword=$($MDTPassword)
"@ # The closing part of the here-string needs to be the first characters on the line
    return $BootstrapFile
}

function Start-Installation {
    $ErrorActionPreference = "Stop"
    $OutputBox.ResetText()
    Interactive-TabPages -Option Disable
    $ButtonStart.Enabled = $false

    # Phase 1 - Install Microsoft Deployment Toolkit
    Set-StatusBarText -State Running -Message "Installing Microsoft Deployment Toolkit"
    Write-OutputBox -OutputBoxMessage "Starting to install Microsoft Deployment Toolkit" -Type INFO
    try {
        # Install MDT 2013
        $ArgumentList = "/qn"
        Start-Process -FilePath $TBSFMDT.Text -ArgumentList $ArgumentList -Wait -ErrorAction Stop
        Write-OutputBox -OutputBoxMessage "Successfully installed Microsoft Deployment Toolkit" -Type INFO
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 2 - Create and configure a new Deployment Share
    Set-StatusBarText -State Running -Message "Creating and configuring a new Deployment Share"
    Write-OutputBox -OutputBoxMessage "Starting to create the '$($MDTDSPath)\$($MDTDSName)' Deployment Share" -Type INFO
    try {
        # Create a new Deployment Share
        Add-PSSnapIn Microsoft.BDD.PSSnapIn -ErrorAction Stop 
        if (-not(Test-Path "$($MDTDSPath)\$($MDTDSName)" -PathType Container)) {
            Write-OutputBox -OutputBoxMessage "$($MDTDSPath)\$($MDTDSName) was not found, creating the directory" -Type INFO
            New-Item -ItemType Directory "$($MDTDSPath)\$($MDTDSName)" -ErrorAction Stop | Out-Null
        }
        Write-OutputBox -OutputBoxMessage "Creating the '$($MDTDSName)' Deployment Share" -Type INFO
        New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "$($MDTDSPath)\$($MDTDSName)" -Description "MDT Factory - Reference Image" -NetworkPath "\\$($MDTServer)\$($MDTDSName)$" -ErrorAction Stop | Add-MDTPersistentDrive | Out-Null
        Write-OutputBox -OutputBoxMessage "Successfully created the '$($MDTDSName)' Deployment Share" -Type INFO
        # Edit the Bootstrap.ini
        Remove-Item "$($MDTDSPath)\$($MDTDSName)\Control\Bootstrap.ini" -Force -ErrorAction Stop | Out-Null
        New-Item -ItemType File -Path "$($MDTDSPath)\$($MDTDSName)\Control\Bootstrap.ini" -Value (New-BootStrapFile) -ErrorAction Stop | Out-Null
        if (Test-Path -Path "$($MDTDSPath)\$($MDTDSName)\Control\Bootstrap.ini") {
            Write-OutputBox -OutputBoxMessage "Successfully updated the bootstrap.ini configuration" -Type INFO
        }
        else {
            Write-OutputBox -OutputBoxMessage "There was an error while creating $($MDTDSPath)\$($MDTDSName)\Control\Bootstrap.ini" -Type WARNING
        }
        # Edit the CustomSettings.ini
        Remove-Item "$($MDTDSPath)\$($MDTDSName)\Control\CustomSettings.ini" -Force -ErrorAction Stop | Out-Null
        New-Item -ItemType File -Path "$($MDTDSPath)\$($MDTDSName)\Control\CustomSettings.ini" -Value (New-CustomSettingsFile) -ErrorAction Stop | Out-Null
        if (Test-Path -Path "$($MDTDSPath)\$($MDTDSName)\Control\CustomSettings.ini") {
            Write-OutputBox -OutputBoxMessage "Successfully updated the CustomSettings.ini configuration" -Type INFO
        }
        else {
            Write-OutputBox -OutputBoxMessage "There was an error while creating $($MDTDSPath)\$($MDTDSName)\Control\CustomSettings.ini" -Type WARNING
        }
        Write-OutputBox -OutputBoxMessage "Successfully installed and configured the '$($MDTDSName)' Deployment Share" -Type INFO
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 3 - Create the ReferenceImages folder
    Set-StatusBarText -State Running -Message "Creating the ReferenceImages folder"
    try {
        # Create the ReferenceImages folder
        New-Item -Path "$($MDTDSPath)\$($MDTDSName)\Captures\ReferenceImages" -ItemType Directory -Force -ErrorAction Stop | Out-Null
        if (Test-Path -Path "$($MDTDSPath)\$($MDTDSName)\Captures\ReferenceImages" -PathType Container) {
            Write-OutputBox -OutputBoxMessage "Successfully created the 'ReferenceImages' folder" -Type INFO
        }
        else {
            Write-OutputBox -OutputBoxMessage "There was an error while creating $($MDTDSPath)\$($MDTDSName)\Captures\ReferenceImages" -Type WARNING
        }
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 4 - Copy settings.xml to the Deployment Share
    Set-StatusBarText -State Running -Message "Copying Settings.xml to $($MDTDSPath)\$($MDTDSName)\Control"
    Write-OutputBox -OutputBoxMessage "Copying Settings.xml to $($MDTDSPath)\$($MDTDSName)\Control" -Type INFO
    try {
        # Copy settings.xml to Deployment Share
        Copy-Item -Path "$($env:ProgramFiles)\Microsoft Deployment Toolkit\Templates\Settings.xml" -Destination "$($MDTDSPath)\$($MDTDSName)\Control" -Force -ErrorAction Stop | Out-Null
        
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 5 - Create console Folders
    Set-StatusBarText -State Running -Message "Creating console folders"
    Write-OutputBox -OutputBoxMessage "Starting to console folders" -Type INFO
    $OSPathObjects | ForEach-Object {
        try {
            # Create deployment share folders - Operating Systems
            Write-OutputBox -OutputBoxMessage "Creating folder DS001:\Operating Systems\$($_.Name)" -Type INFO
            New-Item -Path "DS001:\Operating Systems\$($_.Name)" -ItemType Folder -ErrorAction Stop | Out-Null
            # Create deployment share folders - Task Sequences
            Write-OutputBox -OutputBoxMessage "Creating folder DS001:\Task Sequences\$($_.Name)" -Type INFO
            New-Item -Path "DS001:\Task Sequences\$($_.Name)" -ItemType Folder -ErrorAction Stop | Out-Null
        }
        catch {
            Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
            Set-StatusBarText -State Error -Message ""
            Interactive-TabPages -Option Enable
            [System.Windows.Forms.Application]::DoEvents()
            return
        }
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 6 - Import Operating Systems
    Set-StatusBarText -State Running -Message "Importing Operating Systems"
    Write-OutputBox -OutputBoxMessage "Starting to import Operating Systems" -Type INFO
    $OSPathObjects | ForEach-Object {
        try {   
            # Import Operating Systems
            Write-OutputBox -OutputBoxMessage "Importing Operating System: '$($_.Name)'" -Type INFO
            Import-MDTOperatingSystem -Path "DS001:\Operating Systems\$($_.Name)" -SourcePath "$($_.SourcePath)" -DestinationFolder "$($_.Name)" -ErrorAction Stop | Out-Null
            $OSCount = (Get-ChildItem -Path "DS001:\Operating Systems\$($_.Name)" | Measure-Object).Count
            if ($OSCount -ge 1) {
                Write-OutputBox -OutputBoxMessage "Successfully imported '$($_.Name)'" -Type INFO
            }
            else {
                Write-OutputBox -OutputBoxMessage "There was a problem when importing '$($_.Name)'" -Type WARNING
            }
        }
        catch {
            Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
            Set-StatusBarText -State Error -Message ""
            Interactive-TabPages -Option Enable
            [System.Windows.Forms.Application]::DoEvents()
            return
        }
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 7 - Create Task Sequences
    Set-StatusBarText -State Running -Message "Creating Task Sequences"
    Write-OutputBox -OutputBoxMessage "Starting to create Task Sequences" -Type INFO
    $OSPathObjects | ForEach-Object {
        try {
            # Import Task Sequences
            $GetOSPathObjects = Get-ChildItem -Path "DS001:\Operating Systems\$($_.Name)"
            $OSCount = ($GetOSPathObjects | Measure-Object).Count
            if ($OSCount -eq 1) {
                $OSObjectInstance = Get-ChildItem -Path "DS001:\Operating Systems\$($_.Name)"
            }
            if ($OSCount -ge 2) {
                foreach ($OSPath in $GetOSPathObjects) {
                    Get-OSObjects -Path "$($OSPath.Name)"
                }
                Load-FormOSSelection
                $OSObjectInstance = Get-Item -Path "DS001:\Operating Systems\$($_.Name)\$($Global:OSSelectedObject)"
            }
            Write-OutputBox -OutputBoxMessage "Creating Task Sequence '$($_.Name) - Reference Image'" -Type INFO
            Import-MDTTaskSequence -Path "DS001:\Task Sequences\$($_.Name)" –Template "Client.xml" –Name "$($_.Name) - Reference Image" –ID "$($_.ID)" –Comments "Generated by MDT Factory Tool" –Version "1.00" –OperatingSystem $OSObjectInstance –FullName "$($_.FullName)" –OrgName "$($_.OrgName)" -HomePage "$($_.HomePage)" -AdminPassword "$($_.AdminPassword)" -ErrorAction Stop | Out-Null
            $TSCount = (Get-ChildItem -Path "DS001:\Task Sequences\$($_.Name)" | Measure-Object).Count
            if ($TSCount -ge 1) {
                Write-OutputBox -OutputBoxMessage "Successfully created the '$($_.Name) - Reference Image' Task Sequences" -Type INFO
            }
            else {
                Write-OutputBox -OutputBoxMessage "There was a problem when creating the '$($_.Name) - Reference Image' Task Sequence" -Type WARNING
            }
        }
        catch {
            Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
            Set-StatusBarText -State Error -Message ""
            Interactive-TabPages -Option Enable
            [System.Windows.Forms.Application]::DoEvents()
            return
        }
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 8 - Configure the Task Sequences to enable Windows Update, disable BitLocker and User State Restore
    Set-StatusBarText -State Running -Message "Modifying the Task Sequence(s)"
    Write-OutputBox -OutputBoxMessage "Starting to modify all Task Sequences" -Type INFO
    $OSPathObjects | ForEach-Object {
        try {
            # Configure the Task Sequences
            Write-OutputBox -OutputBoxMessage "Enabling Windows Update steps in the '$($_.Name)' Task Sequence" -Type INFO
            $TSXMLFile = "$($MDTDSPath)\$($MDTDSName)\Control\$($_.ID)\ts.xml"
            [xml]$TSSettingsXML = Get-Content $TSXMLFile
            $TSSettingsXML.Sequence.Group.Step | Where-Object {$_.Name -like "*Windows Update*"} | ForEach-Object {
                $_.Disable = "false"
            }
            Write-OutputBox -OutputBoxMessage "Disabling Restore User State steps in the '$($_.Name)' Task Sequence" -Type INFO
            $TSSettingsXML.Sequence.Group.Step | Where-Object {$_.Name -like "*Restore User State*"} | ForEach-Object {
                $_.Disable = "true"
            }
            Write-OutputBox -OutputBoxMessage "Disabling Enable BitLocker step in the '$($_.Name)' Task Sequence" -Type INFO
            $TSSettingsXML.Sequence.Group.Step | Where-Object {$_.Name -like "Enable BitLocker (Offline)"} | ForEach-Object {
                $_.Disable = "true"
            }
            $TSSettingsXML.Sequence.Group.Step | Where-Object {$_.Name -like "Enable BitLocker"} | ForEach-Object {
                $_.SetAttribute("disable","true")
            }
            $TSSettingsXML.Save($TSXMLFile)
            Write-OutputBox -OutputBoxMessage "Successfully modified the '$($_.Name)' Task Sequence" -Type INFO
        }
        catch {
            Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
            Set-StatusBarText -State Error -Message ""
            Interactive-TabPages -Option Enable
            [System.Windows.Forms.Application]::DoEvents()
            return
        }
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 9 - Import Applications
    if (($TBAppPath.Text.Length -ge 1) -and ($DGVApp.RowCount -ge 1)) {
        Set-StatusBarText -State Running -Message "Importing Application(s)"
        Write-OutputBox -OutputBoxMessage "Starting to import all Applications" -Type INFO
        $ApplicationPathObjects | ForEach-Object {
            try {
                # Create applications
                Import-MDTApplication -Path "DS001:\Applications" -Name "$($_.Name)" -ApplicationSourcePath "$($_.SourcePath)" -DestinationFolder "$($_.Name)" -Shortname "$($_.ShortName)" -CommandLine "$($_.CmdLine)" -WorkingDirectory ".\Applications\$($_.Name)" -ErrorAction Stop | Out-Null
                $CurrentApplicationName = $_.Name
                Write-OutputBox -OutputBoxMessage "Successfully imported application $($_.Name)" -Type INFO
            }
            catch {
                Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
                Set-StatusBarText -State Error -Message ""
                Interactive-TabPages -Option Enable
                [System.Windows.Forms.Application]::DoEvents()
                return
            }
        }
        Set-StatusBarText -State Ready -Message ""
    }

    # Phase 10 - Edit the Deployment Share setting to enable PowerShell if checked in the tool
    if ($CBMDTFeatures.Checked -eq $true) {
        Set-StatusBarText -State Running -Message "Editing Deployment Share settings, adding features"
        try {
            # Edit the Deployment Share settings
            Write-OutputBox -OutputBoxMessage "Adding support for PowerShell in the boot images" -Type INFO
            $XMLFile = "$($MDTDSPath)\$($MDTDSName)\Control\Settings.xml"
            [xml]$SettingsXML = Get-Content $XMLFile
            $SettingsXML.Settings."Boot.x64.FeaturePacks" = "winpe-mdac,winpe-netfx,winpe-powershell"
            $SettingsXML.Settings."Boot.x86.FeaturePacks" = "winpe-mdac,winpe-netfx,winpe-powershell"
            $SettingsXML.Save($XMLFile)
        }
        catch {
            Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
            Set-StatusBarText -State Error -Message ""
            Interactive-TabPages -Option Enable
            [System.Windows.Forms.Application]::DoEvents()
            return
        }
        Set-StatusBarText -State Ready -Message ""
    }

    # Phase 11 - Edit the Deployment Share settings to set the Scratch Space
    Set-StatusBarText -State Running -Message "Editing Deployment Share settings, setting Scratch Space"
    Write-OutputBox -OutputBoxMessage "Setting Scratch Space in the boot images" -Type INFO
    try {
        # Edit the Deployment Share settings
        $XMLFile = "$($MDTDSPath)\$($MDTDSName)\Control\Settings.xml"
        [xml]$SettingsXML = Get-Content $XMLFile
        $SettingsXML.Settings."Boot.x64.ScratchSpace" = "$($CMBMDTScratchSpace.SelectedItem)"
        $SettingsXML.Settings."Boot.x86.ScratchSpace" = "$($CMBMDTScratchSpace.SelectedItem)"
        $SettingsXML.Save($XMLFile)
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 12 - Create the local MDT User Account
    Set-StatusBarText -State Running -Message "Creating local user account"
    Write-OutputBox -OutputBoxMessage "Creating the local '$($MDTUserName)' user account" -Type INFO
    try {
        # Create a local user account
        $ComputerObject = [ADSI]"WinNT://$($MDTServer)"
        $UserObject = $ComputerObject.Create("User",$MDTUserName)
        $UserObject.SetPassword($MDTPassword)
        $UserObject.SetInfo() | Out-Null
        $GetUserObject = [ADSI]"WinNT://$($MDTServer)/$($MDTUserName)"
        if ($GetUserObject) {
            Write-OutputBox -OutputBoxMessage "Successfully created the local $($MDTUserName) user account" -Type INFO
        }
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 13 - Share the Deployment Share and give Everyone Full permissions
    Set-StatusBarText -State Running -Message "Creating a network share for the Deployment Share"
    Write-OutputBox -OutputBoxMessage "Starting to create a network share for the '$($MDTDSName)' Deployment Share" -Type INFO
    try {
        # Share the deployment share
        $SecurityDescriptor = ([WmiClass]"\\$($MDTServer)\root\cimv2:Win32_SecurityDescriptor").CreateInstance()
        $ACE = ([WmiClass]"\\$($MDTServer)\root\cimv2:Win32_ACE").CreateInstance()
        $Trustee = ([WmiClass]"\\$($MDTServer)\root\cimv2:Win32_Trustee").CreateInstance()
        $Trustee.Name = "Everyone"
        $Trustee.Domain = $null
        $ACE.AccessMask = 2032127
        $ACE.AceFlags = 3 
        $ACE.AceType = 0
        $ACE.Trustee = $Trustee 
        $SecurityDescriptor.DACL += $ACE.PsObject.BaseObject 
        $WMIConnection = [WmiClass]"\\$($MDTServer)\root\cimv2:Win32_Share"
        $ObjectParams = $WMIConnection.psbase.GetMethodParameters("Create")
        $ObjectParams.Path = "$($MDTDSPath)\$($MDTDSName)"
        $ObjectParams.Name = "$($MDTDSName)$"
        $ObjectParams.Type = 0
        $ObjectParams.MaximumAllowed = 100
        $ObjectParams.Access = $SecurityDescriptor
        $WMIConnection.InvokeMethod("Create",$ObjectParams,$null) | Out-Null
        $GetShareObject = Get-WmiObject -Namespace "root\cimv2" -Class "Win32_Share" | Where-Object { $_.Name -like "$($MDTDSName)$" }
        if ($GetShareObject) {
            Write-OutputBox -OutputBoxMessage "Successfully shared the Deployment Share as '\\$($MDTServer)\$($MDTDSName)$'" -Type INFO
        }
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 14 - Give MDTUserName NTFS Full Control permissions on the Deployment Share
    Set-StatusBarText -State Running -Message "Editing NTFS permissions"
    Write-OutputBox -OutputBoxMessage "Changing the NTFS permissions on the '$($MDTDSName)' Deployment Share" -Type INFO
    try {
        # Set permissions on the network share
        $ACLObject = Get-Acl "$($MDTDSPath)\$($MDTDSName)"
        $ACLObject.SetAccessRuleProtection($True, $False)
        $RuleObject = New-Object System.Security.AccessControl.FileSystemAccessRule("$($MDTUserName)","FullControl","ContainerInherit,ObjectInherit","None","Allow")
        $ACLObject.AddAccessRule($RuleObject)
        $RuleObject = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")
        $ACLObject.AddAccessRule($RuleObject)
        $RuleObject = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","ContainerInherit,ObjectInherit","None","Allow")
        $ACLObject.AddAccessRule($RuleObject)
        $RuleObject = New-Object System.Security.AccessControl.FileSystemAccessRule("Authenticated Users",@("ReadData","AppendData","Synchronize"),"None","None","Allow")
        $ACLObject.AddAccessRule($RuleObject)
        $RuleObject = New-Object System.Security.AccessControl.FileSystemAccessRule("CREATOR OWNER","FullControl","ContainerInherit,ObjectInherit","InheritOnly","Allow")
        Set-Acl "$($MDTDSPath)\$($MDTDSName)" $ACLObject
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 15 - Install the Windows Server Update Services features
    Set-StatusBarText -State Running -Message "Installing WSUS"
    Write-OutputBox -OutputBoxMessage "Starting to install WSUS" -Type INFO
    try {
        # Install and configure WSUS
        $WarningPreference = "SilentlyContinue"
        if (-not(Test-Path -Path $WSUSContentFolder)) {
            Write-OutputBox -OutputBoxMessage "WSUS Content Folder was not found, creating it" -Type INFO
            New-Item -Path $WSUSContentFolder -ItemType Directory | Out-Null
        }
        Write-OutputBox -OutputBoxMessage "Installing WSUS" -Type INFO
        $WSUSFeatures = @("UpdateServices-Services","UpdateServices-WidDB","UpdateServices-API","UpdateServices-UI")
        $WSUSFeatures | ForEach-Object {
            $WSUSCurrentFeature = $_
			Start-Job -Name $WSUSCurrentFeature -ScriptBlock {
    			param(
                [parameter(Mandatory=$true)]
        		$CurrentFeature
    			)
    			Add-WindowsFeature -Name $CurrentFeature
			} -ArgumentList $WSUSCurrentFeature | Out-Null
			Wait-Job -Name $WSUSCurrentFeature
			Remove-Job -Name $WSUSCurrentFeature
        }
        if (Get-WindowsFeature | Where-Object {($_.Name -eq "UpdateServices") -and ($_.Installed -eq "Installed")}) {
            Write-OutputBox -OutputBoxMessage "Successfully installed WSUS" -Type INFO
        }
        else {
            Write-OutputBox -OutputBoxMessage "There was a problem with installing WSUS" -Type WARNING
        }
        $WSUSUtil = "$($Env:ProgramFiles)\Update Services\Tools\WsusUtil.exe"
        $WSUSUtilArgs = "POSTINSTALL CONTENT_DIR=$($WSUSContentFolder)"
        Write-OutputBox -OutputBoxMessage "Configuring Windows Server Update Services post install" -Type INFO
        Start-Process -FilePath $WSUSUtil -ArgumentList $WSUSUtilArgs -NoNewWindow -Wait -RedirectStandardOutput "C:\Temp.txt" | Out-Null
        Remove-Item "C:\Temp.txt" -Force
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 16 - Load the WSUS Administration assembly
    Set-StatusBarText -State Running -Message "Loading the WSUS Administration assempbly"
    Write-OutputBox -OutputBoxMessage "Attempting to load the WSUS Administration assembly" -Type INFO  
    try {
        # Load WSUS assembly
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | Out-Null
        Write-OutputBox -OutputBoxMessage "Successfully loaded the WSUS Administration assembly" -Type INFO  
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 17 - Configure selected WSUS Classifications
    Set-StatusBarText -State Running -Message "Configuring WSUS update classifications"
    Write-OutputBox -OutputBoxMessage "Starting to configure WSUS update classifications" -Type INFO
    try {
        # Configure WSUS classifications
        $EnabledWSUSUpdateClassification = New-Object System.Collections.ArrayList
        $WSUSServer = Get-WsusServer -Name $MDTServer -Port 8530
        Set-WsusServerSynchronization -UpdateServer $WSUSServer -SyncFromMU | Out-Null
        Write-OutputBox -OutputBoxMessage "Configured synchronization to run from Microsoft Update" -Type INFO
        $WSUSUpdateClassificationList = New-Object System.Collections.ArrayList
        $WSUSUpdateClassificationList.AddRange(@("Critical Updates","Definition Updates","Drivers","Feature Packs","Security Updates","Service Packs","Tools","Update Rollups","Updates"))
        foreach ($WSUSUpdateClassification in $WSUSUpdateClassificationList) {
            Get-WsusClassification | Where-Object { $_.Classification.Title -like "$($WSUSUpdateClassification)" } | Set-WsusClassification -Disable
        }
        foreach ($TabPageWSUSObject in $TabPageWSUS.Controls) {
            if ($TabPageWSUSObject.GetType().ToString() -eq "System.Windows.Forms.CheckBox") {
                if ($TabPageWSUSObject.Checked -eq $true) {
                    $CBName = $TabPageWSUSObject.Name
                    $UpdateClassificationID = Get-WSUSUpdateClassificationID -Classification $CBName
                    $EnabledWSUSUpdateClassification.Add($UpdateClassificationID)
                    Write-OutputBox -OutputBoxMessage "Enabling the '$($CBName)' update classification" -Type INFO
                    Get-WsusClassification | Where-Object { $_.Classification.ID -like "$($UpdateClassificationID)" } | Set-WsusClassification | Out-Null
                }
            }
        }
        Write-OutputBox -OutputBoxMessage "Successfully enabled all selected update classifications" -Type INFO
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 18 - Configure the WSUS default automatic approval rule
    Set-StatusBarText -State Running -Message "Configuring WSUS automatic approval rules"
    Write-OutputBox -OutputBoxMessage "Starting to configure the WSUS default automatic approval rule" -Type INFO
    try {
        # Configure WSUS automatic approval rule
        $WSUSConnection = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($MDTServer,$false,"8530")
        $WSUSRuleName = "Default Automatic Approval Rule"
        $WSUSRule = $WSUSConnection.GetInstallApprovalRules() | Where-Object { $_.Name -like "$($WSUSRuleName)" }
        $WSUSClassificationCollection = New-Object Microsoft.UpdateServices.Administration.UpdateClassificationCollection
        $EnabledWSUSUpdateClassification | ForEach-Object {
            $CurrentUpdateClassification = $_
            $CheckedUpdateClassification = $WSUSConnection.GetUpdateClassifications() | Where-Object {
                $_.Id -like "$($CurrentUpdateClassification)"
            }
            $WSUSClassificationCollection.Add($CheckedUpdateClassification)
        }
        $WSUSRule.SetUpdateClassifications($WSUSClassificationCollection)
        $WSUSRule.Enabled = $true
        $WSUSRule.Save()
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 19 - Configure the WSUS automatic synchronization schedule
    Set-StatusBarText -State Running -Message "Configuring WSUS automatic synchronization schedule"
    Write-OutputBox -OutputBoxMessage "Starting to configure the WSUS automatic synchronization schedule" -Type INFO
    try {
        # Create a WSUS automatic synchronization schedule
        $WSUSSubscription = $WSUSConnection.GetSubscription()
        $WSUSSubscription.SynchronizeAutomatically = $true
        $WSUSSubscription.SynchronizeAutomaticallyTimeOfDay = (New-TimeSpan -Hours 6)
        $WSUSSubscription.Save()
        Write-OutputBox -OutputBoxMessage "Successfully configured the WSUS automatic synchronization schedule" -Type INFO
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 20 - Configure the WSUS languages settings
    Set-StatusBarText -State Running -Message "Configuring WSUS languages settings"
    Write-OutputBox -OutputBoxMessage "Starting to configure the WSUS language settings" -Type INFO
    try {
        # Configure WSUS languages settings
        $WSUSLanguageCollection = New-Object System.Collections.ArrayList
        $WSUSConfiguration = $WSUSConnection.GetConfiguration()
        $WSUSConfiguration.AllUpdateLanguagesEnabled = $false
        if ($DGVWSUSLanguages.RowCount -ge 1) {
            for ($WSUSLanguageRow = 0; $WSUSLanguageRow -lt $DGVWSUSLanguages.RowCount; $WSUSLanguageRow++) {
                $WSUSLanguageCollection.Add($DGVWSUSLanguages.Rows[$WSUSLanguageRow].Cells["ID"].Value)
            }
            $WSUSLanguageCollection | ForEach-Object {
                $CurrentWSUSLanguageID = $_
                Write-OutputBox -OutputBoxMessage "Enabling the WSUS language ID '$($CurrentWSUSLanguageID.ToUpper())'" -Type INFO
            }
            $WSUSConfiguration.SetEnabledUpdateLanguages($WSUSLanguageCollection)
            $WSUSConfiguration.Save()
        }
        else {
            Write-OutputBox -OutputBoxMessage "No languages was selected, using default" -Type INFO
        }
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 21 - Start initial WSUS synchronization
    Set-StatusBarText -State Running -Message "Starting initial WSUS synchronization"
    Write-OutputBox -OutputBoxMessage "Starting the initial WSUS synchronization process" -Type INFO
    try {
        # Start WSUS initial synchronization
        $WSUSSubscription.StartSynchronizationForCategoryOnly()
        Write-OutputBox -OutputBoxMessage "Waiting for initial WSUS synchronization, this will take some time" -Type INFO
        while ($WSUSSubscription.GetSynchronizationStatus() -ne "NotProcessing") {
            Interactive-TextLoop -Text "Synchronizing WSUS" -Count 4
        }
        Write-OutputBox -OutputBoxMessage "Initial WSUS synchronization completed successfully" -Type INFO
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 22 - Configuring WSUS Products
    Set-StatusBarText -State Running -Message "Configuring WSUS products"
    Write-OutputBox -OutputBoxMessage "Starting to configure WSUS products" -Type INFO
    try {
        # Configure WSUS products
        $WSUSSubscription = $WSUSConnection.GetSubscription()
        $WSUSCategoryCollection = New-Object Microsoft.UpdateServices.Administration.UpdateCategoryCollection
        $WSUSProductCollection = New-Object System.Collections.ArrayList
        for ($WSUSProductRow = 0; $WSUSProductRow -lt $DGVWSUSProducts.RowCount; $WSUSProductRow++) {
            $WSUSProductCollection.Add($DGVWSUSProducts.Rows[$WSUSProductRow].Cells["ID"].Value)
        }
        $WSUSProductCollection | ForEach-Object {
            $CurrentWSUSProduct = $_
            $WSUSProduct = $WSUSConnection.GetUpdateCategories() | Where-Object {
                $_.Id -like "$($CurrentWSUSProduct)"
            }
            $WSUSCategoryCollection.Add($WSUSProduct)
        }
        $WSUSSubscription.SetUpdateCategories($WSUSCategoryCollection)
        $WSUSSubscription.Save()
        Write-OutputBox -OutputBoxMessage "Successfully configured WSUS products" -Type INFO
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 23 - Start WSUS Synchronization
    Set-StatusBarText -State Running -Message "Synchronizing WSUS"
    Write-OutputBox -OutputBoxMessage "Starting to synchonize WSUS" -Type INFO
    try {
        # Start WSUS synchronization
        $WSUSSubscription.StartSynchronization()
        while ($WSUSSubscription.GetSynchronizationStatus() -ne "NotProcessing") {
            Interactive-TextLoop -Text "Synchronizing WSUS" -Count 4
        }
        Write-OutputBox -OutputBoxMessage "Successfully synchonized WSUS" -Type INFO
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 24 - Run Automatic Approval Rule
    Set-StatusBarText -State Running -Message "Running Automatic Approval rule"
    Write-OutputBox -OutputBoxMessage "Running the Automatic Approval rule to approve updates" -Type INFO
    try {
        $WSUSConnection = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($MDTServer,$false,"8530")
        $WSUSAutomaticRule = $WSUSConnection.GetInstallApprovalRules() | Where-Object { $_.Name -like "Default Automatic Approval Rule" }
        $WSUSAutomaticRule.ApplyRule()
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 25 (Automatic) - Add all imported applications to the CustomSettings.ini
    if (($CMBGeneralOptionMode.SelectedItem -like "Automatic") -and ($DGVApp.RowCount -ge 1)) {
        Set-StatusBarText -State Running -Message "Editing CustomSettings.ini"
        Write-OutputBox -OutputBoxMessage "Editing the CustomSettings.ini to add all imported Applications" -Type INFO
        try {
            $AppGUIDCount = 0
            $AppsXMLFile = "$($MDTDSPath)\$($MDTDSName)\Control\Applications.xml"
            [xml]$AppsXML = Get-Content $AppsXMLFile
            $MDTApplications = $AppsXML.Applications.application | Select-Object -ExpandProperty Guid
            $MDTApplicationsCount = ($MDTApplications | Measure-Object).Count
            if ($MDTApplicationsCount -ge 1) {
                Add-Content -Path "$($MDTDSPath)\$($MDTDSName)\Control\CustomSettings.ini" "`n"
                $MDTApplications | ForEach-Object {
                    $AppGUIDCount++
                    $CurrentAppGUID = $_
                    Write-OutputBox -OutputBoxMessage "Adding Application with GUID '$($CurrentAppGUID)' to CustomSettings.ini" -Type INFO
                    if ($AppGUIDCount -le 9) {
                        Add-Content -Path "$($MDTDSPath)\$($MDTDSName)\Control\CustomSettings.ini" "MandatoryApplications00$($AppGUIDCount)=$($CurrentAppGUID)"
                    }
                    if (($AppGUIDCount -ge 10) -and ($AppGUIDCount -le 99)) {
                        Add-Content -Path "$($MDTDSPath)\$($MDTDSName)\Control\CustomSettings.ini" "MandatoryApplications0$($AppGUIDCount)=$($CurrentAppGUID)"
                    }
                    if (($AppGUIDCount -ge 100) -and ($AppGUIDCount -le 999)) {
                        Add-Content -Path "$($MDTDSPath)\$($MDTDSName)\Control\CustomSettings.ini" "MandatoryApplications$($AppGUIDCount)=$($CurrentAppGUID)"
                    }
                }
            }
        }
        catch {
            Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
            Set-StatusBarText -State Error -Message ""
            Interactive-TabPages -Option Enable
            [System.Windows.Forms.Application]::DoEvents()
            return
        }
        Set-StatusBarText -State Ready -Message ""
    }

    # Phase 26 (Automatic) - Disable Task Sequence and Application wizard pages
    if ($CMBGeneralOptionMode.SelectedItem -like "Automatic") {
        Set-StatusBarText -State Running -Message "Editing CustomSettings.ini"
        Write-OutputBox -OutputBoxMessage "Editing the CustomSettings.ini to disable the Task Sequence and Applications wizard pages" -Type INFO
        try {
            $MDTCSPath = "$($MDTDSPath)\$($MDTDSName)\Control\CustomSettings.ini"
            $MDTCSFile = Get-Content -Path $MDTCSPath
            $MDTCSFile[(($MDTCSFile | Select-String -Pattern "SkipTaskSequence").LineNumber)-1] = "SkipTaskSequence=YES"
            $MDTCSFile[(($MDTCSFile | Select-String -Pattern "SkipApplications").LineNumber)-1] = "SkipApplications=YES"
            $MDTCSFile | Set-Content -Path $MDTCSPath
            Write-OutputBox -OutputBoxMessage "Successfully amended the CustomSettings.ini settings" -Type INFO
        }
        catch {
            Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
            Set-StatusBarText -State Error -Message ""
            Interactive-TabPages -Option Enable
            [System.Windows.Forms.Application]::DoEvents()
            return
        }
        Set-StatusBarText -State Ready -Message ""
    }

    # Phase 27 (Automatic) - Add mandatory Task Sequence to CustomSettings.ini
    if ($CMBGeneralOptionMode.SelectedItem -like "Automatic") {
        Set-StatusBarText -State Running -Message "Editing CustomSettings.ini"
        Write-OutputBox -OutputBoxMessage "Adding mandatory Task Sequence to CustomSettings.ini" -Type INFO
        try {
            # Add mandatory Task Sequence to CustomSettings.ini
            $MDTTSName = "$($CMBGeneralOptionModeOS.Text)" + " - Reference Image"
            $MDTTSXMLPath = "$($MDTDSPath)\$($MDTDSName)\Control\TaskSequences.xml"
            [xml]$MDTTSXML = Get-Content -Path $MDTTSXMLPath
            $MDTTSID = $MDTTSXML.tss.ts | Where-Object { $_.Name -like $($MDTTSName) } | Select-Object -ExpandProperty ID
            Add-Content -Path "$($MDTDSPath)\$($MDTDSName)\Control\CustomSettings.ini" "`nTaskSequenceID=$($MDTTSID)"
        }
        catch {
            Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
            Set-StatusBarText -State Error -Message ""
            Interactive-TabPages -Option Enable
            [System.Windows.Forms.Application]::DoEvents()
            return
        }
        Set-StatusBarText -State Ready -Message ""
    }

    # Phase 28 (Manual) - SkipApplications if there's no imported Applications
    if ($CMBGeneralOptionMode.SelectedItem -like "Manual") {
        if ($DGVApp.RowCount -eq 0) {
            Set-StatusBarText -State Running -Message "Editing CustomSettings.ini"
            Write-OutputBox -OutputBoxMessage "Disabling the Applications wizard page" -Type INFO
            try {
                $MDTCSPath = "$($MDTDSPath)\$($MDTDSName)\Control\CustomSettings.ini"
                $MDTCSFile = Get-Content -Path $MDTCSPath
                $MDTCSFile[(($MDTCSFile | Select-String -Pattern "SkipApplications").LineNumber)-1] = "SkipApplications=YES"
                $MDTCSFile | Set-Content -Path $MDTCSPath
            }
            catch {
                Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
                Set-StatusBarText -State Error -Message ""
                Interactive-TabPages -Option Enable
                [System.Windows.Forms.Application]::DoEvents()
                return
            }
            Set-StatusBarText -State Ready -Message ""
        }
    }

    # Phase 29 - Install Windows Assessment Deployment Kit
    Set-StatusBarText -State Running -Message "Installing Windows ADK"
    Write-OutputBox -OutputBoxMessage "Starting to install Windows ADK, this will take some time" -Type INFO
    try {
        # Install ADK
        $ADKArguments = "/norestart /q /ceip off /features OptionId.WindowsPreinstallationEnvironment OptionId.DeploymentTools"
	    Start-Process -FilePath "$($TBSFADK.Text)" -ArgumentList $ADKArguments
	    while (Get-WmiObject -Class Win32_Process -Filter 'Name = "adksetup.exe"') {
		    Interactive-TextLoop -Text "Installing ADK" -Count 4
	    }
        Write-OutputBox -OutputBoxMessage "Successfully installed Windows ADK" -Type INFO
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 30 - Update Deployment Share
    Set-StatusBarText -State Running -Message "Updating Deployment Share"
    Write-OutputBox -OutputBoxMessage "Starting to update the Deployment Share '$($MDTDSName)'" -Type INFO
    try {
        # Update deployment share
        Update-MDTDeploymentShare -Path "DS001:" -Force -ErrorAction Stop | Out-Null
        Write-OutputBox -OutputBoxMessage "Successfully updated the '$($MDTDSName)'" -Type INFO
    }
    catch {
        Write-OutputBox -OutputBoxMessage "$($_.Exception.Message)" -Type ERROR
        Set-StatusBarText -State Error -Message ""
        Interactive-TabPages -Option Enable
        [System.Windows.Forms.Application]::DoEvents()
        return
    }
    Set-StatusBarText -State Ready -Message ""

    # Phase 31 - Completion
    Set-StatusBarText -State Done -Message "MDT Factory installation completed"
    Write-OutputBox -OutputBoxMessage "Successfully installed the MDT Factory" -Type INFO
    Interactive-TabPages -Option Enable
    $ButtonStart.Enabled = $true
}

# Hash tables
$WSUSLanguages = @{
    "ar" = "Arabic"
    "bg" = "Bulgarian"
    "cs" = "Czech"
    "da" = "Danish"
    "de" = "German"
    "el" = "Greek"
    "en" = "English"
    "es" = "Spanish"
    "et" = "Estonian"
    "fi" = "Finnish"
    "fr" = "France"
    "he" = "Hebrew"
    "hi" = "Hindi"
    "hr" = "Croatian"
    "hu" = "Hungarian"
    "it" = "Italian"
    "ja" = "Japanese"
    "ko" = "Korean"
    "lt" = "Lithuanian"
    "lv" = "Latvian"
    "nl" = "Dutch"
    "no" = "Norwegian"
    "pl" = "Polish"
    "pt" = "Portuguese (Portugal)"
    "pt-br" = "Portuguese (Brazil)"
    "ro" = "Romanian"
    "ru" = "Russian"
    "sk" = "Slovak"
    "sl" = "Slovenian"
    "sr" = "Serbian"
    "sv" = "Swedish"
    "th" = "Thai"
    "tr" = "Turkish"
    "uk" = "Ukrainian"
    "zh-cn" = "Chinese (China)"
    "zh-hk" = "Chinese (Hong Kong SAR)"
    "zh-tw" = "Chinese (Taiwan)"
}
$WSUSProducts = @{
    "bfe5b177-a086-47a0-b102-097e4fa1f807" = "Windows 7"
    "6407468e-edc7-4ecd-8c32-521f64cee65e" = "Windows 8.1"
    "2ee2ad83-828c-4405-9479-544d767993fc" = "Windows 8"
    "fdfe8200-9d98-44ba-a12a-772282bf60ef" = "Windows Server 2008 R2"
    "d31bd4c3-d872-41c9-a2e7-231f372588cb" = "Windows Server 2012 R2"
    "a105a108-7c9b-4518-bbbe-73f0fe30012b" = "Windows Server 2012"
    "84f5f325-30d7-41c4-81d1-87a0e6535b66" = "Office 2010"
    "704a0a4a-518f-4d69-9e03-10ba44198bd5" = "Office 2013"
}

# Assemblies
try {
    [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
}
catch {
    Write-Error $_.Exception.Message
}

# Forms
$Form = New-Object System.Windows.Forms.Form    
$Form.Size = New-Object System.Drawing.Size(700,745)
$Form.MinimumSize = New-Object System.Drawing.Size(700,745)
$Form.MaximumSize = New-Object System.Drawing.Size(700,745)
$Form.SizeGripStyle = "Hide"
$Form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHome + "\powershell.exe")
$Form.Text = "MDT Factory Tool 1.0.1"
$Form.ControlBox = $true
$Form.TopMost = $true
$FormOS = New-Object System.Windows.Forms.Form    
$FormOS.Size = New-Object System.Drawing.Size(500,270)
$FormOS.MinimumSize = New-Object System.Drawing.Size(500,270)
$FormOS.MaximumSize = New-Object System.Drawing.Size(500,270)
$FormOS.SizeGripStyle = "Hide"
$FormOS.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHome + "\powershell.exe")
$FormOS.Text = "Select an Operating System"
$FormOS.ControlBox = $true
$FormOS.TopMost = $true

# OutputBoxs
$OutputBox = New-Object System.Windows.Forms.RichTextBox
$OutputBox.Location = New-Object System.Drawing.Size(10,410)
$OutputBox.Size = New-Object System.Drawing.Size(663,255)
$OutputBox.Font = "Courier New"
$OutputBox.BackColor = "white"
$OutputBox.ReadOnly = $true
$OutputBox.MultiLine = $True

# StatusBars
$SBPStatus = New-Object Windows.Forms.StatusBarPanel
$SBPStatus.Text = "Ready"
$SBPStatus.Width = "100"
$SBPProcessingStatus = New-Object Windows.Forms.StatusBarPanel
$SBPProcessingStatus.Text = ""
$SBPProcessingStatus.Width = "740"
$SBStatus = New-Object Windows.Forms.StatusBar
$SBStatus.ShowPanels = $true
$SBStatus.SizingGrip = $false
$SBStatus.AutoSize = "Full"
$SBStatus.Panels.AddRange(@($SBPStatus, $SBPProcessingStatus))

# ComboBoxes
$CMBMDTScratchSpace = New-Object System.Windows.Forms.ComboBox
$CMBMDTScratchSpace.Location = New-Object System.Drawing.Size(275,205)
$CMBMDTScratchSpace.Size = New-Object System.Drawing.Size(110,20)
$CMBMDTScratchSpace.DropDownStyle = "DropDownList"
$CMBMDTScratchSpace.Items.AddRange(@("128","256","512")) | Out-Null
$CMBMDTScratchSpace.SelectedIndex = 1
$CMBMDTScratchSpace.Name = "ScratchSpace"
$CMBWSUSProductSelection = New-Object System.Windows.Forms.ComboBox
$CMBWSUSProductSelection.Location = New-Object System.Drawing.Size(20,195)
$CMBWSUSProductSelection.Size = New-Object System.Drawing.Size(225,20)
$CMBWSUSProductSelection.DropDownStyle = "DropDownList"
$CMBWSUSProductSelection.Items.AddRange(@(
    "Windows 7",
    "Windows 8",
    "Windows 8.1",
    "Windows Server 2008 R2",
    "Windows Server 2012",
    "Windows Server 2012 R2",
    "Office 2010",
    "Office 2013"
)) | Out-Null
$CMBWSUSProductSelection.SelectedIndex = 0
$CMBWSUSProductSelection.Name = "WSUSProducts"
$CMBWSUSLanguageSelection = New-Object System.Windows.Forms.ComboBox
$CMBWSUSLanguageSelection.Location = New-Object System.Drawing.Size(275,195)
$CMBWSUSLanguageSelection.Size = New-Object System.Drawing.Size(225,20)
$CMBWSUSLanguageSelection.DropDownStyle = "DropDownList"
$CMBWSUSLanguageSelection.Items.AddRange(@(
    "Arabic",
    "Bulgarian",
    "Chinese (China)",
    "Chinese (Hong Kong SAR)",
    "Chinese (Taiwan)",
    "Croatian",
    "Czech",
    "Danish",
    "Dutch",
    "English",
    "Estonian",
    "Finnish",
    "France",
    "German",
    "Greek",
    "Hebrew",
    "Hindi",
    "Hungarian",
    "Italian",
    "Japanese",
    "Korean",
    "Latvian",
    "Lithuanian",
    "Norwegian",
    "Polish",
    "Portuguese (Brazil)",
    "Portuguese (Portugal)",
    "Romanian",
    "Russian",
    "Serbian",
    "Slovak",
    "Slovenian",
    "Spanish",
    "Swedish",
    "Thai",
    "Turkish",
    "Ukrainian"
)) | Out-Null
$CMBWSUSLanguageSelection.SelectedIndex = 0
$CMBWSUSLanguageSelection.Name = "WSUSLanguages"
$CMBGeneralOptionMode = New-Object System.Windows.Forms.ComboBox
$CMBGeneralOptionMode.Location = New-Object System.Drawing.Size(30,260)
$CMBGeneralOptionMode.Size = New-Object System.Drawing.Size(140,20)
$CMBGeneralOptionMode.DropDownStyle = "DropDownList"
$CMBGeneralOptionMode.Items.AddRange(@("Manual","Automatic")) | Out-Null
$CMBGeneralOptionMode.SelectedIndex = 0
$CMBGeneralOptionMode.Name = "InstallationMode"
$CMBGeneralOptionMode.Add_SelectedValueChanged({
    if ($CMBGeneralOptionMode.SelectedItem -like "Automatic") {
        if ($CMBGeneralOptionModeOS.Enabled -eq $false) {
            $CMBGeneralOptionModeOS.Enabled = $true
            $CMBGeneralOptionModeOS.Items.Clear()
            if ($GeneralModeOS.Count -ge 1) {
                $GeneralModeOS | ForEach-Object {
                    $CMBGeneralOptionModeOS.Items.Add($_)
                }
                $CMBGeneralOptionModeOS.SelectedIndex = 0
            }
        }
        if ($CMBGeneralOptionModeOS.Items.Count -eq 0) {
            Write-OutputBox -OutputBoxMessage "No Operating Systems have been imported, this can be done in the Operating System tab by specifying a CSV file and import it" -Type INFO
        }
    }
    if ($CMBGeneralOptionMode.SelectedItem -like "Manual") {
        if ($CMBGeneralOptionModeOS.Enabled -eq $true) {
            $CMBGeneralOptionModeOS.Enabled = $false
            $CMBGeneralOptionModeOS.Items.Clear()
            $CMBGeneralOptionModeOS.Items.Add("All Imported")
            $CMBGeneralOptionModeOS.SelectedIndex = 0
        }
    }
}) | Out-Null
$CMBGeneralOptionModeOS = New-Object System.Windows.Forms.ComboBox
$CMBGeneralOptionModeOS.Location = New-Object System.Drawing.Size(200,260)
$CMBGeneralOptionModeOS.Size = New-Object System.Drawing.Size(290,20)
$CMBGeneralOptionModeOS.DropDownStyle = "DropDownList"
$CMBGeneralOptionModeOS.Items.Add("All imported") | Out-Null
$CMBGeneralOptionModeOS.SelectedIndex = 0
$CMBGeneralOptionModeOS.Enabled = $false
$CMBGeneralOptionModeOS.Name = "AutomaticOS"

# CheckBoxes
$CBMDTFeatures = New-Object System.Windows.Forms.CheckBox
$CBMDTFeatures.Location = New-Object System.Drawing.Size(30,206)
$CBMDTFeatures.Size = New-Object System.Drawing.Size(110,20)
$CBMDTFeatures.Text = "PowerShell"
$CBWSUSCriticalUpdates = New-Object System.Windows.Forms.CheckBox
$CBWSUSCriticalUpdates.Location = New-Object System.Drawing.Size(275,298)
$CBWSUSCriticalUpdates.Size = New-Object System.Drawing.Size(105,20)
$CBWSUSCriticalUpdates.Text = "Critical Updates"
$CBWSUSCriticalUpdates.Name = "Critical Updates"
$CBWSUSCriticalUpdates.Checked = $true
$CBWSUSSecurityUpdates = New-Object System.Windows.Forms.CheckBox
$CBWSUSSecurityUpdates.Location = New-Object System.Drawing.Size(275,316)
$CBWSUSSecurityUpdates.Size = New-Object System.Drawing.Size(110,20)
$CBWSUSSecurityUpdates.Text = "Security Updates"
$CBWSUSSecurityUpdates.Name = "Security Updates"
$CBWSUSSecurityUpdates.Checked = $true
$CBWSUSUpdates = New-Object System.Windows.Forms.CheckBox
$CBWSUSUpdates.Location = New-Object System.Drawing.Size(385,298)
$CBWSUSUpdates.Size = New-Object System.Drawing.Size(110,20)
$CBWSUSUpdates.Text = "Updates"
$CBWSUSUpdates.Name = "Updates"
$CBWSUSUpdates.Checked = $false
$CBWSUSDefinitionUpdates = New-Object System.Windows.Forms.CheckBox
$CBWSUSDefinitionUpdates.Location = New-Object System.Drawing.Size(385,316)
$CBWSUSDefinitionUpdates.Size = New-Object System.Drawing.Size(120,20)
$CBWSUSDefinitionUpdates.Text = "Definition Updates"
$CBWSUSDefinitionUpdates.Name = "Definition Updates"
$CBWSUSDefinitionUpdates.Checked = $false

# TextBoxes
$TBSFMDT = New-Object System.Windows.Forms.TextBox
$TBSFMDT.Location = New-Object System.Drawing.Size(30,85)
$TBSFMDT.Size = New-Object System.Drawing.Size(370,20)
$TBSFMDT.Enabled = $false
$TBSFADK = New-Object System.Windows.Forms.TextBox
$TBSFADK.Location = New-Object System.Drawing.Size(30,145)
$TBSFADK.Size = New-Object System.Drawing.Size(370,20)
$TBSFADK.Enabled = $false
$TBMDTDSPath = New-Object System.Windows.Forms.TextBox
$TBMDTDSPath.Location = New-Object System.Drawing.Size(30,75)
$TBMDTDSPath.Size = New-Object System.Drawing.Size(215,20)
$TBMDTDSPath.Text = "C:\DeploymentShares"
$TBMDTDSPath.Add_TextChanged({
    $Global:MDTDSPath = $TBMDTDSPath.Text
    Validate-TextboxLength -Object $TBMDTDSPath -Text "Specified Deployment Share path contains more than 255 characters, this is not supported"
})
$TBMDTDSName = New-Object System.Windows.Forms.TextBox
$TBMDTDSName.Location = New-Object System.Drawing.Size(275,75)
$TBMDTDSName.Size = New-Object System.Drawing.Size(215,20)
$TBMDTDSName.Text = "MDTFactory"
$TBMDTDSName.Add_TextChanged({
    $Global:MDTDSName = $TBMDTDSName.Text
    Validate-TextboxLength -Object $TBMDTDSPath -Text "Specified Deployment Share name contains more than 255 characters, this is not supported"
})
$TBMDTUserName = New-Object System.Windows.Forms.TextBox
$TBMDTUserName.Location = New-Object System.Drawing.Size(20,300)
$TBMDTUserName.Size = New-Object System.Drawing.Size(100,20)
$TBMDTUserName.Text = "MDTUser"
$TBMDTUserName.Add_TextChanged({
    $Global:MDTUserName = $TBMDTUserName.Text
    Validate-TextboxLength -Object $TBMDTDSPath -Text "Specified user name contains more than 255 characters, this is not supported"
})
$TBMDTPassword = New-Object System.Windows.Forms.TextBox
$TBMDTPassword.Location = New-Object System.Drawing.Size(200,300)
$TBMDTPassword.Size = New-Object System.Drawing.Size(100,20)
$TBMDTPassword.Text = "P@ssw0rd!"
$TBMDTPassword.Add_TextChanged({
    $Global:MDTPassword = $TBMDTPassword.Text
    Validate-TextboxLength -Object $TBMDTDSPath -Text "Specified password contains more than 255 characters, this is not supported"
})
$TBAppPath = New-Object System.Windows.Forms.TextBox
$TBAppPath.Location = New-Object System.Drawing.Size(20,70)
$TBAppPath.Size = New-Object System.Drawing.Size(360,20)
$TBAppPath.Enabled = $false
$TBOSPath = New-Object System.Windows.Forms.TextBox
$TBOSPath.Location = New-Object System.Drawing.Size(20,70)
$TBOSPath.Size = New-Object System.Drawing.Size(360,20)
$TBOSPath.Enabled = $false
$TBOSSelection = New-Object System.Windows.Forms.TextBox
$TBOSSelection.Location = New-Object System.Drawing.Size(10,184)
$TBOSSelection.Size = New-Object System.Drawing.Size(330,20)
$TBOSSelection.Enabled = $false
$TBWSUSContentFolder = New-Object System.Windows.Forms.TextBox
$TBWSUSContentFolder.Location = New-Object System.Drawing.Size(20,305)
$TBWSUSContentFolder.Size = New-Object System.Drawing.Size(225,20)
$TBWSUSContentFolder.Text = "C:\WSUSContent"
$TBWSUSContentFolder.Add_TextChanged({
    $Global:WSUSContentFolder = $TBWSUSContentFolder.Text
    Validate-TextboxLength -Object $TBMDTDSPath -Text "Specified WSUS content folder path contains more than 255 characters, this is not supported"
})

# Labels
$LabelMDTDSPath = New-Object System.Windows.Forms.Label
$LabelMDTDSPath.Location = New-Object System.Drawing.Size(28,50)
$LabelMDTDSPath.Size = New-Object System.Drawing.Size(220,20)
$LabelMDTDSPath.Text = "Specify a local path for the DS:"
$LabelMDTDSName = New-Object System.Windows.Forms.Label
$LabelMDTDSName.Location = New-Object System.Drawing.Size(273,50)
$LabelMDTDSName.Size = New-Object System.Drawing.Size(220,20)
$LabelMDTDSName.Text = "Enter a name for the DS:"
$LabelMDTBIFeatures = New-Object System.Windows.Forms.Label
$LabelMDTBIFeatures.Location = New-Object System.Drawing.Size(28,170)
$LabelMDTBIFeatures.Size = New-Object System.Drawing.Size(220,30)
$LabelMDTBIFeatures.Text = "Select the features that you would like to enable in the Boot Images:"
$LabelMDTBIScratchSpace = New-Object System.Windows.Forms.Label
$LabelMDTBIScratchSpace.Location = New-Object System.Drawing.Size(273,170)
$LabelMDTBIScratchSpace.Size = New-Object System.Drawing.Size(220,30)
$LabelMDTBIScratchSpace.Text = "Specify the Scratch Space size (in MB) of the Boot Image:"
$LabelMDTUP = New-Object System.Windows.Forms.Label
$LabelMDTUP.Location = New-Object System.Drawing.Size(18,275)
$LabelMDTUP.Size = New-Object System.Drawing.Size(450,15)
$LabelMDTUP.Text = "Enter an username and password for a new local user account:"
$LabelWSUSProducts = New-Object System.Windows.Forms.Label
$LabelWSUSProducts.Location = New-Object System.Drawing.Size(18,30)
$LabelWSUSProducts.Size = New-Object System.Drawing.Size(220,30)
$LabelWSUSProducts.Text = "Select the products for which to synchronize updates for:"
$LabelWSUSLanguages = New-Object System.Windows.Forms.Label
$LabelWSUSLanguages.Location = New-Object System.Drawing.Size(273,30)
$LabelWSUSLanguages.Size = New-Object System.Drawing.Size(220,30)
$LabelWSUSLanguages.Text = "Select the languages for which to synchronize updates for:"
$LabelWSUSContentFolder = New-Object System.Windows.Forms.Label
$LabelWSUSContentFolder.Location = New-Object System.Drawing.Size(18,280)
$LabelWSUSContentFolder.Size = New-Object System.Drawing.Size(235,20)
$LabelWSUSContentFolder.Text = "Specify a local path for the Content Folder:"
$LabelWSUSUpdateClassification = New-Object System.Windows.Forms.Label
$LabelWSUSUpdateClassification.Location = New-Object System.Drawing.Size(273,280)
$LabelWSUSUpdateClassification.Size = New-Object System.Drawing.Size(235,20)
$LabelWSUSUpdateClassification.Text = "Select the desired classifications:"
$LabelApp = New-Object System.Windows.Forms.Label
$LabelApp.Location = New-Object System.Drawing.Size(18,30)
$LabelApp.Size = New-Object System.Drawing.Size(450,30)
$LabelApp.Text = "Import a .CSV file containing all the information to install the applications unattended:"
$LabelOS = New-Object System.Windows.Forms.Label
$LabelOS.Location = New-Object System.Drawing.Size(18,30)
$LabelOS.Size = New-Object System.Drawing.Size(450,30)
$LabelOS.Text = "Import a .CSV file containing all the information to install the operating systems unattended:"
$LabelGeneralSF = New-Object System.Windows.Forms.Label
$LabelGeneralSF.Location = New-Object System.Drawing.Size(18,30)
$LabelGeneralSF.Size = New-Object System.Drawing.Size(420,30)
$LabelGeneralSF.Text = "Select the proper setup files for the Microsoft Deployment Toolkit and Windows Assessment Deployment Kit:"
$LabelGeneralOption = New-Object System.Windows.Forms.Label
$LabelGeneralOption.Location = New-Object System.Drawing.Size(18,220)
$LabelGeneralOption.Size = New-Object System.Drawing.Size(450,20)
$LabelGeneralOption.Text = "Select how the reference image creation mode will be configured:"

# TabControls
$MainTabControl = New-Object System.Windows.Forms.TabControl
$MainTabControl.Location = New-Object System.Drawing.Size(5,5)
$MainTabControl.Size = New-Object System.Drawing.Size(530,380)
$MainTabControl.Anchor = "Top, Bottom, Left, Right"
$MainTabControl.Name = "Global"
$MainTabControl.SelectedIndex = 0
$MainTabControl.BackColor = "Control"
$MainTabControl.Appearance = "Normal"

# TabPages
$TabPageSetup = New-Object System.Windows.Forms.TabPage
$TabPageSetup.Location = New-Object System.Drawing.Size(0,0)
$TabPageSetup.Size = New-Object System.Drawing.Size(530,600)
$TabPageSetup.Text = "General"
$TabPageSetup.Name = "General"
$TabPageSetup.BackColor = "White"
$TabPageMDT = New-Object System.Windows.Forms.TabPage
$TabPageMDT.Location = New-Object System.Drawing.Size(0,0)
$TabPageMDT.Size = New-Object System.Drawing.Size(530,600)
$TabPageMDT.Text = "MDT"
$TabPageMDT.Name = "MDT"
$TabPageMDT.BackColor = "White"
$TabPageWSUS = New-Object System.Windows.Forms.TabPage
$TabPageWSUS.Location = New-Object System.Drawing.Size(0,0)
$TabPageWSUS.Size = New-Object System.Drawing.Size(530,600)
$TabPageWSUS.Text = "WSUS"
$TabPageWSUS.Name = "WSUS"
$TabPageWSUS.BackColor = "White"
$TabPageApplications = New-Object System.Windows.Forms.TabPage
$TabPageApplications.Location = New-Object System.Drawing.Size(0,0)
$TabPageApplications.Size = New-Object System.Drawing.Size(530,600)
$TabPageApplications.Text = "Applications"
$TabPageApplications.Name = "Applications"
$TabPageApplications.BackColor = "White"
$TabPageOS = New-Object System.Windows.Forms.TabPage
$TabPageOS.Location = New-Object System.Drawing.Size(0,0)
$TabPageOS.Size = New-Object System.Drawing.Size(530,600)
$TabPageOS.Text = "Operating Systems"
$TabPageOS.Name = "Operating Systems"
$TabPageOS.BackColor = "White"

# Buttons
$ButtonValidate = New-Object System.Windows.Forms.Button
$ButtonValidate.Location = New-Object System.Drawing.Size(545,315) 
$ButtonValidate.Size = New-Object System.Drawing.Size(120,30) 
$ButtonValidate.Text = "Validate"
$ButtonValidate.Enabled = $true
$ButtonValidate.Add_MouseClick({Validate-Installation})
$ButtonStart = New-Object System.Windows.Forms.Button
$ButtonStart.Location = New-Object System.Drawing.Size(545,355) 
$ButtonStart.Size = New-Object System.Drawing.Size(120,30) 
$ButtonStart.Text = "Start"
$ButtonStart.Enabled = $false
$ButtonStart.Add_MouseClick({Start-Installation})
$ButtonSFMDTBrowse = New-Object System.Windows.Forms.Button
$ButtonSFMDTBrowse.Location = New-Object System.Drawing.Size(410,85) 
$ButtonSFMDTBrowse.Size = New-Object System.Drawing.Size(80,20) 
$ButtonSFMDTBrowse.Text = "Browse"
$ButtonSFMDTBrowse.Add_MouseClick({Get-SetupFilePath -Option MDT -Extension MSI})
$ButtonSFADKBrowse = New-Object System.Windows.Forms.Button
$ButtonSFADKBrowse.Location = New-Object System.Drawing.Size(410,145) 
$ButtonSFADKBrowse.Size = New-Object System.Drawing.Size(80,20) 
$ButtonSFADKBrowse.Text = "Browse"
$ButtonSFADKBrowse.Add_MouseClick({Get-SetupFilePath -Option ADK -Extension EXE})
$ButtonWSUSProducts = New-Object System.Windows.Forms.Button
$ButtonWSUSProducts.Location = New-Object System.Drawing.Size(166,225) 
$ButtonWSUSProducts.Size = New-Object System.Drawing.Size(80,20) 
$ButtonWSUSProducts.Text = "Add"
$ButtonWSUSProducts.Add_MouseClick({Add-WSUSProduct -Product $CMBWSUSProductSelection.SelectedItem -Method Add})
$ButtonWSUSLanguages = New-Object System.Windows.Forms.Button
$ButtonWSUSLanguages.Location = New-Object System.Drawing.Size(421,225) 
$ButtonWSUSLanguages.Size = New-Object System.Drawing.Size(80,20) 
$ButtonWSUSLanguages.Text = "Add"
$ButtonWSUSLanguages.Add_MouseClick({Add-WSUSLanguage -Language $CMBWSUSLanguageSelection.SelectedItem -Method Add})
$ButtonAppBrowse = New-Object System.Windows.Forms.Button
$ButtonAppBrowse.Location = New-Object System.Drawing.Size(400,70) 
$ButtonAppBrowse.Size = New-Object System.Drawing.Size(80,20) 
$ButtonAppBrowse.Text = "Browse"
$ButtonAppBrowse.Add_MouseClick({Get-CSVFile -Option App -Object $DGVApp})
$ButtonOSBrowse = New-Object System.Windows.Forms.Button
$ButtonOSBrowse.Location = New-Object System.Drawing.Size(400,70) 
$ButtonOSBrowse.Size = New-Object System.Drawing.Size(80,20) 
$ButtonOSBrowse.Text = "Browse"
$ButtonOSBrowse.Add_MouseClick({Get-CSVFile -Option OS -Object $DGVOS})
$ButtonSelect = New-Object System.Windows.Forms.Button
$ButtonSelect.Location = New-Object System.Drawing.Size(351,180) 
$ButtonSelect.Size = New-Object System.Drawing.Size(120,30) 
$ButtonSelect.Text = "Select"
$ButtonSelect.Enabled = $false
$ButtonSelect.Add_MouseClick({$FormOS.Close()})

# GroupBoxes
$GBOutputBox = New-Object System.Windows.Forms.GroupBox
$GBOutputBox.Location = New-Object System.Drawing.Size(5,390) 
$GBOutputBox.Size = New-Object System.Drawing.Size(673,280) 
$GBOutputBox.Text = "Logging"
$GBGeneralSF = New-Object System.Windows.Forms.GroupBox
$GBGeneralSF.Location = New-Object System.Drawing.Size(10,10) 
$GBGeneralSF.Size = New-Object System.Drawing.Size(500,180) 
$GBGeneralSF.Text = "Setup files"
$GBGeneralSF.BackColor = "White"
$GBGeneralOption = New-Object System.Windows.Forms.GroupBox
$GBGeneralOption.Location = New-Object System.Drawing.Size(10,200) 
$GBGeneralOption.Size = New-Object System.Drawing.Size(500,110) 
$GBGeneralOption.Text = "Reference Image creation mode"
$GBGeneralOption.BackColor = "White"
$GBGeneralOptionMode = New-Object System.Windows.Forms.GroupBox
$GBGeneralOptionMode.Location = New-Object System.Drawing.Size(20,240) 
$GBGeneralOptionMode.Size = New-Object System.Drawing.Size(160,55) 
$GBGeneralOptionMode.Text = "Mode"
$GBGeneralOptionMode.BackColor = "White"
$GBGeneralOptionOS = New-Object System.Windows.Forms.GroupBox
$GBGeneralOptionOS.Location = New-Object System.Drawing.Size(190,240) 
$GBGeneralOptionOS.Size = New-Object System.Drawing.Size(310,55) 
$GBGeneralOptionOS.Text = "Mandatory Operating System"
$GBGeneralOptionOS.BackColor = "White"
$GBSFMDT = New-Object System.Windows.Forms.GroupBox
$GBSFMDT.Location = New-Object System.Drawing.Size(20,65) 
$GBSFMDT.Size = New-Object System.Drawing.Size(480,50) 
$GBSFMDT.Text = "Setup file for Microsoft Deployment Toolkit 2013"
$GBSFMDT.BackColor = "White"
$GBSFADK = New-Object System.Windows.Forms.GroupBox
$GBSFADK.Location = New-Object System.Drawing.Size(20,125) 
$GBSFADK.Size = New-Object System.Drawing.Size(480,50) 
$GBSFADK.Text = "Setup file for Windows Assessment Deployment Kit"
$GBSFADK.BackColor = "White"
$GBMDTDS = New-Object System.Windows.Forms.GroupBox
$GBMDTDS.Location = New-Object System.Drawing.Size(10,10) 
$GBMDTDS.Size = New-Object System.Drawing.Size(500,110) 
$GBMDTDS.Text = "Deployment Share Configuration"
$GBMDTDS.BackColor = "White"
$GBMDTDSPath = New-Object System.Windows.Forms.GroupBox
$GBMDTDSPath.Location = New-Object System.Drawing.Size(20,30) 
$GBMDTDSPath.Size = New-Object System.Drawing.Size(235,80) 
$GBMDTDSPath.Text = "Deployment Share path"
$GBMDTDSPath.BackColor = "White"
$GBMDTDSName = New-Object System.Windows.Forms.GroupBox
$GBMDTDSName.Location = New-Object System.Drawing.Size(265,30) 
$GBMDTDSName.Size = New-Object System.Drawing.Size(235,80) 
$GBMDTDSName.Text = "Deployment Share name"
$GBMDTDSName.BackColor = "White"
$GBMDTBI = New-Object System.Windows.Forms.GroupBox
$GBMDTBI.Location = New-Object System.Drawing.Size(10,130) 
$GBMDTBI.Size = New-Object System.Drawing.Size(500,120) 
$GBMDTBI.Text = "Boot Image Configuration"
$GBMDTBI.BackColor = "White"
$GBMDTBIFeatures = New-Object System.Windows.Forms.GroupBox
$GBMDTBIFeatures.Location = New-Object System.Drawing.Size(20,150) 
$GBMDTBIFeatures.Size = New-Object System.Drawing.Size(235,90) 
$GBMDTBIFeatures.Text = "Features"
$GBMDTBIFeatures.BackColor = "White"
$GBMDTBIScratchSpace = New-Object System.Windows.Forms.GroupBox
$GBMDTBIScratchSpace.Location = New-Object System.Drawing.Size(265,150) 
$GBMDTBIScratchSpace.Size = New-Object System.Drawing.Size(235,90) 
$GBMDTBIScratchSpace.Text = "Scratch Space"
$GBMDTBIScratchSpace.BackColor = "White"
$GBWSUSProducts = New-Object System.Windows.Forms.GroupBox
$GBWSUSProducts.Location = New-Object System.Drawing.Size(10,10) 
$GBWSUSProducts.Size = New-Object System.Drawing.Size(245,245) 
$GBWSUSProducts.Text = "Products"
$GBWSUSProducts.BackColor = "White"
$GBWSUSLanguages = New-Object System.Windows.Forms.GroupBox
$GBWSUSLanguages.Location = New-Object System.Drawing.Size(265,10)
$GBWSUSLanguages.Size = New-Object System.Drawing.Size(245,245) 
$GBWSUSLanguages.Text = "Languages"
$GBWSUSLanguages.BackColor = "White"
$GBWSUSContentFolder = New-Object System.Windows.Forms.GroupBox
$GBWSUSContentFolder.Location = New-Object System.Drawing.Size(10,260) 
$GBWSUSContentFolder.Size = New-Object System.Drawing.Size(245,80) 
$GBWSUSContentFolder.Text = "Content Folder"
$GBWSUSContentFolder.BackColor = "White"
$GBWSUSUpdateClassification = New-Object System.Windows.Forms.GroupBox
$GBWSUSUpdateClassification.Location = New-Object System.Drawing.Size(265,260) 
$GBWSUSUpdateClassification.Size = New-Object System.Drawing.Size(245,80) 
$GBWSUSUpdateClassification.Text = "Update Classifications"
$GBWSUSUpdateClassification.BackColor = "White"
$GBMDTUP = New-Object System.Windows.Forms.GroupBox
$GBMDTUP.Location = New-Object System.Drawing.Size(10,255) 
$GBMDTUP.Size = New-Object System.Drawing.Size(500,85) 
$GBMDTUP.Text = "User Configuration"
$GBMDTUP.BackColor = "White"
$GBApp = New-Object System.Windows.Forms.GroupBox
$GBApp.Location = New-Object System.Drawing.Size(10,10) 
$GBApp.Size = New-Object System.Drawing.Size(500,330) 
$GBApp.Text = "Import Applications"
$GBApp.BackColor = "White"
$GBOS = New-Object System.Windows.Forms.GroupBox
$GBOS.Location = New-Object System.Drawing.Size(10,10) 
$GBOS.Size = New-Object System.Drawing.Size(500,330) 
$GBOS.Text = "Import Operating Systems"
$GBOS.BackColor = "White"

# DataGridViews
$DGVWSUSProducts = New-Object System.Windows.Forms.DataGridView
$DGVWSUSProducts.Location = New-Object System.Drawing.Size(20,70)
$DGVWSUSProducts.Size = New-Object System.Drawing.Size(225,120)
$DGVWSUSProducts.ColumnCount = 2
$DGVWSUSProducts.ColumnHeadersVisible = $true
$DGVWSUSProducts.Columns[0].Name = "Product"
$DGVWSUSProducts.Columns[0].Width = 160
$DGVWSUSProducts.Columns[1].Name = "ID"
$DGVWSUSProducts.Columns[1].Width = 62
$DGVWSUSProducts.AllowUserToAddRows = $false
$DGVWSUSProducts.AllowUserToDeleteRows = $false
$DGVWSUSProducts.ReadOnly = $true
$DGVWSUSProducts.MultiSelect = $false
$DGVWSUSProducts.RowHeadersVisible = $false
$DGVWSUSProducts.AllowUserToResizeRows = $false
$DGVWSUSProducts.ColumnHeadersHeightSizeMode = "DisableResizing"
$DGVWSUSLanguages = New-Object System.Windows.Forms.DataGridView
$DGVWSUSLanguages.Location = New-Object System.Drawing.Size(275,70)
$DGVWSUSLanguages.Size = New-Object System.Drawing.Size(225,120)
$DGVWSUSLanguages.ColumnCount = 2
$DGVWSUSLanguages.ColumnHeadersVisible = $true
$DGVWSUSLanguages.Columns[0].Name = "Language"
$DGVWSUSLanguages.Columns[0].Width = 160
$DGVWSUSLanguages.Columns[1].Name = "ID"
$DGVWSUSLanguages.Columns[1].Width = 62
$DGVWSUSLanguages.AllowUserToAddRows = $false
$DGVWSUSLanguages.AllowUserToDeleteRows = $false
$DGVWSUSLanguages.ReadOnly = $true
$DGVWSUSLanguages.MultiSelect = $false
$DGVWSUSLanguages.RowHeadersVisible = $false
$DGVWSUSLanguages.AllowUserToResizeRows = $false
$DGVWSUSLanguages.ColumnHeadersHeightSizeMode = "DisableResizing"
$DGVApp = New-Object System.Windows.Forms.DataGridView
$DGVApp.Location = New-Object System.Drawing.Size(20,105)
$DGVApp.Size = New-Object System.Drawing.Size(480,220)
$DGVApp.ColumnCount = 4
$DGVApp.ColumnHeadersVisible = $true
$DGVApp.Columns[0].Name = "Name"
$DGVApp.Columns[0].Width = 160
$DGVApp.Columns[1].Name = "CmdLine"
$DGVApp.Columns[1].Width = 180
$DGVApp.Columns[2].Name = "Short Name"
$DGVApp.Columns[2].Width = 120
$DGVApp.Columns[3].Name = "Source Path"
$DGVApp.Columns[3].Width = 160
$DGVApp.AllowUserToAddRows = $false
$DGVApp.AllowUserToDeleteRows = $false
$DGVApp.ReadOnly = $true
$DGVApp.MultiSelect = $false
$DGVApp.RowHeadersVisible = $false
$DGVApp.AllowUserToResizeRows = $false
$DGVApp.ColumnHeadersHeightSizeMode = "DisableResizing"
$DGVOS = New-Object System.Windows.Forms.DataGridView
$DGVOS.Location = New-Object System.Drawing.Size(20,105)
$DGVOS.Size = New-Object System.Drawing.Size(480,220)
$DGVOS.ColumnCount = 7
$DGVOS.ColumnHeadersVisible = $true
$DGVOS.Columns[0].Name = "Name"
$DGVOS.Columns[0].Width = 160
$DGVOS.Columns[1].Name = "ID"
$DGVOS.Columns[1].Width = 80
$DGVOS.Columns[2].Name = "Source Path"
$DGVOS.Columns[2].Width = 160
$DGVOS.Columns[3].Name = "Full Name"
$DGVOS.Columns[3].Width = 80
$DGVOS.Columns[4].Name = "Organization Name"
$DGVOS.Columns[4].Width = 140
$DGVOS.Columns[5].Name = "Home Page"
$DGVOS.Columns[5].Width = 100
$DGVOS.Columns[6].Name = "Admin Password"
$DGVOS.Columns[6].Width = 120
$DGVOS.AllowUserToAddRows = $false
$DGVOS.AllowUserToDeleteRows = $false
$DGVOS.ReadOnly = $true
$DGVOS.MultiSelect = $false
$DGVOS.RowHeadersVisible = $false
$DGVOS.AllowUserToResizeRows = $false
$DGVOS.ColumnHeadersHeightSizeMode = "DisableResizing"
$DGVOSSelection = New-Object System.Windows.Forms.DataGridView
$DGVOSSelection.Location = New-Object System.Drawing.Size(10,10)
$DGVOSSelection.Size = New-Object System.Drawing.Size(460,160)
$DGVOSSelection.ColumnCount = 1
$DGVOSSelection.ColumnHeadersVisible = $true
$DGVOSSelection.Columns[0].Name = "Operating Systems"
$DGVOSSelection.Columns[0].Width = "456"
$DGVOSSelection.AllowUserToAddRows = $false
$DGVOSSelection.AllowUserToDeleteRows = $false
$DGVOSSelection.ReadOnly = $true
$DGVOSSelection.MultiSelect = $false
$DGVOSSelection.RowHeadersVisible = $false
$DGVOSSelection.AllowUserToResizeRows = $false
$DGVOSSelection.ColumnHeadersHeightSizeMode = "DisableResizing"
$DGVOSSelection.Add_CellContentClick({
    $Global:OSSelectedObject = $DGVOSSelection.CurrentCell.Value
    $TBOSSelection.Text = $Global:OSSelectedObject
    if ($ButtonSelect.Enabled -eq $false) {
        $ButtonSelect.Enabled = $true
    }
})

# OpenFileDialogs
$OpenFileDialogEXE = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialogEXE.InitialDirectory = "C:\"
$OpenFileDialogEXE.Filter = "Executable (*.exe) |*.exe"
$OpenFileDialogMSI = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialogMSI.InitialDirectory = "C:\"
$OpenFileDialogMSI.Filter = "MSI files (*.msi) |*.msi"
$OpenFileDialogCSV = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialogCSV.InitialDirectory = "C:\"
$OpenFileDialogCSV.Filter = "Comma Seperated (*.CSV) |*.csv"

# Load Form
Load-Form