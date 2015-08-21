<#
.SYNOPSIS
Script module with 2 functions that get data from a database or execute SQL Queries on it.

.DESCRIPTION
Run Import-Module DataAccess to load the functions Get-DatabaseData and Invoke-DatabaseQuery into the shell. 
They’re designed to work with either SQLServer or OLEDB connection strings; 
you’ll pass in the connection string that you want to use.

.PARAMETER 
-ConnectionString Connects to DB server and database on that server with Windows
integrated credentials or with standard username and password. See http://ConnectionStrings.com  for .NET connection strings

.PARAMETER 
-Query Query to Execute. See http://www.w3schools.com/SQl/default.asp for more info on the syntax.

.PARAMETER 
isSQLServer <SwitchParameter>
Omit –isSQLServer if you’re providing an OLEDBconnection string. Only use if connecting to a MS SQLserver.

.EXAMPLE
Import-Module DataAccess 
Get-DatabaseData -verbose –connectionString 'Server=localhost\SQLEXPRESS;Database=Inventory;Trusted_Connection=True;'
-isSQLServer -query "SELECT * FROM Computers"

.EXAMPLE
Invoke-DatabaseQuery -verbose –connectionString 'Server=localhost\SQLEXPRESS;Database=Inventory;Trusted_Connection=True;'
-isSQLServer -query "INSERT INTO Computers (computer) VALUES('win7')"

.NOTES
See book 'PowerShell in Depth' from page 527 for more info

.LINK
http://ConnectionStrings.com 

#>

function Get-DatabaseData {
# Reading data with a SELECT query (or to execute a stored procedure that returns data)

[CmdletBinding()]
param (
[string]$connectionString,
[string]$query,
[switch]$isSQLServer
)
if ($isSQLServer) {
Write-Verbose 'in SQL Server mode'
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
} else {
Write-Verbose 'in OleDB mode'
$connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
}
$connection.ConnectionString = $connectionString
$command = $connection.CreateCommand()
$command.CommandText = $query
if ($isSQLServer) {
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command
} else {
$adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
}
$dataset = New-Object -TypeName System.Data.DataSet
$adapter.Fill($dataset)
$dataset.Tables[0]
}

function Invoke-DatabaseQuery {
# INSERT, UPDATE, and DELETE queries (or a stored procedure that doesn’t return data)

[CmdletBinding()]
param (
[string]$connectionString,
[string]$query,
[switch]$isSQLServer
)
if ($isSQLServer) {
Write-Verbose 'in SQL Server mode'
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
} else {
Write-Verbose 'in OleDB mode'
$connection = New-Object System.Data.OleDb.OleDbConnection
}
$connection.ConnectionString = $connectionString
$command = $connection.CreateCommand()
$command.CommandText = $query
$connection.Open()
$command.ExecuteNonQuery()
$connection.close()
}