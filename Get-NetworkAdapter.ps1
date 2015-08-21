ipmo showui
function Get-NetworkAdapter
{
$Nics = gwmi -Class Win32_NetworkAdapterConfiguration -Computername "." -Filter IPEnabled=$true | Select-Object -ExpandProperty Description

}
$nic= $nics | Out-GridView -Title "Select your network adapter:" -PassThru


New-Window {
	StackPanel {
		New-Label "Select network adapter:"
		New-Button "OK" -On_Initialized { $this.IsVisible = $false } -On_Click { Close-Control }
	}
} -Show


StackPanel -Orientation Horizontal -DataContext { 
   Get-ChildItem | Sort-Object Extension | Group-Object Extension 
} -Children {
   Listbox -Width 75 -MinHeight 300 -DataBinding @{ ItemsSource = New-Binding -Path "." } -DisplayMemberPath Name -IsSynchronizedWithCurrentItem:$true
   Listbox -MinWidth 350 -DataBinding @{ ItemsSource = New-Binding -Path "CurrentItem.Group" }
} -Show