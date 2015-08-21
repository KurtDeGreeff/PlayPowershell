<#
.Synopsis
    Lists Folder ACLs for a targeted directory
.DESCRIPTION
    Leverages the Get-ACL cmdlet's Access property to display the ACLs for a targeted directory in a list format.
.EXAMPLE
    Local or Mapped Drive: Get-FolderACL -Path C:\Scripts
.EXAMPLE
    Network Drive: Get-FolderACL -Path \\Server01\Share
.NOTES
    Created by Will Anderson - December 31, 2014
    Version 1.1
#>

Function Get-FolderACL{[cmdletbinding()]

    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)][ValidateNotNullorEmpty()][string[]]$Path
    )#EndParam
        BEGIN{Write-Verbose "Reading ACLs for $($MyInvocation.Mycommand)"
        }#BEGIN

        PROCESS{$Directory = Get-Acl -Path $Path
                    Try{
                        ForEach($Dir in $Directory.Access){
                            Write-Verbose "Reading Permissions for $($Dir.IdentityReference)"
                            [PSCustomObject]@{
                                Path = $Path
                                Group = $Dir.IdentityReference
                                AccessType = $Dir.AccessControlType
                                Rights = $Dir.FileSystemRights
                                }
                        }#EndForEach
                    }#EndTry
                    Catch{
                          Write-Error $PSItem
                    }#EndCatch
         }#PROCESS
         
         END{Write-Verbose "Ending $($MyInvocation.Mycommand)"
         }#END

}#EndFunction
