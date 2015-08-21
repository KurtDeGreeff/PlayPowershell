function Get-EnumValues {  
     <#
    .SYNOPSIS
        Return list of names and values for an enumeration object
     
    .DESCRIPTION
        Return list of names and values for an enumeration object
     
    .PARAMETER Type
        Pass in an actual type, or a string for the type name.

    .EXAMPLE
        Get-EnumValues system.dayofweek

    .EXAMPLE
        [System.DayOfWeek] | Get-EnumValues

     .FUNCTIONALITY
        General Command
    #>
    [cmdletbinding()]
    param(
        [parameter( Mandatory = $True,
                    ValueFromPipeline = $True,
                    ValueFromPipelineByPropertyName = $True)]
        [Alias("FullName")]
        $Type
    )
 
    Process
    {
        [enum]::getvalues($type) |
            Select @{name="Type";  expression={$Type.ToString()}},
                   @{name="Name";  expression={$_}},
                   @{name="Value"; expression={$_.value__}}
    }
}