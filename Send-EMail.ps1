##############################################################################
#  Script: Send-EMail.ps1
#    Date: 7.Sept.2007
# Version: 1.3
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Send e-mail using SMTP or SMTPS.
#   Notes: If multiple addresses to the addressing fields, separate with commas.
#          Use the -useintegrated switch to use NTLM or Kerberos with the
#          credentials of the person running the script.  If you add an 
#          attachment, you must specify full path to file.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

param ($to, $cc, $bcc, $from, $subject, $body, $username, $password, 
       $smtpserver, $file, [Switch] $UseIntegrated, [Switch] $UseSSL) 


function send-email ($to, $cc, $bcc, $from, $subject, $body, $username, $password, 
                     $smtpserver, $file, [Switch] $UseIntegrated, [Switch] $UseSSL) 
{
    $mail = new-object System.Net.Mail.MailMessage
    $mail.To.Add($to)       
    $mail.From = $from   
    
    if ($cc)  { $mail.CC.Add($cc)   }
    if ($bcc) { $mail.BCC.Add($bcc) }
    if ($body){ $mail.Body = $body  }
    if ($subject) { $mail.Subject = $subject }

    if ($file) {
        $attachment = new-object System.Net.Mail.Attachment -arg $file
        $mail.Attachments.Add($attachment)
    }
    
    $smtpclient = new-object System.Net.Mail.SmtpClient
    $smtpclient.Host = $smtpserver
    $smtpclient.Port = 25
    $smtpclient.Timeout = 30000  #milliseconds

    if ($UseSSL) { $smtpclient.EnableSSL = $true ; $smtpclient.Port = 465 }

    if ($UseIntegrated)
        { $smtpclient.UseDefaultCredentials = $true }
    elseif ($username)
        { $smtpclient.Credentials = new-object System.Net.NetworkCredential($username, $password) 
          if (-not $UseSSL) { "WARNING: Password sent in plaintext! Use SSL!" }
        }
    else
        { $smtpclient.UseDefaultCredentials = $false } # Send message without authentication. 
   
   
    $smtpclient.Send($mail)
   
}



send-email -to $to -cc $cc -bcc $bcc -from $from -subject $subject -body $body `
           -username $username -password $password -smtpserver $smtpserver `
           -file $file
           
          