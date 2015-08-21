Function Get-Constructor {
    <#
        .SYNOPSIS
            Displays the available constructor parameters for a given type

        .DESCRIPTION
            Displays the available constructor parameters for a given type

        .PARAMETER Type
            The type name to list out available contructors and parameters

        .PARAMETER AsObject
            Output the results as an object instead of a formatted table

        .EXAMPLE
            Get-Constructor -Type "adsi"

            DirectoryEntry Constructors
            ---------------------------

            System.String path
            System.String path, System.String username, System.String password
            System.String path, System.String username, System.String password, System.DirectoryServices.AuthenticationTypes aut...
            System.Object adsObject

            Description
            -----------
            Displays the output of the adsi contructors as a formatted table

        .EXAMPLE
            "adsisearcher" | Get-Constructor

            DirectorySearcher Constructors
            ------------------------------

            System.DirectoryServices.DirectoryEntry searchRoot
            System.DirectoryServices.DirectoryEntry searchRoot, System.String filter
            System.DirectoryServices.DirectoryEntry searchRoot, System.String filter, System.String[] propertiesToLoad
            System.String filter
            System.String filter, System.String[] propertiesToLoad
            System.String filter, System.String[] propertiesToLoad, System.DirectoryServices.SearchScope scope
            System.DirectoryServices.DirectoryEntry searchRoot, System.String filter, System.String[] propertiesToLoad, System.D...

            Description
            -----------
            Takes input from pipeline and displays the output of the adsi contructors as a formatted table

        .EXAMPLE
            "adsisearcher" | Get-Constructor -AsObject

            Type                                                        Parameters
            ----                                                        ----------
            System.DirectoryServices.DirectorySearcher                  {}
            System.DirectoryServices.DirectorySearcher                  {searchRoot}
            System.DirectoryServices.DirectorySearcher                  {searchRoot, filter}
            System.DirectoryServices.DirectorySearcher                  {searchRoot, filter, propertiesToLoad}
            System.DirectoryServices.DirectorySearcher                  {filter}
            System.DirectoryServices.DirectorySearcher                  {filter, propertiesToLoad}
            System.DirectoryServices.DirectorySearcher                  {filter, propertiesToLoad, scope}
            System.DirectoryServices.DirectorySearcher                  {searchRoot, filter, propertiesToLoad, scope}

            Description
            -----------
            Takes input from pipeline and displays the output of the adsi contructors as an object

        .INPUTS
            System.Type
        
        .OUTPUTS
            System.Constructor
            System.String

        .NOTES
            Author: Boe Prox
            Date Created: 28 Jan 2013
            Version 1.0
    #>
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline=$True)]
        [Type]$Type,
        [parameter()]
        [switch]$AsObject
    )
    Process {
        If ($PSBoundParameters['AsObject']) {
            $type.GetConstructors() | ForEach {
                $object = New-Object PSobject -Property @{
                    Type = $_.DeclaringType
                    Parameters = $_.GetParameters()
                }
                $object.pstypenames.insert(0,'System.Constructor')
                Write-Output $Object
            }


        } Else {
            $Type.GetConstructors() | Select @{
		        Label="$($type.Name) Constructors"
		        Expression={($_.GetParameters() | ForEach {$_.ToString()}) -Join ", "}
	        }
        }
    }
}