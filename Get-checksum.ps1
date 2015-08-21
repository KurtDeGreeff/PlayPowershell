Function Get-CheckSum            
{            
[CmdletBinding()]            
param(            
    [parameter(ValueFromPipeline=$true,Mandatory=$true,Position=0)]            
    [system.string[]]$FilePath = $null,            
            
    [parameter(ValueFromPipeline=$false, Mandatory=$false, Position=1)]            
    [ValidateSet("SHA1","MD5", "SHA256", "SHA384","SHA512")]            
    [system.string[]] ${Type} = "SHA1"            
            
)            
    Begin             
    {            
        Switch ($Type)            
        {            
            SHA1   { $cryptoServiceProvider = New-Object -TypeName System.Security.Cryptography.SHA1CryptoServiceProvider   }            
            MD5    { $cryptoServiceProvider = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider    }            
            SHA256 { $cryptoServiceProvider = New-Object -TypeName System.Security.Cryptography.SHA256CryptoServiceProvider }            
            SHA384 { $cryptoServiceProvider = New-Object -TypeName System.Security.Cryptography.SHA384CryptoServiceProvider }            
            SHA512 { $cryptoServiceProvider = New-Object -TypeName System.Security.Cryptography.SHA512CryptoServiceProvider }            
        } # end of switch            
    }            
    Process            
    {            
            
        $FilePath | ForEach-Object -Process {            
            $hash = $null            
            $File = $_            
            if (Test-Path $File)            
            {            
                if ((Get-Item -Path $File) -is [System.IO.FileInfo])            
                {            
                    try            
                    {            
                        $hash = $cryptoServiceProvider.ComputeHash(([System.IO.File]::ReadAllBytes($File)))            
                    } catch {            
                        Write-Warning -Message "Failed to read file $File"            
                    }            
                    if ($hash)            
                    {            
                        $result = New-Object System.Text.StringBuilder            
                        foreach ($byte in $hash)            
                        {            
                            [void]  $result.Append($byte.ToString("x2"))            
                        }            
                         ([system.string]$result)            
                    }            
            
                }            
            }            
        }            
    }            
    End             
    {            
        [gc]::collect()            
    }            
}

function get-sha256 { 
param($file )
[system.bitconverter ]::tostring([System.Security.Cryptography.sha256 ]::
create().computehash( [system.io.file]::
openread((resolve-path $file)))) -replace "-" ,""
}


function get-sha512 { 
param($file )
[system.bitconverter ]::tostring([System.Security.Cryptography.sha512 ]::
create().computehash( [system.io.file]::
openread((resolve-path $file)))) -replace "-" ,""
}

function get-sha1 { 
param($file )
[system.bitconverter ]::tostring([System.Security.Cryptography.sha1 ]::
create().computehash( [system.io.file]::
openread((resolve-path $file)))) -replace "-" ,""
}