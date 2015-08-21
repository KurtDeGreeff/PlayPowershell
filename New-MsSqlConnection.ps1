function New-MsSqlConnection {
    <#
        .SYNOPSIS
            Create a new MSSQL database connection.
        .DESCRIPTION
            This function will create a new Microsoft SQL Server database connection and return a database connection object.
        .EXAMPLE
            New-MsSqlConnection -DatabaseServer dbServer01 -DatabaseName 'myDB'
        .NOTES
            Author: Øyvind Kallstad
            Date: 22.01.2015
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        # Name of server or instance.
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias('Server','ComputerName','dbServer')]
        [string] $DatabaseServer,

        # Name of database.
        [Parameter(Mandatory = $true, Position = 1)]
	[string] $DatabaseName,

        # Port to connect to. Default is 1433.
        [Parameter()]
        [int] $Port,

        # Credential, if not using trusted connection.
        [Parameter(Mandatory = $false)]
	[System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )
    try {
        
        # start building the connection string
        $connectionStringBuilder = New-Object 'System.Data.SqlClient.SqlConnectionStringBuilder'
        if($Port) {$DatabaseServer = "$($DatabaseServer),$($Port);"}
        $connectionStringBuilder.Server = $DatabaseServer
        $connectionStringBuilder.Database = $DatabaseName

        # if credential parameter is not used, trusted connection will be used
        if (-not($PSBoundParameters['Credential'])) {
            $connectionStringBuilder.Trusted_Connection = $true
        }

        # otherwise create a sqlcredential object
        else {
            $Credential.Password.MakeReadOnly()
            $sqlCred = New-Object 'System.Data.SqlClient.SqlCredential' -ArgumentList ($Credential.UserName,$Credential.Password)
        }

        # create database connection
        $dbConnection = New-Object -TypeName 'System.Data.SqlClient.SqlConnection' -ArgumentList $connectionStringBuilder.ConnectionString

        # if needed, add the sqlcredential object
        if($PSBoundParameters['Credential']) {
            $dbConnection.Credential = $sqlCred
        }

        # open the connection
        [void]$dbConnection.Open()

        # return the connection object
        Write-Output $dbConnection
    }

    catch {
        Write-Warning "At line:$($_.InvocationInfo.ScriptLineNumber) char:$($_.InvocationInfo.OffsetInLine) Command:$($_.InvocationInfo.InvocationName), Exception: '$($_.Exception.Message.Trim())'"
    }
}