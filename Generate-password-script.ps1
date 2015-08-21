$pwd = Read-Host 'Enter Password'
$user = Read-Host 'Enter Username'
$key = 1..32 | ForEach-Object { Get-Random -Maximum 256 } 
$pwdencrypted = $pwd |   ConvertTo-SecureString -AsPlainText -Force |
ConvertFrom-SecureString -Key $key 
$text = @()
$text += '$password = "{0}"' -f ($pwdencrypted -join ' ')
$text += '$key = "{0}"' -f ($key -join ' ')
$text += '$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))'
$text += '$cred = New-Object system.Management.Automation.PSCredential("{0}", $passwordSecure)' -f $user
$text += '$cred' 
$newFile = $psise.CurrentPowerShellTab.Files.Add()
$newFile.Editor.Text = $text | Out-String