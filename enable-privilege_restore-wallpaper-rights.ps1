# Windows PowerShell script to restore the right to set your desktop wallpaper when a group policy blocked it.
# Must be executed as administrator.

# Automates the steps described at http://neuralfibre.com/paul/it/how-to-block-your-corporate-wallpaper-in-windows

Set-StrictMode -Version 2.0

function enable-privilege {
 param(
  ## The privilege to adjust. This set is taken from
  ## http://msdn.microsoft.com/en-us/library/bb530716(VS.85).aspx
  [ValidateSet(
   "SeAssignPrimaryTokenPrivilege", "SeAuditPrivilege", "SeBackupPrivilege",
   "SeChangeNotifyPrivilege", "SeCreateGlobalPrivilege", "SeCreatePagefilePrivilege",
   "SeCreatePermanentPrivilege", "SeCreateSymbolicLinkPrivilege", "SeCreateTokenPrivilege",
   "SeDebugPrivilege", "SeEnableDelegationPrivilege", "SeImpersonatePrivilege", "SeIncreaseBasePriorityPrivilege",
   "SeIncreaseQuotaPrivilege", "SeIncreaseWorkingSetPrivilege", "SeLoadDriverPrivilege",
   "SeLockMemoryPrivilege", "SeMachineAccountPrivilege", "SeManageVolumePrivilege",
   "SeProfileSingleProcessPrivilege", "SeRelabelPrivilege", "SeRemoteShutdownPrivilege",
   "SeRestorePrivilege", "SeSecurityPrivilege", "SeShutdownPrivilege", "SeSyncAgentPrivilege",
   "SeSystemEnvironmentPrivilege", "SeSystemProfilePrivilege", "SeSystemtimePrivilege",
   "SeTakeOwnershipPrivilege", "SeTcbPrivilege", "SeTimeZonePrivilege", "SeTrustedCredManAccessPrivilege",
   "SeUndockPrivilege", "SeUnsolicitedInputPrivilege")]
  $Privilege,
  ## The process on which to adjust the privilege. Defaults to the current process.
  $ProcessId = $pid,
  ## Switch to disable the privilege, rather than enable it.
  [Switch] $Disable
 )

 ## Taken from P/Invoke.NET with minor adjustments.
 $definition = @'
 using System;
 using System.Runtime.InteropServices;
  
 public class AdjPriv
 {
  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,
   ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);
  
  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);
  [DllImport("advapi32.dll", SetLastError = true)]
  internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);
  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct TokPriv1Luid
  {
   public int Count;
   public long Luid;
   public int Attr;
  }
  
  internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
  internal const int SE_PRIVILEGE_DISABLED = 0x00000000;
  internal const int TOKEN_QUERY = 0x00000008;
  internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
  public static bool EnablePrivilege(long processHandle, string privilege, bool disable)
  {
   bool retVal;
   TokPriv1Luid tp;
   IntPtr hproc = new IntPtr(processHandle);
   IntPtr htok = IntPtr.Zero;
   retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
   tp.Count = 1;
   tp.Luid = 0;
   if(disable)
   {
    tp.Attr = SE_PRIVILEGE_DISABLED;
   }
   else
   {
    tp.Attr = SE_PRIVILEGE_ENABLED;
   }
   retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
   retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
   return retVal;
  }
 }
'@

 $processHandle = (Get-Process -id $ProcessId).Handle
 $type = Add-Type $definition -PassThru
 $type[0]::EnablePrivilege($processHandle, $Privilege, $Disable)
}

function registry-value-exists {
    param($path, $name)
    try {
        Get-ItemProperty -path $path -name $name -ErrorAction Stop
        return $true
    }
    catch [Exception] {
        return $false
    }
}

function delete-registry-value {
    param($path, $name)
    if (registry-value-exists $path $name) {
        Remove-ItemProperty -path $path -name $name
    }
}

# get the current user
$me = [System.Security.Principal.NTAccount]"$env:userdomain\$env:username"

# get the local System user
$localSystemId = [System.Security.Principal.WellKnownSidType]::LocalSystemSid
$localSystem = New-Object System.Security.Principal.SecurityIdentifier($localSystemId, $null)

# get the Administrators group
$administratorsId = [System.Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid
$administrators = New-Object System.Security.Principal.SecurityIdentifier($administratorsId, $null)

# Take ownership of registry key
# http://social.technet.microsoft.com/Forums/en/winserverpowershell/thread/e718a560-2908-4b91-ad42-d392e7f8f1ad
enable-privilege SeTakeOwnershipPrivilege |out-null
$subkey = "Software\Microsoft\Windows\CurrentVersion\Policies\System"
$key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($subkey,[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::takeownership)
if (!$key) { 
    Write-Host "key is null"
    exit
}
$acl = $key.GetAccessControl([System.Security.AccessControl.AccessControlSections]::None)
$acl.SetOwner($me)
$key.SetAccessControl($acl)

# Set registry key permissions
$acl = $key.GetAccessControl()
$isProtected = $true
$preserveInheritance = $false
$acl.SetAccessRuleProtection($isProtected, $preserveInheritance)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule($me,"FullControl","Allow")
$acl.SetAccessRule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule($localSystem,"ReadKey","Allow")
$acl.SetAccessRule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule($administrators,"ReadKey","Allow")
$acl.SetAccessRule($rule)
$key.SetAccessControl($acl)

# delete wallpaper values
delete-registry-value HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System Wallpaper
delete-registry-value HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System WallpaperStyle

# clean up
$key.Close()
