   ##########################################################################################
    Function Test-IsNetworkLocation {
        <#
            .SYNOPSIS
                Determines whether or not a given path is a network location or a local drive.
            
            .DESCRIPTION
                Function to determine whether or not a specified path is a local path, a UNC path,
                or a mapped network drive.

            .PARAMETER Path
                The path that we need to figure stuff out about,
        #>
    
        [CmdletBinding()]
        param(
            [Parameter(ValueFromPipeLine = $true)]
            [string]
            [ValidateNotNullOrEmpty()]
            $Path
        )

        $result = $false
    
        if ([bool]([URI]$Path).IsUNC) {
            $result = $true
        } else {
            $driveInfo = [IO.DriveInfo]((Resolve-Path $Path).Path)

            if ($driveInfo.DriveType -eq "Network") {
                $result = $true
            }
        }

        return $result
    }
    ##########################################################################################

    #endregion Helper Functions
    Test-IsNetworkLocation f:

