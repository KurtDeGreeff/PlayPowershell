function Get-VMWareSnapshot {
	[CmdletBinding()]
	param (
		# vSphere server(s) to connect to
	 	[Parameter()]
	 	[string[]] $VIServer,

	 	# Filter snapshots on VM Name
	 	[Parameter()]
	 	[string[]] $VMName
	)

	try {
		# Check if VMWare snapin is loaded, and load it if it's not
		if ((Get-PSSnapin -Name 'VMWare.VimAutomation.Core' -ErrorAction 'SilentlyContinue') -eq $null) {
			Add-PSSnapin -Name 'VMWare.VimAutomation.Core'
			Write-Verbose 'VMWare.VimAutomation.Core snapin loaded'
		}

		if ($PSBoundParameters['VIServer']) {
			# Connect to VIserver(s)
			Connect-VIServer -Server $VIServer -WarningAction 'SilentlyContinue' | Out-Null
			Write-Verbose 'Connected to VIServer(s)'
		}

		if ($PSBoundParameters['VMName']) {
			# if more than one name is given, generate correct regex for the filtering
			if ($VMName.Length -gt 1) {
				$regexString = ($VMName | ForEach-Object {"($($_)`$)"}) -Join '|'
				$snapshots = Get-View -ViewType 'VirtualMachine' -Property Name,Snapshot -Filter @{"Name"=$regexString;"Snapshot"="VMware.Vim.VirtualMachineSnapshotinfo"}
			}
			# if only one name is given, the filter is easier
			else {
				$snapshots = Get-View -ViewType 'VirtualMachine' -Property Name,Snapshot -Filter @{"Name"="$($VMName)`$";"Snapshot"="VMware.Vim.VirtualMachineSnapshotinfo"}
			}
			Write-Verbose 'Got data from vSphere'
		}

		# if the name parameter is not used, no filtering is done
		else {
			$snapshots = Get-View -ViewType 'VirtualMachine' -Property Name,Snapshot -Filter @{"Snapshot"="VMware.Vim.VirtualMachineSnapshotinfo"}
			Write-Verbose 'Got data from vSphere'
		}

		if ($snapshots) {
			foreach ($snapshot in $snapshots){
				Write-Output (,([PSCustomObject] [Ordered] @{
					VMName = $snapshot.Name
					Name = (($snapshot.snapshot.rootsnapshotlist | Select-Object Name).Name)
					Description = (($snapshot.snapshot.rootsnapshotlist | Select-Object Description).Description)
					CreateTime = (($snapshot.snapshot.rootsnapshotlist | Select-Object CreateTime).CreateTime)
					State = (($snapshot.snapshot.rootsnapshotlist | Select-Object State).State)
					ChildSnapshots = $snapshot.snapshot.rootsnapshotlist.childsnapshotlist
				}))
			}
		}
	}

	catch {
		Write-Warning $_.Exception.Message
	}
}