function Get-FolderSize{
    <#
        .SYNOPSIS
            Get the total size of a folder.
 
        .DESCRIPTION
            Get the total size of a folder.
 
        .PARAMETER Path
            Path to target folder.
 
        .EXAMPLE
            Get-FolderSize .\Folder01
            Will get the total size of the folder Folder01.
 
        .NOTES
            Name: Get-FolderSize
            Author: Øyvind Kallstad
            Date: 11.02.2014
            Version: 1.1
            UpdateNotes: 	13.02.2014
                Added SizeInBytes after input from Alan Seglen.
                This column is hidden by default and can be used for size calculations.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelinebyPropertyName = $true, Mandatory = $true, HelpMessage='Enter the path to the target folder')]
        [ValidateScript({Test-Path $_})]
        [string[]]$Path
    )
 
    PROCESS{
        foreach($filePath in $Path){
            try{
                # get the total size of the current path
                $size = Get-ChildItem $filePath -Force -Recurse -ErrorAction 'Stop' | Measure-Object -Property 'Length' -Sum
                
                # dynamically adjust the size format based on the size
                switch($size.Sum){
                    {$_ -gt 1KB}	{$formatedSize = '{0:n2} KB' -f ($_ / 1KB)}
                    {$_ -gt 1MB}	{$formatedSize = '{0:n2} MB' -f ($_ / 1MB)}
                    {$_ -gt 1GB}	{$formatedSize = '{0:n2} GB' -f ($_ / 1GB)}
                    {$_ -gt 1TB}	{$formatedSize = '{0:n2} TB' -f ($_ / 1TB)}
                    DEFAULT			{$formatedSize = '{0} B' -f $_}
                }

                # create output object
                $output = ([PSCustomObject] [Ordered] @{
                    Name        = $filePath
                    Count       = $size.Count
                    Size        = $formatedSize
                    SizeInBytes = $size.Sum
                })
 
                # customize default display properties of the object
                $defaultProperties = @('Name','Count','Size')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $output | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers
 
                # write output object to pipeline
                Write-Output $output
 
                # clean-up
                Remove-Variable formatedSize, Size -ErrorAction 'SilentlyContinue'
            }

            catch{
                # handling exceptions
                Write-Warning $_.Exception.Message
            }
        }
    }
}