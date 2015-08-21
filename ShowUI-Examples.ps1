New-Object PSObject -Property @{
  FirstName = "Joel"
  LastName = "Bennett"
  BirthDate = [DateTime]"1974-5-22"
} | Select-ViaUI -Show

#But since you don't need to select, it would be more fun to write something custom:

function ConvertTo-UniformGrid {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True, ParameterSetName="Dictionary", Position=0, Mandatory=$True)]
        [Collections.IDictionary]$Dictionary,

        [Parameter(ValueFromPipeline=$True, ParameterSetName="InputObject", Position=0, Mandatory=$True)]
        $InputObject
    )
    process {
        UniformGrid -Columns 2 {
            if($InputObject) {
                $InputObject = Select-Object * -InputObject $InputObject
                foreach($member in Get-Member -InputObject $InputObject -Type NoteProperty) {
                    Label $member.Name
                    Label $InputObject.($Member.Name)
                }
            } else {
                foreach($kv in $Dictionary.GetEnumerator()) {
                    Label $kv.Key
                    Label $kv.Value
                }
            }
        } -Show
    }
}


function ConvertTo-DataGrid {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True, ParameterSetName="Dictionary", Position=0, Mandatory=$True)]
        [Collections.IDictionary]$Dictionary,

        [Parameter(ValueFromPipeline=$True, ParameterSetName="InputObject", Position=0, Mandatory=$True)]
        $InputObject,

        [Switch]$IsReadOnly,

        [Switch]$IsDisabled
    )
    process {
        # UniformGrid -Columns 2 {
        DataGrid -IsReadOnly:$IsReadOnly -IsEnabled:(!$IsDisabled) -HeadersVisibility "None" -ItemsSource @(
            if($InputObject) {
                $InputObject = Select-Object * -InputObject $InputObject
                foreach($member in Get-Member -InputObject $InputObject -Type NoteProperty) {
                    New-Object PSObject -Property ([ordered]@{
                                            Field = $member.Name
                                            Value = $InputObject.($Member.Name)
                                        })
                }
            } else {
                foreach($kv in $Dictionary.GetEnumerator()) {
                    New-Object PSObject -Property ([ordered]@{
                                            Field = $kv.Key
                                            Value = $kv.Value
                                        })
                }
            }
        ) -Show
    }
}