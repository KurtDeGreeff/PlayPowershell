$Gpo = Add-Type -Path "X:\Users\Kurt\Downloads\LocalPolicy.1.0.0.1\LocalPolicy.dll" -PassThru

New-Object LocalPolicy.GroupPolicyObject #.ComputerGroupPolicyObject   Cannot find constructor??



var gpo = new ComputerGroupPolicyObject();
const string keyPath = @"SOFTWAREPoliciesMicrosoftWindows NTTerminal Services";
using (var machine = gpo.GetRootRegistryKey(GroupPolicySection.Machine))
{
    using (var terminalServicesKey = machine.CreateSubKey(keyPath))
    {
        terminalServicesKey.SetValue("SecurityLayer", 00000000, RegistryValueKind.DWord);
    }
}
gpo.Save();