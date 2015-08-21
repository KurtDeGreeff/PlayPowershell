##############################################################################
#  Script: Manipulate-Binary.ps1
#    Date: 5.Oct.2009
# Version: 2.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
#   Notes: Requires PowerShell 2.0 or later.
# Purpose: Quick demo of getting/setting raw bytes of a file.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


# You can read a binary (or text) file into an array of bytes
# using the -encoding parameter of get-content:

[System.Byte[]] $filebytes = get-content HelloWorld.ps1 -encoding byte 

# You can of course construct the array and then write it to a file:
$filebytes = @(13,10,34,72,101,108,108,111,32,87,111,114,108,100,33,34,13,10,13,10)

# Once you have an array of bytes, you can write them back to a file:
$filebytes | set-content HelloWorld2.ps1 -encoding byte




#Read raw bytes of a file and return an array of System.Byte:
function Read-Byte
{ 
    Param ( $Path ) 
    if ($Path.GetType().FullName -eq "System.IO.FileInfo") { $Path = $Path.FullName } 
    [System.IO.File]::ReadAllBytes( $(resolve-path $Path) ) 
} 


#Write raw bytes of a System.Byte[] array to a file.
function Write-Byte 
{
    Param ( [System.Byte[]] $ByteArray, $Path ) 
    if ($Path.GetType().FullName -eq "System.IO.FileInfo") { $Path = $Path.FullName } 
    elseif ($Path -notlike "*\*") { $Path = "$pwd" + "\" + "$Path" }  #Simple file name.
    elseif ($Path -like ".\*") { $Path = $Path -replace "^\.",$pwd.Path } #pwd of script
    elseif ($Path -like "..\*") { $Path = $Path -replace "^\.\.",$(get-item $pwd).Parent.FullName } #parent directory of pwd of script 
    else { throw "Cannot resolve path!" } 
    [System.IO.File]::WriteAllBytes($Path, $ByteArray) 
}


#Convert a System.Byte[] array to an ASCII, Unicode or UTF string. 
function Convert-ByteArrayToString
{
    Param ( [System.Byte[]] $ByteArray, $Encoding = "ASCII" )
    switch ( $Encoding.ToUpper() )
    {
        "ASCII"   { $EncodingType = "System.Text.ASCIIEncoding" }
        "UNICODE" { $EncodingType = "System.Text.UnicodeEncoding" }
        "UTF7"    { $EncodingType = "System.Text.UTF7Encoding" }
        "UTF8"    { $EncodingType = "System.Text.UTF8Encoding" }
        "UTF32"   { $EncodingType = "System.Text.UTF32Encoding" }
        Default   { $EncodingType = "System.Text.ASCIIEncoding" }
    }
    $Encode = new-object $EncodingType
    $Encode.GetString($ByteArray)
}
 

#Convert a System.Byte[] array to an ASCII hex representation.
function Convert-ByteArrayToHexString
{
    Param ( [System.Byte[]] $ByteArray, $Width = 10, $Delimiter = ",0x", $Prepend = "", [Switch] $AddQuotes )
    if ($Width -lt 1) { $Width = 1 } 
    if ($ByteArray.Length -eq 0) { Return }  
    $FirstDelimiter = $Delimiter -Replace "^[\,\;\:\t]",""
    $From = 0
    $To = $Width - 1
    Do
    {
        $String = [System.BitConverter]::ToString($ByteArray[$From..$To])
        $String = $FirstDelimiter + ($String -replace "\-",$Delimiter) 
        if ($AddQuotes) { $String = '"' + $String + '"' }
        if ($Prepend -ne "") { $String = $Prepend + $String }
        $String
        $From += $Width
        $To += $Width
    } While ($From -lt $ByteArray.Length)
}
 

 
 
# Convert a string with hex data to System.Byte[] array, even if only one element.
function Convert-HexStringToByteArray
{
    Param ( $String )
    #Clean out whitespaces and any other non-hex crud.
    $String = $String.ToLower() -replace '[^a-f0-9\\\,x\-\:]',''
    
    #Try to put into canonical colon-delimited format.
    $String = $String -replace '0x|\\x|\-|,',':'

    #Remove beginning and ending colons, plus other detritus.
    $String = $String -replace '^:+|:+$|x|\\',''

    #Maybe there's nothing left over to convert...
    if ($String.Length -eq 0) { ,@() ; return } 

    #Split string with or without colon delimiters. 
    if ($String.Length -eq 1) 
    { ,@([System.Convert]::ToByte($String,16)) }
    elseif (($String.Length % 2 -eq 0) -and ($String.IndexOf(":") -eq -1)) 
    { ,@($String -split '([a-f0-9]{2})' | foreach-object { if ($_) {[System.Convert]::ToByte($_,16)}}) } 
    elseif ($String.IndexOf(":") -ne -1)
    { ,@($String -split ':+' | foreach-object {[System.Convert]::ToByte($_,16)}) }
    else
    { ,@() }  
    #The ugly ",@(...)" syntax is needed to force the output into an 
    # array even if there is zero or only one element.
}





<#
Why is manipulating binary bytes sometimes a pain? :

Text can be ASCII vs. Unicode vs. UTF
Big-endian vs. little-endian
Raw byte object vs. byte represented in hexadecimal (in ASCII or Unicode)
Hex strings can be delimited in different ways, or not delimited at all.
Some cmdlets inject unwanted newlines.
Some .NET classes have unexpected working directories when invoked.

#>



