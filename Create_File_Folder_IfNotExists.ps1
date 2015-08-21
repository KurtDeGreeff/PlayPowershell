function Create-FSOIfNotExists
{
       param(
             [ValidateNotNullOrEmpty()]
             $path,
             [ValidateSet('Directory','File')]
             $itemtype
       )
      
       if(-not(Test-Path -Path $path))
       {
             New-Item -Path $path -ItemType $itemtype |
             Out-Null;
       }
}
Create-FSOIfNotExists c:\testsetset.txt  -itemtype File 