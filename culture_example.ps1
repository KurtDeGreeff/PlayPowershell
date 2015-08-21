# --------------------------------- Meta Information for Microsoft Script Explorer for Windows PowerShell V1.0 ---------------------------------
# Title: culture_example
# Author: Unknown
# Description: C:\downloads\_POWERSHELL\Windows PowerShell in Action, 2nd edition - SourceCode\finalcode\Appendix D\culture_example.ps1
# Date Published: 16/05/2011 1:44:04
# Source: C:\downloads\_POWERSHELL\Windows PowerShell in Action, 2nd edition - SourceCode\finalcode\Appendix D\culture_example.ps1
# Search Terms: culture
# ------------------------------------------------------------------

#
# Windows PowerShell in Action, Second Edition
#
# Appendix D - Additional PowerShell Topics
#
# Internationalization support in a script
#

function Invoke-Hello
{
    $msgTable = Data {
        if ($PSCulture -eq "fr-CA")
        {
            ConvertFrom-StringData @'
                HelloString = Salut tout le monde!
'@
        }
        else
                {
            ConvertFrom-StringData @'
                HelloString = Hello world|
'@
        }
    }
    
    "$PSCulture`: " + $msgTable.HelloString
}

& {
Invoke-Hello
[System.Threading.Thread]::CurrentThread.CurrentCulture =
[System.Globalization.CultureInfo]::CreateSpecificCulture("fr-CA")
Invoke-Hello
}
