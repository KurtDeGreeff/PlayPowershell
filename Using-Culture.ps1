Function Using-Culture (
[System.Globalization.CultureInfo]$culture = (throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"),
[ScriptBlock]$script= (throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"))
{
    $OldCulture = [System.Threading.Thread]::CurrentThread.CurrentCulture
    trap 
    {
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture
    }
    [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture
    Invoke-Command $script
    [System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture
}
using-culture fr-be {get-date}