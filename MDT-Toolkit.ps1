Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "D:\Deploy"


Update-MDTLinkedDS -Path "DS001:\Linked Deployment Shares\LINKED002" -Verbose -WhatIf
Update-MDTMedia -path "DS001:\Media\MEDIA001" -Verbose -WhatIf

#Create Linked Deployment share; modify -Root and -Name to create another one
#new-item -path "DS001:\Linked Deployment Shares" -enable "True" -Name "LINKED001" -Comments "" -Root "\\10.5.22.177\deploy$" -SelectionProfile "KVM" -Replace "False" -CopyStandardFolders "True" -UpdateBoot "True" -SingleUser "True" -Verbose