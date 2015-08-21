Function BitLockerSAK {
<#
.SYNOPSIS
	Get and set Bitlocker related information.
   
.DESCRIPTION
	Based on WMI classes, this function can achiev the following tasks :

    --TPM operations---
        -TPM activation state.
        -If the TPM is enabled or not.
        -If a TPM OwnerShip is Allowed.
        -If the TPM is currently owned.
        -The possibility to take the ownerShip

    --Encryption possibilities ---
        - Retrieves the current encryption method.
        - Get the current protection status.
        - The current protection state.
        - The possibility to encrypt a Drive.
        - The possibility to Resume an encryption that has been paused.
        - Possibility to return the current protector ID's.
        - Possibility to return the current protector type(s).
   

.PARAMETER isTPMActivated
	Returns activation state of the TPM:
    Returns true if activated and false if not.

.PARAMETER isTPMEnabled
	Returns the enabled state of the TPM:
    Returns true if activated and false if not.

.PARAMETER IsTPMOwnerShipAllowed
    Returns if the TPM ownership is allowed.
    Returns true if allowed, false if not.

.PARAMETER ResumeEncryption
   Will resume an paused encryption.

.PARAMETER GetEncryptionState
    Returns the current encurrent state in an object as wolled : 

.PARAMETER GetProtectionStatus
    Returns the current protection status. It will return "Protected" if the drive is 100% encrypted, and "Unprotected" if anything else then "100% encrypted".

.PARAMETER Encrypt
    Will encrypt a drive.

.PARAMETER TakeOwnerShip
    Returns true if allowed, false if not

.PARAMETER pin
    Is needed in order to take the ownership and to encrypt the drive.

.PARAMETER IsTPMOwned
    Returns true if owned, false if not

.PARAMETER GetProtectorIds
    Returns all the protector id's available on the machine.

.PARAMETER GetKeyProtectorType
    Returns the type of protector that is currently in use.

.PARAMETER GetEncryptionMethod
    REturns the current encryption method that is in use.
		
.PARAMETER Whatif
	Permits to launch this script in "draft" mode. This means it will only show the results without really making generating the files.

.PARAMETER Verbose
	Allow to run the script in verbose mode for debbuging purposes.
   
.EXAMPLE

BitLockerSAK

Returns the current status of the drives.

IsTPMOwned                  : True
EncryptionMethod            : AES_128
IsTPMOwnerShipAllowed       : True
IsTPMActivated              : True
IsTPMEnabled                : True
CurrentEncryptionPercentage : 100
EncryptionState             : FullyEncrypted
ProtectorIds                : {{FFC19381-6E75-4D1E-94E9-D6E0D3E681FA}, {65AF5A93-9846-47AC-B3B1-D8DE6F06B780}}
KeyProtectorType            : {Numerical password, Trusted Platform Module (TPM)}

.EXAMPLE
 
BitLockerSAK -GetProtectionStatus

Returns the current protection status : Protected or unprotected

.EXAMPLE
 
BitLockerSAK -GetEncryptionState

CurrentEncryptionProgress is express in percentage. 

CurrentEncryptionProgress EncryptionState                                                                                      
------------------------- ---------------                                                                                      
                      100 FullyEncrypted
   
.NOTES
	-Author: Stephane van Gulick
	-Email : 
	-CreationDate: 13-01-2014
	-LastModifiedDate: 16-01-2014
	-Version: 1.2
	-History:
    #0.1 : Created function
    #1.1 : 20140901 Added GetProtectorIds
    #1.2 : 20140909 Rewrote function
                    Added GetKeyprotectorType
                    Added EncryptionMethod
    

.LINK
    www.PowerShellDistrict.com

#>
    [cmdletBinding()]
    Param(
        [Switch]$IsTPMActivated,
        [Switch]$IsTPMEnabled,
        [Switch]$IsTPMOwnerShipAllowed,
        [Switch]$ResumeEncryption,
        [Switch]$GetEncryptionState,
        [Switch]$GetProtectionStatus,
        [switch]$Encrypt,
        [Parameter(ParameterSetName="OwnerShip")][switch]$TakeOwnerShip,
        [Parameter(ParameterSetName="OwnerShip")][int]$pin,
        [switch]$IsOwned,
        [Switch]$GetProtectorIds,
        [switch]$GetEncryptionMethod,
        [string]$DriveLetter="C:",
        [switch]$GetKeyProtectorType
        
        
    )
    Begin {
        
            $Tpm = Get-WmiObject -Namespace ROOT\CIMV2\Security\MicrosoftTpm -Class Win32_Tpm
    }
    Process{
    
       
        
        switch ($PSBoundParameters.keys){

            "IsTPMActivated"{$return = $tpm.IsActivated().isactivated;break}
            "IsTPMEnabled"{$return = $tpm.IsEnabled().isenabled;break}
            "IsTPMOwnerShipAllowed"{$return = $tpm.IsOwnerShipAllowed().IsOwnerShipAllowed;break}
            "IsTPMOwned"{$return = $Tpm.isowned().isowned;break}
            "GetEncryptionState"{
                        write-verbose "Getting the encryptionstate of drive $($driveletter)"
            #http://msdn.microsoft.com/en-us/library/aa376433(VS.85).aspx
            #We only want to work on the C: drive.
            $EncryptionData= Get-WmiObject -Namespace ROOT\CIMV2\Security\Microsoftvolumeencryption -Class Win32_encryptablevolume -Filter "DriveLetter = '$DriveLetter'"
            $protectionState = $EncryptionData.GetConversionStatus()
            $CurrentEncryptionProgress = $protectionState.EncryptionPercentage
                switch ($ProtectionState.Conversionstatus){
                    
                    "0" {
                            
                            $Properties = @{'EncryptionState'='FullyDecrypted';'CurrentEncryptionProgress'=$CurrentEncryptionProgress}
                            $Return = New-Object psobject -Property $Properties
                            
                           }

                    "1" {
                            
                            $Properties = @{'EncryptionState'='FullyEncrypted';'CurrentEncryptionProgress'=$CurrentEncryptionProgress}
                            $Return = New-Object psobject -Property $Properties
                            
                           }
                    "2" {
                            
                            $Properties = @{'EncryptionState'='EncryptionInProgress';'CurrentEncryptionProgress'=$CurrentEncryptionProgress}
                            $Return = New-Object psobject -Property $Properties
                            }
                    "3" {
                            
                            $Properties = @{'EncryptionState'='DecryptionInProgress';'CurrentEncryptionProgress'=$CurrentEncryptionProgress}
                            $Return = New-Object psobject -Property $Properties
                            }
                    "4" {
                            
                            $Properties = @{'EncryptionState'='EncryptionPaused';'CurrentEncryptionProgress'=$CurrentEncryptionProgress}
                            $Return = New-Object psobject -Property $Properties
                            }
                    "5" {
                            
                            $Properties = @{'EncryptionState'='DecryptionPaused';'CurrentEncryptionProgress'=$CurrentEncryptionProgress}
                            $Return = New-Object psobject -Property $Properties
                            }
                    default {
                                write-verbose "Couldn't retrieve an encryption state."
                                $Properties = @{'EncryptionState'=$false;'CurrentEncryptionProgress'=$false}
                                $Return = New-Object psobject -Property $Properties
                             }
                }
            }
            #Change C: drive (add more)
            "ResumeEncryption"{
                        write-verbose "Resuming encryption"
            $ProtectionState = Get-WmiObject -Namespace ROOT\CIMV2\Security\Microsoftvolumeencryption -Class Win32_encryptablevolume -Filter "DriveLetter = 'C:'"
            
            
               $Ret = $protectionState.ResumeConversion()
               $ReturnCode = $ret.ReturnValue
               
               switch ($ReturnCode){
               
                    ("0"){$Message = "The Method Resume Conversion was called succesfully."}
                    ("2150694912"){$message = "The volume is locked"}
                    default {$message = "The resume operation failed with an uknowned return code."}
               }
           
               $Properties = @{'ReturnCode'=$ReturnCode;'ErrorMessage'=$message}
               $Return = New-Object psobject -Property $Properties
        }   
            "GetProtectionStatus"{
            #http://msdn.microsoft.com/en-us/library/windows/desktop/aa376448(v=vs.85).aspx
            $ProtectionState = Get-WmiObject -Namespace ROOT\CIMV2\Security\Microsoftvolumeencryption -Class Win32_encryptablevolume -Filter "DriveLetter = 'C:'"
            write-verbose "Gathering BitLocker protection status infos."
            
            switch ($ProtectionState.GetProtectionStatus().protectionStatus){

                ("0"){$return = "Unprotected"}
                ("1"){$return = "Protected"}
                ("2"){$return = "Uknowned"}
                default {$return = "NoReturn"}
               
                
                }
        }
            "Encrypt"{
            #http://msdn.microsoft.com/en-us/library/windows/desktop/aa376432(v=vs.85).aspx
                $ProtectionState = Get-WmiObject -Namespace ROOT\CIMV2\Security\Microsoftvolumeencryption -Class Win32_encryptablevolume -Filter "DriveLetter = 'C:'"
                write-verbose "Launching drive encryption."
                    
                    $ProtectorKey = $protectionState.ProtectKeyWithTPMAndPIN("ProtectWithTPMAndPIN",$null,$pin)
                    Start-Sleep -Seconds 3
                    $NumericalPasswordReturn = $protectionState.ProtectKeyWithNumericalPassword($pin)
                    
                    $Return = $protectionState.Encrypt()
                    $returnCode = $return.returnvalue
                    switch ($ReturnCode) {
                    
                        ("0"){$message = "Operation succesfully started."}
                        ("2147942487") {$message = "The EncryptionMethod parameter is provided but is not within the known range or does not match the current Group Policy setting."}
                        ("2150694958") {$message = "No encryption key exists for the volume"}
                        ("2150694957") {$message = "The provided encryption method does not match that of the partially or fully encrypted volume."}
                        ("2150694942") {$message = "The volume cannot be encrypted because this computer is configured to be part of a server cluster."}
                        ("2150694956") {$message = "No key protectors of the type Numerical Password are specified. The Group Policy requires a backup of recovery information to Active Directory Domain Services"}
                        default{
                            $message = "An unknown status was returned by the Encryption action."
                            
                            }
                    }

                    $Properties = @{'ReturnCode'=$ReturnCode;'ErrorMessage'=$message}
                    $Return = New-Object psobject -Property $Properties
        }
            "GetProtectorIds"{
            $BitLocker = Get-WmiObject -Namespace "Root\cimv2\Security\MicrosoftVolumeEncryption" -Class "Win32_EncryptableVolume"
            $return =$BitLocker.GetKeyProtectors("0").volumekeyprotectorID
        }
            "GetEncryptionMethod"{
            $BitLocker = Get-WmiObject -Namespace "Root\cimv2\Security\MicrosoftVolumeEncryption" -Class "Win32_EncryptableVolume"
            $EncryptMethod=$BitLocker.GetEncryptionMethod().encryptionmethod
            switch ($EncryptMethod){
                "0"{$Return = "None";break}
                "1"{$Return = "AES_128_WITH_DIFFUSER";break}
                "2"{$Return = "AES_256_WITH_DIFFUSER";break}
                "3"{$Return = "AES_128";break}
                "4"{$Return = "AES_256";break}
                "5"{$Return = "HARDWARE_ENCRYPTION";break}
                default{$Return = "UNKNOWN";break}
            }
            
        }
            "GetKeyProtectorType"{
            $ProtectorIds = $BitLocker.GetKeyProtectors("0").volumekeyprotectorID
            $BitLocker = Get-WmiObject -Namespace "Root\cimv2\Security\MicrosoftVolumeEncryption" -Class "Win32_EncryptableVolume"
            #$LastProtectorID = $BitLocker.GetKeyProtectors("0").volumekeyprotectorID[-1]
            
            $return = @()

            foreach ($ProtectorID in $ProtectorIds){

            $KeyProtectorType = $BitLocker.GetKeyProtectorType($ProtectorID).KeyProtectorType

                switch($KeyProtectorType){
                    "0"{$return += "Unknown or other protector type";break}
                    "1"{$return += "Trusted Platform Module (TPM)";break}
                    "2"{$return += "External key";break}
                    "3"{$return += "Numerical password";break}
                    "4"{$return += "TPM And PIN";break}
                    "5"{$return += "TPM And Startup Key";break}
                    "6"{$return += "TPM And PIN And Startup Key";break}
                    "7"{$return += "Public Key";break}
                    "8"{$return += "Passphrase";break}
                    "9"{$return += "TPM Certificate";break}
                    "10"{$return += "CryptoAPI Next Generation (CNG) Protector";break}
                
                }
            }



        }
   
        }#endSwitch
        

        if ($PSBoundParameters.Keys.Count -eq 0){
            #Returning info on all drives.
            write-verbose "Returning bitlocker main status"
            $Tpm = Get-WmiObject -Namespace ROOT\CIMV2\Security\MicrosoftTpm -Class Win32_Tpm
            $BitLocker = Get-WmiObject -Namespace "Root\cimv2\Security\MicrosoftVolumeEncryption" -Class "Win32_EncryptableVolume"
            
            $TpmActivated = $tpm.IsActivated().isactivated
            $TPMEnabled=$tpm.IsEnabled().isenabled
            $TPMOwnerShipAllowed=$Tpm.IsOwnershipAllowed().IsOwnerShipAllowed
            $TPMOwned=$Tpm.isowned().isowned
            $ProtectorIds = $BitLocker.GetKeyProtectors("0").volumekeyprotectorID
            $CurrentEncryptionState = BitLockerSAK -GetEncryptionState
            $EncryptionMethod= BitLockerSAK -GetEncryptionMethod
            $KeyProtectorType = BitLockerSAK -GetKeyProtectorType

            $properties= @{ "IsTPMActivated"= $TpmActivated;`
                            "IsTPMEnabled" = $TPMEnabled;`
                            "IsTPMOwnerShipAllowed"=$TPMOwnerShipAllowed;`
                            "IsTPMOwned"= $TPMOwned;`
                            "ProtectorIds"=$ProtectorIds;`
                            "CurrentEncryptionPercentage"=$CurrentEncryptionState.CurrentEncryptionProgress;`
                            "EncryptionState"=$CurrentEncryptionState.encryptionState; `
                            "EncryptionMethod"=$EncryptionMethod;`
                            "KeyProtectorType"=$KeyProtectorType
                            }
            
            $Return = New-Object psobject -Property $Properties
        }

    }
    End{
        return $return
    }

}