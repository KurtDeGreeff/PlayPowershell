<#
The sample scripts are not supported under any Microsoft standard support 
program or service. The sample scripts are provided AS IS without warranty  
of any kind. Microsoft further disclaims all implied warranties including,  
without limitation, any implied warranties of merchantability or of fitness for 
a particular purpose. The entire risk arising out of the use or performance of  
the sample scripts and documentation remains with you. In no event shall 
Microsoft, its authors, or anyone else involved in the creation, production, or 
delivery of the scripts be liable for any damages whatsoever (including, 
without limitation, damages for loss of business profits, business interruption, 
loss of business information, or other pecuniary loss) arising out of the use 
of or inability to use the sample scripts or documentation, even if Microsoft 
has been advised of the possibility of such damages.
#> 

#requires -Version 3

<#
	.SYNOPSIS
		The RemoveAppxPackage command will remove Windows Store Appx packages.

	.DESCRIPTION
		This script can help you to remove several Windows Store Apps at one time.  
		
	.EXAMPLE
		PS C:\> C:\Script\RemoveWindowsStoreApp.ps1
		
		ID       App name
		 1       Microsoft.Media.PlayReadyClient.2
		 2       Microsoft.Media.PlayReadyClient.2
		 3       CheckPoint.VPN
		 4       f5.vpn.client
		 5       FileManager
		 6       JuniperNetworks.JunosPulseVpn
		 7       Microsoft.MoCamera
		 8       SonicWALL.MobileConnect
		 9       windows.immersivecontrolpanel
		 10      winstore
		 11      Microsoft.BingSports
		 12      Microsoft.BingTravel
		 13      Microsoft.SkypeApp
		 14      Microsoft.BingFinance
		 15      Microsoft.HelpAndTips
		 16      Microsoft.BingFoodAndDrink
		 17      Microsoft.BingHealthAndFitness
		 18      Microsoft.BingNews
		 19      microsoft.windowscommunicationsapps
		 20      Microsoft.WindowsSoundRecorder
		 21      Microsoft.WindowsScan
		 22      Microsoft.ZuneMusic
		 23      Microsoft.VCLibs.120.00
		 24      Microsoft.WindowsAlarms
		 25      Microsoft.WinJS.2.0
		 26      Microsoft.WindowsCalculator
		 27      Microsoft.BingWeather
		 28      Microsoft.Reader
		 29      Microsoft.ZuneVideo
		 30      Microsoft.WindowsReadingList
		 31      Microsoft.BingMaps
		 32      Microsoft.XboxLIVEGames
		 33      Microsoft.VCLibs.120.00
		Which Apps do you want to remove?
		Input their IDs and seperate IDs by comma: 28

		This example shows how to list all Windows Store apps, and remove the apps specified by user.
	
	.LINK
		Windows PowerShell Advanced Function
		http://technet.microsoft.com/en-us/library/dd315326.aspx
	
	.LINK
		Get-AppxPackage
		http://technet.microsoft.com/en-us/library/hh856044.aspx
		
	.LINK
		Remove-AppxPackage
		http://technet.microsoft.com/en-us/library/hh856038.aspx	
#>
Import-LocalizedData -BindingVariable Messages

Function PSCustomErrorRecord
{
	#This function is used to create a PowerShell ErrorRecord
	Param
	(		
		[Parameter(Mandatory=$true,Position=1)][String]$ExceptionString,
		[Parameter(Mandatory=$true,Position=2)][String]$ErrorID,
		[Parameter(Mandatory=$true,Position=3)][System.Management.Automation.ErrorCategory]$ErrorCategory,
		[Parameter(Mandatory=$true,Position=4)][PSObject]$TargetObject
	)
	Process
	{
		$exception = New-Object System.Management.Automation.RuntimeException($ExceptionString)
		$customError = New-Object System.Management.Automation.ErrorRecord($exception,$ErrorID,$ErrorCategory,$TargetObject)
		return $customError
	}
}
	
Function RemoveAppxPackage
{
	$index=1
	$apps=Get-AppxPackage
	#return entire listing of applications 
	Write-Host "ID`t App name"
	foreach ($app in $apps)
	{
		Write-Host " $index`t $($app.name)"
		$index++
	}
    
    Do
    {
        $IDs=Read-Host -Prompt "Which Apps do you want to remove? `nInput their IDs and seperate IDs by comma"
    }
    While($IDs -eq "")
    
	#check whether input values are correct
	try
	{	
		[int[]]$IDs=$IDs -split ","
	}
	catch
	{
		$errorMsg = $Messages.IncorrectInput
		$errorMsg = $errorMsg -replace "Placeholder01",$IDs
		$customError = PSCustomErrorRecord `
		-ExceptionString $errorMsg `
		-ErrorCategory NotSpecified -ErrorID 1 -TargetObject $pscmdlet
		$pscmdlet.WriteError($customError)
		return
	}

	foreach ($ID in $IDs)
	{
		#check id is in the range
		if ($ID -ge 1 -and $ID -le $apps.count)
		{
			$ID--
			#Remove each app
			$AppName=$apps[$ID].name

			Remove-AppxPackage -Package $apps[$ID] -ErrorAction SilentlyContinue
			if (-not(Get-AppxPackage -Name $AppName))
			{
				Write-host "$AppName has been removed successfully"
			}
			else
			{
				Write-Warning "Remove '$AppName' failed! This app is part of Windows and cannot be uninstalled on a per-user basis."
			}
		}
		else
		{
			$errorMsg = $Messages.WrongID
			$errorMsg = $errorMsg -replace "Placeholder01",$ID
			$customError = PSCustomErrorRecord `
			-ExceptionString $errorMsg `
			-ErrorCategory NotSpecified -ErrorID 1 -TargetObject $pscmdlet
			$pscmdlet.WriteError($customError)
		}
	}
}

RemoveAppxPackage
