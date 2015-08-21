function RunAndWait([string] $command, [string] $arguments) {
    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo.FileName = $command
    $proc.StartInfo.Arguments = $arguments
	$proc.StartInfo.LoadUserProfile = $false
	$proc.StartInfo.UseShellExecute = $true
	$proc.StartInfo.CreateNoWindow = $true
	$proc.StartInfo.WorkingDirectory = (Get-Location).Path
	
    $proc.Start()
    $proc.WaitForExit()
  
    #new-variable -name EXITCODE -scope Script -visibility public -value $proc.ExitCode
}


$WebClient = New-Object System.Net.WebClient

if (!(Test-Path "$env:TEMP\SCCMPrereqs")) {
	$temp = New-Item -ItemType Directory -Name SCCMPrereqs -Path $env:TEMP
	$expTarget = New-Item -ItemType Directory -Name Manifests -Path $temp
} elseif (!(Test-Path "$env:TEMP\SCCMPrereqs\Manifests")) {
	$expTarget = New-Item -ItemType Directory -Name Manifests -Path $temp
} else { 
	$temp = Get-Item "$env:TEMP\SCCMPrereqs"
	$expTarget = Get-Item "$temp\Manifests"
}

# These locations are current as of SCCM 2012 SP1 RTM, January 18th, 2013
$SCCMLNManifest = 'http://go.microsoft.com/fwlink/?linkid=269721'
$SCCMManifest = 'http://go.microsoft.com/fwlink/?linkid=269720'

#Assuming this works - not capturing the error
# DownloadFile always overwrites existing
$WebClient.DownloadFile($SCCMManifest,"$($temp.FullName)\ConfigMgr.Manifest.cab")
$WebClient.DownloadFile($SCCMLNManifest,"$($temp.FullName)\ConfigMgr.LN.Manifest.cab")

# expand.exe always overwrites existing, but must target a different dir than cab (Src)
if (Test-Path "$($expTarget.FullName)\ConfigMgr.Manifest.xml") {
	Move-Item -Force "$($expTarget.FullName)\ConfigMgr.Manifest.xml" "$($expTarget.FullName)\ConfigMgr.Manifest.xml.old"
}
if (Test-Path "$($expTarget.FullName)\ConfigMgr.LN.Manifest.xml") {
	Move-Item -Force "$($expTarget.FullName)\ConfigMgr.LN.Manifest.xml" "$($expTarget.FullName)\ConfigMgr.LN.Manifest.xml.old"
}
RunAndWait "expand.exe" "-R $temp\*.cab -F:* $($expTarget.FullName)" > $null

#hoping files exist. I'm not actually checking if download or expand was successful
[xml] $Manifest = Get-Content "$($expTarget.FullName)\ConfigMgr.Manifest.xml"
[xml] $LNManifest = Get-Content "$($expTarget.FullName)\ConfigMgr.LN.Manifest.xml"

#if (Test-Path "$expTarget.FullName\ConfigMgr.Manifest.xml.old") {
#	[xml] $OldManifest = Get-Content "$expTarget.FullName\ConfigMgr.Manifest.xml.old"
#} elseif (Test-Path "$expTarget.FullName\ConfigMgr.LN.Manifest.xml.old") {
#	[xml] $OldLNManifest = Get-Content "$expTarget.FullName\ConfigMgr.LN.Manifest.xml.old"
#}

foreach ($file in $Manifest.ConfigMgr.Group) {
	foreach ($source in $file.File) {
		$name = $source.CopyName
		$url = $source.Source
		$hash = $source.SHA256
		$target = "$temp\$name"
		if (Test-Path $target) {
			$fileStream = [system.io.file]::openread((resolve-path $target))
			$hasher = [System.Security.Cryptography.HashAlgorithm]::create('sha256')
			$DiffHash = $hasher.ComputeHash($fileStream)
			$DiffHash = [system.bitconverter]::tostring($DiffHash)
			$DiffHash = $DiffHash.Replace('-','')
			$fileStream.close()
			$fileStream.dispose()
			if (!($hash -eq $DiffHash)) {
				Remove-Item -Force $target
				Write-Host "Downloading (replace) $name from $url to $temp..."
				$WebClient.DownloadFile($url,$target)
			} else { Write-Host "Skipping $name, versions match..." }
		} else {
			Write-Host "Downloading (new) $name from $url to $temp..."
			$WebClient.DownloadFile($url,$target)
		}
	}
}

Write-Host "Be sure to grab your SCCM 2012 prerequisites from $temp. You may keep the contents around or delete them. If you decide to keep them, version checking will download only the files you need."