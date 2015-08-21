ipmo showUI

showUI\New-TextBlock -Text "Introduction to Powershell GUI" -FontSize 40 -Show

showUI\New-TextBox -Text "Smaller text box" -MinHeight 100 -MinWidth 100 -Show

showUI\New-Calendar -DisplayDate now -DisplayDateEnd "08 April 2014" -SelectionMode MultipleRange -Show

ShowUI\New-TreeView -Items {dir C:\Windows -Directory} -Show

showUI\New-WebBrowser -Source "http://www.bing.com" -Show

showUI\New-UniformGrid -Columns 2 -Rows 3 -Children { New-TextBlock -Text "This is first col" -background red; New-TextBox -Text "This second" `
;New-TreeView -Items {dir c:\}; New-Calendar;New-DatePicker -Foreground blue; New-TextBlock -Background green} -Show

# Get-Eventlogs Gui
$getEventInput = StackPanel -ControlName 'Get-EventLogsSinceDate' { 
New-Label -VisualStyle 'MediumText' -Name "Get Event Logs Since..."
New-ComboBox -IsEditable:$false -SelectedIndex 0 -Name LogName @("Application", "Security", "System", "Setup")
Select-Date -Name After
New-Button "Get Events" -On_Click { 
Get-ParentControl | Set-UIValue -passThru | Close-Control}
} -show
Get-EventLog @getEventInput | Out-GridView


