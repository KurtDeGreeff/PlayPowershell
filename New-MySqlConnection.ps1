function New-MySqlConnection {
    <#
        .SYNOPSIS
            Create a new MySQL database connection.
        .DESCRIPTION
            This function will create a new MySQL database connection and return a database connection object.
        .EXAMPLE
            New-MySqlConnection -DatabaseServer 'dbserver01' -DatabaseName 'MyDatabase'
            Will create a new database connection object using integrated security.
        .EXAMPLE
            New-MySqlConnection -DatabaseServer 'dbserver01' -DatabaseName 'MyDatabase' -Credential 'dbuser'
            Will create a new database connection object after prompting for the password to the user 'dbuser'.
        .LINK
            http://dev.mysql.com/downloads/connector/net/
        .NOTES
            Author: Øyvind Kallstad
            Date: 21.01.2015
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

        # Port to connect to. Default is 3306.
        [Parameter()]
        [int] $Port = 3306,

        # Credential, if not using integrated security.
        [Parameter(Mandatory = $false)]
	[System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )
    try {
        # load MySQL .NET connector
        [void][System.Reflection.Assembly]::LoadWithPartialName('MySql.Data')

        # start building the connection string
        $connectionStringBuilder = New-Object 'MySql.Data.MySqlClient.MySqlConnectionStringBuilder'
        $connectionStringBuilder.Server = $DatabaseServer
        $connectionStringBuilder.Database = $DatabaseName
        $connectionStringBuilder.Port = $Port

        # if credential parameter is not used, integrated security will be used
        if (-not($PSBoundParameters['Credential'])) {
            $connectionStringBuilder.IntegratedSecurity = $true
        }

        # otherwise user user id and password
        else {
            $connectionStringBuilder.UserId = $Credential.UserName
            $connectionStringBuilder.Password = $Credential.GetNetworkCredential().Password
        }

        # create database connection
        $dbConnection = New-Object MySql.Data.MySqlClient.MySqlConnection
        $dbConnection.ConnectionString = $connectionStringBuilder.ToString()

        # open database connection
	[void]$dbConnection.Open()

        # return the connection object
        Write-Output $dbConnection
    }

    catch {
        Write-Warning "At line:$($_.InvocationInfo.ScriptLineNumber) char:$($_.InvocationInfo.OffsetInLine) Command:$($_.InvocationInfo.InvocationName), Exception: '$($_.Exception.Message.Trim())'"
    }
}