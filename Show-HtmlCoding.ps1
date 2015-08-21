<#
.SYNOPSIS
    This script encodes and decodes an HTML String
.DESCRIPTION
    This script used 
.NOTES
    File Name  : Show-HtmlCoding.ps1
    Author     : Thomas Lee - tfl@psp.co.uk
    Requires   : PowerShell Version 2.0
.LINK
    This script posted to:
	    http://www.pshscripts.blogspot.com
    MSDN sample posted tot:
	    http://msdn.microsoft.com/en-us/library/ee388364.aspx
.EXAMPLE
    PSH [C:\foo]: .\Show-HtmlCoding.ps1
    Original String: <this is a string123> & so is this one??
    Encoded String : &lt;this is a string123&gt; &amp; so is this one??
    Decoded String : <this is a string123> & so is this one??
    Original string = Decoded string?: True   
#>

# Create string to encode/decode
$Str = "<this is a string123> & so is this one??"

# Encode String
$Encstr = [System.Net.WebUtility]::HtmlEncode($str)

# Decode String
$Decstr = [System.Net.WebUtility]::HtmlDecode($EncStr)

# Display strings
"Original String: {0}" -f $Str
"Encoded String : {0}" -f $Encstr
"Decoded String : {0}" -f $Decstr
$eq = ($str -eq $Decstr)
"Original string = Decoded string?: {0}" -f $eq 