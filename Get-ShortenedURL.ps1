Function Get-ShortenedURL {
 <#
.SYNOPSIS
 
    Get-ShortenedURL
    
    Author: Chris Campbell (@obscuresec)
    License: BSD 3-Clause
    
.DESCRIPTION

    A function that returns the actual URL from a http redirect.

.PARAMETER $ShortenedURL

    Specifies the shortened URL.

.EXAMPLE

    PS C:\> Get-ShortenedURL -ShortenedURL http://goo.gl/V4PKq
    PS C:\> Get-ShortenedURL -ShortenedURL http://goo.gl/V4PKq,http://bit.ly/IeWSIZ
    PS C:\> Get-Content C:\urls.txt | Get-ShortenedURL 
    PS C:\> Get-ShortenedURL -ShortenedURL (Get-Content C:\urls.txt)

.LINK

    http://obscuresecurity.blogspot.com/2013/01/Get-ShortenedURL.html
    https://github.com/obscuresec/random/blob/master/Get-ShortenedURL

#>

    [CmdletBinding()] Param(
            [Parameter(Mandatory=$True,ValueFromPipeline=$True)]             
            [string[]] $ShortenedURL 
            )

    BEGIN {}
        
    PROCESS {

       Try {
            #Loop through each URL in the array
            Foreach ($URL in $ShortenedURL) {
                
                #Create the WebClient Object and request
                $WebClientObject = New-Object System.Net.WebClient
                $WebRequest = [System.Net.WebRequest]::create($URL)
                $WebResponse = $WebRequest.GetResponse()
                
                #Parse out redirected URL
                $ActualDownloadURL = $WebResponse.ResponseUri.AbsoluteUri
                
                #Create custom object to store results
                $ObjectProperties = @{ 'Shortened URL' = $URL;
                                       'Actual URL' = $ActualDownloadURL}
                $ResultsObject = New-Object -TypeName PSObject -Property $ObjectProperties
                
                #Output the results
                Write-Output $ResultsObject
                
                #Close the webclient connection
                $WebResponse.Close()
            }       
       }

        Catch {}
    }

    END {}
} 
