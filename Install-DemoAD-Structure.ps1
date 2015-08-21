# http://blogs.technet.com/b/heyscriptingguy/archive/2013/11/01/building-a-demo-active-directory-part-5.aspx

Import-module ActiveDirectory

# Crude Random Password Generator 

Function GeneratePassword

{

# How many Characters Minimum?

$Length=15

# Create a password choosing everying from Character 34 to 127

1..$Length | foreach{ $Password+=([char]((Get-Random 93)+34))}

# Convert to a Secure String

$Password=Convertto-SecureString $Password -asplaintext -force

Return $Password

}

Function GET-GroupInfo()

{

Param(

$City,

$Division

)

$GroupName=$City.replace(" ","")+"-"+$Division.replace(" ","")

$GroupDescription="$Division in $City Access Group"

# Return the Results (This is a feature new to version 3)

[pscustomobject]@{Name=$Groupname;Description=$GroupDescription}

}

# Define OU at Base of AD for Offices

$BaseOU="Offices"

# Provide List of Office Names

$CityOU=“Tokyo”,”Redmond”,”Ottawa”,”Madrid”,”New Orleans”,”Queensland”

# Provide List of Divisions Per Office

$DivisionOU="Sales","Marketing","HR","Finance"

# DistinguishedName of Domain Root

$Domain="DC=Contoso,DC=Local"

# Whatever the name of the $BaseOU Combined with Domain

$CompanyPath="OU=$BaseOU,"+$Domain

# UPN Extension to the Domain

$UPN="@contoso.local"

# Create BaseOU for Offices

NEW-ADOrganizationalUnit -name $BaseOU -path $Domain

# Gather through list of Cities

Foreach ($City in $CityOU) 

   {

    # Create OU for City

    NEW-ADOrganizationalUnit -path $CompanyPath -name $City

    # Gather through list of Divisions

    Foreach($Division in $DivisionOU)

    {

 # Create Division within City

 NEW-ADOrganizationalUnit -path "OU=$City,$CompanyPath" -name $Division

 # Create Group within Division and Description

$Groupdata=GET-Groupinfo –City $City –Division $Division

$GroupName=$Groupdate.Name

$GroupDescription=$Groupdata.Description

NEW-ADGroup -name $GroupName -GroupScope Global -Description $GroupDescription -Path "OU=$Division,OU=$City,$CompanyPath"

    }

}

# Pull together list of CSV raw data supplied from Generator

# 

$Names=IMPORT-CSV C:\Script\samplenames.csv

# Generate 150 Random Users from pulled Raw data

For ($x=0;$x -lt 150;$x++)

 {

 # Pick a Random First and Last Name

 $Firstname=GET-Random $Names.Firstname

 $Lastname=GET-Random $Names.Lastname

 $Displayname=$Lastname+”, “+$Firstname

 {

 # Pick a Random City

 $City=GET-RANDOM $Cityou

 # Pick a Random Division

 $Division=GET-RANDOM $DivisionOU

 $LoginID=$Firstname.substring(0,1)+$Lastname

 $UserPN=$LoginID+$UPN

 $Sam=$LoginID.padright(20).substring(0,20).trim()

 # Define their path in Active Directory

 $ADPath="OU=$Division,OU=$City,$CompanyPath"

 # Create the user in Active Directory

 New-ADUser -GivenName $Givenname -Surname $Surname -DisplayName $Displayname -UserPrincipalName $UserPN -Division $Division -City $City -Path $ADPath -name $Displayname -SamAccountName $Sam –userpassword (GENERATEPASSWORD)

 # Add User to appropriate Security Group

 $Groupname=(GET-GroupInfo –city $City –division $Division).Name

 ADD-ADGroupmember $Groupname –members $Sam

 # Enable the account for access

 ENABLE-ADAccount $Sam

 }

} 