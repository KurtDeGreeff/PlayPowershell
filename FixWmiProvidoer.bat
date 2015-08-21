@ECHO OFF
NET STOP SharedAccess

NET STOP winmgmt

CD %WINDIR%\System32\Wbem\Repository
DEL /F /Q /S %WINDIR%\System32\Wbem\Repository\*.*
CD %WINDIR%\system32\wbem

REGSVR32 /s %WINDIR%\system32\scecli.dll
REGSVR32 /s %WINDIR%\system32\userenv.dll

MOFCOMP cimwin32.mof
MOFCOMP cimwin32.mfl
MOFCOMP rsop.mof
MOFCOMP rsop.mfl
FOR /f %%s IN ('DIR /b /s *.dll') DO REGSVR32 /s %%s
FOR /f %%s IN ('DIR /b *.mof') DO MOFCOMP %%s
FOR /f %%s IN ('DIR /b *.mfl') DO MOFCOMP %%s
MOFCOMP exwmi.mof
MOFCOMP -n:root\cimv2\applications\exchange wbemcons.mof
MOFCOMP -n:root\cimv2\applications\exchange smtpcons.mof
MOFCOMP exmgmt.mof

rundll32 wbemupgd, UpgradeRepository

NET STOP Cryptsvc
DEL /F /Q /S %WINDIR%\System32\catroot2\*.*
DEL /F /Q C:\WINDOWS\security\logs\*.log
NET START Cryptsvc

msiexec /unregister
msiexec /regserver
REGSVR32 /s msi.dll

NET START winmgmt
NET START SharedAccess