#requires -version 2
param([switch]$Disable)

add-type -namespace Hacks -name Aero -memberdefinition @"

    [StructLayout(LayoutKind.Sequential)]
    public struct MARGINS
    {
       public int left; 
       public int right; 
       public int top; 
       public int bottom; 
    } 

    [DllImport("dwmapi.dll", PreserveSig = false)]
    public static extern void DwmExtendFrameIntoClientArea(IntPtr hwnd, ref MARGINS margins);

    [DllImport("dwmapi.dll", PreserveSig = false)]
    public static extern bool DwmIsCompositionEnabled();
"@


if (([Environment]::OSVersion.Version.Major -gt 5) -and
     [hacks.aero]::DwmIsCompositionEnabled()) {

   $hwnd = (get-process -id $pid).mainwindowhandle

   $margin = new-object 'hacks.aero+margins'

   $host.ui.RawUI.BackgroundColor = "black"
   $host.ui.rawui.foregroundcolor = "white"

   if ($Disable) {

       $margin.top = 0
       $margin.left = 0


   } else {

       $margin.top = -1
       $margin.left = -1

   }

   [hacks.aero]::DwmExtendFrameIntoClientArea($hwnd, [ref]$margin)

} else {

   write-warning "Aero is either not available or not enabled on this workstation."

}