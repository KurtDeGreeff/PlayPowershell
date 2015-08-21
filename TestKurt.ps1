configuration NameKurt
{
    # One can evaluate expressions to get the node list
    # E.g: $AllNodes.Where("Role -eq Web").NodeName
    node ("localhost")
    {
        # Call Resource Provider
        # E.g: WindowsFeature, File
        WindowsFeature FriendlyName
        {
           Ensure = "Present"
           Name = "TelnetClient"
        }      
    }
}
NameKurt

