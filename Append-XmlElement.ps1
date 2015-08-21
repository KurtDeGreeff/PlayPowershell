##############################################################################
#  Script: Append-XmlElement.ps1
#    Date: 4.Jun.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Demo some XML manipulation.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


function Append-XmlElement ($XmlDoc, $AppendToElement, $NewElementName, $Text = $null)
{
    $element = $xmldoc.CreateElement($NewElementName)
    if ($Text -ne $null) { $element.Set_InnerText($Text) }
    $AppendToElement.AppendChild($element)
}

function Get-RawXML ($xmldoc) 
{
    $xmldoc.Save("$env:temp\tempxmlfile.xml")
    get-content $env:temp\tempxmlfile.xml
    remove-item $env:temp\tempxmlfile.xml -force
}



# Create a new blank XML document.

$xmldoc = new-object System.Xml.XmlDocument


# Create a top-level element and append to doc.

$Users = $xmldoc.CreateElement("Users")
$xmldoc.AppendChild($Users)


# Manually create and append a Person element.

$Person = $xmldoc.CreateElement("Person")

$fn = $xmldoc.CreateElement("FirstName")
$fn.Set_InnerText("Leslie")
$Person.AppendChild($fn)

$ln = $xmldoc.CreateElement("LastName")
$ln.Set_InnerText("Cummings")
$Person.AppendChild($ln)

$bd = $xmldoc.CreateElement("BirthDate")
$bd.Set_InnerText('18-May-1978')
$Person.AppendChild($bd)

$Users.AppendChild($Person)


# Now do the same, but use the function instead.

$newelement = append-xmlelement $xmldoc $xmldoc.Users "Person"
append-xmlelement $xmldoc $newelement "FirstName" "Matt"
append-xmlelement $xmldoc $newelement "LastName" "Shepard"
append-xmlelement $xmldoc $newelement "BirthDate" '22-Apr-1962'


# Show the XML text.

get-rawxml $xmldoc


# Remove just one element.

$element = $xmldoc.Users.Person[0]
$xmldoc.Users.RemoveChild($element)


# Remove all contents from the XML document.

# $xmldoc.RemoveAll()



