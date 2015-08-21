# Copyright (c) Microsoft Corporation.  All rights reserved. 
# For personal use only.  Provided AS IS and WITH ALL FAULTS. 
 
# Get-WmiNamespaceSecurity.ps1
# Example: Get-WmiNamespaceSecurity root/cimv2
 
Param ( [parameter(Mandatory=$true,Position=0)][string] $namespace,
    [string] $computer = ".",
    [System.Management.Automation.PSCredential] $credential = $null)
 
Process {
    $ErrorActionPreference = "Stop"
 
    Function Get-PermissionFromAccessMask($accessMask) {
        $WBEM_ENABLE            = 1
        $WBEM_METHOD_EXECUTE         = 2
        $WBEM_FULL_WRITE_REP           = 4
        $WBEM_PARTIAL_WRITE_REP     = 8
        $WBEM_WRITE_PROVIDER          = 0x10
        $WBEM_REMOTE_ACCESS            = 0x20
        $READ_CONTROL = 0x20000
        $WRITE_DAC = 0x40000
       
        $WBEM_RIGHTS_FLAGS = $WBEM_ENABLE,$WBEM_METHOD_EXECUTE,$WBEM_FULL_WRITE_REP,`
            $WBEM_PARTIAL_WRITE_REP,$WBEM_WRITE_PROVIDER,$WBEM_REMOTE_ACCESS,`
            $WBEM_RIGHT_SUBSCRIBE,$WBEM_RIGHT_PUBLISH,$READ_CONTROL,$WRITE_DAC
        $WBEM_RIGHTS_STRINGS = "Enable","MethodExecute","FullWrite","PartialWrite",`
            "ProviderWrite","RemoteAccess","Subscribe","Publish","ReadSecurity","WriteSecurity"
 
        $permission = @()
        for ($i = 0; $i -lt $WBEM_RIGHTS_FLAGS.Length; $i++) {
            if (($accessMask -band $WBEM_RIGHTS_FLAGS[$i]) -gt 0) {
                $permission += $WBEM_RIGHTS_STRINGS[$i]
            }
        }
       
        $permission
    }
 
    $INHERITED_ACE_FLAG = 0x10
 
    $invokeparams = @{Namespace=$namespace;Path="__systemsecurity=@";Name="GetSecurityDescriptor";ComputerName=$computer}
 
    if ($credential -eq $null) {
        $credparams = @{}
    } else {
        $credparams = @{Credential=$credential}
    }
 
    $output = Invoke-WmiMethod @invokeparams @credparams
    if ($output.ReturnValue -ne 0) {
        throw "GetSecurityDescriptor failed: $($output.ReturnValue)"
    }
   
    $acl = $output.Descriptor
    foreach ($ace in $acl.DACL) {
        $user = New-Object System.Management.Automation.PSObject
        $user | Add-Member -MemberType NoteProperty -Name "Name" `
            -Value "$($ace.Trustee.Domain)\$($ace.Trustee.Name)"
        $user | Add-Member -MemberType NoteProperty -Name "Permission" `
            -Value (Get-PermissionFromAccessMask($ace.AccessMask))
        $user | Add-Member -MemberType NoteProperty -Name "Inherited" `
            -Value (($ace.AceFlags -band $INHERITED_ACE_FLAG) -gt 0)
        $user
    }
}