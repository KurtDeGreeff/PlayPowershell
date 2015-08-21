#requires -version 2.0

<#
 -----------------------------------------------------------------------------
 Script: Get-ISEFunction.ps1
 Version: 0.9.1
 Author: Jeffery Hicks
    http://jdhitsolutions.com/blog
    http://twitter.com/JeffHicks
    http://www.ScriptingGeek.com
 Date: 5/10/2012
 Keywords:
 Comments:
 List all functions and their line number from the current script 
 file in the ISE. The script will add a menu under Add-Ons called
 List Functions which you can run for the current file. Or you can
 use the alias gif from the ISE command prompt.
 
 The default behavior is to display the results using Out-GridView. 
 You will have to manually go to any line number you want.  If you 
 have the ShowUI module, a stackpanel is created for each function. 
 Click on the button to jump to that function. The ShowUI control
 will close after you select a function.
 
 When using this with Out-GridView, if you modify the file and change
 line numbers dont' forget to close the grid view and re-run the menu
 command.
 
 This version assumes your filter and function keywords are left justified
 with no spaces and that you use the format
 
 Function SomeName {
 
 This is the format I use and I wrote this function to accomodate it. If 
 you have something different, you'll have to tweak the regular expression.
 
 "Those who forget to script are doomed to repeat their work."

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
 -----------------------------------------------------------------------------
 #>
 
Function Get-ISEFunction {

[cmdletbinding()]
Param([string]$Path=$psise.CurrentFile.FullPath)

#import ShowUI if found and use it later in the functoin
if (Get-module -name ShowUI -listavailable) {
    Import-Module ShowUI
    $showui=$True
}
else {
    Write-Verbose "Using Out-GridView"
    $showui=$False
}

#define a regex to find "function | filter NAME {"
[regex]$r="^(Function|Filter)\s\S+\s{"

$list=get-content $path | 
 select-string $r | Select LineNumber,
 @{Name="Function";Expression={$_.Line.Split()[1]}}

#were any functions found?
if ($list) {
    $count=$list | measure-object | Select-object -ExpandProperty Count
    Write-Verbose "Found $count functions"
    if ($showui) {
     <#
        display function list with a WPF Form from ShowUI
        Include file name so the right tab can get selected
     #>

    [string]$n=$psise.CurrentFile.DisplayName
    Write-Verbose "Building list for $n"
    
    ScrollViewer -ControlName $n -CanContentScroll  -tag $psise.CurrentFile.FullPath -content {
     StackPanel  -MinWidth 300 -MaxHeight 250  `
     -orientation Vertical -Children {
        #get longest number if more than one function is found
        if ($count -eq 1) {
            [string]$i=$list.Linenumber
        }
        else {
            [string]$i=$list[-1].Linenumber
        }
        $l=$i.length
        foreach ($item in $list) {
            
            [string]$text="{0:d$l}    {1}" -f $item.linenumber,$item.function
            Write-Verbose $text
            Button $text -HorizontalContentAlignment Left -On_Click {
                #get the line number
                [regex]$num="^\d+"
                #parse out the line number
                $goto = $num.match($this.content).value
                #grab the file name from the tab value of the parent control
                [string]$f= $parent | get-uivalue
                #Open the file in the editor
                psedit $f
                #goto the selected line
                $psise.CurrentFile.Editor.SetCaretPosition($goto,1)
               #close the control
               Get-ParentControl | Set-UIValue -PassThru |Close-Control
            } #onclick
        } #foreach
     } 
     } -show 

    } #if $showui
    else {
        #no ShowUI module so use Out-GridView
        $list | out-gridview -Title $psise.CurrentFile.FullPath
    }
 }
else {
 Write-Host "No functions found in $($psise.CurrentFile.FullPath)" -ForegroundColor Magenta
}

} #close function

#Add to the Add-ons menu
$PSISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("List Functions",{Get-ISEFunction},$null)

#optional alias
set-alias gif get-isefunction