#requires -version 4.0
 
Function Get-DSCResourceCommands {
[cmdletbinding()]
Param([string]$Name)
 
Begin {
    Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"  
    #define a regular expression to pull out cmdlet names using some common verbs
    [regex]$rx="\b(Get|New|Set|Add|Remove|Test)-\w+\b"
} #begin
 
Process {
    Write-Verbose "Getting DSC Resource $Name"
        Try {
            $resource = Get-DscResource -Name $name -ErrorAction Stop
            Write-Verbose ($resource | out-string)
        }
 
        Catch {
            Throw
        }
        if ($resource) {
 
        #get the code from the module path which will be something like this:
        #'C:\Program Files\WindowsPowerShell\Modules\xSmbShare\DSCResources\MSFT_xSmbShare\MSFT_xSmbShare.psm1'
        Write-Verbose "Processing content from $($resource.path)"
        $code = Get-Content -path $resource.path
 
        #find matching names
        $rx.matches($code).Value | sort | Get-Unique | Where {$_ -notmatch "-TargetResource$"}
        } #if $resource
 
} #process
 
End {
    Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
} #end
 
}
