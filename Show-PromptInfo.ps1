<#Prompting for Function Parameters

With a simple trick, you can add a dialog window that helps users to provide the function parameters for your function.
Simply use $PSBoundParameters to determine if a user submitted parameters. 
If not, run Show-Command and submit the name of your function, then return your function without doing anything.
Show-Command automatically takes care of the rest: it displays a dialog which prompts for all function parameters, 
and once the user clicks "Run", it runs the function with the submitted arguments
When you run the function Show-PromptInfo with parameters, it immediately executes your call.
When you run the function without any parameters, a dialog opens and prompts interactively for your parameters.#>

function Show-PromptInfo 
{
  param 
  (
    [string] 
    $Name, 
    
    [int] 
    $ID 
  )
  if ($PSBoundParameters.Count -eq 0)
  {
    Show-Command -Name Show-PromptInfo 
    return 
  }
  
  "Your name is $name, and the id is $id." 
}