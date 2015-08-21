#******************************************************************************
#* <Function Start-RemoteProcess>                                             *
#*                                                                            *
#* This function uses WMI to start a process on a remote computer.            *
#*                                                                            *
#* Input:                                                                     *
#*     [string] $Path - path to the file to execute                           *
#*     [string] $Computer - computer to create the process on                 *
#*              $Window {                                                     *
#*                  "Hidden" - hide the process window                        *
#*                  "Normal" - activate and display the window (default)      *
#*                  "Minimized" - minimize the window                         *
#*                  "Maximized" - maximize the window                         *
#*              }                                                             *
#*     [string] $StartPath - the starting path for the application            *
#*     [string] $Title - set the title of the window                          *
#*     [switch] $Priority {                                                   *
#*                  "Realtime" - set the process priority to realtime         *
#*                  "High" - set the process priority to high                 *
#*                  "AboveNormal" - set the process priority to above normal  *
#*                  "Normal" - set the process priority to normal (default)   *
#*                  "BelowNormal" - set the process priority to below normal  *
#*                  "Idle" - set the process priority to idle                 *
#*              }                                                             *
#*     [int]    $X - set the x position of the window                         *
#*     [int]    $XSize - set the width of the window                          *
#*     [int]    $Y - set the y position of the window                         *
#*     [int]    $YSize - set the height of the window                         *
#*     [PSCredential] $Credential - Credentials to connect to the computer    *
#*     [switch] $Elevate - Elevate the process in UAC                         *
#*                                                                            *
#* Output:                                                                    *
#*     [wmiobject]"Win32_Process" - the process that was created              *
#******************************************************************************
function Start-RemoteProcess {
    param(
        [Parameter(
            Mandatory=$True,
            ValueFromPipeline=$True,
            HelpMessage='The process to start on the computer')]
            [string] $Path,
        [Parameter(
            HelpMessage='The computer to start the process on')]
            [string] $Computer = ".",
        [Parameter(
            HelpMessage='The starting working path for the application')]
            [string] $StartPath = "c:\windows\system32\",
        [ValidateSet("Hidden", "Normal", "Minimized", "Maximized",
            IgnoreCase= $True)]
            [Parameter(
            HelpMessage='What state to start the program window')]
            $Window = "Normal",
        [Parameter(
            HelpMessage='The title to assign to the window')]
            [string] $Title,
        [ValidateSet("RealTime", "High", "AboveNormal", "Normal", 
            "BelowNormal","Idle", IgnoreCase=$True)]
            [Parameter(
            HelpMessage='What priority to assign the new process')]
            $Priority = "Normal",
        [Parameter(
            HelpMessage='The starting X position of the window')]
            [int] $X,
        [Parameter(
            HelpMessage='The width of the window')]
            [int] $XSize,
        [Parameter(
            HelpMessage='The starting Y position of the window')]
            [int] $Y,
        [Parameter(
            HelpMessage='The starting height of the window')]
            [int] $YSize,
        [Parameter(
            HelpMessage='Credentials to connect to the remote computer')]
            [PSCredential] $Credential,
        [Parameter(
            HelpMessage='Elevate the process in User Account Control')]
            [switch] $Elevate = $False
    )
    
    #Create a new instance of W32_ProcessStartup
    $wmiProcessStartup = [wmiclass]"Win32_ProcessStartup"

    #Set the window state for the process
    switch($Window) {
        "Hidden" {$wmiProcessStartup.Properties['ShowWindow'].Value = 0}
        "Minimized" {$wmiProcessStartup.Properties['ShowWindow'].Value = 2}
        "Maximized" {$wmiProcessStartup.Properties['ShowWindow'].Value = 3}
    }

    #Set the window title if specified
    if ($Title -ne $Null) {$wmiProcessStartup.Properties['Title'].Value = $Title}

    #Set the process priority, if specified
    switch($Priority){
        "RealTime" {$wmiProcessStartup.Properties['PriorityClass'].Value = 256}
        "High" {$wmiProcessStartup.Properties['PriorityClass'].Value = 128}
        "AboveNormal" {$wmiProcessStartup.Properties['PriorityClass'].Value = 32768}
        "BelowNormal" {$wmiProcessStartup.Properties['PriorityClass'].Value = 16384}
        "Idle" {$wmiProcessStartup.Properties['PriorityClass'].Value = 64}
    }

    #Set the window X position if specified
    If ($X -ne $Null) {$wmiProcessStartup.Properties['X'].Value = $X}

    #Set the window Y position if specified
    If ($Y -ne $Null) {$wmiProcessStartup.Properties['Y'].Value = $Y}

    #Set the window width if specified
    If ($XSize -ne $Null) {$wmiProcessStartup.Properties['XSize'].Value = $XSize}

    #Set the window height if specified
    If ($YSize -ne $Null) {$wmiProcessStartup.Properties['YSize'].Value = $YSize}

    if ($Credential -eq $Null) {
        #Credentials were not specified
        If ($Elevate) {
            #Elevation was requested
            return Invoke-WmiMethod -ComputerName $Computer -Class "Win32_Process" -Name Create -EnableAllPrivileges -ArgumentList $Path, $StartPath, $wmiProcessStartup
        } else {
            #Elevation was not requested
            return Invoke-WmiMethod -ComputerName $Computer -Class "Win32_Process" -Name Create -ArgumentList $Path, $StartPath, $wmiProcessStartup
        }
    } else {
        #Credentials were specified
        If ($Elevate) {
            #Elevation was requested
            return Invoke-WmiMethod -ComputerName $Computer -Class "Win32_Process" -Name Create -EnableAllPrivileges -ArgumentList $Path, $StartPath, $wmiProcessStartup -Credential $Credential
        } else {
            #Elevation was not requested
            return Invoke-WmiMethod -ComputerName $Computer -Class "Win32_Process" -Name Create -ArgumentList $Path, $StartPath, $wmiProcessStartup -Credential $Credential
        }
    }
}

#******************************************************************************
#* </Function Start-RemoteProcess>                                            *
#******************************************************************************