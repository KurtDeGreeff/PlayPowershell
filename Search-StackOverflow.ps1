##############################################################################
##
## Search-StackOverflow
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##############################################################################

<#

.SYNOPSIS

Searches Stack Overflow for PowerShell questions that relate to your
search term, and provides the link to the accepted answer.


.EXAMPLE

PS > Search-StackOverflow upload ftp
Searches StackOverflow for questions about how to upload FTP files

.EXAMPLE

PS > $answers = Search-StackOverflow.ps1 upload ftp
PS > $answers | Out-GridView -PassThru | Foreach-Object { start $_ }

Launches Out-GridView with the answers from a search. Select the URLs
that you want to launch, and then press OK. PowerShell then launches
your default web brower for those URLs.

#>

Set-StrictMode -Off
Add-Type -Assembly System.Web

$query = ($args | Foreach-Object { '"' + $_ + '"' }) -join " "
$query = [System.Web.HttpUtility]::UrlEncode($query)

## Use the StackOverflow API to retrieve the answer for a question
$url = "https://api.stackexchange.com/2.0/search?order=desc&sort=relevance" +
    "&pagesize=5&tagged=powershell&intitle=$query&site=stackoverflow"
$question = Invoke-RestMethod $url

## Now go through and show the questions and answers
$question.Items | Where accepted_answer_id | Foreach-Object {
        "Question: " + $_.Title
        "URL: http://www.stackoverflow.com/questions/$($_.accepted_answer_id)"
        ""
}