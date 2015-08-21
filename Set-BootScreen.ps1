#This script is about to edit your registry.
#Continue at your own risk
#Translation: Don't come crying to me if this crashes your machine.  You should know better!
#Nic Cain says this doesn't work on XP

<#Furthermore - Buck take it away!
Script Disclaimer, for people who need to be told this sort of thing: 
Never trust any script, including those that you find here, until you understand exactly what it does and how it will act on your systems. 
Always check the script on a test system or Virtual Machine, not a production system. 
Yes, there are always multiple ways to do things, and this script may not work in every situation, for everything. It’s just a script, people. 
All scripts on this site are performed by a professional stunt driver on a closed course. 
Your mileage may vary. Void where prohibited. Offer good for a limited time only. 
Keep out of reach of small children. Do not operate heavy machinery while using this script. 
If you experience blurry vision, indigestion or diarrhea during the operation of this script, see a physician immediately.
#>
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background\ -name OEMBackground -value 1

$wc = new-object net.webclient
$wc.DownloadFile("http://sqlvariant.com/BlogSupport/Images/SQLServer2008BackgroundDark.jpg", "c:\temp\SQLServer2008BackgroundDark.jpg")
#sqlvariant.com/BlogSupport/Images/SQLServer2008BackgroundDark.jpg
cd C:\Windows\System32\Oobe
mkdir info
cd info
mkdir backgrounds
cd backgrounds

Copy-Item c:\temp\SQLServer2008BackgroundDark.jpg C:\Windows\System32\Oobe\info\backgrounds\backgroundDefault.jpg

