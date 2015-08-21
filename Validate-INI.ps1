#http://jeffwouters.nl/index.php/2014/05/validate-an-ini-file/
function Validate-INI {
    [cmdletbinding()]
    param (
        [parameter(mandatory=$true,position=0)][String]$Path
    )
    $Check = @()
    $File = try {
        Get-Content -Path $Path -ErrorAction 'SilentlyContinue'
    } catch {
    }
    if ($File -ne $null) {
        foreach ($Line in $File) {
            switch -regex ($Line) {
                
# Section
                "^\[(.+)\]$" {
                    $Check = $Check + $true
                    break
                }
                
# Integer
                "^\s*([^#].+?)\s*=\s*(\d+)\s*$" {
                    $Check = $Check + $true
                    break
                }
                
# Decimal
                "^\s*([^#].+?)\s*=\s*(\d+\.\d+)\s*$" {
                    $Check = $Check + $true
                    break
                }
                
# Comment
                "^[;]" {
                    $Check = $Check + $true
                    break
                }
                
# Empty line
                "^\s*$" {
                    $Check = $Check + $true
                    break
                }
                
# Everything else that is allowed
                "^\s*([^#].+?)\s*=\s*(.*)" {
                    $Check = $Check + $true
                    break
                }
                default {
                    $Check = $Check + $false
                    $LineNumber = $Check.count
                    write-verbose "A problem was found on line $LineNumber"
                    break
                }
            }
        }
        if ($Check -contains $false) {
            $false
        } else {
            $true
        }
    } else {
         Write-Warning "Unable to open and/or validate $Path"
        $false
    }
}