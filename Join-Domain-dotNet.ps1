$h = @"
[DllImport("netapi32.dll", CharSet=CharSet.Unicode)]
public static extern int NetJoinDomain(
          string lpServer,
          string lpDomain,
          string lpAccountOU,
          string lpAccount,
          string lpPassword,
          int fJoinOptions );
"@
$J = Add-Type -MemberDefinition $h -Name "JoinDomain" -Namespace Win32 -PassThru
[Win32.JoinDomain]::NetJoinDomain



