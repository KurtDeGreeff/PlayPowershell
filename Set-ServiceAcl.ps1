<#
WARNING: These functions, especially Set-ServiceAcl, make it possible to make mass changes 
to the security descriptors of services, which can be dangerous from both a usability and 
security standpoint. DO NOT use these functions unless you have tested them in a controlled
environment. If you do use them, use them at your own risk. If you don't understand what
these functions do, please don't use them.
 
To use the functions, save the code as a script file, and dot source it. If you'd like to
hide the variables that are created in the global scope, you may save the file as a .psm1
module file, and use Import-Module to load it into the session. This should expose all
of the functions, but none of the variables.
#>
 
# [System.ServiceProcess.ServiceController] isn't loaded unless Get-Service has been
# called, so Add-Type just in case Get-Service hasn't been called yet
Add-Type -AssemblyName System.ServiceProcess
 
# There are several helper variables used that are loaded in global scope if script
# is dot-sourced. These are prefixed with __ to try to prevent collisions. Using the
# script as a module without exporting these variables makes this a much cleaner
# solution...
 
 
# Store namespace and enumeration name in variables so they can easily be changed
$__ServiceAclNamespace = "CustomNamespace.Services"
$__ServiceAccessFlagsEnumerationName = "ServiceAccessFlags"
 
# Store the full name for a faux object type that we'll store in our custom "service
# acl" objects:
$__ServiceAclTypeName = "ServiceAcl"
$__ServiceAclTypeFullName = "$__ServiceAclNamespace.$__ServiceAclTypeName"
 
# Add our service access mask enumeration:
Add-Type  @"
    namespace $__ServiceAclNamespace {
        [System.FlagsAttribute]
        public enum $__ServiceAccessFlagsEnumerationName : uint {
            QueryConfig = 1,
            ChangeConfig = 2,
            QueryStatus = 4,
            EnumerateDependents = 8,
            Start = 16,
            Stop = 32,
            PauseContinue = 64,
            Interrogate = 128,
            UserDefinedControl = 256,
            Delete = 65536,
            ReadControl = 131072,
            WriteDac = 262144,
            WriteOwner = 524288,
            Synchronize = 1048576,
            AccessSystemSecurity = 16777216,
            GenericAll = 268435456,
            GenericExecute = 536870912,
            GenericWrite = 1073741824,
            GenericRead = 2147483648
        }
    }
"@
 
$__ServiceAccessFlagsEnum = "$__ServiceAclNamespace.$__ServiceAccessFlagsEnumerationName" -as [type]
<#
.Synopsis
   Gets the security descriptor for a service or device driver.
.DESCRIPTION
   The Get-ServiceAcl function gets objects that represent the security descriptor of a 
   service or device driver. The security descriptor contains the access control lists 
   (ACLs) of the resources. The ACLs contain access control entries (ACEs) that specify 
   the permissions that users and/or groups have to access the resource.
 
   This function does not currently return the full security descriptor. It currently 
   only returns the Discretionary ACL (DACL), which contains access permissions. It does 
   not return the Owner, Group, or System ACL (which contains ACEs that control object 
   auditing). A future version will have the option to return the full security descriptor.
.PARAMETER ServiceName
   Specifies the name of a service. The function will get the security descriptor of the 
   service identified by the Name. Wildcards are permitted.
.PARAMETER DisplayName
   Specifies the display name of a service. The function will get the security descriptor 
   of the service identified by the DisplayName. Wildcards are permitted.
.PARAMETER ServiceObject
   Specifies an object of type [System.ServiceProcess.ServiceController]. The function 
   will get the security descriptor of the service identified by the object.
.PARAMETER ComputerName
   The name of the computer to get the service ACL from. The default is the local computer. 
   This parameter cannot be used with the -ServiceObject parameter since a ServiceController 
   object already has the computer name.
.EXAMPLE
   PS> Get-ServiceAcl -ServiceName WinRM
    
   This command gets the security descriptor for the WinRM service by specifying the name 
   of the service.
.EXAMPLE
   PS> Get-ServiceAcl -ServiceName WinRM -ComputerName server01
    
   This command gets the security descriptor for the WinRM service on a remote computer 
   named server01 by specifying the name of the service.
.EXAMPLE
   PS> Get-ServiceAcl -DisplayName "Windows Remote Management*"
    
   This command gets the security descriptor for the WinRM service by specifying the 
   display name of the service with a wildcard.
.EXAMPLE
   PS> Get-ServiceAcl -ServiceObject (Get-Service WinRM)
 
   This command gets the security descriptor for the WinRM service by passing a 
   ServiceController object obtained from Get-Service.
.EXAMPLE
   PS> Get-Service WinRM | Get-ServiceAcl
 
   This command gets the security descriptor for the WinRM service by passing a 
   ServiceController object obtained from Get-Service through the pipeline.
.EXAMPLE
   PS> "b*" | Get-ServiceAcl
 
   This command gets the security descriptors for all services that start with the 
   letter b on the local computer.
.EXAMPLE
   PS> Get-Service b* -ComputerName server01 | Get-ServiceAcl
 
   This command gets the security descriptors for all services that start with the 
   letter b on a remote computer named server01.
.EXAMPLE
   PS> [System.ServiceProcess.ServiceController]::GetDevices() | where { $_.Name -like "b*" } | Get-ServiceAcl
 
   This command gets the security descriptors for all device drivers that start with 
   the letter b on the local computer.
.EXAMPLE
   PS> [System.ServiceProcess.ServiceController]::GetDevices("server01") | where { $_.Name -like "b*" } | Get-ServiceAcl
 
   This command gets the security descriptors for all device drivers that start with 
   the letter b on a remote computer named server01.
.EXAMPLE
   PS> $Acl = Get-Service WinRM | Get-ServiceAcl
   PS> $Acl.AddAccessRule((New-AccessControlEntry -ServiceRights "Start,Stop" -Principal "Interactive"))
   PS> $Acl.SDDL
   PS> $Acl | Set-ServiceAcl
 
   This set of commands gets the security descriptor for the WinRM service on the local 
   machine and stores it to a variable named Acl. A new access control entry is then 
   added to the $Acl object, and the new SDDL is output to the screen. Finally, the 
   updated security descriptor is saved by using Set-ServiceAcl.
.NOTES
   The return object contains the following properties:
     - ServiceName: The name of the service where the security descriptor originated
     - ComputerName: The computer name where the service that contains the security 
       descriptor originated
     - SecurityDescriptor: The raw, untouched security descriptor (of type
       System.Security.AccessControl.RawSecurityDescriptor)
     - Access: An array of ACEs in the Discretionary ACL
     - AccessToString: A string representation of the Access property
#>
function Get-ServiceAcl {
    [CmdletBinding(DefaultParameterSetName="ByName")]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ParameterSetName="ByName")]
        [Alias("Name")]
        [string[]] $ServiceName,
        [Parameter(Mandatory=$true, Position=0, ParameterSetName="ByDisplayName")]
        [string[]] $DisplayName,
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ParameterSetName="ByServiceObject")]
        [System.ServiceProcess.ServiceController] $ServiceObject,
        [Parameter(Mandatory=$false, ParameterSetName="ByName")]
        [Parameter(Mandatory=$false, ParameterSetName="ByDisplayName")]
        [Alias('MachineName')]
        [string] $ComputerName = $env:COMPUTERNAME
    )
 
    begin {
        # Make sure enumeration has been added:
        if (-not ($__ServiceAccessFlagsEnum -is [type])) {
            Write-Warning "ServiceAccessFlags enumeration hasn't been loaded!"
            return
        }
 
        # Make sure computer has 'sc.exe':
        $ServiceControlCmd = Get-Command "$env:SystemRoot\system32\sc.exe"
        if (-not $ServiceControlCmd) {
            throw "Could not find $env:SystemRoot\system32\sc.exe command!"
        }
    }
 
    process {
        # Use Get-Service to our advantage to:
        #   1. Expand wild cards if user provided them to -ServiceName or -DisplayName parameters
        #   2. Ensure service(s) exist on local or remote computer
        switch ($PSCmdlet.ParameterSetName) {
            "ByName" {
                $Services = Get-Service -Name $ServiceName -ComputerName $ComputerName -ErrorAction Stop
            }
 
            "ByDisplayName" {
                $Services = Get-Service -DisplayName $DisplayName -ComputerName $ComputerName -ErrorAction Stop 
            }
 
            "ByServiceObject" {
                $Services = $ServiceObject
            }
        }
 
        # If function was called with 'ByName' or 'ByDisplayName' param sets, there may be 
        # multiple service objects, so step through each one:
        $Services | ForEach-Object {
         
            # We might need this info in catch block, so store it to a variable
            $CurrentServiceName = $_.Name
            $CurrentComputerName = $_.MachineName
 
            # Get SDDL using sc.exe
            $Sddl = & $ServiceControlCmd.Definition "\\$CurrentComputerName" sdshow "$CurrentServiceName" | Where-Object { $_ }
 
            try {
                # Get the DACL from the SDDL string
                $Dacl = New-Object System.Security.AccessControl.RawSecurityDescriptor($Sddl)
            }
            catch {
                Write-Warning "Couldn't get security descriptor for service '$CurrentName': $Sddl"
                return
            }
 
            # Create the custom object with the note properties
            $CustomObject = New-Object -TypeName PSObject -Property @{ ServiceName = $_.Name
                                                                       ComputerName = $_.MachineName
                                                                       SecurityDescriptor = $Dacl
                                                                     } | Select-Object ServiceName, ComputerName, SecurityDescriptor
 
            # Give the custom object a faux type name so that the Set-ServiceAcl function can easily tell
            # that the $AclObject passed is correct
            $CustomObject.PsObject.TypeNames.Insert(0, $__ServiceAclTypeFullName)
 
            # Add the 'Access' property:
            $CustomObject | Add-Member -MemberType ScriptProperty -Name Access -Value {
                $AccessRules = @($this.SecurityDescriptor.DiscretionaryAcl | ForEach-Object {
                    $CurrentDacl = $_
 
                    try {
                        $IdentityReference = $CurrentDacl.SecurityIdentifier.Translate([System.Security.Principal.NTAccount])
                    }
                    catch {
                        $IdentityReference = $CurrentDacl.SecurityIdentifier.Value
                    }
                 
                    New-Object -TypeName PSObject -Property @{ ServiceRights = [System.Enum]::Parse($__ServiceAccessFlagsEnum, $CurrentDacl.AccessMask)
                                                               AccessControlType = $CurrentDacl.AceType
                                                               IdentityReference = $IdentityReference
                                                               IsInherited = $CurrentDacl.IsInherited
                                                               InheritanceFlags = $CurrentDacl.InheritanceFlags
                                                               PropagationFlags = $CurrentDacl.PropagationFlags
                                                             } | Select-Object ServiceRights, AccessControlType, IdentityReference, IsInherited, InheritanceFlags, PropagationFlags
                })
 
                # I had a lot of trouble forcing the return to be an array when there's only one object. I 
                # finally settled on using the unary comma to force an array to be returned (so, no, the 
                # comma isn't a typo).
                ,$AccessRules
                 
            }
 
            # Add 'AccessToString' property that mimics a property of the same name from normal Get-Acl call
            $CustomObject | Add-Member -MemberType ScriptProperty -Name AccessToString -Value {
                $this.Access | ForEach-Object {
                    "{0} {1} {2}" -f $_.IdentityReference, $_.AccessControlType, $_.ServiceRights
                } | Out-String
            }
 
            # Add 'RemoveAccessRule' method to mimic the method of the same name from a normal Get-Acl call
            $CustomObject | Add-Member -MemberType ScriptMethod -Name RemoveAccessRule -Value {
                param(
                    [int] $Index = (Read-Host "Enter the index of the Access Control Entry")
                )
 
                $this.SecurityDescriptor.DiscretionaryAcl.RemoveAce($Index)
            }
 
            # Add 'AddAccessRule' method
            $CustomObject | Add-Member -MemberType ScriptMethod -Name AddAccessRule -Value {
 
                param(
                    [System.Security.AccessControl.CommonAce] $Rule
                )
 
                if (-not $Rule) {
                    Write-Warning "You  must provide an object of type System.Security.AccessControl.CommonAce to this method!"
                    return
                }
 
                $this.SecurityDescriptor.DiscretionaryAcl.InsertAce($this.SecurityDescriptor.DiscretionaryAcl.Count, $Rule)
 
            }
 
            # Add 'Sddl' property that returns the SDDL of the Acl object
            $CustomObject | Add-Member -MemberType ScriptProperty -Name Sddl -Value {
                $this.SecurityDescriptor.GetSddlForm("All")
            }
 
            # Emit the custom return object
            $CustomObject
        }
    }
}
 
<#
.Synopsis
   Changes the security descriptor of a service or device driver.
.DESCRIPTION
   The Set-ServiceAcl function changes the security descriptor of a service or device driver to match the 
   values in a security descriptor that you supply.
 
   NOTE: This function makes it possible to make mass changes to the security descriptors on services, which 
   can be dangerous from both a usability and security standpoint. Please do not use this function unless 
   you have tested it fully, and you know exactly what those changes will do.
.PARAMETER AclObject
   Specifies a security descriptor with the desired property values. Set-ServiceAcl changes the security 
   descriptor of the service specified by the ServiceName, DisplayName, or ServiceController object to match 
   the values in the specified AclObject
.PARAMETER ServiceName
   Specifies the name of a service. The function will change the security descriptor of the service 
   identified by the Name. Wildcards are permitted.
.PARAMETER DisplayName
   Specifies the display name of a service. The function will change the security descriptor of the service 
   identified by the DisplayName. Wildcards are permitted.
.PARAMETER ServiceObject
   Specifies an object of type [System.ServiceProcess.ServiceController]. The function will change the 
   security descriptor of the service identified by the object.
.PARAMETER ComputerName
   The name of the computer that contains the object that will have its security descriptor changed. The 
   default is the local computer. This parameter cannot be used with the -ServiceObject parameter since a 
   ServiceController object already has the computer name.
.EXAMPLE
   PS> $Acl = Get-Service WinRM | Get-ServiceAcl
   PS> $Acl.AddAccessRule((New-AccessControlEntry -ServiceRights "Start,Stop" -Principal "Interactive"))
   PS> $Acl | Set-ServiceAcl
 
   This set of commands gets the security descriptor for the WinRM service on the local machine and stores it 
   to a variable named Acl. A new access control entry is then added to the $Acl object that gives the 
   interactive user Start and Stop rights over the service, and the updated security descriptor is saved by 
   using Set-ServiceAcl. 
    
   Because the $Acl object contains the service name and computer name, they did not have to be explicitly 
   specified to the function.
.EXAMPLE
   PS> $Acl = Get-Service WinRM | Get-ServiceAcl
   PS> $Acl.AddAccessRule((New-AccessControlEntry -ServiceRights "Start,Stop" -Principal "Interactive"))
   PS> $Acl | Set-ServiceAcl -ServiceName bits, wi* -WhatIf
 
   This set of commands gets the security descriptor for the WinRM service on the local machine and stores it to 
   a variable named Acl. A new access control entry is then added to the $Acl object that gives the interactive 
   user Start and Stop rights over the service. The security descriptor is then saved to the bits service, and 
   all services that have a service name that starts with 'wi'.  (NOTE: The -WhatIf parameter stops the security 
   descriptor from actually being changed for the services in question. Doing a mass ACL change on multiple 
   services this way is not recommended.)
.EXAMPLE
   PS> $Acl = Get-Service WinRM -ComputerName server01 | Get-ServiceAcl
   PS> $Acl.AddAccessRule((New-AccessControlEntry -ServiceRights "Start,Stop" -Principal "Interactive"))
   PS> $Acl | Set-ServiceAcl -ServiceName bits, wi* -WhatIf
 
   This set of commands gets the security descriptor for the WinRM service on the remote computer 'server01' and 
   stores it to a variable named Acl. A new access control entry is then added to the $Acl object that gives the 
   interactive user Start and Stop rights over the service. The security descriptor is then saved to the bits 
   service on the remote computer, and all services that have a service name that starts with 'wi' on the remote 
   computer.  (NOTE: The -WhatIf parameter stops the security descriptor from actually being changed for the 
   services in question. Doing a mass ACL change on multiple services this way is not recommended.)
 
   Because the ACL object contains the remote computer name, any call to Set-ServiceAcl without explicitly 
   providing the -ComputerName parameter to the function will modify the security descriptor on the remote machine.
#>
function Set-ServiceAcl {
    [CmdletBinding(DefaultParameterSetName="ByName",SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true, ParameterSetName="ByName")]
        [Alias("Name")]
        [string[]] $ServiceName,
        [Parameter(Mandatory=$true, Position=0, ParameterSetName="ByDisplayName")]
        [string[]] $DisplayName,
        [Parameter(Mandatory=$true, Position=0, ParameterSetName="ByServiceObject")]
        [System.ServiceProcess.ServiceController] $ServiceObject,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        #[ValidateScript({ $this.PsObject.TypeNames -contains $__ServiceAclTypeFullName })]
        $AclObject,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ParameterSetName="ByName")]
        [Parameter(Mandatory=$false, ParameterSetName="ByDisplayName")]
        [string] $ComputerName = $env:COMPUTERNAME
    )                                   
 
    begin {
        # Make sure computer has 'sc.exe':
        $ServiceControlCmd = Get-Command "$env:SystemRoot\system32\sc.exe"
        if (-not $ServiceControlCmd) {
            throw "Could not find $env:SystemRoot\system32\sc.exe command!"
        }
    }
     
    process {
 
        # Validate AclObject:
        if (-not ($AclObject.PsObject.TypeNames -contains $__ServiceAclTypeFullName)) {
            Write-Warning "`$AclObject is not a valid Service Acl object (`$AclObject must be created by calling Get-ServiceAcl)"
            return
        }
 
        # Use Get-Service to our advantage to:
        #   1. Expand wild cards if user provided them to -ServiceName or -DisplayName parameters
        #   2. Ensure service(s) exist on local or remote computer
        switch ($PSCmdlet.ParameterSetName) {
            "ByName" {
                $Services = Get-Service -Name $ServiceName -ComputerName $ComputerName -ErrorAction Stop
            }
 
            "ByDisplayName" {
                $Services = Get-Service -DisplayName $DisplayName -ComputerName $ComputerName -ErrorAction Stop 
            }
 
            "ByServiceObject" {
                $Services = $ServiceObject
            }
        }
 
        # If function was called with 'ByName' or 'ByDisplayName' param sets, there may be multiple service objects,
        # so step through each one:
        $Services | ForEach-Object {
 
            # Get SDDL:
            $Sddl = $AclObject.Sddl
 
            $CurrentComputerName = $_.MachineName
            $CurrentServiceName = $_.Name
 
            $ShouldProcessDescription = "Set ACL for service '{0}' on computer '{1}' to $Sddl" -f $CurrentServiceName, $CurrentComputerName
            if ($PSCmdlet.ShouldProcess("$ShouldProcessDescription`.", "$ShouldProcessDescription`?", "Confirm ACL Change")) {
                $Arguments = '"\\{0}" sdset "{1}" "{2}"' -f $CurrentComputerName, $CurrentServiceName, $Sddl
 
                Write-Verbose ("Running command: {0} {1}" -f $ServiceControlCmd.Definition, $Arguments)
                $ReturnString = & $ServiceControlCmd.Definition $Arguments
                Write-Verbose "Output from sc.exe: $ReturnString"
 
                # Not sure if the return string is the same for all OSes, hoping this basic regex will work
                if ($ReturnString -notmatch "SUCCESS$") {
                    Write-Warning "Error setting ACL: $ReturnString"
                }
            }
        }            
    }
}
 
<#
.Synopsis
   Creates a new access control entry for a securable object.
.DESCRIPTION
   The New-AccessControlEntry function creates access control entries (ACEs) that can be added to access control 
   lists (ACLs).
 
   The function currently supports creating ACEs for registry rights, file and folder rights, and service rights.
.EXAMPLE
   PS> New-AccessControlEntry -FileSystemRights Modify -Principal Users -InheritanceFlags ContainerInherit,ObjectInherit
 
   This command creates an ACE allowing file modify rights to the 'Users' local group, with ContainerInherit and 
   ObjectInherit inheritance flags.
.EXAMPLE
   PS> New-AccessControlEntry -RegistryRights FullControl -Principal Users
 
   This command creates an ACE allowing registry full control rights to the 'Users' local group.
.EXAMPLE
   PS> New-AccessControlEntry -ServiceRights "Start,Stop" -Principal Users
 
   This command creates an ACE allowing service Start and Stop rights to the 'Users' local group.
.PARAMETER FileSystemRights
   Specifies the file system rights for the ACE. This parameter cannot be used with the RegistryRights or 
   ServiceRights parameters.
 
   Valid values can be found in the [System.Security.AccessControl.FileSystemRights] enumeration.
.PARAMETER RegistryRights
   Specifies the registry rights for the ACE. This parameter cannot be used with the FileSystemRights or 
   ServiceRights parameters.
 
   Valid values can be found in the [System.Security.AccessControl.RegistryRights] enumeration.
.PARAMETER ServiceRights
   Specifies the service rights for the ACE. This parameter cannot be used with the FileSystemRights or 
   RegistryRights parameters.
 
   Valid values can be found in a custom enumeration defined at the same time as this function.
.PARAMETER Principal
   Specifies a user or group account.
.PARAMETER InheritanceFlags
   Specifies any inheritance flags for the ACE.
.PARAMETER PropagationFlags
   Specifies any propagation flags for the ACE.
.PARAMETER AccessControlType
   Specifies whether or not the ACE is an Allow or Deny entry.
.NOTES
   The function currently only creates ACEs that can be used with discretionary ACLs, but it can easily be 
   extended to work with system ACLs (used for auditing). The functionc an also be easily extended to work 
   with any other securable object, e.g., printers, shares, etc.
#>
function New-AccessControlEntry {
    [CmdletBinding(DefaultParameterSetName='File')]
    param(
        [Parameter(Mandatory=$true, ParameterSetName='File')]
        [System.Security.AccessControl.FileSystemRights] $FileSystemRights,
        [Parameter(Mandatory=$true, ParameterSetName='Registry')]
        [System.Security.AccessControl.RegistryRights] $RegistryRights,
        [Parameter(Mandatory=$true, ParameterSetName='Service')]
        [string] $ServiceRights,
        [Parameter(Mandatory=$true)]
        [Alias('User','Group','IdentityReference')]
        [System.Security.Principal.NTAccount] $Principal,
        [System.Security.AccessControl.InheritanceFlags] $InheritanceFlags = "None",
        [System.Security.AccessControl.PropagationFlags] $PropagationFlags = "None",
        [System.Security.AccessControl.AccessControlType] $AccessControlType = "Allow"
    )
 
 
    switch ($PSCmdlet.ParameterSetName) {
 
        "File" {
            $AccessControlObject = "System.Security.AccessControl.FileSystemAccessRule"
 
            $Arguments = @( $Principal         # System.String
                            $FileSystemRights  # System.Security.AccessControl.FileSystemRights
                            $InheritanceFlags  # System.Security.AccessControl.InheritanceFlags
                            $PropagationFlags  # System.Security.AccessControl.PropagationFlags
                            $AccessControlType # System.Security.AccessControl.AccessControlType
                          )
            break
        }
 
        "Registry" {
            $AccessControlObject = "System.Security.AccessControl.RegistryAccessRule"
 
            $Arguments = @( $Principal         # System.String
                            $RegistryRights    # System.Security.AccessControl.RegistryRights
                            $InheritanceFlags  # System.Security.AccessControl.InheritanceFlags
                            $PropagationFlags  # System.Security.AccessControl.PropagationFlags
                            $AccessControlType # System.Security.AccessControl.AccessControlType
                          )
            break
        }
 
        "Service" {
             
            if (-not ($__ServiceAccessFlagsEnum -is [type])) {
                Write-Warning "[ServiceAccessFlags] enumeration has not been added; cannot create ACE"
                return
            }
 
            $AccessControlObject = "System.Security.AccessControl.CommonAce"
 
            # AceQualifer has four possible values: AccessAllowed, AccessDenied, SystemAlarm, and SystemAudit
            # We need to convert AccessControlType (can only be Allow or Deny) to proper AceQualifer enum
            if ($AccessControlType -eq "Allow") { $AceQualifer = "AccessAllowed" }
            else { $AceQualifer = "AccessDenied" }
 
            # Make sure $ServiceRights are valid:
            try {
                $AccessMask = [int] [System.Enum]::Parse($__ServiceAccessFlagsEnum, $ServiceRights, $true)  # Third argument means ignore case
            }
            catch {
                Write-Warning "Invalid ServiceRights defined; cannot create ACE"
                return
            }
 
            $Arguments = @( "None"       # System.Security.AccessControl.AceFlags
                            $AceQualifer # System.Security.AccessControl.AceQualifier
                            $AccessMask
                            $Principal.Translate([System.Security.Principal.SecurityIdentifier])
                            $false       # isCallback?
                            $null        # opaque data (only for callbacks)
                          )
            break
        }
 
        default {
            Write-Warning "Unknown ParameterSetName"
            return
        }
 
    }
 
    # Create the ACE object
    New-Object -TypeName $AccessControlObject -ArgumentList $Arguments
}