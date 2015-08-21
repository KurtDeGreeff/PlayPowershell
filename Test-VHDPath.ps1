#requires -version 3.0

Function Test-VHDPath {

[cmdletbinding()]
Param (
[ValidateNotNullorEmpty()]
[ValidateScript({Test-Path $_})]
#paths to my virtual hard disks for Hyper-V virtual machines
[string[]]$paths = @("G:\VHDs","F:\VHD","D:\VHD","C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks")
)

Write-Verbose "Starting $($MyInvocation.mycommand)"

foreach ($path in $paths) {
  Try {
    #grab the first VHD\VHDX file and test it. No guarantee other files are OK
    #but at least I know the path has been verified.
    Write-Verbose "Validating $path"
    dir $path\*.vhd,*.vhdx | Select -first 1 | Test-VHD -ErrorAction Stop | out-null
  }
  Catch {
    Write-Error "Failed to validate VHD\VHDX files in $Path. $_.Exception.Message"
    Return
  }
}

#if no errors were found then return a simple True
Write-Verbose "No problems found with VHD paths"
Write $True

} #end function