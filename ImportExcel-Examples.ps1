gsv | Export-Excel .\test.xlsx -WorkSheetname Services
dir -file | Export-Excel .\test1.xlsx -WorkSheetname Files 
######################################################
$p=@{       
    Title = "Process Report as of $(Get-Date)" 
    TitleFillPattern = "LightTrellis"
    TitleSize = 18
    TitleBold = $true

    Path  = "$pwd\testExport.xlsx"
    Show = $true
    AutoSize = $true
}

Get-Process |
    Where Company | Select Company, PM |
    Export-Excel @p
####################################################

$p = Get-Process
$DataToGather = @{
    PM        = {$p|select company, pm}
    Handles   = {$p|select company, handles}
    Services  = {gsv}
    Files     = {dir -File}
    Albums    = {(Invoke-RestMethod http://www.dougfinke.com/powershellfordevelopers/albums.js)}
}
Export-MultipleExcelSheets -Show -AutoSize .\testExport.xlsx $DataToGather

#######################################################
