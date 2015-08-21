function New-OSUser
{
<#
.Synopsis
    Create New user
.DESCRIPTION
   User will create as you passed Credential.
.EXAMPLE
    New-OSUser -Credential (Get-Credential) -Groups Administrators
    # create new user with Group assigned Administrators
.NOTES
    - User Flag Property Samples
    Run LogOn Script　&H0001
    ADS_UF_SCRIPT  =  0X0001
    Account Disable　&H0002
    ADS_UF_ACCOUNTDISABLE =  0X0002
    Account requires Home Directory　&H0008
    ADS_UF_HOMEDIR_REQUIRED =  0X0008
    Account Lockout　&H0010
    ADS_UF_LOCKOUT =  0X0010
    No Password reqyured for account　&H0020
    ADS_UF_PASSWD_NOTREQD =  0X0020
    No change Password　&H0040
    ADS_UF_PASSWD_CANT_CHANGE =  0X0040
    Allow Encypted Text Password　&H0080
    ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED  =  0X0080
    ADS_UF_TEMP_DUPLICATE_ACCOUNT =  0X0100
    ADS_UF_NORMAL_ACCOUNT  =  0X0200
    ADS_UF_INTERDOMAIN_TRUST_ACCOUNT =  0X0800
    ADS_UF_WORKSTATION_TRUST_ACCOUNT =  0X1000
    ADS_UF_SERVER_TRUST_ACCOUNT  =  0X2000
    Password infinit　&H10000
    ADS_UF_DONT_EXPIRE_PASSWD =  0X10000
    ADS_UF_MNS_LOGON_ACCOUNT =  0X20000
    Smart Card Required　&H40000
    ADS_UF_SMARTCARD_REQUIRED  =  0X40000
    ADS_UF_TRUSTED_FOR_DELEGATION =  0X80000
    ADS_UF_NOT_DELEGATED =  0X100000
    ADS_UF_USE_DES_KEY_ONLY = 0x200000
    ADS_UF_DONT_REQUIRE_PREAUTH = 0x400000
    Password expired &H800000 
    ADS_UF_PASSWORD_EXPIRED = 0x800000
    ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION = 0x1000000
#>
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(mandatory)]
        [PSCredential[]]$Credential,

        [parameter(mandatory = 0)]
        [string[]]$Groups = "administrators",

        [parameter(mandatory = 0)]
        [int32]$UserFlag = 0x10000
    )

    $hostPC = [System.Environment]::MachineName
    $directoryComputer = New-Object System.DirectoryServices.DirectoryEntry("WinNT://" + $hostPC + ",computer")
    $existingUsers = Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount='true'"

    foreach ($x in $Credential)
    {
        # skip check
        if ($x -in $ExistingUsers.Name){ Write-Verbose ("User : {0} already exist. Nothing had changed." -f $x.UserName); return }

        Write-Verbose ("Create new user : {0}." -f $x.UserName)
        # Create User
        $newuser = $DirectoryComputer.Create("user", $x.UserName)
        $newuser.SetPassword($x.GetNetworkCredential().Password)
        $newuser.SetInfo()

        # Password must change
        $newuser.PasswordExpired = 0
        $newuser.SetInfo()

        # Get Account UserFlag to set
        $userFlags = $newuser.Get("UserFlags")
        $userFlags = $userFlags -bor $UserFlag
        $newuser.Put("UserFlags", $userFlags)

        Write-Verbose "Assign User to UserGroup $Groups"
        foreach ($group in $Groups)
        {
            #Assign Group for this user
            $DirectoryGroup = $DirectoryComputer.GetObject("group", $group)
            $DirectoryGroup.Add("WinNT://" + $HostPC + "/" + $x.UserName)
        }
    }
}