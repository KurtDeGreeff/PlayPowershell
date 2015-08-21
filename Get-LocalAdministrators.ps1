function get-localadministrators {
    param ([string]$computername=$env:computername)

    $computername = $computername.toupper()
    $ADMINS = get-wmiobject -computername $computername -query "select * from win32_groupuser where GroupComponent=""Win32_Group.Domain='$computername',Name='administrators'""" | % {$_.partcomponent}

    foreach ($ADMIN in $ADMINS) {
                $admin = $admin.replace("\\$computername\root\cimv2:Win32_UserAccount.Domain=","") # trims the results for a user
                $admin = $admin.replace("\\$computername\root\cimv2:Win32_Group.Domain=","") # trims the results for a group
                $admin = $admin.replace('",Name="',"\")
                $admin = $admin.REPLACE("""","")#strips the last "

                $objOutput = New-Object PSObject -Property @{
                    Machinename = $computername
                    Fullname = ($admin)
                    DomainName  =$admin.split("\")[0]
                    UserName = $admin.split("\")[1]
                }#end object

    $objreport+=@($objoutput)
    }#end for

    return $objreport
}#end function

get-localadministrators