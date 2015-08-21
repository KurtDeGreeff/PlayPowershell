function Resize-Image
{
   <#
    .SYNOPSIS
        Resize-Image resizes an image file

    .DESCRIPTION
        This function uses the native .NET API to resize an image file, and optionally save it to a file or display it on the screen. You can specify a scale or a new resolution for the new image.
        
        It supports the following image formats: BMP, GIF, JPEG, PNG, TIFF 
 
    .EXAMPLE
        Resize-Image -InputFile "C:\kitten.jpg" -Display

        Resize the image by 50% and display it on the screen.

    .EXAMPLE
        Resize-Image -InputFile "C:\kitten.jpg" -Width 200 -Height 400 -Display

        Resize the image to a specific size and display it on the screen.

    .EXAMPLE
        Resize-Image -InputFile "C:\kitten.jpg" -Scale 30 -OutputFile "C:\kitten2.jpg"

        Resize the image to 30% of its original size and save it to a new file.

    .LINK
        Author: Patrick Lambert - http://dendory.net
    #>
    Param([Parameter(Mandatory=$true)][string]$InputFile, [string]$OutputFile, [int32]$Width, [int32]$Height, [int32]$Scale, [Switch]$Display)

    # Add System.Drawing assembly
    Add-Type -AssemblyName System.Drawing

    # Open image file
    $img = [System.Drawing.Image]::FromFile((Get-Item $InputFile))

    # Define new resolution
    if($Width -gt 0) { [int32]$new_width = $Width }
    elseif($Scale -gt 0) { [int32]$new_width = $img.Width * ($Scale / 100) }
    else { [int32]$new_width = $img.Width / 2 }
    if($Height -gt 0) { [int32]$new_height = $Height }
    elseif($Scale -gt 0) { [int32]$new_height = $img.Height * ($Scale / 100) }
    else { [int32]$new_height = $img.Height / 2 }

    # Create empty canvas for the new image
    $img2 = New-Object System.Drawing.Bitmap($new_width, $new_height)

    # Draw new image on the empty canvas
    $graph = [System.Drawing.Graphics]::FromImage($img2)
    $graph.DrawImage($img, 0, 0, $new_width, $new_height)

    # Create window to display the new image
    if($Display)
    {
        Add-Type -AssemblyName System.Windows.Forms
        $win = New-Object Windows.Forms.Form
        $box = New-Object Windows.Forms.PictureBox
        $box.Width = $new_width
        $box.Height = $new_height
        $box.Image = $img2
        $win.Controls.Add($box)
        $win.AutoSize = $true
        $win.ShowDialog()
    }

    # Save the image
    if($OutputFile -ne "")
    {
        $img2.Save($OutputFile);
    }
}

Export-ModuleMember Resize-Image