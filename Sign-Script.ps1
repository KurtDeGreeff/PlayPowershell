####################################################################################
#.Synopsis 
#    Digitally signs PowerShell scripts. 
#
#.Description 
#    If you have a code-signing certificate, this script can sign one or
#    multiple other scripts for the sake of satisfying PowerShell's
#    execution policy restrictions.  The script will not create or enroll
#    for a code-signing certificate, this must be obtained separately first.
#
#.Parameter Path  
#    Either 1) a string with or without wildcards to one or more PowerShell 
#    scripts, or 2) one or more FileInfo objects representing scripts.
#
#.Parameter Recurse
#    Switch to recurse through subdirectories of the given path.
#
#.Parameter Thumbprint
#    Optional hash of the code-signing certificate to use if the user has
#    more than one available certificate with that purpose.
#
#.Parameter DoNotAskWhichCertificateToUse
#    Switch to avoid compelling the user to enter a thumbprint when 
#    multiple code-signing certificates are available.  This
#    switch will simply use the first certificate in the list.
#
#.Example 
#    .\sign-script.ps1 -path onescript.ps1
#.Example 
#    .\sign-script.ps1 -path c:\folder\*many*.ps1 
#.Example 
#    .\sign-script.ps1 -path c:\folder -recurse 
#.Example 
#    .\sign-script.ps1 foo.ps1 -thumprint 4342368F1339CB59010AE3720ED5672B73E94CD4
#.Example 
#    .\sign-script.ps1 -path script.ps1 -DoNotAskWhichCertificateToUse
#
#
#Requires -Version 2.0 
#
#.Notes 
#  Author: Jason Fossen (http://www.sans.org/windows-security/)  
# Version: 1.0
# Updated: 3.Oct.2011
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR 
#          GUARANTEES OF ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY 
#          AND/OR FITNESS FOR A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS 
#          WITH THE USER, EVEN IF THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN 
#          ADVISED OF THE POSSIBILITY OF ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT 
#          PERMIT THE COMPLETE LIMITATION OF LIABILITY, THEN DELETE THIS FILE 
#          SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################



param ( $Path, [Switch] $Recurse, $Thumbprint = "blank" , [Switch] $DoNotAskWhichCertificateToUse )

# Expand path of script(s) to sign.
if (-not $Path) { "`nError, you must enter the path to one or more scripts to sign, wildcards are permitted, exiting.`n" ; exit } 
if ($Recurse) { $Path = (dir $Path -include *.ps1 -force -recurse) } else { $Path = (dir $Path -include *.ps1 -force) } 
if ($Path -eq $null) { "`nError, invalid argument to -Path parameter, exiting.`n" ; exit } 

# Get the current user's code-signing cert(s), if any.
$certs = @(dir cert:\currentuser\my -codesigningcert)

# Check for zero, one or multiple code-signing certificates.
if ($certs.count -eq 0) { "`nYou have no code-signing certificates, exiting.`n" ; exit }
elseif ($Thumbprint -ne "blank") { $signingcert = ($certs | where { $_.Thumbprint -match "$Thumbprint" }) } 
elseif ($certs.count -ge 1 -or $DoNotAskWhichCertificateToUse) { $signingcert = $certs[0] }
elseif ($Thumbprint -eq "blank") { "`nYou have multiple code-signing certificates.  Run the script again, but enter the thumbprint of the one you wish to use as the argument to the -Thumbprint parameter (or use -DoNotAskWhichCertificateToUse to simply use the first certificate available).`n" ; $certs | format-list Thumbprint,Issuer,Subject,SerialNumber,NotAfter,FriendlyName ; exit } 
else { "`nError, should not have gotten here, exiting.`n" ; exit } 

# Quick check that we actually got a cert to use...
if ($certs -notcontains $signingcert) 
{ 
    "`nError, an invalid certificate choice was made, exiting.`n"
    if ($Thumbprint -ne "blank") { "Did you enter the correct thumbprint hash value without`n any spaces, colons or other delimiters?`n" } 
    exit 
} 

# Sign each script.
foreach ($file in $Path) { set-authenticodesignature -filepath $file -certificate $signingcert } 

