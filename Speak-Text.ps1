##############################################################################
#  Script: Speak-Text.ps1
#    Date: 27.Mar.2010
# Version: 1.2
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Demos how to use a COM object to speak audible text.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################



function Speak-Text( $Text = "Please tell me what to say!" )
{
    $Voice = new-object -com "SAPI.SpVoice" -strict
    $Voice.Rate = -2                # Valid Range: -10 to 10, slowest to fastest, 0 default.
    $Voice.Speak($Text) | out-null  # Piped to null to suppress text output.
}




if ($args.count -ne 0) { speak-text $args }
else { speak-text $input } 




