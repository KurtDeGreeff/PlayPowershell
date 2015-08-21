param([string]$Title)


$Global:baseUrl = 'http://odata.msteched.com/tena2012/sessions.svc/'
$Global:url = $baseUrl + 'Sessions'

$search = $url + "?`$filter=substringof('$($Title)', Title)"

function Global:Invoke-ODataTransform ($records) {

    $propertyNames = ($records | Select -First 1).content.properties | 
        Get-Member -MemberType Properties | 
        Select -ExpandProperty name

    foreach($record in $records) {
    
        $h = @{}
        $h.ID = $record.ID
        $properties = $record.content.properties

        foreach($propertyName in $propertyNames) {
            $targetProperty = $properties.$propertyName
            if($targetProperty -is [System.Xml.XmlElement]) {
                $h.$propertyName = $targetProperty.'#text'
            } else {
                $h.$propertyName = $targetProperty 
            }
        }
    
        [PSCustomObject] $h
    }
}

Invoke-ODataTransform (Invoke-RestMethod $search)