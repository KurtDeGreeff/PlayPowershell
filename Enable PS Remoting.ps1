#Run winrm quickconfig defaults
echo Y | winrm quickconfig

#Run enable psremoting command with defaults
enable-psremoting -force

#Enabled Trusted Hosts for Universial Access
cd wsman:
cd localhost\client
Set-Item TrustedHosts * -force
restart-Service winrm
echo "Complete"