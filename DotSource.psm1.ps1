#requires -version 3
$accelerators = [psobject].Assembly.GetType(
    'System.Management.Automation.TypeAccelerators'
)

foreach ($Type in 
    'Parser', 
    'FunctionDefinitionAst',
    'AssignmentStatementAst',
    'VariableExpressionAst',
    'TokenKind') 
{
    $accelerators::Add(
        $Type,
        "System.Management.Automation.Language.$Type"
    )    
}


function Import-Script {
param (
    $Path,
    [ValidateSet(
        'Script',
        'Global',
        'Local'
    )]
    $Scope = 'Global',
    [switch]$IncludeVariables
)

    $fullName = (Resolve-Path $Path).ProviderPath
    $ast = [Parser]::ParseFile(
        $fullName,
        [ref]$null,
        [ref]$null
    )
    foreach ($function in $ast.FindAll({
        $args[0] -is [FunctionDefinitionAst]
        }, $false)) {
        $define = $false
        switch -Regex ($function.Name) {
            '^(?!.*:)' {
                $define = $true
                $name = $function.Name
                break
            }
            '(Global|Script|Local):' {
                $define = $true
                $name = $function.Name -replace '.*:'
            }
            default {
                $define = $false
            }
        }
        if ($define) {
            & ([scriptblock]::Create("
                function $Scope`:$name
                $($function.Body)
                "
            ))
        }
    }
    if ($IncludeVariables) {
    foreach ($variable in $ast.FindAll({
        $args[0] -is [AssignmentStatementAst] -and
        $args[0].Operator -eq [TokenKind]::Equals -and
        $args[0].Left -is [VariableExpressionAst]
        }, $false)) {
        $define = $false
        switch -Regex ($variable.Left.VariablePath) {
            '^(?!.*:)' {
                $define = $true
                $name = $variable.Left.VariablePath
                break
            }
            '(Global|Script|Local):' {
                $define = $true
                $name = $variable.Left.VariablePath -replace '.*:'
            }
            default {
                $define = $false
            }
        }
        if ($define) {
            & ([scriptblock]::Create(
                "`$$Scope`:$name = $(
                $variable.Right.Extent.Text
                )"
            ))
        }
    }
    }
}

New-Alias -Name .. -Value Import-Script -Force
Export-ModuleMember -Function * -Alias *