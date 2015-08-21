[CmdletBinding()] 
param() 

$page = 1 
do 
{ 
    do 
    { 
        Start-Sleep -Seconds 1 
        $url = "http://www.amazon.com/s/ref=nb_sb_noss_1?url=search-alias%3Dstripbooks&field-keywords=powershell&page=$page" 
        try { $r = iwr $url } catch {} 
    } while(-not $r) 

    $results = $r.ParsedHtml.getElementsByTagName("H2") | 
        ? { ($_.classname -match "access-title") -and ($_.outertext -match "powershell") } | 
        % outertext 

    $results 
    $page++   
} while($results)

# .\Get-PowerShellBook.ps1 -OutVariable books; $books | sort | clip  