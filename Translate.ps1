##############################################################################
#  Script: translate.ps1
#    Date: 16.May.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Demos filters and piping into functions/scripts with $input.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################
param ($lang = "German")


filter translate ([String] $into = "German") {
	$word = $_
	switch ($into) {
		French  {"La "  + $word + "ette..."}
		Greek   {"Oi "  + $word + "tai;"   }
		German  {"Das " + $word + "en!"    }
	    English {"The " + $word + ", dude!"}
	}
}

$input | translate -into $lang



filter auf-deutsch {
    "Das " + $_ + "en!"
}


# ForEach ($word in $input) {"Das " + $word + "en!" } 
# While ($input.movenext()) {"Das " + $input.current + "en!"}
 



function thewayofdata ($p) {
    $p
    $args[0]
    $args[1]
    foreach ($x in $input) { $x }
}

#   1,2,3 | thewayofdata 4 5 -p 6




