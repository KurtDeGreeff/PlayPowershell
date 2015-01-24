function Connect-RDP {
 
  param (
    [Parameter(Mandatory=$true)]
    $ComputerName,
 
    [System.Management.Automation.Credential()]
    $Credential
  )
 
  # take each computername and process it individually
  $ComputerName | ForEach-Object {
 
    # if the user has submitted a credential, store it
    # safely using cmdkey.exe for the given connection
    if ($PSBoundParameters.ContainsKey('Credential'))
    {
      # extract username and password from credential
      $User = $Credential.UserName
      $Password = $Credential.GetNetworkCredential().Password
 
      # save information using cmdkey.exe
      cmdkey.exe /generic:$_ /user:$User /pass:$Password
    }
 
    # initiate the RDP connection
    # connection will automatically use cached credentials
    # if there are no cached credentials, you will have to log on
    # manually, so on first use, make sure you use -Credential to submit
    # logon credential
 
    mstsc.exe /v $_ /f
  }
}