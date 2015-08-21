#requires -Version 3
function Get-BitcoinPrice
{
	<#
		.SYNOPSIS
			Gets the current price of bitcoin in a given currency

		.DESCRIPTION
			Uses the web api from Coindesk.com to retrieve the current
			price in the specified currency.
						
		.PARAMETER Currency
			The currency to get the bitcoin price in as denoted by the 
			three letter ISO 4217 currency code
		
		.EXAMPLE
			#Get the price in three different currencies
			"Eur","gbp","USD" | Get-BitcoinPrice
		
		.NOTES
			Author: Tim Bertalot
		
		.LINK
			http://www.coindesk.com/api/
			http://gallery.technet.microsoft.com/site/search?query=lanatmwan&f%5B0%5D.Value=lanatmwan&f%5B0%5D.Type=SearchText&ac=4
	#> 
	
	[CmdletBinding(  
		RemotingCapability		= "PowerShell",
		SupportsShouldProcess   = $false,
		ConfirmImpact           = "None",
		DefaultParameterSetName = ""
	)]
		 
	param
	(
		[Parameter(
			HelpMessage			= "Enter the currency to get the bitcoin value in",
			Position			= 0,
			ValueFromPipeline	= $true
		)]
		[ValidateNotNullOrEmpty()]
		[ValidateSet("USD","EUR","GBP")] #exhaustive list of supported currencies: http://api.coindesk.com/v1/bpi/supported-currencies.json
		[String[]]
		$Currency = "USD"
	)
	
	process
	{
		foreach ($item in $currency)
		{
			Invoke-WebRequest -Uri "http://api.coindesk.com/v1/bpi/currentprice/$Currency.json" |
				Select-Object -ExpandProperty Content |
				ConvertFrom-Json |
				Foreach-Object  {
					$_.bpi.$Currency |
						Add-Member -PassThru -Force -membertype Noteproperty -Name Time -Value ([datetime]$_.time.updatedISO)
				}
		}
	}
}
