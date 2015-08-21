$conn = 'LDAP://ldapserver:389/cn=Users,DC=domain,DC=com'
$entry = New-Object System.DirectoryServices.DirectoryEntry($conn,'USERNAME','PASSWORD','none')
$LDAPfilter = '(uid=Kevin.Bhunut*)'
$directorySearcher = New-Object System.DirectoryServices.DirectorySearcher($entry,$LDAPfilter)
$results = $directorySearcher.FindAll()

foreach($result in $results){
    foreach($propertyName in $result.Properties.PropertyNames){

        foreach($property in $result.Properties["$propertyName"]){

            if($(($property | gm).TypeName) -eq 'System.Byte'){
                    $bytes = $property | Select-Object
                    $value = [System.Text.Encoding]::ASCII.GetString($bytes)
            }else{

                $value = $property
            }

            Write-Host "$propertyName :: $value"

        }

    }

        Write-Host "`n`n"
}