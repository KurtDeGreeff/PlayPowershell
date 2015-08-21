
Function Show-Window{
    Param(  [parameter(Mandatory=$false, ValuefromPipeline = $false)] [String[]] [ValidateSet( "Hide", "Normal", "ShowMinimized", "Maximize", "ShowNoActivate", "Show", "Minimize", "ShowMinNoActive", "ShowNA", "Restore", "ShowDefault", "ForceMinimize")] $WindowState = "Normal",
            [parameter(Mandatory=$false, ValuefromPipeline = $true)]  [Int32] $ID = $PID
            )
   $signature = @"
[DllImport("user32.dll")] 
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@
    $showWindowAsync = Add-Type -memberDefinition $signature -name "Win32ShowWindowAsync" -namespace Win32Functions -passThru
    switch($WindowState){
        "Hide"               {$WinStateInt =  0}
        "Normal"             {$WinStateInt =  1}
        "ShowMinimized"      {$WinStateInt =  2}
        "Maximize"           {$WinStateInt =  3}
        "ShowNoActivate"     {$WinStateInt =  4}
        "Show"               {$WinStateInt =  5}
        "Minimize"           {$WinStateInt =  6}
        "ShowMinNoActive"    {$WinStateInt =  7}
        "ShowNA"             {$WinStateInt =  8}
        "Restore"            {$WinStateInt =  9}
        "ShowDefault"        {$WinStateInt = 10}
        "ForceMinimize"      {$WinStateInt = 11}
        default    {$WinStateInt =  1}
        }
    $showWindowAsync::ShowWindowAsync((Get-Process -id $ID).MainWindowHandle, $WinStateInt)|Out-Null
    
    <#
            .SYNOPSIS 
            Show, Hide Minimize, Maximize, or Restore the Powershell Console or other Window. 
        
            .DESCRIPTION 
           Show, Hide Minimize, Maximize, or Restore the Powershell Console or other Window. 
            
            .PARAMETER WindowState
            [string] The New Window state Mode.
                May be one of the following:
                        
                    Hide                Hides the window and activates another window.
                    Normal              Activates and displays a window. This is the Default. If the window is minimized or maximized, the system restores it to its original size and position. An application should specify this flag when displaying the window for the first time.
                    ShowMinimized       Activates the window and displays it as a minimized window.
                    Maximize            Maximizes the specified window.
                    ShowNoActivate      Displays a window in its most recent size and position. This value is similar to SW_SHOWNORMAL, except that the window is not activated.
                    Show                Activates the window and displays it in its current size and position. 
                    Minimize            Minimizes the specified window and activates the next top-level window in the Z order.
                    ShowMinNoActive     Displays the window as a minimized window. This value is similar to SW_SHOWMINIMIZED, except the window is not activated.
                    ShowNA              Displays the window in its current size and position. This value is similar to SW_SHOW, except that the window is not activated. 
                    Restore             Activates and displays the window. If the window is minimized or maximized, the system restores it to its original size and position. An application should specify this flag when restoring a minimized window.
                    ShowDefault         Sets the show state based on the SW_ value specified in the STARTUPINFO structure passed to the CreateProcess function by the program that started the application. 
                    ForceMinimize       Minimizes a window, even if the thread that owns the window is not responding. This flag should only be used when minimizing windows from a different thread.
            .PARAMETER ID
            [Int32] The Process Identifier (PID) of the Target Window. If this paremeter is not specified the Target window defaults to the current Powershell Console Window.
            .INPUTS
            [Int32] $ID You can pipe Process Identifier (PID) of the Target Window.
            .OUTPUTS
            None Show-Window does not return any data.
            .Example
            PS C:\Users\User\Documents> Show-Window -WindowState Minimize
            This will Minimize the Powershell Console Window.
            #>
}
# $id = (Get-Process -Name 'Foxit Reader').MainWindowHandle
Show-Window -WindowState Minimize
$PSCommandPath
Split-path -Parent $PSCommandPath