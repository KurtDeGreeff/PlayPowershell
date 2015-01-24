$source = @”
public class LastBoot
{
  public string ComputerName {get; set;}
  public string LastBootime {get; set;}
}
“@

Add-Type -TypeDefinition $source -Language CSharpVersion3

$computer = $env:COMPUTERNAME

$props = [ordered]@{
  ComputerName = $computer
  LastBootime = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computer | 
    select -ExpandProperty LastBootUpTime
}

New-Object -TypeName LastBoot -Property $props