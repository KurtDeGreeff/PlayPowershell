# --------------------------------- Meta Information for Microsoft Script Explorer for Windows PowerShell V1.0 ---------------------------------
# Title: copy-data
# Description: Copy Data between Folders including a Progressbar
# Source: http://poshcode.org/1103
# Search Terms: copy
# ------------------------------------------------------------------

function copy-data {
	param($source, $dest)
	$counter = 0
	$files = Get-ChildItem $source -Force -Recurse
	foreach($file in $files)
		{
		$status = "Copying file {0} of {1}: {2}" -f $counter, $files.count, $file.name
		Write-Progress -Activity "Copyng Files" -Status $status -PercentComplete ($counter/$files.count * 100)
		Copy-Item $file.pspath $dest -Force
		$counter++
		}
}

copy-data X:\drivers x:\test 