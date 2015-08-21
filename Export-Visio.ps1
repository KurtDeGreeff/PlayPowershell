function Export-Visio
{
    [CmdletBinding()]
    [OutputType([String])]
    Param
    (
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        Position=0
        )]
        [ValidateScript({[System.IO.Path]::IsPathRooted($_)})]
        [string]$fileName,

        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        Position=1
        )]
        [ValidateScript({[System.IO.Path]::IsPathRooted($_)})]
        [string]$destinationFolder,

        [Parameter(Mandatory=$false,
        ValueFromPipeline=$true,
        Position=2
        )]
        [ValidateSet("png", "svg", "svgz", "vdw", "vss", "vst", "vdx", "vsx", "vtx", "gif", "jpeg")]
        [string]$To="png"
    )

    Begin
    {
        try {
            $visio = New-Object -ComObject Visio.Application
        }
        catch {
            Write-Error $_
        }
    }
    Process
    {
        $document = $visio.Documents.Open($fileName)
        $pages = $visio.ActiveDocument.Pages
        $pages | ForEach-Object {
            try {
                Write-Verbose "Exporting page $($_.Name) to ${To} format"
$_.Export("${destinationFolder}\$($_.Name).${To}")
            }
            catch {
                Write-Error $_
            }
        }
    }
    End {
        $document.Close()
        $visio.Quit()
    }
}
