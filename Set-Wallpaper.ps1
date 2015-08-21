#requires -version 2.0
## Set-Wallpaper - set your windows desktop wallpaper
###################################################################################################
## Usage:
##    Set-Wallpaper "C:\Users\Joel\Pictures\Wallpaper\Dual Monitor\mandolux-tiger.jpg" "Tile"
##    ls *.jpg | get-random | Set-Wallpaper
##    ls *.jpg | get-random | Set-Wallpaper -Style "Stretch"
###################################################################################################
## History:
##    v0.5  First release (on #PowerShell@irc.freenode.net)
##    v1.0  Public release (http://www.poshcode.org/488)
##          - Added Style: Tile|Center|Stretch
##    v1.1  (http://poshcode.org/491)
##          - Added "NoChange" style to just use the style setting already set
##          - Made the Style parameter to the cmdlet optional
##    v2.0  This Release
##          - Updated for CTP3, and made it run as a script instead of a function.
###################################################################################################
[CmdletBinding()]
Param(
   [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName")]
   [string]
   $Path
,
   [Parameter(Position=1, Mandatory=$false)]
   [Wallpaper.Style]
   $Style = "NoChange"
)

BEGIN {
try {
   $WP = [Wallpaper.Setter]
} catch {
   $WP = add-type @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32;
namespace Wallpaper
{
   public enum Style : int
   {
       Tile, Center, Stretch, NoChange
   }

   public class Setter {
      public const int SetDesktopWallpaper = 20;
      public const int UpdateIniFile = 0x01;
      public const int SendWinIniChange = 0x02;

      [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
      private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
      
      public static void SetWallpaper ( string path, Wallpaper.Style style ) {
         SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
         
         RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
         switch( style )
         {
            case Style.Stretch :
               key.SetValue(@"WallpaperStyle", "2") ; 
               key.SetValue(@"TileWallpaper", "0") ;
               break;
            case Style.Center :
               key.SetValue(@"WallpaperStyle", "1") ; 
               key.SetValue(@"TileWallpaper", "0") ; 
               break;
            case Style.Tile :
               key.SetValue(@"WallpaperStyle", "1") ; 
               key.SetValue(@"TileWallpaper", "1") ;
               break;
            case Style.NoChange :
               break;
         }
         key.Close();
      }
   }
}
"@ -Passthru
}
}
PROCESS {
   Write-Verbose "Setting Wallpaper ($Style) to $(Convert-Path $Path)"
   $WP::SetWallpaper( (Convert-Path $Path), $Style )
}