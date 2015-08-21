# Set the initial value to control the do loop
$seed = 0
# How many files should be generated
$random = 10
# File size in bytes
$ranSize = 4096
# Path where the file will be created
$ranPath = "$env:TEMP"
do {
    $netFn = [System.IO.Path]::GetRandomFileName()
    $netfn = [System.IO.Path]::ChangeExtension($netFn, 'txt')
    fsutil file createnew $ranPath$netFn $ranSize
    $seed++
}
#Generate the defined number of files
until ($seed -eq $random)
