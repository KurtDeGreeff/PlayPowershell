function Get-ComObject {
<#
.Synopsis
Returns a list of ComObjects

.DESCRIPTION
This function has two parameter sets, it can either return all ComObject or a sub-section by the filter parameter. This information is gathered from the HKLM:\Software\Classes container.

.NOTES   
Name: Get-ComObject
Author: Jaap Brasser
Version: 1.0
DateUpdated: 2013-06-24

.LINK
http://www.jaapbrasser.com

.PARAMETER Filter
The string that will be used as a filter. Wildcard characters are allowed.
	
.PARAMETER ListAll
Switch parameter, if this parameter is used no filter is required and all ComObjects are returned

.EXAMPLE
Get-ComObject -Filter *Application

Description:
Returns all objects that match the filter

.EXAMPLE
Get-ComObject -Filter ????.Application

Description:
Returns all objects that match the filter

.EXAMPLE
Get-ComObject -ListAll

Description:
Returns all ComObjects
#>
    param(
        [Parameter(Mandatory=$true,
        ParameterSetName='FilterByName')]
            [string]$Filter,
        [Parameter(Mandatory=$true,
        ParameterSetName='ListAllComObjects')]
            [switch]$ListAll
    )
    $ListofObjects = Get-ChildItem HKLM:\Software\Classes -ErrorAction SilentlyContinue | 
    Where-Object {
        $_.PSChildName -match '^\w+\.\w+$' -and (Test-Path -Path "$($_.PSPath)\CLSID")
    } | Select-Object -ExpandProperty PSChildName 
    
    if ($Filter) {
        $ListofObjects | Where-Object {$_ -like $Filter}
    } else {
        $ListofObjects
    }
}
