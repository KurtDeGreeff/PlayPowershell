function Show-PSDemo{
Param([String] $FileLocation)

	## - Verify for a valid file location:
	if((Test-Path -Path $FileLocation) -ne $true)
	{
		Write-Host "No script files to execute!" `
			-ForegroundColor 'Yellow';
		Break;
	}
	else
	{
		[Array] $executethis = Get-Content $FileLocation;
	};

	## - Saved previous default Host Colors:
	$defaultForegroundColor = $host.UI.RawUI.ForegroundColor;
	$defaultBackgroundColor = $host.UI.RawUI.BackgroundColor;

	## - Customizing Host Colors:
	$host.UI.RawUI.ForegroundColor = "Cyan";
	$host.UI.RawUI.BackgroundColor = "Black";
	$StartDemoTime = [DateTime]::now; $i = 0;
	Clear-Host;

	Write-Host "Demo Start Time: $([DateTime]::now)" -ForeGroundColor 'White';
	Write-Host "`t Running Script file: $FileLocation" -ForegroundColor 'Yellow';

	foreach($line in $executethis)
	{
		$i++
		## - Identify comment lines:
		if($line.Startswith('#')){
			Write-Host -NoNewLine $("`n[$i]PS> ")
	        Write-Host -NoNewLine -Foreground 'Green' $($($line) + "  ")
		}
		Else
		{
			## - add section identify oneliners with continuation tick:
			[string] $Addline = $null;
			if($line -match '`')
			{
				#Write-Host " Found tick = `t`r`n $($line)" -ForegroundColor yellow;
				$Addline = $line.replace('`','').tostring();
				$Scriptline += $Addline;
				$tickFound = $true;
				$continuation = $true;

				## - List oneliner with continuation tick:
				Write-Host -NoNewLine $("`n[$i]PS> ");
				Write-Host -NoNewLine $line;
			}
			else
			{
				## - identify the last line of a continuation oneliner:
				if($tickFound -eq $true)
				{
					$Scriptline += $line;
					$tickFound = $false;
					$continuation = $false;

					## - List oneliner with continuation tick:
					Write-Host -NoNewLine $("`n[$i]PS> ");
					Write-Host -NoNewLine $line "`r`n";
				}
				Else
				{
					## - Single onliner found:
					$Scriptline = $line;
					$continuation = $false;
					Write-Host -NoNewLine $("`n[$i]PS> ")
					Write-Host -NoNewLine $Scriptline "`r`n";
				};
			};
			if($continuation -eq $false)
			{
				## - Executive:
				Write-Host "`r`n`t Executing Script...`r`n" -ForegroundColor 'Yellow';
				Invoke-Expression $('.{' +$Scriptline + '}| out-host');
				$Scriptline = $null;
			}
			## - --------------------------------------------------------------------
			if($continuation -eq $false)
			{
			Write-Host "`r`n-- Press Enter to continue --" -ForegroundColor 'Magenta' `
				-BackgroundColor white;
			Read-Host;
			};
		};
	};

	$DemoDurationTime = ([DateTime]::Now) - $StartDemoTime;
	Write-Host ("`t <Demo Duration: {0} Minutes and {1} Seconds>" `
		-f [int]$DemoDurationTime.TotalMinutes, [int]$DemoDurationTime.Seconds)
                -ForeGroundColor 'Yellow' ;
	Write-Host "`t Demo Completed at: $([DateTime]::now))" -ForeGroundColor 'White';

	## - Set back to Default Color:
	$host.UI.RawUI.ForegroundColor = $defaultForegroundColor;
	$host.UI.RawUI.BackgroundColor = $defaultBackgroundColor;
};