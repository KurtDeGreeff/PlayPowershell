Function Get-Certificate  {

  <#

  .SYNOPSIS

Retrieves  certificates from a local or remote system.
        .DESCRIPTION

Retrieves  certificates from a local or remote system.


        .PARAMETER  Computername

  A single or  list of computernames to perform search against


        .PARAMETER  StoreName

  The name of  the certificate store name that you want to search


        .PARAMETER  StoreLocation

  The location  of the certificate store.


        .NOTES

  Name:  Get-Certificate

  Author: Boe  Prox

  Version  History:

  1.0 -  Initial Version


        .EXAMPLE

  Get-Certificate -Computername 'boe-pc' -StoreName My -StoreLocation  LocalMachine


             Thumbprint                                 Subject                              

  ----------                                 -------                              

  F29B6CB248E3395B2EB45FCA6EA15005F64F2B4E   CN=SomeCert                          

  B93BA840652FB8273CCB1ABD804B2A035AA39877   CN=YetAnotherCert                    

  B1FF5E183E5C4F03559E80B49C2546BBB14CCB18   CN=BOE                               

  65F5A012F0FE3DF8AC6B5D6E07817F05D2DF5104   CN=SomeOtherCert                     

  63BD74490E182A341405B033DFE6768E00ECF21B   CN=www.example.com


            Description

  -----------

  Lists all certificates


        .EXAMPLE

  Get-Certificate -Computername 'boe-pc' -StoreName My -StoreLocation  LocalMachine -DaysUntilExpired 14 |

  Select  Subject, DaysUntilExpired,NotAfter


            Subject                              DaysUntilExpired  NotAfter                 

  -------                              ----------------  --------                 

  CN=SomeCert                                        12  10/22/2014 12:00:00 AM   

  CN=SomeOtherCert                                    4 10/14/2014  12:00:00 AM   

  CN=www.example.com                            Expired 12/21/2011  11:00:00 PM


            Description

  -----------

  Lists all  certificates that Expire in 14 days or has already expired


        .EXAMPLE

  Get-Certificate -Computername 'boe-pc' -StoreName My -StoreLocation  LocalMachine -DaysUntilExpired 14 -HideExpired |

  Select  Subject, DaysUntilExpired,NotAfter


            Subject                              DaysUntilExpired  NotAfter                 

  -------                              ----------------  --------                 

  CN=SomeCert                                        12  10/22/2014 12:00:00 AM   

  CN=SomeOtherCert                                    4  10/14/2014 12:00:00 AM


            Description

  -----------

  Lists all  certificates that Expire in 14 days and hides certificates that have expired


    #> 

  [cmdletbinding(

  DefaultParameterSetName = 'All'

  )]

  Param (

  [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]

  [Alias('PSComputername','__Server','IPAddress')]

  [string[]]$Computername =  $env:COMPUTERNAME,

  [System.Security.Cryptography.X509Certificates.StoreName]$StoreName = 'My',

  [System.Security.Cryptography.X509Certificates.StoreLocation]$StoreLocation  = 'LocalMachine',

  [parameter(ParameterSetName='Expire')]

  [Int]$DaysUntilExpired,

  [parameter(ParameterSetName='Expire')]

  [Switch]$HideExpired

  )

  Process  {

  ForEach  ($Computer in  $Computername) {

  Try  {

  Write-Verbose  ("Connecting to {0}\{1}" -f "\\$($Computername)\$($StoreName)",$StoreLocation)

  $CertStore  = New-Object  System.Security.Cryptography.X509Certificates.X509Store  -ArgumentList "\\$($Computername)\$($StoreName)", $StoreLocation

  $CertStore.Open('ReadOnly')

  Write-Verbose  "ParameterSetName: $($PSCmdlet.ParameterSetName)"

  Switch  ($PSCmdlet.ParameterSetName)  {

  'All'  {

  $CertStore.Certificates

  }

  'Expire'  {

  $CertStore.Certificates | Where {

  $_.NotAfter -lt (Get-Date).AddDays($DaysUntilExpired)

  } | ForEach {

  $Days = Switch ((New-TimeSpan  -End $_.NotAfter).Days)  {

  {$_ -gt 0} {$_}

  Default {'Expired'}

  }

  $Cert = $_ | Add-Member -MemberType  NoteProperty -Name  DaysUntilExpired -Value  $Days -PassThru

  If ($HideExpired  -AND $_.DaysUntilExpired -ne  'Expired') {

  $Cert

  } ElseIf (-Not $HideExpired) {

  $Cert

  }

  }

  }

  }

  } Catch  {

  Write-Warning  "$($Computer): $_"

  }

  }

  }

  } 