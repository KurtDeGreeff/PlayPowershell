Function Show-Message { 
 
[CmdletBinding()] 
Param (  
   [Parameter(Mandatory=$True,  
              HelpMessage="Content of Message box")] 
   [string]$Message , 
 
   [Parameter(Mandatory=$False, 
             HelpMessage="Title for Message box")] 
   [string]$BoxTitle = "Message" 
)           
 
# Just in case, load the relevant assembly 
$v1 = [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
 
# Now use the messagebox class to display the message 
[Windows.Forms.MessageBox]::Show($Message, $BoxTitle,  
       [Windows.Forms.MessageBoxButtons]::OK ,  
       [Windows.Forms.MessageBoxIcon]::Information)  
 
} # End of function 
 
# Set an alias 
Set-Alias sm Show-Message 

# call the function 
sm 'Please remove USB stick now and re-insert it again after reboot!' 'Remove USB stick


Add-Type -AssemblyName System.Windows.Forms
$result = [System.Windows.Forms.MessageBox]::Show('Please remove USB stick now and re-insert it again after reboot!', 'Remove USB', 'OK', 'Information')
if ($result -eq 'OK')
{Restart-Computer -whatIf}
else
{Write-Warning 'Skipping Restart'} #>
