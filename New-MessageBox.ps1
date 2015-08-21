#requires -version 3.0

Function New-Messagebox {

<#
.SYNOPSIS
Display a VisualBasic style message box.

.DESCRIPTION
This function will display a graphical messagebox, like the one from VisualBasic
or VBScript. You must specify a message. The default button is OKOnly and the 
default icon is for Information. If you want to use the value from a button click
in a PowerShell expression, use the -Passthru parameter.

The message box will remain displayed until the user clicks a button. The box may 
also not appear on top, but if you have audio enabled you should hear the Windows 
exclamation sound.

As an added bonus you can use the -Voice parameter to hear the prompt spoken aloud.

.PARAMETER Message
The text to display. Keep it short. The command will throw an exception if the
message length is greater than 800.

.PARAMETER Button
The button set to display. The default is OKOnly. Possible values are:
    OkOnly
    OkCancel
    AbortRetryIgnore
    YesNoCancel
    YesNo
    RetryCancel

.PARAMETER Icon
The icon to display. The default is Information. Possible values are:
    Critical
    Question
    Exclamation
    Information

.PARAMETER Title
The message box title. The default is no title. The title should be less than 
60 characters long, otherwise it will be truncated. Shorter is always better.

.PARAMETER Passthru
Use this parameter if you want the button value to be passed to the pipeline.

.PARAMETER Voice
Use text to speech to announce the prompt. This parameter has an alias of Speak.

.EXAMPLE
.Parameter VoiceGender
The command will use the default voice. Or you can specify either a Male or Female
voice. This parameter will have no affect unless you also use -Voice. This 
parameter has an alias of Gender.

.EXAMPLE
PS C:\> New-Messagebox "Time to go home!"
Display a message box with no title and the OK button.

.EXAMPLE 
PS C:\> $rc= New-Messagebox -message "Do you know what you're doing?" -icon exclamation -button "YesNoCancel" -title "Hey $env:username!!" -passthru
Switch ($rc) {
 "Yes" {"I hope your resume is up to date."}
 "No" {"Wise move."}
 "Cancel" {"When in doubt, punt."}
 Default {"nothing returned"}
}

.EXAMPLE
PS C:\> New-MessageBox -message "Are you the walrus?" -icon question -title "Hey, Jude" -button YesNo -voice

Display the message box and speak the message.

.NOTES
Version      : 2.0
Last Updated : 1/30/2014

Learn more:
  PowerShell in Depth: An Administrator's Guide
  PowerShell Deep Dives
  Learn PowerShell 3 in a Month of Lunches 
  Learn PowerShell Toolmaking in a Month of Lunches 
 

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************

"Those who forget to script are doomed to repeat their work."

.LINK
http://jdhitsolutions.com/blog/

.INPUTS
None
.OUTPUTS
[system.string]

#>

[cmdletbinding()]

Param (
[Parameter(Position=0,Mandatory=$True,
HelpMessage="Specify a display message or prompt for the message box",
ValueFromPipelinebyPropertyName=$True)]
[ValidateNotNullorEmpty()]
[Alias("prompt")]
[ValidateScript({
 if ($_.length -gt 800) {
   Throw "Keep the message to less than 800 characters"
 }
 else {
    $True
 }
})]
[string]$Message,

[Parameter(ValueFromPipelinebyPropertyName=$True)]
[ValidateSet("OkOnly","OkCancel","AbortRetryIgnore","YesNoCancel","YesNo","RetryCancel")]
[string]$Button="OkOnly",

[Parameter(ValueFromPipelinebyPropertyName=$True)]
[ValidateSet("Critical", "Question", "Exclamation", "Information")]
[string]$Icon="Information",
[ValidateScript({
 if ($_.length -gt 60) {
   Throw "Keep the title to less than 60 characters"
 }
 else {
    $True
 }
})]
[Parameter(ValueFromPipelinebyPropertyName=$True)]
[string]$Title,

[Parameter(ValueFromPipelinebyPropertyName=$True)]
[switch]$Passthru,

[Parameter(ValueFromPipelinebyPropertyName=$True)]
[Alias("Speak")]
[switch]$Voice,

[Parameter(ValueFromPipelinebyPropertyName=$True)]
[ValidateSet("Male","Female")]
[Alias("Gender")]
[string]$VoiceGender

)

Write-Verbose "Starting $($myinvocation.MyCommand)"
Write-Verbose "Title = $Title"
Write-Verbose "Icon = $icon"
Write-Verbose "Button = $Button"
Write-Verbose "Message = $Message"


Try { 
    Write-Verbose "Loading VisualBasic assembly"
    #load the necessary assembly
    Add-Type -AssemblyName "Microsoft.VisualBasic" -ErrorAction Stop     
    if ($voice) {
        Write-Verbose "Loading speech assembly"
        Try { 
            #load the necessary assembly
            Add-Type -assembly system.speech -ErrorAction Stop
            $synth = new-object System.Speech.Synthesis.SpeechSynthesizer -ErrorAction Stop
            if ($VoiceGender) {
                Write-Verbose "Selecting a $voiceGender voice"
                $synth.SelectVoiceByHints($VoiceGender)
            }
            else {
                Write-Verbose "Using default voice"
            }
            $synth.SpeakAsync($message) | Out-Null
        }
        Catch {
            Write-Warning "Failed to add System.Speech assembly or create the SpeechSynthesizer object."
            Write-Warning $error[0].Exception.Message
            #bail out
            Return
        }
    } #if $voice    
    
    #create the message box using the parameter values
    #Whatever button the user clicks will be the return value
    $returnValue = [microsoft.visualbasic.interaction]::Msgbox($message,"$button,$icon",$title)
}
Catch {
    Write-Warning "Failed to add Microsoft.VisualBasic assembly or create the messagebox."
    Write-Warning $error[0].Exception.Message
}
#write return value if -Passthru is called
if ($Passthru) {
    Write-Verbose "Passing return value from message box"
    Write-Output $returnValue
}

Write-Verbose "Ending $($myinvocation.MyCommand)"

} #end function

#set an optional alias
Set-Alias -name nmb -Value New-Messagebox
