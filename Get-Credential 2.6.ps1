## Get-Credential 
## An improvement over the default cmdlet which has no options ...
###################################################################################################
## History
## v 2.6 Put back support for passing in the domain when getting credentials without prompting
## v 2.5 Added examples for the help
## v 2.4 Fix a bug in -Store when the UserName isn't passed in as a parameter
## v 2.3 Add -Store switch and support putting credentials into the file system
## v 2.1 Fix the comment help and parameter names to agree with each other (whoops)
## v 2.0 Rewrite for v2 to replace the default Get-Credential
## v 1.2 Refactor ShellIds key out to a variable, and wrap lines a bit
## v 1.1 Add -Console switch and set registry values accordingly (ouch)
## v 1.0 Add Title, Message, Domain, and UserName options to the Get-Credential cmdlet
###################################################################################################
function Get-Credential { 
## .Synopsis
##    Gets a credential object based on a user name and password.
## .Description
##    The Get-Credential function creates a credential object for a specified username and password, with an optional domain. You can use the credential object in security operations.
## 
##    The function accepts more parameters to customize the security prompt than the default Get-Credential cmdlet (including forcing the call through the console if you're in the native PowerShell.exe CMD console), but otherwise functions identically.
## .Example
##    Get-Credential -user key -pass secret -store | % { $_.GetNetworkCredential() } | fl *
## 
##    Demonstrates the ability to store passwords securely, and pass them in on the command line
## .Example
##    Get-Credential key
## 
##    If you haven't stored the password for "key", you'll be prompted with the regular PowerShell credential prompt, otherwise it will read the stored password and return credentials without prompting
## .Example
##    Get-Credential -inline
##  
##    Will prompt for credentials inline in the host instead of in a popup dialog
[CmdletBinding(DefaultParameterSetName="Prompted")]
PARAM(
#   A default user name for the credential prompt, or a pre-existing credential (would skip all prompting)
   [Parameter(ParameterSetName="Prompted",Position=1,Mandatory=$false)]
   [Parameter(ParameterSetName="Promptless",Position=1,Mandatory=$true)]
   [Parameter(ParameterSetName="StoreCreds",Position=1,Mandatory=$true)]
   [Parameter(ParameterSetName="Flush",Position=1,Mandatory=$true)]
   [Alias("Credential")]
   [PSObject]$UserName=$null
,
#  Allows you to override the default window title of the credential dialog/prompt
#
#  You should use this to allow users to differentiate one credential prompt from another.  In particular, if you're prompting for, say, Twitter credentials, you should put "Twitter" in the title somewhere. If you're prompting for domain credentials. Being specific not only helps users differentiate and know what credentials to provide, but also allows tools like KeePass to automatically determine it.
   [Parameter(ParameterSetName="Prompted",Position=2,Mandatory=$false)]
   [string]$Title=$null
,
#  Allows you to override the text displayed inside the credential dialog/prompt.
#  
#  You can use this for things like presenting an explanation of what you need the credentials for.
   [Parameter(ParameterSetName="Prompted",Position=3,Mandatory=$false)]
   [string]$Message=$null
,
#  Specifies the default domain to use if the user doesn't provide one (by default, this is null)
   [Parameter(ParameterSetName="Prompted",Position=4,Mandatory=$false)]
   [Parameter(ParameterSetName="Promptless",Position=4,Mandatory=$false)]
   [string]$Domain=$null
,
#  The Get-Credential cmdlet forces you to always return DOMAIN credentials (so even if the user provides just a plain user name, it prepends "\" to the user name). This switch allows you to override that behavior and allow generic credentials without any domain name or the leading "\".
   [Parameter(ParameterSetName="Prompted",Mandatory=$false)]
   [switch]$GenericCredentials
,
#  Forces the credential prompt to occur inline in the console/host using Read-Host -AsSecureString (not implemented properly in PowerShell ISE)
   [Parameter(ParameterSetName="Prompted",Mandatory=$false)]
   [switch]$Inline
,
#  Store the credential in the file system (and overwrite them)
   [Parameter(ParameterSetName="Prompted",Mandatory=$false)]
   [Parameter(ParameterSetName="Promptless",Mandatory=$false)]
   [Parameter(ParameterSetName="StoreCreds",Mandatory=$true)]
   [switch]$Store
,
#  Remove stored credentials from the file system
   [Parameter(ParameterSetName="Prompted",Mandatory=$false)]
   [Parameter(ParameterSetName="Promptless",Mandatory=$false)]
   [Parameter(ParameterSetName="Flush",Mandatory=$true)]
   [switch]$Flush
,
#  Allows you to override the path to store credentials in
   [Parameter(ParameterSetName="Prompted",Mandatory=$false)]
   [Parameter(ParameterSetName="Promptless",Mandatory=$false)]
   [Parameter(ParameterSetName="StoreCreds",Mandatory=$false)]
   $CredentialFolder = $(Join-Path ${Env:APPDATA} Credentials)
,
#  The password
   [Parameter(ParameterSetName="Promptless",Position=5,Mandatory=$true)]
   $Password = $(
   if($UserName -and (Test-Path "$(Join-Path $CredentialFolder $UserName).cred")) {
         if($Flush) {
            Remove-Item "$(Join-Path $CredentialFolder $UserName).cred"
         } else {
            Get-Content "$(Join-Path $CredentialFolder $UserName).cred" | ConvertTo-SecureString 
         }
   })
)
process {
   [PSCredential]$Credential = $null
   
   if( $UserName -is [System.Management.Automation.PSCredential]) {
      $Credential = $UserName
   } elseif($UserName -ne $null) {
      $UserName = $UserName.ToString()
   }
   
   if($Password) {
      if($Password -isnot [System.Security.SecureString]) {
         [char[]]$Chars = $Password.ToString().ToCharArray()
         $Password = New-Object System.Security.SecureString
         foreach($c in $chars) { $Password.AppendChar($c) }
      }
      if($Domain) {
         $Credential = New-Object System.Management.Automation.PSCredential ${Domain}\${UserName}, ${Password}
      } else {
         $Credential = New-Object System.Management.Automation.PSCredential ${UserName}, ${Password}
      }
   }
   
   if(!$Credential) {
      if($Inline) {
         if($Title)    { Write-Host $Title }
         if($Message)  { Write-Host $Message }
         if($Domain) { 
            if($UserName -and $UserName -notmatch "[@\\]") { 
               $UserName = "${Domain}\${UserName}"
            }
         }
         if(!$UserName) {
            $UserName = Read-Host "User"
            if(($Domain -OR !$GenericCredentials) -and $UserName -notmatch "[@\\]") {
               $UserName = "${Domain}\${UserName}"
            }
         }
         $Credential = New-Object System.Management.Automation.PSCredential $UserName,$(Read-Host "Password for user $UserName" -AsSecureString)
      }
   
      if($GenericCredentials) { $Type = "Generic" } else { $Type = "Domain" }
   
      ## Now call the Host.UI method ... if they don't have one, we'll die, yay.
      ## BugBug? PowerShell.exe (v2) disregards the last parameter
      $Credential = $Host.UI.PromptForCredential($Title, $Message, $UserName, $Domain, $Type, "Default")
   }
   
   if($Store) {
      $CredentialFile = "$(Join-Path $CredentialFolder $Credential.UserName).cred"
      if(!(Test-Path $CredentialFolder)) {
         mkdir $CredentialFolder | out-null
      }
      $Credential.Password | ConvertFrom-SecureString | Set-Content $CredentialFile
   }
   return $Credential
}
}