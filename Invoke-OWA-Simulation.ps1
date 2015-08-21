#Parameters Block
# More info @ http://blogs.technet.com/b/gk_blog/archive/2015/03/12/powershell-script-to-simulate-outlook-web-access-url-user-logon.aspx
#URL = "https://myserver.mydoamin.com/owa

param(

[Parameter(Mandatory=$true)]
$URL,

[Parameter(Mandatory=$true)]
$Domain,

[Parameter(Mandatory=$true)]
$Username,

[Parameter(Mandatory=$true)]
$Password
)

#Initialize default values

$Result = $False
$StatusCode = 0
$Latency = 0

$Username = $Domain + "\" + $Username

try{
#########################
#Work around to Trust All Certificates is is from this post

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
       }
   }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

#Initialize Stop Watch to calculate the latency.

$StopWatch = [system.diagnostics.stopwatch]::startNew()

#Invoke the login page
$Response = Invoke-WebRequest -Uri $URL -SessionVariable owa

#Login Page - Fill Logon Form

if ($Response.forms[0].id -eq "logonform") {
$Form = $Response.Forms[0]
$Form.fields.username= $Username
$form.Fields.password= $Password
$authpath = "$URL/auth/owaauth.dll"
#Login to OWA
$Response = Invoke-WebRequest -Uri $authpath -WebSession $owa -Method POST -Body $Form.Fields
#SuccessfulLogin 
if ($Response.forms[0].id -eq "frm") {
  $StopWatch.stop()
  $StatusCode = $Response.StatusCode
  $Result = $True
  $Latency = $StopWatch.Elapsed.TotalSeconds
}
#Fill Out Language Form, if it is first login
elseif ($Response.forms[0].id -eq "lngfrm") {
  $Form = $Response.Forms[0]

  #Set Default Values
  $Form.Fields.add("lcid",$Response.ParsedHtml.getElementById("selLng").value)
  $Form.Fields.add("tzid",$Response.ParsedHtml.getElementById("selTZ").value)

  $langpath = "$uri/lang.owa"
  $Response = Invoke-WebRequest -Uri $langpath -WebSession $owa -Method $form.Method -Body $form.fields
  $StopWatch.stop()
  $StatusCode = $Response.StatusCode
  $Result = $True
  $Latency = $StopWatch.Elapsed.TotalSeconds
}
elseif ($Response.forms[0].id -eq "logonform") {
  #We are still in LogonPage
  $StopWatch.stop()
  $Result = "Failed to logon $username. Check the password or account."
  $StatusCode = $Response.StatusCode
}
}

}

#Catch Exception, If any
catch
{
$StopWatch.stop()
$Result = $_.Exception.Message
$StatusCode = $Response.StatusCode
if ($StatusCode -notmatch '\d\d\d') {$StatusCode = 0}
}

#Display Results

Write-Host "Status Code: $StatusCode`nResult: $Result`nLatency: $Latency Seconds"