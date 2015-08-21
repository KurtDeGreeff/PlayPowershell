'*************************************************************************************
' Script Name: Run_PowerShell_Script.vbs
'     Version: 1.0
'      Author: Jason Fossen (www.WindowsPowerShellTraining.com)
'Last Updated: 17.May.2007
'     Purpose: Use the script or just the function to run PowerShell scripts, 
'              such as with scheduled jobs or logon scripts.  
'        Note: Set bHidden = True when you want to run the PowerShell script with
'              wscript.exe in a hidden window using PowerShell's -noninteractive
'              command-line switch.  If bHidden is True and the script is launched
'              with cscript.exe, the VBS script will automatically relaunch itself
'              with wscript.exe instead.
'        Note: If you pass in any parameters or arguments to the PowerShell script,
'              you must put all the parameters/arguments into a single double-quoted
'              string and pass that into the sParameters argument.  Don't pass in
'              any parameters/arguments in with the full path to the PS script.  If
'              there are no parameters/arguments, you must still pass in "".
'        Note: Paths with space characters are automatically mapped to their "short
'              name" equivalents, and the short names are used instead.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*************************************************************************************

' Don't forget that this script will try to relaunch itself if bHidden = True and
' cscript.exe was used instead of wscript.exe.  If wscript.exe is used, it doesn't relaunch.
' If no params are passed in and the script is relaunched with wscript.exe, the empty
' params argument is lost, hence, the relaunched script sees only two arguments, which
' causes an error unless it's handled like this:

If Wscript.Arguments.Count = 2 Then
    iResult = RunPowerShellScript(WScript.Arguments.Item(0), "", WScript.Arguments.Item(1))
Else
    iResult = RunPowerShellScript(WScript.Arguments.Item(0), WScript.Arguments.Item(1), WScript.Arguments.Item(2)) 
End If    





'-----------------------------------------------------------------------------------------
'FUNCTION: RunPowerShellScript(sPathToScript, sParameters, bHidden)
'sPathToScript = Full path to PowerShell script.
'  sParameters = Double-quoted string of all parameters/arguments to PowerShell script.
'                If there are none, pass in "".
'      bHidden = Boolean. If true, PowerShell script will run hidden with -noninteractive switch.
'                If false, PowerShell script runs unhidden without the -noninteractive switch.
'-----------------------------------------------------------------------------------------         
Function RunPowerShellScript(sPathToScript, sParameters, bHidden)
    On Error Resume Next

    Set oWshShell = CreateObject("WScript.Shell")
    Set oFileSystem = CreateObject("Scripting.FileSystemObject")

    If bHidden Then 
        iCode = 0   'Hidden Window.
        sCommand = "powershell.exe -nologo -noninteractive -command "
        'Check if wscript.exe is being used, if not, relaunch with wscript.exe.
        If InStr( LCase(WScript.FullName), "cscript" ) <> 0 Then
            Set oThisScript = oFileSystem.GetFile(WScript.ScriptFullName)
            sShortPathToThisScript = oThisScript.ShortPath
            Set oThisScript = Nothing
            oWshShell.Run "wscript.exe //nologo " & sShortPathToThisScript & " " & sPathToScript & " " & sParameters & " True", 0
            WScript.Quit(0)
        End If
    Else 
        iCode = 10  'Visible Window.
        sCommand = "powershell.exe -nologo -command "
    End If

    If oFileSystem.FileExists(sPathToScript) Then
        Set oFile = oFileSystem.GetFile(sPathToScript)
        sCommand = sCommand & Chr(34) & "&{" & oFile.ShortPath & " " & sParameters & "}" & Chr(34) 
        Set oFile = Nothing
        oWshShell.Run sCommand, iCode  
    End If

    If Err.Number = 0 Then 
        RunPowerShellScript = True
    Else
        RunPowerShellScript = False
    End If
End Function





'END OF SCRIPT ------------------------------------------------------------------------------
