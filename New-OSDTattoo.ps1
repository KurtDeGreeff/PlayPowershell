<#
.SYNOPSIS
    [INFO] to get the latest help / version of this script use --> get-help .\New-OSDTattoo.ps1 -Online[/INFO]
	This script will set a tatoo information into an OS image during OSD deployment.
    
   
.DESCRIPTION 
    This script will tatoo the Windows Image with specefic values into one or all of the following locations:
		--> Registry
        --> environment variable
        --> WMI Repository

.PARAMETER ALL
    This switch will tatoo the values in the following locations:
        --> Registry
        --> environment variable
        --> WMI Repository

.PARAMETER Registry
    This switch will tatoo the value only in the following location:
        --> Registry

.PARAMETER EnvironmentVariable
    This switch will tatoo the value only in the following location:
        --> environment variable

.PARAMETER WMI
    This switch will tatoo the value only in the following location:
        --> WMI Repository

.PARAMETER Online
    Will redirect you to the web page containing all the latest help, infos, and script updates from the New-OSDTattoo.ps1 script.
    
.Example
     New-OSDTatoo.ps1 -All

     Will tatoo all the data in the following locations:
        --> Registry
        --> environment variable
        --> WMI Repository 

.Example
     New-OSDTatoo.ps1 -WMI -Registry

     Will tatoo all the data in the following locations:
        --> Registry
        --> WMI Repository 

.Example
     New-OSDTatoo.ps1 

    This is equivalent to -All. It Will tatoo all the data in the following locations:
        --> Registry
        --> environment variable
        --> WMI Repository 

.NOTES
	-Author: Stéphane van Gulick
	-Email : 
	-CreationDate: 12.01.2014
	-LastModifiedDate: 04.14.2015
	-Version: 1.4.3
    -History:
    1.4.3 ; 16/08/2015 ; Added -Online help support Commented OSDBuildversion variable out since it was a custom TS variable. 
    1.4.2 ; 04.14.2015 ; Changed variable name: PSDistrict_TaskSequenceInstallationName --> PSDistrict_TSName
    1.4.2 ; 04.14.2015 ; Changed variable name: PSDistrict_TaskSequenceInstallationID --> PSDistrict_TSID  
    1.4.1 ; 02.11.2015 ; Corrected minor bug with old write-log function
    1.4 ; 02.11.2015 ; Added WMI instance creation

	
#>
[cmdletBinding(
    HelpURI='http://powershelldistrict.com/osd-tattoo-powershell/'
)]
Param(
        [Parameter(Mandatory=$false)][switch]$All,
        [Parameter(Mandatory=$false)][switch]$WMI,
        [Parameter(Mandatory=$false)][switch]$Registry,
        [Parameter(Mandatory=$false)][switch]$EnvironmentVariable,
        [Parameter(Mandatory=$false)][String]$Root = "OsBuildInfo"
)

#region helperFunctions

$PSDistrict_TattooScriptVersion = "1.4.3"

Function Set-EnvironmentVariable {
<#
.SYNOPSIS
	Creates a system envirnment variable.
   
.DESCRIPTION
	The system environment variable can contain a value, or if not spécified, it will just be empty.

.PARAMETER Name
	Parameter that identifies which variables should be retrived from the line server configuration file.

.PARAMETER Value

.EXAMPLE

Set-EnvironmentVariable -Name plop -Value 1234

Creates a variable called "plop" whit a value of "1234"
    
#>

    [Cmdletbinding()]
    Param(

        [Parameter(Mandatory=$true)][string[]]$Name,
        [Parameter(Mandatory=$false)]$Value = $null,
        [Parameter(Mandatory=$false)][Switch]$Force


    )
        
        Begin{
        
            

        }
        Process{
        
                #Verifying if variable exists
                    if ($env:name){
                            #Variable is existing

                            if ($force){
                                #Forcing to change the variable

                                write-verbose "Variable $($name)is already existing. Forcing new value $($value)."
                                try{
                                    [Environment]::SetEnvironmentVariable($($name), $($value), "Machine")
                                    }
                                catch{
                                    write-warning $_
                                }

                    
                            }
                            else{
                
                                write-warning "Variable $($name) is already existing. If you still want to force the new variable setting call this function whit parameter -force"

                            }
                        }
                    else{
                #Variable is not existing
                        [Environment]::SetEnvironmentVariable($($name), $($value), "Machine")
                        write-verbose "New environment variable $($name) has been created whit value $($value)"
                    }
                      

        }
        End{}

}

Function New-RegistryItem {
<#
.SYNOPSIS
	Set's a registry item.
   
.DESCRIPTION 
    Set's a registry item in a specefic hvye.
	
	
.PARAMETER RegistryPath
    Specefiy the registry path.
    Default it is in HKLM:SOFTWARE\Company\ hyve.
    /!\Important note /!\
    Powershell requires that the following registry format is respected :
    "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" <-- the "HKLM:" is important and CANNOT be "HKEY_LOCAL_MACHINE" (notice the ':' also!!).


.PARAMETER RegistryString
    This parameter will is used in order to give the name to the registry string that is needed to be tatooted and that will contain information that can later be reported on through SCCM.
    ex : DisplayName
    ex : InstallDate
    Use the parameter "RegistryValue" to give a value to the "registryString".

.PARAMETER RegistryValue
    This parameter is used in order to give a value to a registry string that is already existing or has been previously created.
    example : a date for a registry string called "InstalledDate".
    
.Example
     New-RegistryItem -RegistryString PowerShellDistrictURL -RegistryValue "www.PowerShellDistrict.com"

.NOTES
	-Author: Stéphane van Gulick
	-Email : 
	-CreationDate: 12.01.2014
	-LastModifiedDate: 12.01.2014
	-Version: 1.0
	
#>



    [cmdletBinding()]
    Param(


        [Parameter(Mandatory=$false)]
        [string]$RegistryPath = "HKLM:SOFTWARE\",

        [Parameter(Mandatory=$true)]
        [string]$RegistryString,

        [Parameter(Mandatory=$true)]
        [string]$RegistryValue
        
    )
    begin{

    }
    Process{
    
            ##Creating the registry node
            if (!(test-path $RegistryPath)){
                write-verbose "Creating the registry node at : $($RegistryPath)."
                try{
                    if ($RegistryPath -ne "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"){
                        New-Item -Path $RegistryPath -force -ErrorAction stop | Out-Null
                       }else{
                        write-verbose "The registry path that is tried to be created is the uninstall string.HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\."
                        write-verbose "Creating this here would have as consequence to erase the whole content of the Uninstall registry hive."
                        
                        exit 
                       }
                    }
                catch [System.Security.SecurityException] {
                    write-warning "No access to the registry. Please launch this function with elevated privileges."
                }
                catch{
                    write-host "An unknowed error occured : $_ "
                }
            }
            else{
                write-verbose "The registry hyve already exists at $($registrypath)"
            }

            ##Creating the registry string and setting its value
            if ($RegistryPath -ne "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\")
                {
                         write-verbose "Setting the registry string $($RegistryString) with value $($registryvalue) at path : $($registrypath) ."

                        try{
                           
                            New-ItemProperty -Path $RegistryPath  -Name $RegistryString -PropertyType STRING -Value $RegistryValue -Force -ErrorAction Stop | Out-Null
                            }
                        catch [System.Security.SecurityException] {
                            write-host "No access to the registry. Please launch this function with elevated privileges."
                        }
                        catch{
                            write-host "An uncatched error occured : $_ "
                        }
                       }
            else{
                write-verbose "The registry path that is tried to be created is the uninstall string. HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\."
                write-verbose "Creating this here would have as consequence to erase the whole content of the Uninstall registry hive."
                exit
            }

               
            
            
        }

    End{}
}

Function Get-WMIClass{
  <#
	.SYNOPSIS
		get information about a specefic WMI class.

	.DESCRIPTION
		returns the listing of a WMI class.

	.PARAMETER  ClassName
		Specify the name of the class that needs to be queried.

    .PARAMETER  NameSpace
		Specify the name of the namespace where the class resides in (default is "Root\cimv2").

	.EXAMPLE
		get-wmiclass
        List all the Classes located in the root\cimv2 namespace (default location).

	.EXAMPLE
		get-wmiclass -classname win32_bios
        Returns the Win32_Bios class.

	.EXAMPLE
		get-wmiclass -classname MyCustomClass
        Returns information from MyCustomClass class located in the default namespace (Root\cimv2).

    .EXAMPLE
		Get-WMIClass -NameSpace root\ccm -ClassName *
        List all the Classes located in the root\ccm namespace

	.EXAMPLE
		Get-WMIClass -NameSpace root\ccm -ClassName ccm_client
        Returns information from the cm_client class located in the root\ccm namespace.

	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:23.07.2014
        Last modification date: 23.07.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>
[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$false,valueFromPipeLine=$true)][string]$ClassName,
        [Parameter(Mandatory=$false)][string]$NameSpace = "root\cimv2"
	
	)  
    begin{
    write-verbose "Getting WMI class $($Classname)"
    }
    Process{
        if (!($ClassName)){
            $return = Get-WmiObject -Namespace $NameSpace -Class * -list
        }else{
            $return = Get-WmiObject -Namespace $NameSpace -Class $ClassName -list
        }
    }
    end{

        return $return
    }

}

Function New-WMIClass {
<#
	.SYNOPSIS
		This function help to create a new WMI class.

	.DESCRIPTION
		The function allows to create a WMI class in the CimV2 namespace.
        Accepts a single string, or an array of strings.

	.PARAMETER  ClassName
		Specify the name of the class that you would like to create. (Can be a single string, or a array of strings).

    .PARAMETER  NameSpace
		Specify the namespace where class the class should be created.
        If not specified, the class will automatically be created in "Root\cimv2"

	.EXAMPLE
		New-WMIClass -ClassName "PowerShellDistrict"
        Creates a new class called "PowerShellDistrict"
    .EXAMPLE
        New-WMIClass -ClassName "aaaa","bbbb"
        Creates two classes called "aaaa" and "bbbb" in the Root\cimv2

	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:16.07.2014
        Last modification date: 16.07.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>
[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true,valueFromPipeLine=$true)][string[]]$ClassName,
        [Parameter(Mandatory=$false)][string]$NameSpace = "root\cimv2"
	
	)


        
        

        foreach ($NewClass in $ClassName){
            if (!(Get-WMIClass -ClassName $NewClass -NameSpace $NameSpace)){
                write-verbose "Attempting to create class $($NewClass)"
                    $WMI_Class = ""
                    $WMI_Class = New-Object System.Management.ManagementClass($NameSpace, $null, $null)
                    $WMI_Class.name = $NewClass
	                $WMI_Class.Put() | out-null
                
                write-output "Class $($NewClass) created."

            }else{
                write-output "Class $($NewClass) is already present. Skiping.."
            }
        }

}
					
Function New-WMIProperty {
<#
	.SYNOPSIS
		This function help to create new WMI properties.

	.DESCRIPTION
		The function allows to create new properties and set their values into a newly created WMI Class.
        Event though it is possible, it is not recommended to create WMI properties in existing WMI classes !

	.PARAMETER  ClassName
		Specify the name of the class where you would like to create the new properties.

	.PARAMETER  PropertyName
		The name of the property.

    .PARAMETER  PropertyValue
		The value of the property.

	.EXAMPLE
		New-WMIProperty -ClassName "PowerShellDistrict" -PropertyName "WebSite" -PropertyValue "www.PowerShellDistrict.com"

	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:16.07.2014
        Last modification date: 16.07.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>


[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace="Root\cimv2",

        [Parameter(Mandatory=$true)][string[]]$PropertyName,
        [Parameter(Mandatory=$false)][string]$PropertyValue=""

	
	)
    begin{
        [wmiclass]$WMI_Class = Get-WmiObject -Class $ClassName -Namespace $NameSpace -list
    }
    Process{
            write-verbose "Attempting to create property $($PropertyName) with value: $($PropertyValue) in class: $($ClassName)"
            $WMI_Class.Properties.add($PropertyName,$PropertyValue) | Out-Null
            Write-verbose "Added $($PropertyName) with to $($PropertyValue) in class: $($ClassName)."
    }
    end{
           		$WMI_Class.Put() | Out-Null
                [wmiclass]$WMI_Class = Get-WmiObject -Class $ClassName -list
                return $WMI_Class
    }

            
            
  
                    


}

Function Set-WMIPropertyQualifier {
<#
	.SYNOPSIS
		This function sets a WMI property qualifier value.

	.DESCRIPTION
		The function allows to set a new property qualifier on an existing WMI property.

	.PARAMETER  ClassName
		Specify the name of the class where the property resides.

	.PARAMETER  PropertyName
		The name of the property.

    .PARAMETER  QualifierName
		The name of the qualifier.

    .PARAMETER  QualifierValue
		The value of the qualifier.

	.EXAMPLE
		Set-WMIPropertyQualifier -ClassName "PowerShellDistrict" -PropertyName "WebSite" -QualifierName Key -QualifierValue $true
        Sets the propertyQualifier "Key" on the property "WebSite"
    
		


	.NOTES
		Version: 1.1
        Author: Stephane van Gulick
        Creation date:16.07.2014
        Last modification date: 27.01.2015

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>


[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace="Root\cimv2",

        [Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$PropertyName,

        [Parameter(Mandatory=$false)]
        $QualifierName,

        [Parameter(Mandatory=$false)]
        $QualifierValue,

        [switch]$key,
        [switch]$IsAmended=$false,
        [switch]$IsLocal=$true,
        [switch]$PropagatesToInstance=$true,
        [switch]$PropagesToSubClass=$false,
        [switch]$IsOverridable=$true

	
	)

    
    write-verbose "Setting  qualifier $($QualifierName) with value $($QualifierValue) on property $($propertyName) located in $($ClassName) in Namespace $($NameSpace)"
    $Class = Get-WMIClass -ClassName $ClassName -NameSpace $NameSpace

    if ($Class.Properties[$PropertyName]){

        write-verbose "Property $($PropertyName) has been found."
        if ($Key){
            write-verbose "Setting Key property on $($PropertyName)"
            $Class.Properties[$PropertyName].Qualifiers.Add("Key",$true)
            $Class.put() | out-null
        
        
        }else{
            write-verbose "Setting $($QualifierName) with qualifier value $($QualifierValue) on property $($PropertyName)"
            $Class.Properties[$PropertyName].Qualifiers.add($QualifierName,$QualifierValue, $IsAmended,$IsLocal,$PropagatesToInstance,$PropagesToSubClass)
            $Class.put() | out-null
        }

        $return = Get-WMIProperty -NameSpace $Namespace -ClassName $ClassName -PropertyName $PropertyName
        return $return

    }else{
        write-warning "Could not find any propertyname named $($PropertyName)."
    }
    


}

Function New-WMIClassInstance {
    <#
	.SYNOPSIS
		creates a new WMI class instance.

	.DESCRIPTION
		The function allows to retrieve a specefic WMI class instance. If none is specified, all will be retrieved.

	.PARAMETER  ClassName
		Specify the name of the class where the instance resides.

	.PARAMETER NameSpace
        Specify the name of the namespace where the class is located (default is Root\cimv2).

    .PARAMETER  InstanceName
		Name of the Instance to retrieve.

    .PARAMETER  PutInstance
		This parameter needs to be called once the instance has all of its properties set up.

	.EXAMPLE
        $MyNewInstance = New-WMIClassInstance -ClassName PowerShellDistrict -InstanceName "Instance01"
        
        Creates a new Instance name "Instance01" of the WMI custom class "PowerShellDistrict" and sets it in a variable for future use.

        The at least the key property set to a value. To get the key property of a class, use the Get-WMIKeyPropertyQualifier cmdlet.		

    .EXAMPLE
        New-WMIClassInstance -ClassName PowerShellDistrict -PutInstance $MyNewInstance

        Validates the changes and writes the new Instance persistantly into memory.
		
	.NOTES
		Version: 1.0
        Author: Stéphane van Gulick
        Creation date:16.07.2014
        Last modification date: 21.08.2014

	.LINK
		www.powershellDistrict.com
        
        My blog.

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

        My other projects and contributions.

#>


[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace="Root\cimv2",

        [Parameter(Mandatory=$false)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string[]]$InstanceName,

        [Parameter(valueFromPipeLine=$true)]$PutInstance


	
	)
    Begin{
            $WmiClass = Get-WMIClass -NameSpace $NameSpace -ClassName $ClassName
    }
    Process{
            
            if ($PutInstance){
                
                $PutInstance.Put()
            }else{
                $Return = $WmiClass.CreateInstance()
            }
          
    }
    End{

        If ($Return){
            return $Return
        }

    }
}

Function New-OSDTattoo{
<#
.SYNOPSIS
	Will tatoo an Image during OSD deployment.
   
.DESCRIPTION 
    This function will have the possibility to tatoo an information in the Windows image in one (or all) of the following locations:
        --> Registry
        --> Environment variable
        --> WMI Repository
	

.PARAMETER PropertyName
    This parameter will be is used in order to give the name of the tatoo.
    ex : DisplayName
    ex : InstallDate
   

.PARAMETER PropertyValue
    This parameter is used in order to give a value the tatoo.
    ex : "12/01/2015" for a tatoo name called "InstalledDate".
    
.PARAMETER ALL
    This switch will tatoo the value in the following locations:
        --> Registry
        --> environment variable
        --> WMI Repository

.PARAMETER Registry
    This switch will tatoo the value only in the following location:
        --> Registry

.PARAMETER EnvironmentVariable
    This switch will tatoo the value only in the following location:
        --> environment variable

.PARAMETER WMI
    This switch will tatoo the value only in the following location:
        --> WMI Repository

.PARAMETER RegistryRoot
    Specify the registry path. This parameter will automatically be combined with the value of "Root" which should be the name of the company, or the project you are working on.
    Default it is in HKLM:SOFTWARE\ hyve.
    /!\Important note /!\
    Powershell requires that the following registry format is respected :
    "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" <-- the "HKLM:" is important and CANNOT be "HKEY_LOCAL_MACHINE" (notice the ':' also!!).

.Example
     New-RegistryItem -RegistryString PowerShellDistrictURL -RegistryValue "www.PowerShellDistrict.com"

.NOTES
	-Author: Stéphane van Gulick
	-Email : 
	-CreationDate: 12.01.2014
	-LastModifiedDate: 12.01.2014
	-Version: 1.0

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/
	
#>
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]$Root="Woop",
        [Parameter(Mandatory=$true)]$PropertyName,
        [Parameter(Mandatory=$true)]$PropertyValue,
        [Parameter(Mandatory=$false)]$RegistryRoot = "HKLM:\SOFTWARE\",
        [Parameter(Mandatory=$false)][switch]$All,
        [Parameter(Mandatory=$false)][switch]$WMI,
        [Parameter(Mandatory=$false)][switch]$Registry,
        [Parameter(Mandatory=$false)][switch]$EnvironmentVariable
    )
    begin{}
    Process{

    
        $FullRegPath = join-path -Path $RegistryRoot -ChildPath $Root

        switch ($PSBoundParameters.Keys){
            "All"{
                New-WMIClass -ClassName $Root
                New-WMIProperty -ClassName $Root -PropertyName $PropertyName -PropertyValue $PropertyValue
                New-RegistryItem -RegistryPath $FullRegPath -RegistryString $PropertyName -RegistryValue $PropertyValue
                Set-EnvironmentVariable -Name $PropertyName -Value $PropertyValue -Force
                break
            }
            "WMI" {
                New-WMIClass -ClassName $Root
                New-WMIProperty -ClassName $Root -PropertyName $PropertyName -PropertyValue $PropertyValue
                
                Break
            }
            "Registry"{
                New-RegistryItem -RegistryPath $FullRegPath -RegistryString $PropertyName -RegistryValue $PropertyValue
                Break
            }
            "EnvironmentVariable"{
                Set-EnvironmentVariable -Name $PropertyName -Value $PropertyValue -Force
                break
            }
            default{
            
                New-WMIClass -ClassName $Root
                New-WMIProperty -ClassName $Root -PropertyName $PropertyName -PropertyValue $PropertyValue
                New-RegistryItem -RegistryPath $FullRegPath -RegistryString $PropertyName -RegistryValue $PropertyValue
                Set-EnvironmentVariable -Name $PropertyName -Value $PropertyValue -Force
                break
                
            }

        }


    }
    End{}

}

Function Get-WMIProperty {
<#
    .SYNOPSIS
        This function gets a WMI property.
 
    .DESCRIPTION
        The function allows return a WMI property from a specefic WMI Class and located in a specefic NameSpace.
 
    .PARAMETER  NameSpace
        Specify the name of the namespace where the class resides in (default is "Root\cimv2").
 
    .PARAMETER  ClassName
        Specify the name of the class.
 
    .PARAMETER  PropertyName
        The name of the property.
 
    .EXAMPLE
        Get-WMIProperty -ClassName "PowerShellDistrict" -PropertyName "WebSite"
        Returns the property information from the WMI propertyName "WebSite"
 
    .EXAMPLE
        Get-WMIProperty -ClassName "PowerShellDistrict"
        Returns all the properties located in the "PowerShellDistrict" WMI class.
 
    .NOTES
        Version: 1.0
        Author: Stephane van Gulick
        Creation date:29.07.2014
        Last modification date: 12.08.2014
 
    .LINK
        www.powershellDistrict.com
 
    .LINK
 
http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/
 
#>
 
 
[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$ClassName,
 
        [Parameter(Mandatory=$false)]
        [string]$NameSpace="Root\cimv2",
 
        [Parameter(Mandatory=$false)]
        [string]$PropertyName
 
     
 
     
    )
    begin{
          
 
    }
    process{
        If ($PropertyName){
            write-verbose "Returning WMI property $($PropertyName) from class $($ClassName) and NameSpace $($NameSpace)."
            $return = (Get-WMIClass -ClassName $ClassName -NameSpace $NameSpace ).properties["$($PropertyName)"]
 
 
         }else{
            write-verbose "Returning list of WMI properties from class $($ClassName) and NameSpace $($NameSpace)."
            $return = (Get-WMIClass -ClassName $ClassName -NameSpace $NameSpace ).properties
 
             
         } 
    }
    end{
        Return $return
    }  
}

#endregion



#region mainScript

#Loading task sequence COM object

$LogFile = "C:\System\logs\OSD_Tattoo.log"
if (!(Test-Path $LogFile)){
    #Creating log file
    New-Item -Path $LogFile -ItemType file -Force
}

"Starting operations" >> $LogFile

    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    

 "Script version is $($PSDistrict_TattooScriptVersion)">> $LogFile    

    $PSDistrict_TSName = $tsenv.Value("_SMSTSPackageName")
    $PSDistrict_BootImageVersion = $tsenv.Value("_SMSTSBootImageID")
    $PSDistrict_DeploymentID = $tsenv.Value("_SMSTSPackageID")
    $PSDistrict_InstallationMethod = $tsenv.Value("_SMSTSMediaType")
    $PSDistrict_TSID = $tsenv.Value("_SMSTSPackageID")
    $PSDistrict_SiteCode = $tsenv.Value("_SMSTSSiteCode")
    #$PSDistrict_OsBuildversion = $tsenv.Value("OsBuildVersion")

    
    $PSDistrict_InstallationDate = get-date -uformat "%Y%m%d-%T"

    $CustomVariables = @()
    $CustomVariables = $tsenv.getVariables() | ? {$_ -match "PSDistrict_*"}

    

    Foreach ($CustomVariable in $CustomVariables){
        
        New-Variable -Name $CustomVariable -Value $tsenv.value($CustomVariable)
    }

    $VarTatoos = Get-Variable -Name "PSDistrict_*"
    
    

    foreach ($Tatoo in $VarTatoos){
    
        
        switch ($PSBoundParameters.Keys){
            "All"{
                "Tattooing: $($Tatoo.Name) with value: $($Tatoo.value) --> in WMI, Registry and environment variables." >> $LogFile
                New-OSDTattoo -Root $Root -PropertyName $($Tatoo.Name) -PropertyValue $($Tatoo.value) -All
                break
            }
            "WMI" {
                "Tattooing: $($Tatoo.Name) with value: $($Tatoo.value) --> in WMI." >> $LogFile
                New-OSDTattoo -Root $Root -Name $($Tatoo.Name) -Value $($Tatoo.value) -wmi
                break
            }
            "Registry"{
                "Tattooing: $($Tatoo.Name) with value: $($Tatoo.value) --> in Registry." >> $LogFile
                New-OSDTattoo -Root $Root -Name $($Tatoo.Name) -Value $($Tatoo.value) -Registry
                Break
            }
            "EnvironmentVariable"{
                "Tattooing: $($Tatoo.Name) with value: $($Tatoo.value) --> in environment variables." >> $LogFile
                New-OSDTattoo -Root $Root -Name $($Tatoo.Name) -Value $($Tatoo.value) -EnvironmentVariable
                break
            }
            default{
                "Tattooing: $($Tatoo.Name) with value: $($Tatoo.value) --> in WMI, Registry and environment variables.">> $LogFile
                New-OSDTattoo -Root $Root -Name $($Tatoo.Name) -Value $($Tatoo.value) -All
                break
                
            }

        }#End switch

        
    }#End foreach.

    
    if ($PSBoundParameters.ContainsKey("WMI") -or $PSBoundParameters.ContainsKey("All")){
        #Creating WMI instance
                "Creating WMI instance.">> $LogFile
                Set-WMIPropertyQualifier -className $Root -PropertyName "PSDistrict_TattooScriptVersion" -key
                $Instance = New-WMIClassInstance -ClassName $Root
                $Instance.put() | out-null
        }
    "End of script...">> $LogFile
    "For more information or detailed help please visit: http://powershelldistrict.com/osd-tattoo-powershell/" >> $logfile
    #endregion

