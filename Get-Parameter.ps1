function Get-Parameter
{
                
	[OutputType('System.String')]
	[CmdletBinding()]
	
	param( 
		[Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]	
		[ValidateNotNullOrEmpty()]
		[String]$Command,	

		[Parameter(Position=1)]		
		[String[]]$Name=@('*'),

		[Parameter()]		
		[ValidateSet('Name','Type','Pos','BV','BP','DV','Aliases','Mandatory','Dynamic')]
		[String]$SortBy='Name',

		[Parameter()]		
		[switch]$Descending,
		
		[Parameter()]		
		[ValidateSet('Filter','Cmdlet','Function','Alias','ExternalScript')]
		[String]$CommandType,
				
		[switch]$IncludeCommonParameters
	)
        
	
	Process
	{
		
		if($CommandType)
		{
			switch($CommandType)
			{
				"function" 
				{ 
					$cmd = Get-Command -Name $Command -CommandType $CommandType -ErrorAction SilentlyContinue | Where-Object {$_.CommandType -eq $CommandType} 
				}
				
				"filter" 
				{ 
					$cmd = Get-Command -Name $Command -CommandType $CommandType -ErrorAction SilentlyContinue | Where-Object {$_.CommandType -eq $CommandType} 
				}
				
				default
				{
					$cmd = Get-Command -Name $Command -CommandType $CommandType -ErrorAction SilentlyContinue 
				
				}				
			}
		}
		else
		{
			$cmd = Get-Command -Name $Command -CommandType Cmdlet,Function,Alias,ExternalScript -ErrorAction SilentlyContinue
		}
		
		if(!$cmd)
		{
			Throw "'$Name' is not a Cmdlet,Function,Filter,Alias or ExternalScript"
		}
		
		if($cmd.length -gt 1)
		{
			$types = $cmd | Select-Object -ExpandProperty CommandType -Unique
			Throw "'$Command' is ambiguous and matches one of $($types -join ","). Use -CommandType to get only a specified type of command."
		}		


		if($cmd.CommandType -eq 'Alias')
		{
			Write-Verbose "'$Name' refers to an Alias, reolving command."
			$cmd = Get-Command -Name $cmd.ResolvedCommandName				
		}
		

		foreach($set in $cmd.ParameterSets)
		{					
			if($IncludeCommonParameters)
			{			
				[array]$p = $set.Parameters | Select-Object *
			}
			else
			{
				# Get a list of common parameters
				$cp = [System.Management.Automation.Internal.CommonParameters].GetProperties() | Select-Object -ExpandProperty Name
				[array]$p = $set.Parameters | Where-Object {$cp -notcontains $_.Name} | Select-Object *	
			}			
			
			if($p.count -le 0 -and !$IncludeCommonParameters)
			{
				Write-Warning "The specified cmdlet ('$cmd') has no parameters."
				return
			}


			$params = $p | Foreach-Object {$_.Name} 
			

			for($i=0;$i -le $p.length;$i++)
			{
				$flag=$false

				for($x=0;$x -le $params[$i].length -and !($flag);$x++)
				{             
					$regex = "^" + $params[$i].substring(0,$x)
					if(($params -match $regex).count -eq 1)
					{
						$flag=$true
						$p[$i].Aliases += $regex.substring(1).ToLower()
					}
				}
			}


			$p | Where-Object {$_.Name -like $Name} | Foreach-Object {

				$PropertyName = $_.Name
				$psn = $_.Attributes | Where-Object {$_.ParameterSetName}					
				
				
				if($psn.ParameterSetName -notmatch '__AllParameterSets')
				{
					$PropertyName="*$PropertyName"
				}

			
				New-Object PSObject -Property @{
				
					ParameterSet = $set.Name
					Name = $PropertyName
					BV = $_.ValueFromPipeline
					BP = $_.ValueFromPipelineByPropertyName
					Type = $_.ParameterType.Name
					Aliases = $_.Aliases
					Pos = if($_.Position -lt 0) {'Named'} else {$_.Position+1}
					Mandatory = $_.IsMandatory
					Dynamic = $_.IsDynamic
				}

			} | Sort-Object -Descending:$Descending {$_.$SortBy -replace '\*'} | Format-Table Name,Type,Pos,BV,BP,Aliases,Mandatory,Dynamic -AutoSize -GroupBy ParameterSet | Out-String
			
		}
	}
}


Set-Alias -Name gprm -Value Get-Parameter