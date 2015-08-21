# find writable WMI properties. These properties are decorated with a WMI “qualifier,” which is simply a piece of metadata that indicates that the property can be written to.
$ClassList = Get-CimClass;
foreach ($CimClass in $ClassList) {

    foreach ($CimProperty in $CimClass.CimClassProperties) {

        if ($CimProperty.Qualifiers.Name -contains 'write') {

            [PSCustomObject]@{

                ClassName = $CimClass.CimClassName;

                PropertyName = $CimProperty.Name;

                Writable = $true;

                };

        };

    };

};

<#
After you’ve found a property that you want to change, the process of changing it looks like this:
Retrieve the CIM instance by using Get-CimInstance, and assign to a variable.
Change the desired property value.
Call Set-CimInstance, and pass it in the variable.
#>

#Alternative from Lee Holmes
Get-CimClass Win32_printer | Foreach-Object {
    $_.CimClassName; $_.CimClassProperties |
    Where-Object { $_.Qualifiers["Write"] } | Foreach-Object Name
}

##############################################################################
#Calling WMI Methods with CIM Cmdlets
$class = Get-CimClass -ClassName Win32_Share
$class.CimClassMethods
$class.CimClassMethods[‘Create’]
$class.CimClassMethods[‘Create’].Parameters

#Example of creating test share
$args = @{
Name=’myTestshare’
Path=’c:\’
MaximumAllowed=[UInt32]4
Type=[UInt32]0
}
Invoke-CimMethod -ClassName Win32_Share -MethodName Create -Arguments $args