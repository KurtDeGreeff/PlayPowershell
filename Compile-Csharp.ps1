##################################################################
# Compiler
##################################################################
function Compile-Csharp ([string] $code, $FrameworkVersion="v4.0.30319")
{
 $provider = New-Object Microsoft.CSharp.CSharpCodeProvider
 $framework = [System.IO.Path]::Combine($env:windir, "Microsoft.NET\Framework\$FrameWorkVersion")
 $references = New-Object System.Collections.ArrayList
 $references.AddRange( @("${framework}\System.dll","${framework}\System.Core.dll"))
 $parameters = New-Object System.CodeDom.Compiler.CompilerParameters
 $parameters.GenerateInMemory = $true
 $parameters.GenerateExecutable = $false
 $parameters.ReferencedAssemblies.AddRange($references)
 $result = $provider.CompileAssemblyFromSource($parameters, $code)
 if ($result.Errors.Count)
 {
 $codeLines = $code.Split("`n");
 foreach ($ce in $result.Errors)
 {
 write-host "Error: $($codeLines[$($ce.Line - 1)])"
 $ce | out-default
 }
 Throw "Compilation of C# code failed"
 }
}
 
##################################################################
# C# Code
##################################################################
$code = @'
using System;
using System.Runtime.InteropServices;
using System.ComponentModel;
 
namespace CompileTest
{
 public class Sound
 {
 [DllImport("User32.dll", SetLastError = true)]
 static extern Boolean MessageBeep(UInt32 beepType);
 
 public static void Beep(BeepTypes type)
 {
 if (!MessageBeep((UInt32)type))
 {
 Int32 err = Marshal.GetLastWin32Error();
 throw new Win32Exception(err);
 }
 }
 }
 
public enum BeepTypes
 {
 Simple = -1,
 Ok = 0x00000000,
 IconHand = 0x00000010,
 IconQuestion = 0x00000020,
 IconExclamation = 0x00000030,
 IconAsterisk = 0x00000040
 }
}
'@
 
##################################################################
# Compile the code and access the .NET object within PowerShell
##################################################################
Compile-Csharp $code
[CompileTest.Sound]::Beep([CompileTest.BeepTypes]::IconAsterisk)