# Get-ServicesWithAccounts

#region help

<#
.SYNOPSIS
	For a given computer or list of computers, output the list of services which are running under specifically assigned accounts, which may be either a local account or a domain account.
.DESCRIPTION
	For a given computer or list of computers, examine the services installed on that computer and output a list of the services which are:

		[1] Not running as a privileged non-account local process
		[2] Not running as a service authority (NT Service\*)
		[3] Not running as the default ASP.Net user

	In short, the list of services which are running under specifically assigned accounts, which may be either a local account or a domain account.

	To use this script to evaluate remote computers, the remote computers must have Remote Management enabled and available through the remote computer's firewall.

	CIM cmdlet support was introduced as part of Windows Management Framework 3.0 (WMF 3.0), which included PowerShell 3.0. For computers running earlier versions of WMF/PowerShell, you must use WMI instead of CIM.

	There are three different ways to specify lists of computers (FileName, Computers, OrganizationalUnit). You can use all three at once,  if you wish.
.PARAMETER FileName
	This string parameter accepts a filename. The filename is opened and the contents are read. Each line is assumed to continue a single computer name.

	Before a line is evaluated, white-space characters which precede any text, and those which suffix any text are removed. White-space characters are determined by the System.Char.IsWhiteSpace() method.

	Empty lines are accepted, but ignored.

	Lines which begin with '#' are ignored.

	If filename cannot be opened, then a warning is issued to the script's warning stream (using Write-Warn).

	The FileName parameter defaults to 'not set'.
.PARAMETER Computers
	This string array parameter accepts a comma-separated list of computer names. Duplicate names are not removed. If you specify a computer name twice, it will be evaluated twice.

	Both WINS names (short names) the FQDNs (fully qualified domain names) are supported.

	Computer names which begin with '#' are ignored.

	The Computers parameter defaults to 'not set'.
.PARAMETER OrganizationalUnit
	This parameter has an alias of 'OU'.

	This string parameter accepts the name of an organizational unit, in distinguished name format.

	Active Directory is searched within this organizational unit, and all computer objects are returned. These computer objects are then evaluated.

	The SubTree parameter is used to indicate whether the search is only for this level of Active Directory, or if the search should include all subtrees of the current level (as well as the current level).

	The OrganizationalUnit parameter defaults to 'not set'.
.PARAMETER SubTree
	This boolean parameter accepts $true or $false. If the OrganizationalUnit parameter has not been specified, this parameter is ignored.

	If the SubTree parameter is not set, or if is set to $false, then subtrees of the current OrganizationalUnit are not searched for computer objects. Only the current level is searched.

	If the SubTree paramter is set to $true, then all available subtrees of the current OrganizationalUnit are also searched for computer objects.

	The SubTree parameter defaults to $false.
.PARAMETER NoErrors
	This switch parameter should either be set, or not set. The parameter defaults to 'not set'.

	If the NoErrors switch is set, and a computer cannot be contacted using either CIM or WMI (as appropriate), then a PSObject will be output for that computer indicating that the computer cannot be contacted.

	If the NoErrors switch is not set, then an error will be written to the script's error stream (using Write-Error).
.PARAMETER UseWMI
	This switch parameter should either be set, or not set. The parameter defaults to 'not set'. However, this script will detect whether it is being executed on PowerShell v1 or PowerShell v2 - in that case, UseWMI will be set automatically.

	CIM cmdlet support was introduced as part of Windows Management Framework 3.0 (WMF 3.0), which included PowerShell 3.0. For computers running earlier versions of WMF/PowerShell, you must use WMI instead of CIM.

	This script cannot feasibly detect whether a remote computer is using WMF 3.0 or later. If your human knowledge is aware that pre-3.0 versions of WMF are being used - then set this parameter.

	Please be aware that this script was not tested against computers using PowerShell v1.0 (I don't have any in my test environment). However, it was tested against computers using PowerShell v2.0. I believe that (with UseWMI) it should work against computers using PowerShell v1.0.
.PARAMETER Verbose
	Extensive execution-time information, including summary statistics, is provided if you set Verbose. The parameter defaults to 'not set'.
.INPUTS
	None.  You cannot pipe objects into this script.
.OUTPUTS
	This script outputs a series of PSObjects which contain the following properties: Computer, Account, ShortName, and FullName.

	A PSObject will only be output for a computer under two conditions:

		[1] The computer cannot be contacted and the NoErrors switch has been set.
		[2] One or more services running under specifically assigned accounts have been found on the computer. There will be one PSObject for each service which meets that criteria.
.NOTES
	NAME: Get-ServicesWithAccounts
	AUTHOR: Michael B.Smith
	LASTEDIT: December 17, 2014
	EMAIL: michael at TheEssentialExchange dot com
	VERSION: 3.0

	No warranties, express or implied, are available. This script is offered "as is".

	I hope this script works for you. If it does not, please tell me. I will attempt to figure out what is going on. However - no promises.

	Replaces and expands check-services.ps1

	Setting the Verbose switch will generate lots of processing information in the cmdlet, including interesting summary data.

	Since this script will operate against destination computers running PowerShell v1.0 and PowerShell v2.0, using AsJob and/or WorkFlows is not feasible.

	The accounts excluded from consideration by this script are show below. If a service is executing under any other account, the service will be reported. Excluded accounts:

		'NT Authority\LocalService',
		'NT Authority\Local Service',
		'NT Authority\System',
		'NT Authority\Network Service', 
		'NT Authority\NetworkService',
		'LocalSystem',
		'.\ASPNET',
		'NT Service\*'
.LINK
	http://theessentialexchange.com/blogs/michael/archive/2014/12/17/finding-services-using-non-system-accounts-with-powershell-v3.aspx
.EXAMPLE
	C:\> Get-ServicesWithAccounts
	C:\>

	If none of the Computer, FileName, or OrganizationalUnit parameters are specified, then this cmdlet does nothing.
.EXAMPLE
	C:\> Get-ServicesWithAccounts -FileName FileDoesntExist.txt
	WARNING: Could not read file
	C:\>

	If the specified filename cannot be opened and read, then this cmdlet outputs a warning.
.EXAMPLE
	C:\> Get-ServicesWithAccounts -Computers ., localhost, georgie, Win8-L7.example.local
	checkServicesOnComputer : The WinRM client cannot process the request. If the authentication scheme is different from
	Kerberos, or if the client computer is not joined to a domain, then HTTPS transport must be used or the destination
	machine must be added to the TrustedHosts configuration setting. Use winrm.cmd to configure TrustedHosts. Note that
	computers in the TrustedHosts list might not be authenticated. You can get more information about that by running the
	following command: winrm help config.
	At C:\Scripts\Get-ServicesWithAccounts.ps1:338 char:2
	+     checkServicesOnComputer $computer
	+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	    + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
	    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,checkServicesOnComputer
	C:\>

	In this case, all of ".", "localhost", and "Win8-L7" refer to the same computer - which has no special services. "Georgie" is a computer that does not exist.

	The UseWMI parameter was not specified, so the script checked the current OS. The current OS is Windows 8.1, so CIM was used instead of WMI.
.EXAMPLE
	C:\> Get-ServicesWithAccounts -Computers ., localhost, georgie, Win8-L7.example.local -UseWMI
	checkServicesOnComputer : The RPC server is unavailable. (Exception from HRESULT: 0x800706BA)
	At C:\Scripts\Get-ServicesWithAccounts.ps1:338 char:2
	+     checkServicesOnComputer $computer
	+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	    + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
	    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,checkServicesOnComputer
	C:\>

	To compare against the non-UseWMI case, accessing Georgie still fails when using WMI, but the error is different.
.EXAMPLE
	C:\> Get-ServicesWithAccounts -Computers ., localhost, georgie, Win8-L7.example.local -NoErrors
	Computer                      Account                       ShortName                     FullName
	--------                      -------                       ---------                     --------
	georgie                       
	C:\>

	In this case, all of ".", "localhost", and "Win8-L7" refer to the same computer - which has no special services. "Georgie" is a computer that does not exist. With the NoErrors switch, the output is much easier to comprehend.

	If UseWMI had been set, the output would have been the same.
#>

#endregion

[CmdletBinding( SupportsShouldProcess = $false, ConfirmImpact = 'None' )]

Param (
	[Parameter( Mandatory = $false )]
	[string] $FileName = $null,

	[Parameter( Mandatory = $false )]
	[string[]] $Computers = $null,

	[Parameter( Mandatory = $false )]
	[Alias( 'OU' )]
	[string] $OrganizationalUnit = $null,

	[Parameter( Mandatory = $false )]
	[bool] $SubTree = $false,

	[Parameter( Mandatory = $false )]
	[switch] $NoErrors,

	[Parameter( Mandatory = $false )]
	[switch] $UseWMI
)

Set-StrictMode -Version 2.0

$arrExclude = 
	'NT Authority\LocalService',
	'NT Authority\Local Service',
	'NT Authority\System',
	'NT Authority\Network Service', 
	'NT Authority\NetworkService',
	'LocalSystem',
	'.\ASPNET'

$iAdmin    = 0
$iTotal    = 0
$iCount    = 0
$iError    = 0
$iEmpty    = 0
$iComment  = 0
$iExcluded = 0

$psversion = 1
if( Test-Path Variable:PSVersionTable )
{
	$psversion = $PSVersionTable.PSVersion.Major
}
Write-Verbose "Using PSVersion = $psversion"

function searchOU( [string] $ou, [bool] $subtree )
{
	Write-Verbose "About to search '$ou'"

	$objDomain              = New-Object System.DirectoryServices.DirectoryEntry( 'LDAP://' + $ou )
	$objSearcher            = New-Object System.DirectoryServices.DirectorySearcher
	$objSearcher.SearchRoot = $objDomain
	$objSearcher.Filter     = "(objectCategory=Computer)"
	if( $subtree )
	{
		Write-Verbose 'SearchScope is SubTree'
		$objSearcher.SearchScope = [System.DirectoryServices.SearchScope]::SubTree
	}
	else
	{
		Write-Verbose 'SearchScope is OneLevel'
		$objSearcher.SearchScope = [System.DirectoryServices.SearchScope]::OneLevel
	}

	$results = $objSearcher.FindAll()
	Write-Verbose "OU search returned $($results.Count) results"

	[string[]]$array = $null

	foreach( $result in $results )
	{
		Write-Verbose "Result added '$($result.Properties.dnshostname.Item(0))'"
		$array += $result.Properties.dnshostname.Item( 0 )
	}

	return $array
}

function makeObject( [string] $computer, [string] $account, [string] $shortname, [string] $fullname )
{
	$obj = '' | Select Computer, Account, ShortName, FullName

	$obj.Computer  = $computer.ToLower()
	$obj.Account   = $account.ToLower()
	$obj.ShortName = $shortname
	$obj.FullName  = $fullname

	return $obj
}

function checkServicesOnComputer( [string] $strComputer )
{
	[bool] $bResult = $false
	[object] $results = $null

	Write-Verbose "Checking computer $strComputer" 

	$error.Clear()
	if( $useWMI -or ( $psversion -lt 3 ) )
	{
		$results = Get-WmiObject Win32_Service -ComputerName $strComputer -Property Name, StartName, Caption -EA 0 | 
			Select Name, StartName, Caption
		$bResult = $?
	}
	else
	{
		$results = Get-CimInstance Win32_Service -ComputerName $strComputer -Property Name, StartName, Caption -EA 0 | 
			Select Name, StartName, Caption
		$bResult = $?
	}

	if( -not $bResult )	# if( $bResult -eq $false )
	{
		$Script:iError++
		if( -not $noErrors )
		{
			Write-Error $error[ 0 ].ToString()

			### If we use 'throw' instead of write-error, then the error becomes terminating,
			### when the user does not use -noerrors. That is a non-optimal behavior.
			### throw $error[ 0 ]
		}
		else
		{
			makeObject $strComputer '' '' ''
			Write-Verbose "....An error has occurred, but was suppressed; no results were returned from computer $strComputer"
		}

		return
	}

	if( $null -eq $results )
	{
		Write-Verbose "No error occurred, but no results were returned on computer $strComputer"

		return
	}

	Write-Verbose "I have found $($results.Count) services on computer $strComputer"

	$iIncluded = 0
	foreach( $result in $results )
	{
		$account = $result.StartName
		$accName = $result.Name

		if( [String]::IsNullOrEmpty( $account ) )
		{
			Write-Verbose "No account was specified for service $accName"

			$Script:iExcluded++
			continue
		}

		if( $arrExclude -contains $account )
		{
			### this is too verbose
			### Write-Verbose "Account $account excluded for service $accName"

			$Script:iExcluded++
			continue
		}

		$acctLen   = $account.Length

		$ntService = "NT Service\"
		$ntServLen = $ntService.Length

		if( ( $acctLen -gt $ntServLen ) -and ( $account.SubString( 0, $ntServLen ) -eq $ntService ) )
		{
			Write-Verbose "NT Service account excluded: $account for $accName"

			$Script:iExcluded++
			continue
		}

		$iIncluded++

		### i should actually check the SID for '-500'. but i don't.

		$adminR = "\administrator";  ## admin-from-the-right
		if( ( $acctLen -ge $adminR.Length ) -and
		    ( $account.SubString( $acctLen - $adminR.Length ) -eq $adminR ) )
		{
			Write-Verbose "Account $account is an administrator account (1)"
			$Script:iAdmin++
		}

		$adminL = "administrator@";  ## admin-from-the-left
		if( ( $acctLen -ge $adminL.Length ) -and
		    ( $account.SubString( 0, $adminL.Length ) -eq $adminL ) )
		{
			Write-Verbose "Account $account is an administrator account (2)"
			$Script:iAdmin++
		}

		Write-Verbose "Account $account, computer $strComputer, service $accName"

		makeObject $strComputer $account $accName $result.Caption
	}

	$Script:iTotal += $iIncluded
}

function doProcessSingleComputer( [string] $computer )
{
	if( [String]::IsNullOrEmpty( $computer) )
	{
		Write-Verbose 'Computer name is null or empty (1)'

		$Script:iEmpty++
		return
	}

	$computer = $computer.Trim()
	if( [String]::IsNullOrEmpty( $computer ) )
	{
		Write-Verbose 'Computer name is null or empty (2)'

		$Script:iEmpty++
		return
	}

	if( '#' -eq $computer.SubString( 0, 1 ) )
	{
		Write-Verbose 'Computer name is a comment'

		$Script:iComment++
		return
	}

	Write-Verbose "About to process $computer"
	checkServicesOnComputer $computer
	$Script:iCount++
}

function doProcessArray( [string[]] $computerArray )
{
	if( ( $null -eq $computerArray ) -or ( $computerArray.Count -le 0 ) )
	{
		return
	}

	Write-Verbose "About to process computerArray containing $($computerArray.Count) items"

	foreach( $computer in $computerArray )
	{
		doProcessSingleComputer $computer
	}
}

function doProcessFile( [string] $filename )
{
	if( [String]::IsNullOrEmpty( $filename ) )
	{
		return
	}

	Write-Verbose "filename = $filename"
	$computers = Get-Content $filename -EA 0
	if( !$? -or ( $null -eq $computers ) -or ( $computers.Count -le 0 ) )
	{
		Write-Warning "Could not read file"
		Write-Verbose "Could not read file"
		return
	}
	Write-Verbose "$filename contains $($computers.Count) lines"

	doProcessArray $computers
}

function doProcessOU( [string] $ou, [bool] $subtree )
{
	if( [String]::IsNullOrEmpty( $ou ) )
	{
		return
	}

	$computerArray = searchOU $ou $subtree
	if( $computerArray -and ( $computerArray.Count -gt 0 ) )
	{
		doProcessArray $computerArray
	}
}

	###
	### Main
	###

	$start = Get-Date
	Write-Verbose "Script starts: $(Get-Date $start -Format u)"

	doProcessFile  $fileName
	doProcessArray $computers
	doProcessOU    $organizationalUnit $subtree

	Write-Verbose ""
	Write-Verbose "Processing complete."
	Write-Verbose "Total computers processed: . . $iCount"
	Write-Verbose "Total excluded services: . . . $iExcluded"
	Write-Verbose "Total Administrator services:  $iAdmin"
	Write-Verbose "Total special services:  . . . $iTotal"
	Write-Verbose "Total empty lines: . . . . . . $iEmpty"
	Write-Verbose "Total comment lines: . . . . . $iComment"
	Write-Verbose "Total errors:  . . . . . . . . $iError"

	$end = Get-Date
	Write-Verbose "Script end: $(Get-Date $end -Format u)"
	$diff = $end - $start
	Write-Verbose "Script elapsed: $($diff.ToString())"