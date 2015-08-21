$HKLMAddODBC="HKLM:\SOFTWARE\ODBC\ODBC.INI\SoftDisDSN"
cd HKLM:\SOFTWARE\ODBC\ODBC.INI
md "SoftDisDSN"
Set-ItemProperty -Path $HKLMAddODBC -Name "Authentication Method" -Value "0"
Set-ItemProperty -Path $HKLMAddODBC -Name "Description" -Value "SoftDisDSN"
Set-ItemProperty -Path $HKLMAddODBC -Name "Driver" -Value "C:\SWL\Bin\CacheODBC_v2010.dll"
Set-ItemProperty -Path $HKLMAddODBC -Name "Host" -Value "S-GSXSRV"
Set-ItemProperty -Path $HKLMAddODBC -Name "Namespace" -Value "PIP"
Set-ItemProperty -Path $HKLMAddODBC -Name "Password" -Value ""
Set-ItemProperty -Path $HKLMAddODBC -Name "Port" -Value "1972"
Set-ItemProperty -Path $HKLMAddODBC -Name "Query Timeout" -Value "0"
Set-ItemProperty -Path $HKLMAddODBC -Name "Security Level" -Value "2"
# Set-ItemProperty -Path $HKLMAddODBC -Name "Server Type" -Value "0"
Set-ItemProperty -Path $HKLMAddODBC -Name "Service Principal Name" -Value ""
Set-ItemProperty -Path $HKLMAddODBC -Name "SSL Server Name" -Value ""
Set-ItemProperty -Path $HKLMAddODBC -Name "Static Cursors" -Value "0"
Set-ItemProperty -Path $HKLMAddODBC -Name "UID" -Value "_system"
Set-ItemProperty -Path $HKLMAddODBC -Name "UnicodeSQLTypes" -Value "0"

if (-not (Test-Path -Path "HKLM:\SOFTWARE\ODBC\ODBC.INI\'ODBC Data Sources'"))
{cd HKLM:\SOFTWARE\ODBC\ODBC.INI\
md 'ODBC Data Sources'
Test-Path -Path "HKLM:\SOFTWARE\ODBC\ODBC.INI\'ODBC Data Sources'"}

Set-ItemProperty -Path HKLM:\SOFTWARE\ODBC\ODBC.INI\'ODBC Data Sources' -Name "SoftDisDSN" -Value "InterSystems ODBC"