## sudo.ps1
#
# Authors: rbellamy, pezhore, mrigns, This guy: http://tsukasa.jidder.de/blog/2008/03/15/scripting-sudo-with-powershell,
#             other powershell peoples
#
# Sources:
#       http://tsukasa.jidder.de/blog/2008/03/15/scripting-sudo-with-powershell
#       http://www.ainotenshi.org/%E2%80%98sudo%E2%80%99-for-powershell-sorta
#
# Version:
#       1.0     Initial version
#       1.1     added -ps flag, cleaned up passed $file/$script full path
#       1.2     Comments
#       1.3     Fixed passing working directory to powershell/auto closing
#	1.4	Added hidden window, with Export/Import-Clixml to pull results into current window
#		Doesn't deal well with input PS commands (e.g. 'sudo $Local:WindowsPrincipal.IsInRole("Administrators")')
#		is broken.
 
param (
        [switch]$ps = $true,        # Switch for running args as powershell script
        [string]$file,              # Script/Program to run
        [string]$arguments = $args  # Arguments to program/script
		)
		
$tempPath = "$env:TEMP:\PoSH-sudo-$PID.xml";

# Find our powershell full path
$powershell = (Get-Command powershell).Definition;

# Get current directory
$dir = Get-Location;

# File verification
if([System.IO.File]::Exists("$(Get-Location)\$file")) {
        # Get full path
        $file = (Get-ChildItem $file).Fullname;
}

if ($ps) { 
#If we're running this as a elevated powershell script

        # Create a powershell process
        $psi = New-Object System.Diagnostics.ProcessStartInfo $powershell;
        $psi.WorkingDirectory = Get-Location;
		
        # Combine the script and its arguments
        $sArgs = $file + " " + $arguments;
 
        # Set the arguments to be the ps script and it's arguments
        $psi.Arguments = " -Command Set-Location $dir; $sArgs";
		
		# NOT using the shell to execute!
		$psi.UseShellExecute = $false;
 
        # Magic to run as elevated
        $psi.Verb = "RunAs";
} else { 
# We're running something other than a powershells script

        # Same as above, create proccess/working directory/arguments/runas
        $psi = New-Object System.Diagnostics.ProcessStartInfo $file;
        $psi.Arguments = $arguments;
		
        # Magic to run as elevated
        $psi.Verb = "RunAs";
}

$psi.Arguments = $psi.Arguments + " | Export-Clixml -Path `"$tempPath`"";
$psi.WindowStyle = "Hidden";

# Execute the process
[System.Diagnostics.Process]::Start($psi).WaitForExit();

Import-Clixml -Path "$tempPath";
Remove-Item $tempPath;