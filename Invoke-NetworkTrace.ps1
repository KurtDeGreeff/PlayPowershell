#************************************************************************************#
#START NETWORK TRACES ON REMOTE COMPUTERS
#************************************************************************************

# This sample PowerShell script performs the following tasks #

# #

# 1. defines output path & folder on each target computer #

# 2. creates the output path & folder on each target computer if not already present #

# 3. starts network tracing on each target computer #

# 4. stops network tracing on each target computer when “x” key is pressed by user #

# 5. copies network traces from each remote computer to local directory #

# #

#************************************************************************************#

#START NETWORK TRACES ON REMOTE COMPUTERS

#Specify target computer names

$computers= 'COMPUTER1','COMPUTER2',' COMPUTER3','COMPUTER4'

#Drive letter on remote computers to create output folder under

$drive='C'

#Folder path on remote computers to save output file to

$directory='TEMP\TRACES'

$path= $drive + ':\' + $directory

#SCRIPTBLOCK TO BE EXECUTED ON EACH TARGET COMPUTER

$scriptBlockContent=

{

param ($localoutputpath,$tracefullpath)

#Verify that output path & folder exists. If not, create it.

if((Test-Path -isValid $localoutputpath))

{

New-Item -Path $localoutputpath -ItemType directory

}

#Start network trace and output file to specified path

netsh trace start capture=yes tracefile=$tracefullpath

}

#Loop to execute scriptblock on all remote computers

ForEach ($computer in $computers)

{

$file= $computer + '.etl'

$output= $path + '\' + $file

Invoke-Command -ComputerName $computer -ScriptBlock $ScriptBlockContent -ArgumentList $path, $output

}

#Loop to check for “X” key

While($True)

{

$Continue= Read-Host "Press 'X' To Stop the Tracing"

If ($Continue.ToLower() -eq 'x')

{

#STOP NETWORK TRACES ON REMOTE COMPUTERS

#Run 'netsh trace stop' on each target computer

ForEach ($computer in $computers)

{

Invoke-Command -ComputerName $computer -ScriptBlock {netsh trace stop}

}

#COLLECT TRACES

#Copy network traces from each target computer to a folder on the local server

ForEach ($computer in $computers)

{

$file= $computer + '.etl'

$unc= '\\' + $computer + '\' + $drive + "$\" + $directory

#Specify directory on local computer to copy all network traces to

#NOTE: There is no check to verify that folder exists.

$localdirectory='C:\TRACES'

$tracefile= $unc + '\' + $file

Copy-Item $tracefile $localdirectory

Write-Host $file 'copied successfully to' $localdirectory

}

break

}

}