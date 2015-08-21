$CimClasses = Get-CimClass -QualifierName SupportsUpdate 
  Foreach ($CimClass in $CimClasses) 
     { 
         $Write = Get-CimClass -ClassName $CimClass.CimClassName | 
             Select-Object -ExpandProperty CimClassProperties | 
             Where-Object {$_.Qualifiers -like "*write*"} 
         Foreach ($CimPropertyName in $Write.Name) 
             { 
                 [PSCustomObject]@{ 
                     CIMClass=$CimClass.CimClassName 
                     CIMPropertyName=$CimPropertyName 
                     CIMPropertyQualifiers=$Write.Qualifiers 
                     } 
             } 
     }