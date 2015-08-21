#requires -version 3.0

# -----------------------------------------------------------------------------
# Script: Get-QOTD.ps1
# Author: Jeffery Hicks
#    http://jdhitsolutions.com/blog
#    follow on Twitter: http://twitter.com/JeffHicks
# Date: 6/28/2013
# Version: 2.0
# Keywords: RSS, XML, REST
# Comments:
#
# "Those who neglect to script are doomed to repeat their work."
#
#  ****************************************************************
#  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
#  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
#  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
#  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
#  ****************************************************************

# -----------------------------------------------------------------------------

Function Get-QOTD {
<#
.Synopsis
Download quote of the day.
.Description
Using Invoke-RestMethod download the quote of the day from the BrainyQuote RSS
feed. The URL parameter has the necessary default value.
.Example
PS C:\> get-qotd
"We choose our joys and sorrows long before we experience them." - Khalil Gibran
.Link
Invoke-RestMethod
#>
    [cmdletBinding()]

    Param(
    [Parameter(Position=0)]
    [ValidateNotNullorEmpty()]
    [string]$Url="http://feeds.feedburner.com/brainyquote/QUOTEBR"
    )

    Write-Verbose "$(Get-Date) Starting Get-QOTD"  
    Write-Verbose "$(Get-Date) Connecting to $url" 

    Try
    {
        #retrieve the url using Invoke-RestMethod
        Write-Verbose "$(Get-Date) Running Invoke-Restmethod"

        #if there is an exception, store it in my own variable.
        $data = Invoke-RestMethod -Uri $url -ErrorAction Stop -ErrorVariable myErr

        #The first quote will be the most recent
        Write-Verbose "$(Get-Date) retrieved data"
        $quote = $data[0]
    }
    Catch
    {
        $msg = "There was an error connecting to $url. "
        $msg += "$($myErr.Message)."

        Write-Warning $msg
    }

    #only process if we got a valid quote response
    if ($quote.description)
    {
        Write-Verbose "$(Get-Date) Processing $($quote.OrigLink)"
        #write a quote string to the pipeline
        "{0} - {1}" -f $quote.Description,$quote.Title
    }
    else
    {
        Write-Warning "Failed to get expected QOTD data from $url."
    }

    Write-Verbose "$(Get-Date) Ending Get-QOTD"

} #end Get-QOTD

#OPTIONAL: create an alias
#Set-Alias -name "qotd" -Value Get-QOTD