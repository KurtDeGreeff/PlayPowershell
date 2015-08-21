$EmailAddress = Read-Host -Prompt "Enter your Microsoft Account.."
$Password = Read-Host -AsSecureString -Prompt "Enter your Password..."
$ie = New-Object -ComObject InternetExplorer.Application
$ie.height = 800
$ie.width = 1200
$ie.navigate("http://outlook.com")
$ie.visible = $true
while($ie.Busy){Start-Sleep -Milliseconds 500}
<#
inspect the web page elements such as textboxes and buttons and fill them with
the values received from the user in the beginning. The web page's elements
can be inspect using F12 developer tools in Internet Explorer.
#>
$doc = $ie.document
$tbUsername = $doc.getElementByID("i0116")
$tbUsername.value = $EmailAddress
$tbPassword = $doc.getElementByID("i0118")
$tbPassword.value = $Password
$btnSubmit = $doc.getElementByID("idSIButton9")
$btnSubmit.Click()