$ScriptPath   = (Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path)


$MDTPath = “$env:systemdrive\Program Files\Microsoft Deployment Toolkit”

Import-Module “$MDTPath\bin\MicrosoftDeploymentToolkit.psd1”

#New-PSDrive -Name "$NameOfDeploymentShare" -PSProvider "MDTProvider" -Root "$PathToLocalSharedFolder" -Description "$FriendlyNameOfDeploymentShare" -NetworkPath "\\$env:Computername\$NameOfShare" -Verbose | 
#add-MDTPersistentDrive –Verbose