# To create an object whose parent assembly is already loaded:

$object = new-object System.Int32
$object = new-object System.DateTime
$object = new-object System.Net.WebClient
$object = new-object System.Net.Mail.SmtpClient



# But if the assembly containing the class hasn't been loaded, you'll have to load it first:

[System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework")
$object = new-object Microsoft.Win32.OpenFileDialog
$object.ShowDialog()
$object.FileName


# Some .NET object constructor methods require one or more arguments:

$s = new-object -type System.String -argumentlist "Hello"



# To get hints about the possible constructor arguments for a type of object:

[System.String].GetConstructors() | 
foreach-object { $_.getparameters() } | 
select-object  name,member | 
format-table -autosize

