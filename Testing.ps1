Get-Command *-job
Get-Command -ParameterName asjob

Get-WmiObject win32_process -AsJob
Start-Job {

"Hello"
}
Invoke-Command {"World"} -AsJob -computer .

Get-Job
Receive-Job


Workflow Test-workflow
{
    Get-Process -Name *ss
}

Test-workflow -

#Workflow engine

function test {
[CmdletBinding()]
param()
dir
}
test -