#Names file to import: Firstname,Lastname
$Names=IMPORT-CSV C:\Script\samplenames.csv

$UPN="@contoso.local"

# Generate 150 Random Users from pulled Raw data

For ($x=0;$x -lt 150;$x++)

            {

 

            # Pick a Random First and Last Name

            $Firstname=GET-Random $Names.Firstname

            $Lastname=GET-Random $Names.Lastname

 

            $Displayname=$Lastname+", "+$Firstname

 

            # Make sure this user DOES NOT already exist

            {

 

            # Pick a Random City

            $City=GET-RANDOM $Cityou

 

            # Pick a Random Division

            $Division=GET-RANDOM $DivisionOU

 

            $LoginID=$Firstname.substring(0,1)+$Lastname

            $UserPN=$LoginID+$UPN

            $Sam=$LoginID.padright(20).substring(0,20).trim()

                       

            # Create the user in Active Directory

                       

            New-ADUser -GivenName $Givenname -Surname $Surname -DisplayName $Displayname -UserPrincipalName $UserPN -Division $Division -City $City -Path $ADPath-name $Displayname -SamAccountName $Sam

            }

}