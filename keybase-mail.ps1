
  #==========================================#
  # Keybase Encrypted Mailer                 #
  # greg . foss [at] owasp . org             #
  # https://keybase.io/heinzarelli           #
  # v0.1  --  August 2015                    #
  #==========================================#

<#
    Requires Keybase Command Line for Windows
        https://keybase.io/docs/command_line

.NAME
Invoke-KeybaseMail

.SYNOPSIS
PowerShell Keybase Encrypted Mailer

.DESCRIPTION
A simple script that takes the existing Keybase Windows Command Line parameters and utilizes them to send encrypted/signed mail directly.

.INSTALL
    Install Invoke-KeybaseMail Module (note the two dots!). Once this is installed, you can simply call the function.
        PS C:\> . .\keybase-mail.ps1

.EXAMPLE
    Send Emcrypted Email
        PS C:\> Invoke-KeybaseMail -encrypt [recipient's keybase user name] -from from@address.com -to to@address.com -smtpServer 127.0.0.1 -subject "test" -message "test"

.EXAMPLE
    Send Signed and Encrypted Email
        PS C:\> Invoke-KeybaseMail -encrypt [recipient's keybase user name] -sign -from from@address.com -to to@address.com -smtpServer 127.0.0.1 -subject "test" -message "test"

.EXAMPLE
    Send Clear-Signed Email
        PS C:\> Invoke-KeybaseMail -clearSign -from from@address.com -to to@address.com -smtpServer 127.0.0.1 -subject "test" -message "test"

.EXAMPLE
    Attach a file
        Coming soon...

.NOTES
    You may want to hard-code most of these parameters, so you can send mail easily without having to supply these parameters at run-time.
#>

Function Invoke-KeybaseMail {

[CmdLetBinding()]
param(
    [Parameter(Mandatory=$false,Position=0)]
    [string]$to,

    [Parameter(Mandatory=$false,Position=1)]
    [string]$from,

    [Parameter(Mandatory=$false,Position=2)]
    [string]$smtpServer,

    [Parameter(Mandatory=$false,Position=3)]
    [string]$subject,

    [Parameter(Mandatory=$false,Position=4)]
    [string]$message,

    [Parameter(Mandatory=$false,Position=5)]
    [string]$encrypt, # enter the recipient's keybase username

    [Parameter(Mandatory=$false,Position=6)]
    [switch]$sign = $false,

    [Parameter(Mandatory=$false,Position=7)]
    [switch]$clearSign = $false,

    [Parameter(Mandatory=$false,Position=8)]
    [string]$file
)

$ErrorActionPreference= 'silentlycontinue'

#------------------------------
# Build Message
#------------------------------

if ( $encrypt ) {
    if ( $sign ) {
        $encryptedMessage = keybase encrypt $encrypt sign -m "$message"
    } Else {
        $encryptedMessage = keybase encrypt $encrypt -m "$message"
    }
} Elseif ( $clearSign ) {
        $encryptedMessage = keybase sign --clearsign -m "$message<br />"
} ElseIf ( $sign) {
        $encryptedMessage = keybase sign -m "$message"
} Else {
    Write-Host ""
    Write-Host "Please specify how you'd like to encrypt and/or sign the message"
}
$encryptedMessageHTML = $encryptedMessage | foreach {$_ + "<br />"}

#------------------------------
# Send Email
#------------------------------

function sendEmail {
        $msg = New-Object System.Net.Mail.MailMessage
        $smtp = New-Object System.Net.Mail.SMTPClient($smtpServer)
        if ( $file ) { $attachment = New-Object Net.Mail.Attachment($file) }
        $msg.From = $from
        $msg.To.Add($to)
        $msg.Subject = $subject
        $msg.Body = "<p style='font:16px Lucida Console,Monaco,monospace;color:#1F497D;'>$encryptedMessageHTML</p>"
        $msg.IsBodyHTML = $true
        if ( $file ) { $msg.Attachments.Add($attachment) }
        $smtp.Send($msg)
}
    Write-Host ""
    If ( $encrypt ) { Write-Host "     Sending encrypted email using SMTP Server : $smtpServer" }
    ElseIf ( $clearSign ) { Write-Host "     Sending signed email using SMTP Server: $smtpServer" }
    Else { Write-Host "     Sending email using SMTP Server: $smtpServer" }
    sendEmail
    Write-Host "     Message From : $from"
    Write-Host "     Message To : $to"
    Write-Host "     Subject : $subject"
    Write-Host ""
    $encryptedMessage
}