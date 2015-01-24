#
# Windows PowerShell in Action Second Edition
#
# Chapter 18 Using COM
#


# This script defines two different functions for
# showing the COM ProgIDs that are available on the
# system.
#
function global:Get-ProgID1 {
    param ($filter = '.')

    $ClsIdPath = "REGISTRY::HKey_Classes_Root\clsid"
    dir -recurse $ClsIdPath |
        % {if ($_.name -match '\\ProgID$') { $_.GetValue("") }} |
        ? {$_ -match $filter}
}

function global:Get-ProgID2 {
    param ($filter = '.')

    Get-WMIObject Win32_ProgIDSpecification |
        select-object ProgID,Description |
        ? {$_.ProgId -match $filter}
}


# PowerShell Simple script to release a COM object.
#
# This script illustrates how to explicitly release a COM object.
# Although the memory manager will eventually release
# the object for you when it is garbage-collected, that
# may not happen for some significant amount of time.
# By calling this script on the object, the underlying COM
# object will be released immediately and it's resources
# will be freed.

param ($objectToRelease)
[void][System.Runtime.Interopservices.Marshal]::ReleaseComObject(
    $objectToRelease)

#########################################################################################################

# This file contains examples showing how to work with the task
# schedule using its COM interfaces

# Get the scheduler service object...
$ts = New-Object -ComObject Schedule.Service
$ts | Get-Member
$ts.Connect()
$ts.GetRunningTasks(0)

# create a new task
$nt = $ts.NewTask(0)
$ri = $nt.RegistrationInfo
$ri.Description = "Start the calculator in 5 minutes"
$ri.Author = "Bruce Payette"

# Set the logon type to interactive logon
$principal = $nt.Principal
$principal.LogonType = 3

# $settings = $nt.Settings
# $settings.DeleteExpiredTaskAfter = $true

# time trigger is 1
$trigger = $nt.Triggers.Create(1)

function XmlTime ([datetime] $d)
{
  $d.ToUniversalTime().ToString("u") -replace " ","T"
}

$trigger.StartBoundary = XmlTime ((Get-Date).AddSeconds(30))
$trigger.EndBoundary = XmlTime ((Get-Date).AddMinutes(5))
$trigger.ExecutionTimeLimit = "PT1M"    # Five minutes
$trigger.Id = "Trigger in 30 seconds"
$trigger.Enabled = $true

# define the action to perform: start the calculator
$action = $nt.Actions.Create(0)
$action.Path =  @(Get-Command calc)[0].Definition

# root folder that holds registered tasks
$tsFolder = $ts.GetFolder("\")

# get the credentials for the job
$cred = Get-Credential

$tsFolder.RegisterTaskDefinition(
  "PowerShellTimeTriggerTest", $nt, 6,
    $cred.UserName,
      $cred.GetNetworkCredential().PassWord, 3)

############################################################################################

# Demonstrate using COM to call VBScript from PowerShell
#

function Call-VBScript
{
    $sc = New-Object -ComObject ScriptControl
    $sc.Language = 'VBScript'
    $sc.AddCode('
	Function GetLength(ByVal s)
	    GetLength = Len(s)
	End Function
	Function Add(ByVal x, ByVal y)
	    Add = x + y
	End Function
    ')
    $sc.CodeObject
}

$vb = Call-VBScript
"Length of 'abcd' is " + $vb.getlength("abcd")
"2 + 5 is $($vb.add(2,5))"


#############################################################################################

# Script to build a GUI for browsing windows.
#

Add-Type -Assembly PresentationCore,PresentationFrameWork

trap { break }

$mode = [System.Threading.Thread]::CurrentThread.ApartmentState
if ($mode -ne "STA")
{
    throw "This script can only be run when powershell is started with -sta"
}

function Add-ScriptRoot ($file)
{
  $caller = Get-Variable -Value -Scope 1 MyInvocation
  $caller.MyCommand.Definition |
    Split-Path -Parent |
      Join-Path -Resolve -ChildPath $file
}

$xamlPath = Add-ScriptRoot browserWindowList.xaml
$stream = [System.IO.StreamReader] $xamlPath
$form = [System.Windows.Markup.XamlReader]::Load(
      $stream.BaseStream)
$stream.Close()

<#
$Path = $form.FindName("Path")
$Path.Text = $PWD

$FileFilter = $form.FindName("FileFilter")
$FileFilter.Text = "*.ps1"

$TextPattern = $form.FindName("TextPattern")
$Recurse = $form.FindName("Recurse")

$UseRegex = $form.FindName("UseRegex")
$UseRegex.IsChecked = $true

$FirstOnly = $form.FindName("FirstOnly")

$Run = $form.FindName("Run")
$Run.add_Click({
    $form.DialogResult = $true
    $form.Close()
  })
  
$Show = $form.FindName("Show")
$Show.add_Click({Write-Host (Get-CommandString)})

$Cancel = $form.FindName("Cancel")
$Cancel.add_Click({$form.Close()})

function Get-CommandString
{
  "Get-ChildItem $($Path.Text) ``
    -Recurse: `$$($Recurse.IsChecked) ``
    -Filter '$($FileFilter.Text)' |
      Select-String -SimpleMatch: `(! `$$($UseRegex.IsChecked)) ``
        -Pattern '$($TextPattern.Text)' ``
        -List: `$$($FirstOnly.IsChecked)"
}

#>

$BWLisr = $form.FindName("bwList")
foreach ($i in gps | out-string -stream)
{
  $BWLisr.Items.Add($i)
}

if ($form.ShowDialog())
{
  $cmd = Get-CommandString
  Invoke-Expression $cmd
}

##########################################################################################

