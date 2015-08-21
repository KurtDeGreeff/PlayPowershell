#Managing Local User Accounts
# Source: https://goo.gl/IQdq9T

$Computername = $env:COMPUTERNAME
$ADSIComp = [adsi]"WinNT://$Computername"
$Username = 'TestKurt'
$NewUser = $ADSIComp.Create('User',$Username)

#Create password 
$Password = Read-Host -Prompt "Enter password for $Username" -AsSecureString
$BSTR = [system.runtime.interopservices.marshal]::SecureStringToBSTR($Password)
$_password = [system.runtime.interopservices.marshal]::PtrToStringAuto($BSTR)

#Set password on account 
$NewUser.SetPassword(($_password))
$NewUser.SetInfo()

#Cleanup 
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR) 
Remove-Variable Password,BSTR,_password

#look at the event log to see that the account was created

$xml = '
  <QueryList>
  <Query  Id="0" Path="Security">
  <Select  Path="Security">*[System[(EventID=4720)]]</Select>
  </Query>
  </QueryList>
  ' 
Get-WinEvent -FilterXml  $xml |  Select-Object -Expand Message

$NewUser.Description  ='Test account'
$NewUser.SetInfo()

$Disabled = 0x0002
[boolean]($newuser.UserFlags.value  -BAND $Disabled)
$newuser.userflags.value = $newuser.UserFlags.value -BOR $Disabled
$NewUser.SetInfo()
#Testing the account again will show that it has now been  disabled.

#Verify Disabled doing BitWise operation 
[boolean]($newuser.UserFlags.value  -BAND $Disabled)

#ReEnable Account 
$newuser.userflags.value = $newuser.UserFlags.value -BXOR $Disabled
$NewUser.SetInfo()

#Verify Enabled doing BitWise operation 
[boolean]($newuser.UserFlags.value  -BAND $Disabled)

#forces the user to change the password upon logon
$NewUser.PasswordExpired  = 1
$NewUser.SetInfo()

#Deleting an Account
$Computername = $env:COMPUTERNAME
$ADSIComp = [adsi]"WinNT://$Computername"
$ADSIComp.Delete('User','TestKurt')

$xml = '
  <QueryList>
  <Query  Id="0" Path="Security">
  <Select  Path="Security">*[System[(EventID=4726)]]</Select>
  </Query>
  </QueryList>
  ' 
Get-WinEvent -FilterXml  $xml |  Select -Expand Message 

