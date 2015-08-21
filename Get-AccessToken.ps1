<#
.DESCRIPTION 
  Gets an access token for an App-Only Azure AD Application
.PARAMETER TenantId
  The TenantId of the Azure AD Application
  Can be set globally with $global:AzureADApplicationTenantId
.PARAMETER ClientId
  The ClientId of the Azure AD Application
  Can be set globally with $global:AzureADApplicationClientId
.PARAMETER CertificatePath
  The path to the *.pfx certificate used in your Azure AD Application
  Can be set globally with $global:AzureADApplicationCertificatePath
.PARAMETER CertificatePassword
  The password used to secure your *.pfx certificate
  Can be set globally with $global:AzureADApplicationCertificatePassword
.PARAMETER ResourceUri
  The resource URI you want to authenticate against
.EXAMPLE
  Get-AccessToken -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "00000000-0000-0000-0000-000000000000" -CertificatePath "C:\Certificate.pfx" -CertificatePassword "Password" -ResourceUri "https://outlook.office365.com/"
.EXAMPLE
  Get-AccessToken -ResourceUri "https://outlook.office365.com/"
#>
function Get-AccessToken()
{
  Param(
    [Parameter(Mandatory=$true, ParameterSetName="UseLocal")]
    [Parameter(Mandatory=$false, ParameterSetName="UseGlobal")]
    [ValidateNotNullOrEmpty()]
    [String]
    $TenantId = $global:AzureADApplicationTenantId,
    
    [Parameter(Mandatory=$true, ParameterSetName="UseLocal")]
    [Parameter(Mandatory=$false, ParameterSetName="UseGlobal")]
    [ValidateNotNullOrEmpty()]
    [String]
    $ClientId = $global:AzureADApplicationClientId,
    
    [Parameter(Mandatory=$true, ParameterSetName="UseLocal")]
    [Parameter(Mandatory=$false, ParameterSetName="UseGlobal")]
    [ValidateNotNullOrEmpty()]
    [String]
    $CertificatePath = $global:AzureADApplicationCertificatePath,
    
    [Parameter(Mandatory=$true, ParameterSetName="UseLocal")]
    [Parameter(Mandatory=$false, ParameterSetName="UseGlobal")]
    [ValidateNotNullOrEmpty()]
    [String]
    $CertificatePassword = $global:AzureADApplicationCertificatePassword,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $ResourceUri
  )
  
  #region Validations
  #-----------------------------------------------------------------------
  # Validating the TenantId
  #-----------------------------------------------------------------------
  if(!(Is-Guid -Value $TenantId))
  {
    throw [Exception] "TenantId '$TenantId' is not a valid Guid"
  }
  
  #-----------------------------------------------------------------------
  # Validating the ClientId
  #-----------------------------------------------------------------------
  if(!(Is-Guid -Value $ClientId))
  {
    throw [Exception] "ClientId '$ClientId' is not a valid Guid"
  }
  
  #-----------------------------------------------------------------------
  # Validating the Certificate Path
  #-----------------------------------------------------------------------
  if(!(Test-Path -Path $CertificatePath))
  {
    throw [Exception] "CertificatePath '$CertificatePath' does not exist"
  }

  #-----------------------------------------------------------------------
  # Validating the availability of Azure Active Directory Assemblies
  #-----------------------------------------------------------------------
  if(!(Test-Path -Path "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"))
  {
    throw [Exception] "Azure Active Directory Assemblies are not available"
  }
  #endregion
  
  #region Initialization
  #-----------------------------------------------------------------------
  # Loads the Azure Active Directory Assemblies 
  #-----------------------------------------------------------------------
  Add-Type -Path "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll" | Out-Null
  
  #-----------------------------------------------------------------------
  # Constants 
  #-----------------------------------------------------------------------
  $keyStorageFlags = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet
  
  #-----------------------------------------------------------------------
  # Building required values
  #-----------------------------------------------------------------------
  $authorizationUriFormat = "https://login.windows.net/{0}/oauth2/authorize"
  $authorizationUri = [String]::Format($authorizationUriFormat, $TenantId)
  #endregion
  
  #region Process
  #-----------------------------------------------------------------------
  # Building the necessary context to acquire the Access Token
  #-----------------------------------------------------------------------
  $authenticationContext = New-Object -TypeName "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authorizationUri, $false
  $certificate = New-Object -TypeName "System.Security.Cryptography.X509Certificates.X509Certificate2" -ArgumentList $CertificatePath, $CertificatePassword, $keyStorageFlags
  $assertionCertificate = New-Object -TypeName "Microsoft.IdentityModel.Clients.ActiveDirectory.ClientAssertionCertificate" -ArgumentList $ClientId, $certificate

  #-----------------------------------------------------------------------
  # Ask for the AccessToken based on the App-Only configuration
  #-----------------------------------------------------------------------
  $authenticationResult = $authenticationContext.AcquireToken($ResourceUri, $assertionCertificate)
  
  #-----------------------------------------------------------------------
  # Returns the an AccessToken valid for an hour
  #-----------------------------------------------------------------------
  return $authenticationResult.AccessToken
  #endregion
}