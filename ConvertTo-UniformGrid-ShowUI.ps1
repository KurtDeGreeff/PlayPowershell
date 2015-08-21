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