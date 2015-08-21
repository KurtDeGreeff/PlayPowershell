Param($user,
      $password = $(Read-Host "Enter Password" -asSec),
      $filter = "(objectclass=user)",
      $server = $(throw '$server is required'),
      $path = $(throw '$path is required'),
      [switch]$all,
      [switch]$verbose)
    
function GetSecurePass ($SecurePassword) {
  $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($SecurePassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
  [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
  $password
}    

if($verbose){$verbosepreference = "Continue"}

$DN = "LDAP://$server/$path"
Write-Verbose "DN = $DN"
$auth = [System.DirectoryServices.AuthenticationTypes]::FastBind
Write-Verbose "Auth = FastBind"
$de = New-Object System.DirectoryServices.DirectoryEntry($DN,$user,(GetSecurePass $Password),$auth)
Write-Verbose $de
Write-Verbose "Filter: $filter"
$ds = New-Object system.DirectoryServices.DirectorySearcher($de,$filter) 
Write-Verbose $ds
if($all)
{
    Write-Verbose "Finding All"
    $ds.FindAll()
}
else
{
    Write-Verbose "Finding One"
    $ds.FindOne()
}