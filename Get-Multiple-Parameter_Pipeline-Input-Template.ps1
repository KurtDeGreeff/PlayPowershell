<#
Note how the parameter is defined as an object array (so it can accept multiple values). 
Next, the parameter value runs through ForEach-Object to process each element individually. 
This takes care of the first example call: assigning comma-separated (multiple) values.
To be able to accept multiple values via pipeline, make sure you assign ValueFromPipeline 
to the parameter that is to accept pipeline input. Next, add a Process script block to your function. 
It serves as a loop, very similar to ForEach-Object, and runs for each incoming pipeline item.
#>
 function Get-Multiple-Parameter_Pipeline-Input-Template
{
  param  
  (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]    
    [Object[]]    
    $InputObject 
  )
  process  #Takes care of pipeline input
  {
  $InputObject | ForEach-Object {
    $element = $_
    "processing $element"    
    }
  }
}


