# Need to Run As Admin
# Set locations
$WinSATFile = "MyWinSATScore.xml"
$WinSATFolder = "$ENV:windir\performance\winsat\datastore"

# Change to Location
Set-Location $WinSATFolder

# If WinSATFile exists Delete it.
If (Test-Path $WinSATFile)
  {Remove-Item $WinSATFile}

# Run Winsat (CMD command)
Winsat formal -xml MyWinSATScore.XML

# View Scores
[xml]$WinSat=Get-Content $WinSATFile
($sat = $WinSat.WinSAT.WinSPR)