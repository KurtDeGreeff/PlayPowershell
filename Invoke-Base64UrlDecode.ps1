function Invoke-Base64UrlDecode {
    <#
        .SYNOPSIS
        .DESCRIPTION
        .NOTES
            http://blog.securevideo.com/2013/06/04/implementing-json-web-tokens-in-net-with-a-base-64-url-encoded-key/
            Author: Øyvind Kallstad
            Date: 23.03.2015
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [string] $Argument
    )

    $Argument = $Argument.Replace('-', '+')
    $Argument = $Argument.Replace('_', '/')

    switch($Argument.Length % 4) {
        0 {break}
        2 {$Argument += '=='; break}
        3 {$Argument += '='; break}
        DEFAULT {Write-Warning 'Illegal base64 string!'}
    }

    Write-Output $Argument
}