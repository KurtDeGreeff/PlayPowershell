#requires -version 2

param($what, [switch]$gridView, [switch]$msdnView)

# Looks returns all of the .NET types
# currently loaded by PowerShell
function Get-Type() {
  [AppDomain]::CurrentDomain.GetAssemblies() |
  	% { $_.GetTypes() }
}

# Opens a webpage to MSDN
# on the Type
function Get-MSDNInfo([Type]$t) {
  $culture=$(Get-Culture)
  $name="$($t.FullName).aspx"
  $url = "http://msdn.microsoft.com/$culture/library/$name"
  (New-Object -com Shell.Application).Open($url)
}

# Create a new instance of an object and
# displays member info with Out-GridView,
# so you can search the information to find a
# property that might do what you want
function Show-ClassInfo([Type]$t) {
  Get-Member -input (New-Object $t.FullName $args) | Out-Gridview
}

$cmd="Show-ClassInfo"
if($msdnView) {$cmd="Get-MSDNInfo"}

& $cmd (Get-Type |
	Where-Object { $_.IsSubclassOf([Windows.Controls.Control]) } |
		Where-Object {$_.Name -eq "$what"}).FullName