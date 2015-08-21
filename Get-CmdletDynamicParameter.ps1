#requires -Version 2 
<#The function Get-CmdletDynamicParameter returns a list of dynamic parameters and their default values#>
function Get-CmdletDynamicParameter 
{
  param (
    [Parameter(ValueFromPipeline = $true,Mandatory = $true)]  
    [String] 
    $CmdletName 
  )
  
  process 
  {
    $command = Get-Command -Name $CmdletName -CommandType Cmdlet 
    if ($command)
    {
      $cmdlet = New-Object -TypeName $command .ImplementingType.FullName
      if ($cmdlet -is [Management.Automation.IDynamicParameters])
      {
        $flags = [Reflection.BindingFlags]'Instance, Nonpublic' 
        $field = $ExecutionContext.GetType().GetField('_context', $flags)
        $context = $field.GetValue($ExecutionContext)
        $property = [Management.Automation.Cmdlet].GetProperty('Context', $flags)
        $property.SetValue($cmdlet, $context, $null)
  
        $cmdlet.GetDynamicParameters()
      }
    }
  }
}
 
Get-CmdletDynamicParameter -CmdletName Get-ChildItem