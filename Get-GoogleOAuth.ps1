
# Get API Access https://console.developers.google.com/project/projectID/apiui/api?authuser=0
$clientId = "INPUT CLIENT ID for API"
$clientSecret = "CLIENT SECRET for API"

#return to us locally not via a web server
$redirectUri = "urn:ietf:wg:oauth:2.0:oob"
$grantType = "authorization_code"

# change scope here, you can use oauth playground to find scopes
# https://developers.google.com/oauthplayground
# you must enable api in your account before set url in browzer
$scope= "email%20profile"
$responseType = "code"
$getCodeUrl = "https://accounts.google.com/o/oauth2/auth?scope=$scope&redirect_uri=$redirectUri&response_type=$responseType&client_id=$clientId"
"$getCodeUrl" | Clip

Write-Host "Get Access code from paste clip board content"
pause

# Input Access code you obtain from Browser
$accessCode = Read-Host "Enter the access code:  "

$requestUri = "https://accounts.google.com/o/oauth2/token"
$requestBody= "client_secret=$clientSecret&grant_type=$grantType&code=$accessCode&client_id=$clientID&redirect_uri=$redirectUri"

#exchange the code for a token
try
{
    Invoke-RestMethod -URI $requestUri -Method Post -Body $requestBody
}
catch
{
    Write-Host $_.Exception.ToString()
    $error[0] | Format-List -Force
}