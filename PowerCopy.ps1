<#
Description:
Leverages the command-line utility Robocopy.
Includes the ability to copy file attributes along with the NTFS permissions,
to mirror the content of an entire folder hierarchy across local volumes or over a network
excluding certain file types, copying files above or below a certain age or size, monitoring the
source for changes, giving detailed report with an option to output both to console window and log file.

Features:
-supports spaces in the file name
-select and copy text from the content output box
-recommended options
-advanced options
-enable/disable file logging
-generates log file name (current date + source folder name)
-opens the current job logfile in text editor
-parses the current log file and shows only ERROR messages

1.0.1 Updates:
-save preferences function
-progressbar
-stop Robocopy function

Version: 1.0.1 - 1/22/2015
Author: Nikolay Petkov
Blog: http://power-shell.com/
Link: http://power-shell.com/2014/powershell-gui-tools/robocopy-gui-tool/

License Info:
Copyright (c) power-shell.com 2014.
Distributed under the MIT License (http://opensource.org/licenses/MIT)
#>
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  
$Form = New-Object System.Windows.Forms.Form
$Form.Size = New-Object System.Drawing.Size(850,510)
$Form.Text = "PowerCopy (v1.0.1)"
$Form.StartPosition = "CenterScreen" #loads the window in the center of the screen
$Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
#$Image = [system.drawing.image]::FromFile("\\\")
#$Form.BackgroundImage = $Image
#$Form.BackgroundImageLayout = "Zoom"
    # None, Tile, Center, Stretch, Zoom
$Form.MinimizeBox = $False
$Form.MaximizeBox = $False
$Form.WindowState = "Normal"
    # Maximized, Minimized, Normal
$Form.SizeGripStyle = "Hide"
    # Auto, Hide, Show
$Form.Icon = $Icon
#$Form.Opacity = 0.7
#$Font = New-Object System.Drawing.Font("Times New Roman",24,[System.Drawing.FontStyle]::Italic)
    # Font styles are: Regular, Bold, Italic, Underline, Strikeout
#$Form.Font = $Font
#$Form.BackColor = "#CCCCCC"


#Start Robocopy function
function robocopy {
begin {
#Recommended options
if ($checkboxNP.Checked) {$switchNP = "/NP"} else {$switchNP = $null} #No Progress - don't display percentage copied


#Copy options
if ($checkboxS.Checked) {$switchS = "/S"} else {$switchS = $null} #/S :: copy Subdirectories, but not empty ones
if ($checkboxE.Checked) {$switchE = "/E"} else {$switchE = $null} #/E :: copy subdirectories, including Empty ones. /E is including /S
if ($checkboxB.Checked) {$switchB = "/B"} else {$switchB = $null} #copy files in Backup mode
if ($checkboxSEC.Checked) {$switchSEC = "/SEC"} else {$switchSEC = $null} #/SEC :: copy files with SECurity (equivalent to /COPY:DATS)
if ($checkboxCOPYALL.Checked) {$switchCOPYALL = "/COPYALL"} else {$switchCOPYALL = $null} #COPY ALL file info (equivalent to /COPY:DATSOU)
if ($checkboxNOCOPY.Checked) {$switchNOCOPY = "/NOCOPY"} else {$switchNOCOPY = $null} #COPY NO file info (useful with /PURGE)
if ($checkboxSECFIX.Checked) {$switchSECFIX = "/SECFIX"} else {$switchSECFIX = $null} #FIX file SECurity on all files, even skipped files
if ($checkboxPURGE.Checked) {$switchPURGE = "/PURGE"} else {$switchPURGE = $null} #delete dest files/dirs that no longer exist in source
if ($checkboxMIR.Checked) {$switchMIR = "/MIR"} else {$switchMIR = $null} #MIRror a directory tree (equivalent to /E plus /PURGE)
if ($checkboxMOV.Checked) {$switchMOV = "/MOV"} else {$switchMOV = $null} #MOVe files (delete from source after copying)
if ($checkboxMOVE.Checked) {$switchMOVE = "/MOVE"} else {$switchMOVE = $null} #MOVE files AND dirs (delete from source after copying)
if ($checkboxMT.Checked) {$switchMT = "/MT"} else {$switchMT = $null} #Do multi-threaded copies with n threads (default 8)
if ($checkboxA.Checked) {$switchA = "/A"} else {$switchA = $null} #copy only files with the Archive attribute set
if ($checkboxM.Checked) {$switchM = "/M"} else {$switchM = $null} #copy only files with the Archive attribute and reset it
if ($checkboxXC.Checked) {$switchXC = "/XC"} else {$switchXC = $null} #eXclude Changed files
if ($checkboxXN.Checked) {$switchXN = "/XN"} else {$switchXN = $null} #eXclude Newer files
if ($checkboxXO.Checked) {$switchXO = "/XO"} else {$switchXO = $null} #eXclude Older files
if ($checkboxXX.Checked) {$switchXX = "/XX"} else {$switchXX = $null} #eXclude eXtra files and directories
if ($checkboxXL.Checked) {$switchXL = "/XL"} else {$switchXL = $null} #eXclude Lonely files and directories
if ($checkboxIS.Checked) {$switchIS = "/IS"} else {$switchIS = $null} #Include Same files
if ($checkboxIT.Checked) {$switchIT = "/IT"} else {$switchIT = $null} #Include Tweaked files
if ($checkboxXJ.Checked) {$switchXJ = "/XJ"} else {$switchXJ = $null} # eXclude Junction points. (normally included by default)
if ($checkboxXJD.Checked) {$switchXJD = "/XJD"} else {$switchXJD = $null} #eXclude Junction points for Directories
if ($checkboxXJF.Checked) {$switchXJF = "/XJF"} else {$switchXJF = $null} #eXclude Junction points for Files
if ($checkboxL.Checked) {$switchL = "/L"} else {$switchL = $null} #List only - don't copy, timestamp or delete any files
if ($checkboxX.Checked) {$switchX = "/X"} else {$switchX = $null} #report all eXtra files, not just those selected
if ($checkboxV.Checked) {$switchV = "/V"} else {$switchV = $null} #produce Verbose output, showing skipped files
if ($checkboxTS.Checked) {$switchTS = "/TS"} else {$switchTS = $null} #include source file Time Stamps in the output
if ($checkboxFP.Checked) {$switchFP = "/FP"} else {$switchFP = $null} #include Full Pathname of files in the output
if ($checkboxBYTES.Checked) {$switchBYTES = "/BYTES"} else {$switchBYTES = $null} #Print sizes as bytes
if ($checkboxR.Checked) {$switchR = "/R:3"} else {$switchR = $null} #number of Retries on failed copies: default 1 million
if ($checkboxW.Checked) {$switchW = "/W:1"} else {$switchW = $null} #Wait time between retries: default is 30 seconds

#Additional options
if ($InputAdvancedOptions.Text) {$switchAddition = $InputAdvancedOptions.Text.split(' ')} else {$switchAddition = $null}

#Log File Function
if (($checkboxLog.Checked -and $InputLogFile.Text))
{
if(!(Test-Path -Path $InputLogFile.Text)){
$checkpath ="`nError: The logfile path " + """" + $InputLogFile.Text + """" + " doesn't exist!`n"
}
$logfile = $InputLogFile.Text + "\" + ((Get-Date).ToString('yyyy-MM-dd')) + "_" + $InputSource.Text.Split('\')[-1].Replace(" ","_") + ".txt"
$switchlogfile = "/TEE", "/LOG+:$logfile"
}
else {$switchlogfile = $null}
if (!($logfile)) {$checklog = "  Log File : The logging is not enabled."
}
$outputBox.text = $checklog, $checkpath}
process {
#count the source files
$outputBox.text = " Preparing to Robocopy. Please wait..."
if ($InputSource.Text -notlike $null) {
$sourcefiles=robocopy.exe $InputSource.Text $InputSource.Text /L /S /NJH /BYTES /FP /NC /NDL /TS /XJ /R:0 /W:0
If ($sourcefiles[-5] -match '^\s{3}Files\s:\s+(?<Count>\d+).*') {$filecount=$matches.Count}
}
$outputBox.Focus()
$run = robocopy.exe $InputSource.Text $InputTarget.Text $switchNP $switchR $switchW $switchS $switchE $switchB $switchSEC $switchCOPYALL $switchNOCOPY `
$switchSECFIX $switchPURGE $switchMIR $switchMOV $switchMOVE $switchMT $switchA $switchM $switchXC $switchXN $switchXO $switchXX `
$switchXL $switchIS $switchIT $switchXJ $switchXJD $switchXJF $switchL $switchX $switchV $switchTS $switchFP $switchBYTES $switchAddition $switchLogfile | foreach {
$ErrorActionPreference = "silentlycontinue"
#calculate percentage
$i++
[int]$pct = ($i/$filecount)*100
#update the progress bar
$progressbar.Value = ($pct)
$outputBox.AppendText($_ + "`r`n")
[void] [System.Windows.Forms.Application]::DoEvents()
}
}
end {$progressbar.Value = 100}
} #end robocopy function
               
#Robocopy Help function
function robocopyhelp {
$help = robocopy.exe /?
$outputBox.text = $help |Out-String
}
#Open log function
function openlog {
$logfile = $InputLogFile.Text + "\" + ((Get-Date).ToString('yyyy-MM-dd')) + "_" + $InputSource.Text.Split('\')[-1].Replace(" ","_") + ".txt"
if(!(Test-Path $logfile)){$outputBox.text = "There is no logfile for the current job."}
else
{$openlog = notepad.exe $logfile}
}
#Show Errors function
function showerrors {
$logfile = $InputLogFile.Text + "\" + ((Get-Date).ToString('yyyy-MM-dd')) + "_" + $InputSource.Text.Split('\')[-1].Replace(" ","_") + ".txt"
if
(!(Test-Path $logfile)) {$outputBox.text = "There is no logfile for the current job."}
else
{$logcontent = Get-Content $logfile
if ($errors = $logcontent | Select-String -Pattern "ERROR " -Context 0,1 |Out-String) {$outputBox.text = $errors}
else {$outputBox.text = "No errors found."}
}
}
#Stop Robocopy function
function stoprobocopy {
if (get-process -Name robocopy -ErrorAction SilentlyContinue) {Stop-Process -Name robocopy -Force
$timestamp = (Get-Date).ToString('yyyy/MM/dd hh:mm:ss')
$outputBox.AppendText("`n`r$timestamp Robocopy process has been terminated.")}
if ($logfile) {
Add-Content $logfile "`n`r$timestamp ERROR Robocopy process has been terminated."}
} #end stop Robocopy function

#Save Options function
$Scriptpath = $myInvocation.InvocationName
Function saveoptions {
try {
$saveadvanced = """" + $InputAdvancedOptions.Text.ToString() + """"
$savelogpath = """" + $InputLogFile.Text.ToString() + """"
$noerror = $true
(Get-Content $Scriptpath) | ForEach-Object {
if ($_ | Select-String '^.checkboxS.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxS.Checked}
elseif ($_ | Select-String '^.checkboxE.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxE.Checked}
elseif ($_ | Select-String '^.checkboxB.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxB.Checked}
elseif ($_ | Select-String '^.checkboxSEC.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxSEC.Checked}
elseif ($_ | Select-String '^.checkboxCOPYALL.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxCOPYALL.Checked}
elseif ($_ | Select-String '^.checkboxNOCOPY.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxNOCOPY.Checked}
elseif ($_ | Select-String '^.checkboxSECFIX.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxSECFIX.Checked}
elseif ($_ | Select-String '^.checkboxPURGE.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxPURGE.Checked}
elseif ($_ | Select-String '^.checkboxMIR.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxMIR.Checked}
elseif ($_ | Select-String '^.checkboxMOV.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxMOV.Checked}
elseif ($_ | Select-String '^.checkboxMOVE.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxMOVE.Checked}
elseif ($_ | Select-String '^.checkboxMT.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxMT.Checked}
elseif ($_ | Select-String '^.checkboxA.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxA.Checked}
elseif ($_ | Select-String '^.checkboxM.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxM.Checked}
elseif ($_ | Select-String '^.checkboxXC.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxXC.Checked}
elseif ($_ | Select-String '^.checkboxXN.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxXN.Checked}
elseif ($_ | Select-String '^.checkboxXO.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxXO.Checked}
elseif ($_ | Select-String '^.checkboxXX.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxXX.Checked}
elseif ($_ | Select-String '^.checkboxXL.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxXL.Checked}
elseif ($_ | Select-String '^.checkboxIS.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxIS.Checked}
elseif ($_ | Select-String '^.checkboxIT.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxIT.Checked}
elseif ($_ | Select-String '^.checkboxXJ.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxXJ.Checked}
elseif ($_ | Select-String '^.checkboxXJD.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxXJD.Checked}
elseif ($_ | Select-String '^.checkboxXJF.Checked') {$_ -replace ($_ -split "=")[1].substring(1), $checkboxXJF.Checked}
elseif ($_ | Select-String '^.InputAdvancedOptions.Text') {$_.Replace($_.Split("=")[1], $saveadvanced)}
elseif ($_ | Select-String '^.InputLogFile.Text') {$_.Replace($_.Split("=")[1], $savelogpath)}
else {$_}


} | Set-Content $Scriptpath -erroraction stop
} catch {
[System.Windows.Forms.MessageBox]::Show("An error occurred while saving your preferences.","Save Preferences", "Ok", "Error")
$noerror = $false
        }
if ($noerror) {
[System.Windows.Forms.MessageBox]::Show("Your preferences have been saved.","Save Preferences", "Ok", "Information")
              }
}#end Save Options function

#checkbox group boxes

#copy options group box
$copyGroupBox = New-Object System.Windows.Forms.GroupBox
$copyGroupBox.Location = New-Object System.Drawing.Size(210,15) 
$copyGroupBox.size = New-Object System.Drawing.Size(220,110) 
$copyGroupBox.text = "Copy Options" 
$Form.Controls.Add($copyGroupBox)

#file selection options group box
$FileSelectionGroupBox = New-Object System.Windows.Forms.GroupBox
$FileSelectionGroupBox.Location = New-Object System.Drawing.Size(440,15) 
$FileSelectionGroupBox.size = New-Object System.Drawing.Size(185,110) 
$FileSelectionGroupBox.text = "File Selection Options" 
$Form.Controls.Add($FileSelectionGroupBox)

#recommended options group box
$RecommendedGroupBox = New-Object System.Windows.Forms.GroupBox
$RecommendedGroupBox.Location = New-Object System.Drawing.Size(640,15)
$RecommendedGroupBox.size = New-Object System.Drawing.Size(190,50)
$RecommendedGroupBox.text = "Recommended Options" 
$Form.Controls.Add($RecommendedGroupBox)

#advanced options groupBox
$AdvancedGroupBox = New-Object System.Windows.Forms.GroupBox
$AdvancedGroupBox.Location = New-Object System.Drawing.Size(640,75)
$AdvancedGroupBox.Size = New-Object System.Drawing.Size(190,50)
$AdvancedGroupBox.Text = "Advanced Options:" 
$Form.Controls.Add($AdvancedGroupBox)

#advanced options input
$InputAdvancedOptions = New-Object System.Windows.Forms.TextBox
$InputAdvancedOptions.Text=""
$InputAdvancedOptions.Location = New-Object System.Drawing.Size(10,20) 
$InputAdvancedOptions.Size = New-Object System.Drawing.Size(170,30) 
$AdvancedGroupBox.Controls.Add($InputAdvancedOptions)

#log file path groupbox
$LogFileGroupbox = New-Object System.Windows.Forms.GroupBox
$LogFileGroupbox.Text="Logfile Path"
$LogFileGroupbox.Location = New-Object System.Drawing.Size(640,170) 
$LogFileGroupbox.Size = New-Object System.Drawing.Size(190,50) 
$Form.Controls.Add($LogFileGroupbox)

#log file path input
$InputLogFile = New-Object System.Windows.Forms.TextBox
$InputLogFile.Text="c:\logs"
$InputLogFile.Location = New-Object System.Drawing.Size(10,20) 
$InputLogFile.Size = New-Object System.Drawing.Size(170,30) 
$LogFileGroupbox.Controls.Add($InputLogFile)

#logging options group box
$LoggingGroupBox = New-Object System.Windows.Forms.GroupBox
$LoggingGroupBox.Location = New-Object System.Drawing.Size(640,230)
$LoggingGroupBox.size = New-Object System.Drawing.Size(190,70)
$LoggingGroupBox.text = "Logging Options" 
$Form.Controls.Add($LoggingGroupBox)
#end group boxes

#check boxes

#Robocopy options check boxes

#start copy options
$checkboxS = New-Object System.Windows.Forms.checkbox
$checkboxS.Location = New-Object System.Drawing.Size(10,20)
$checkboxS.Size = New-Object System.Drawing.Size(50,20)
$checkboxS.Checked=$False
$checkboxS.Text = "/S"
$copyGroupBox.Controls.Add($checkboxS)

$checkboxE = New-Object System.Windows.Forms.checkbox
$checkboxE.Location = New-Object System.Drawing.Size(10,40)
$checkboxE.Size = New-Object System.Drawing.Size(50,20)
$checkboxE.Checked=$False
$checkboxE.Text = "/E"
$copyGroupBox.Controls.Add($checkboxE)

$checkboxB = New-Object System.Windows.Forms.checkbox
$checkboxB.Location = New-Object System.Drawing.Size(10,60)
$checkboxB.Size = New-Object System.Drawing.Size(50,20)
$checkboxB.Checked=$False
$checkboxB.Text = "/B"
$copyGroupBox.Controls.Add($checkboxB)

$checkboxSEC = New-Object System.Windows.Forms.checkbox
$checkboxSEC.Location = New-Object System.Drawing.Size(10,80)
$checkboxSEC.Size = New-Object System.Drawing.Size(50,20)
$checkboxSEC.Checked=$False
$checkboxSEC.Text = "/SEC"
$copyGroupBox.Controls.Add($checkboxSEC)

#COPY ALL file info (equivalent to /COPY:DATSOU)
$checkboxCOPYALL = New-Object System.Windows.Forms.checkbox
$checkboxCOPYALL.Location = New-Object System.Drawing.Size(70,20)
$checkboxCOPYALL.Size = New-Object System.Drawing.Size(80,20)
$checkboxCOPYALL.Checked=$False
$checkboxCOPYALL.Text = "/COPYALL"
$copyGroupBox.Controls.Add($checkboxCOPYALL)

#COPY NO file info (useful with /PURGE)
$checkboxNOCOPY = New-Object System.Windows.Forms.checkbox
$checkboxNOCOPY.Location = New-Object System.Drawing.Size(70,40)
$checkboxNOCOPY.Size = New-Object System.Drawing.Size(80,20)
$checkboxNOCOPY.Checked=$False
$checkboxNOCOPY.Text = "/NOCOPY"
$copyGroupBox.Controls.Add($checkboxNOCOPY)

#FIX file SECurity on all files, even skipped files
$checkboxSECFIX = New-Object System.Windows.Forms.checkbox
$checkboxSECFIX.Location = New-Object System.Drawing.Size(70,60)
$checkboxSECFIX.Size = New-Object System.Drawing.Size(80,20)
$checkboxSECFIX.Checked=$False
$checkboxSECFIX.Text = "/SECFIX"
$copyGroupBox.Controls.Add($checkboxSECFIX)

#delete dest files/dirs that no longer exist in source
$checkboxPURGE = New-Object System.Windows.Forms.checkbox
$checkboxPURGE.Location = New-Object System.Drawing.Size(70,80)
$checkboxPURGE.Size = New-Object System.Drawing.Size(80,20)
$checkboxPURGE.Checked=$False
$checkboxPURGE.Text = "/PURGE"
$copyGroupBox.Controls.Add($checkboxPURGE)

#MIRror a directory tree (equivalent to /E plus /PURGE)
$checkboxMIR = New-Object System.Windows.Forms.checkbox
$checkboxMIR.Location = New-Object System.Drawing.Size(157,20)
$checkboxMIR.Size = New-Object System.Drawing.Size(60,20)
$checkboxMIR.Checked=$False
$checkboxMIR.Text = "/MIR"
$copyGroupBox.Controls.Add($checkboxMIR)

#MOVE files (delete from source after copying)
$checkboxMOV = New-Object System.Windows.Forms.checkbox
$checkboxMOV.Location = New-Object System.Drawing.Size(157,40)
$checkboxMOV.Size = New-Object System.Drawing.Size(60,20)
$checkboxMOV.Checked=$False
$checkboxMOV.Text = "/MOV"
$copyGroupBox.Controls.Add($checkboxMOV)

#MOVE files AND dirs (delete from source after copying)
$checkboxMOVE = New-Object System.Windows.Forms.checkbox
$checkboxMOVE.Location = New-Object System.Drawing.Size(157,60)
$checkboxMOVE.Size = New-Object System.Drawing.Size(60,20)
$checkboxMOVE.Checked=$False
$checkboxMOVE.Text = "/MOVE"
$copyGroupBox.Controls.Add($checkboxMOVE)

#Do multi-threaded copies with n threads (default 8)
$checkboxMT = New-Object System.Windows.Forms.checkbox
$checkboxMT.Location = New-Object System.Drawing.Size(157,80)
$checkboxMT.Size = New-Object System.Drawing.Size(60,20)
$checkboxMT.Checked=$False
$checkboxMT.Text = "/MT:8"
$copyGroupBox.Controls.Add($checkboxMT)

#end copy options

#start file selection options check boxes

#copy only files with the Archive attribute set
$checkboxA = New-Object System.Windows.Forms.checkbox
$checkboxA.Location = New-Object System.Drawing.Size(10,20)
$checkboxA.Size = New-Object System.Drawing.Size(50,20)
$checkboxA.Checked=$False
$checkboxA.Text = "/A"
$FileSelectionGroupBox.Controls.Add($checkboxA)

#copy only files with the Archive attribute and reset it
$checkboxM = New-Object System.Windows.Forms.checkbox
$checkboxM.Location = New-Object System.Drawing.Size(10,40)
$checkboxM.Size = New-Object System.Drawing.Size(50,20)
$checkboxM.Checked=$False
$checkboxM.Text = "/M"
$FileSelectionGroupBox.Controls.Add($checkboxM)

#eXclude changed files
$checkboxXC = New-Object System.Windows.Forms.checkbox
$checkboxXC.Location = New-Object System.Drawing.Size(10,60)
$checkboxXC.Size = New-Object System.Drawing.Size(50,20)
$checkboxXC.Checked=$False
$checkboxXC.Text = "/XC"
$FileSelectionGroupBox.Controls.Add($checkboxXC)

#eXclude Newer files
$checkboxXN = New-Object System.Windows.Forms.checkbox
$checkboxXN.Location = New-Object System.Drawing.Size(10,80)
$checkboxXN.Size = New-Object System.Drawing.Size(50,20)
$checkboxXN.Checked=$False
$checkboxXN.Text = "/XN"
$FileSelectionGroupBox.Controls.Add($checkboxXN)

#eXclude Older files
$checkboxXO = New-Object System.Windows.Forms.checkbox
$checkboxXO.Location = New-Object System.Drawing.Size(70,20)
$checkboxXO.Size = New-Object System.Drawing.Size(50,20)
$checkboxXO.Checked=$False
$checkboxXO.Text = "/XO"
$FileSelectionGroupBox.Controls.Add($checkboxXO)

#eXclude eXtra files and directories
$checkboxXX = New-Object System.Windows.Forms.checkbox
$checkboxXX.Location = New-Object System.Drawing.Size(70,40)
$checkboxXX.Size = New-Object System.Drawing.Size(50,20)
$checkboxXX.Checked=$False
$checkboxXX.Text = "/XX"
$FileSelectionGroupBox.Controls.Add($checkboxXX)

#eXclude Lonely files and directories
$checkboxXL = New-Object System.Windows.Forms.checkbox
$checkboxXL.Location = New-Object System.Drawing.Size(70,60)
$checkboxXL.Size = New-Object System.Drawing.Size(50,20)
$checkboxXL.Checked=$False
$checkboxXL.Text = "/XL"
$FileSelectionGroupBox.Controls.Add($checkboxXL)

#Include Same files
$checkboxIS = New-Object System.Windows.Forms.checkbox
$checkboxIS.Location = New-Object System.Drawing.Size(70,80)
$checkboxIS.Size = New-Object System.Drawing.Size(50,20)
$checkboxIS.Checked=$False
$checkboxIS.Text = "/IS"
$FileSelectionGroupBox.Controls.Add($checkboxIS)

#Include Tweaked files
$checkboxIT = New-Object System.Windows.Forms.checkbox
$checkboxIT.Location = New-Object System.Drawing.Size(130,20)
$checkboxIT.Size = New-Object System.Drawing.Size(50,20)
$checkboxIT.Checked=$False
$checkboxIT.Text = "/IT"
$FileSelectionGroupBox.Controls.Add($checkboxIT)

#eXclude Junction points
$checkboxXJ = New-Object System.Windows.Forms.checkbox
$checkboxXJ.Location = New-Object System.Drawing.Size(130,40)
$checkboxXJ.Size = New-Object System.Drawing.Size(50,20)
$checkboxXJ.Checked=$False
$checkboxXJ.Text = "/XJ"
$FileSelectionGroupBox.Controls.Add($checkboxXJ)

#eXclude Junction points for Directories
$checkboxXJD = New-Object System.Windows.Forms.checkbox
$checkboxXJD.Location = New-Object System.Drawing.Size(130,60)
$checkboxXJD.Size = New-Object System.Drawing.Size(50,20)
$checkboxXJD.Checked=$False
$checkboxXJD.Text = "/XJD"
$FileSelectionGroupBox.Controls.Add($checkboxXJD)

#eXclude Junction points for Files
$checkboxXJF = New-Object System.Windows.Forms.checkbox
$checkboxXJF.Location = New-Object System.Drawing.Size(130,80)
$checkboxXJF.Size = New-Object System.Drawing.Size(50,20)
$checkboxXJF.Checked=$False
$checkboxXJF.Text = "/XJF"
$FileSelectionGroupBox.Controls.Add($checkboxXJF)

#end Robocopy file selection options

#start logging options

#Enable Logging checkbox
$checkboxLog = New-Object System.Windows.Forms.checkbox
$checkboxLog.Location = New-Object System.Drawing.Size(640,140)
$checkboxLog.Size = New-Object System.Drawing.Size(110,20)
$checkboxLog.Checked=$True
$checkboxLog.Text = "Enable Logging"
$Form.Controls.Add($checkboxLog)

#List only - don't copy, timestamp or delete any files
$checkboxL = New-Object System.Windows.Forms.checkbox
$checkboxL.Location = New-Object System.Drawing.Size(10,20)
$checkboxL.Size = New-Object System.Drawing.Size(50,20)
$checkboxL.Checked=$False
$checkboxL.Text = "/L"
$LoggingGroupBox.Controls.Add($checkboxL)

#report all eXtra files, not just those selected
$checkboxX = New-Object System.Windows.Forms.checkbox
$checkboxX.Location = New-Object System.Drawing.Size(10,40)
$checkboxX.Size = New-Object System.Drawing.Size(50,20)
$checkboxX.Checked=$False
$checkboxX.Text = "/X"
$LoggingGroupBox.Controls.Add($checkboxX)

#produce Verbose output, showing skipped files
$checkboxV = New-Object System.Windows.Forms.checkbox
$checkboxV.Location = New-Object System.Drawing.Size(70,20)
$checkboxV.Size = New-Object System.Drawing.Size(50,20)
$checkboxV.Checked=$False
$checkboxV.Text = "/V"
$LoggingGroupBox.Controls.Add($checkboxV)

#include source file Time Stamps in the output
$checkboxTS = New-Object System.Windows.Forms.checkbox
$checkboxTS.Location = New-Object System.Drawing.Size(70,40)
$checkboxTS.Size = New-Object System.Drawing.Size(50,20)
$checkboxTS.Checked=$False
$checkboxTS.Text = "/TS"
$LoggingGroupBox.Controls.Add($checkboxTS)

#include Full Pathname of files in the output
$checkboxFP = New-Object System.Windows.Forms.checkbox
$checkboxFP.Location = New-Object System.Drawing.Size(125,20)
$checkboxFP.Size = New-Object System.Drawing.Size(50,20)
$checkboxFP.Checked=$False
$checkboxFP.Text = "/FP"
$LoggingGroupBox.Controls.Add($checkboxFP)

#Print sizes as bytes
$checkboxBYTES = New-Object System.Windows.Forms.checkbox
$checkboxBYTES.Location = New-Object System.Drawing.Size(125,40)
$checkboxBYTES.Size = New-Object System.Drawing.Size(63,20)
$checkboxBYTES.Checked=$False
$checkboxBYTES.Text = "/BYTES"
$LoggingGroupBox.Controls.Add($checkboxBYTES)

#end logging options

#start recommended options
#No Progress - don't display percentage copied
$checkboxNP = New-Object System.Windows.Forms.checkbox
$checkboxNP.Location = New-Object System.Drawing.Size(10,20)
$checkboxNP.Size = New-Object System.Drawing.Size(50,20)
$checkboxNP.Checked=$True
$checkboxNP.Text = "/NP"
$RecommendedGroupBox.Controls.Add($checkboxNP)

#start recommended options

#number of Retries on failed copies: default 1 million
$checkboxR = New-Object System.Windows.Forms.checkbox
$checkboxR.Location = New-Object System.Drawing.Size(70,20)
$checkboxR.Size = New-Object System.Drawing.Size(50,20)
$checkboxR.Checked=$True
$checkboxR.Text = "/R:3"
$RecommendedGroupBox.Controls.Add($checkboxR)

#number of Retries on failed copies: default 1 million
$checkboxW = New-Object System.Windows.Forms.checkbox
$checkboxW.Location = New-Object System.Drawing.Size(130,20)
$checkboxW.Size = New-Object System.Drawing.Size(55,20)
$checkboxW.Checked=$True
$checkboxW.Text = "/W:1"
$RecommendedGroupBox.Controls.Add($checkboxW)

#end recommended options

#Text fields

#Source path label
$InputSourceLabel = New-Object System.Windows.Forms.Label
$InputSourceLabel.Text="Source Path:"
$InputSourceLabel.Location = New-Object System.Drawing.Size(15,15) 
$InputSourceLabel.Size = New-Object System.Drawing.Size(170,15) 
$Form.Controls.Add($InputSourceLabel)

#Source path input
$InputSource = New-Object System.Windows.Forms.TextBox
$InputSource.Text=""
$InputSource.Location = New-Object System.Drawing.Size(15,30) 
$InputSource.Size = New-Object System.Drawing.Size(180,20) 
$Form.Controls.Add($InputSource)

#Target path label
$InputTargetLabel = New-Object System.Windows.Forms.Label
$InputTargetLabel.Text="Destination Path:"
$InputTargetLabel.Location = New-Object System.Drawing.Size(15,55) 
$InputTargetLabel.Size = New-Object System.Drawing.Size(170,15) 
$Form.Controls.Add($InputTargetLabel)

#Target path input
$InputTarget = New-Object System.Windows.Forms.TextBox
$InputTarget.Text=""
$InputTarget.Location = New-Object System.Drawing.Size(15,70) 
$InputTarget.Size = New-Object System.Drawing.Size(180,30) 
$Form.Controls.Add($InputTarget)

#Output box
$outputBox = New-Object System.Windows.Forms.RichTextBox 
$outputBox.Location = New-Object System.Drawing.Size(15,150) 
$outputBox.Size = New-Object System.Drawing.Size(610,290)
$outputBox.MultiLine = $True
#$outputBox.WordWrap = $False
$outputBox.ScrollBars = "Both"
$outputBox.Font = "Courier New"
$Form.Controls.Add($outputBox)

########### HomePage URL Label
$URLLabel = New-Object System.Windows.Forms.LinkLabel 
$URLLabel.Location = New-Object System.Drawing.Size(735,455) 
$URLLabel.Size = New-Object System.Drawing.Size(200,30)
$URLLabel.LinkColor = "#000000" 
$URLLabel.ActiveLinkColor = "Blue"
$URLLabel.Text = "Check for updates" 
$URLLabel.add_Click({[system.Diagnostics.Process]::start("http:\\power-shell.com")}) 
$Form.Controls.Add($URLLabel) 

#end text fields

#Start buttons

#Button Start Robocopy
$ButtonStart = New-Object System.Windows.Forms.Button 
$ButtonStart.Location = New-Object System.Drawing.Size(640,360) 
$ButtonStart.Size = New-Object System.Drawing.Size(190,80) 
$ButtonStart.Text = "START ROBOCOPY" 
$ButtonStart.Add_Click({robocopy})
$Form.Controls.Add($ButtonStart) 

#Button Show Robocopy Help
$ButtonHelp = New-Object System.Windows.Forms.Button 
$ButtonHelp.Location = New-Object System.Drawing.Size(15,100) 
$ButtonHelp.Size = New-Object System.Drawing.Size(180,25) 
$ButtonHelp.Text = "Show Robocopy Help" 
$ButtonHelp.Add_Click({robocopyhelp})
$Form.Controls.Add($ButtonHelp)

#Button Save Robocopy Options
$ButtonSave = New-Object System.Windows.Forms.Button 
$ButtonSave.Location = New-Object System.Drawing.Size(640,310) 
$ButtonSave.Size = New-Object System.Drawing.Size(190,30) 
$ButtonSave.Text = "Save Options" 
$ButtonSave.Add_Click({saveoptions})
$Form.Controls.Add($ButtonSave) 

#Button Open Log
$ButtonOpenLog = New-Object System.Windows.Forms.Button 
$ButtonOpenLog.Location = New-Object System.Drawing.Size(15,450) 
$ButtonOpenLog.Size = New-Object System.Drawing.Size(110,25) 
$ButtonOpenLog.Text = "Open Logfile" 
$ButtonOpenLog.Add_Click({openlog})
$Form.Controls.Add($ButtonOpenLog)

#Button Show Errors
$ButtonErrors = New-Object System.Windows.Forms.Button 
$ButtonErrors.Location = New-Object System.Drawing.Size(140,450) 
$ButtonErrors.Size = New-Object System.Drawing.Size(110,25) 
$ButtonErrors.Text = "Show Errors" 
$ButtonErrors.Add_Click({showerrors})
$Form.Controls.Add($ButtonErrors)

#Button Stop Robocopy
$ButtonStop = New-Object System.Windows.Forms.Button 
$ButtonStop.Location = New-Object System.Drawing.Size(515,450) 
$ButtonStop.Size = New-Object System.Drawing.Size(110,25) 
$ButtonStop.Text = "Stop Robocopy" 
$ButtonStop.Add_Click({stoprobocopy})
$Form.Controls.Add($ButtonStop)

#end buttons

#start progres bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Name = 'ProgressBar'
$progressBar.Value = 0
$progressBar.Style="Continuous"
$progressBar.Location = New-Object System.Drawing.Size(270,450) 
$progressBar.Size = New-Object System.Drawing.Size(225,25)
#initialize a counter
$i=0
$Form.Controls.Add($progressBar)

$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()