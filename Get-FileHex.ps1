##############################################################################
#  Script: Get-FileHex.ps1
#    Date: 7.Sep.2007
# Version: 1.1
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Shows the hex translation of a file, binary or otherwise.  The
#          $width argument determines how many bytes are output per line.
#          Output format designed to be identical to the output of DUMPHEX.EXE
#          by Robert Bachmann (http://rbach.priv.at/DumpHex/).
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

param ( $path = $(throw "Enter path to file!"), [Int] $width = 16 )


function Get-FileHex {
    param ( $path = $(throw "Enter path to file!"), [Int] $width = 16 )
    $linecounter = 0        # Each line of output contains offset from beginning in hex.
    $placeholder = "."      # What to print when byte is not a letter or digit.

    get-content $path -encoding byte -readcount $width | 
    foreach-object { 
        $paddedhex = $asciitext = $null
        $bytes = $_        # Array of [Byte] objects that is $width items in length.
 
        foreach ($byte in $bytes) { 
            $byteinhex = [String]::Format("{0:X}", $byte)     # Convert byte to hex, e.g., "F".
            $paddedhex += $byteinhex.PadLeft(2,"0") + " "     # Pad with zero to force 2-digit length, e.g., "0F ". 
        } 
 
        # Total bytes in file unlikely to be evenly divisible by $width, so fix last line.
        # Hex output width is '$width * 3' because of the extra spaces added around hex characters.
        if ($paddedhex.length -lt $width * 3) 
           { $paddedhex = $paddedhex.PadRight($width * 3," ") }

        foreach ($byte in $bytes) { 
            if ( [Char]::IsLetterOrDigit($byte) -or 
                 [Char]::IsPunctuation($byte) -or 
                 [Char]::IsSymbol($byte) ) 
               { $asciitext += [Char] $byte }                 # Cast raw byte to a character.
            else 
               { $asciitext += $placeholder }
        }
        
        $offsettext = [String]::Format("{0:X}", $linecounter) # Linecounter in hex too.
        $offsettext = $offsettext.PadLeft(8,"0") + "h:"       # Pad linecounter with left zeros.
        $linecounter += $width                                # Increment linecounter, each line representing $width bytes.

        "$offsettext $paddedhex $asciitext"                   # Do what you want with the output here: maybe search, maybe only ASCII, etc...
    }
}


Get-FileHex -path $path -width $width

