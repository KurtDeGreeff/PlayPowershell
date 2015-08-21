########################################################################################
#  Script: DumpUsersAndCertCount.ps1
#    Date: 10.Sep.2008
# Version: 1.0
# Purpose: Script outputs the paths to user accounts in Active Directory which have more
#          than one certificate, plus the count of total certificates in AD for each user.
#          This is useful when cleaning up a PKI deployment where duplicate certificates 
#          were not suppressed properly through template options and credentials roaming.
# Params:  Leave $SearchRoot empty to search entire domain, or enter the
#          DN path to an OU, e.g., "LDAP://OU=There,DC=Company,DC=Net".
#Caveats:  Does not return users with zero certificates because of SizeLimit
#          issues which limit the results returned to 1000 by default:
#          http://msdn.microsoft.com/en-us/library/system.directoryservices.directorysearcher.sizelimit.aspx
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
########################################################################################


param ($SearchRoot = "")


function DumpUsersAndCertCount ( $SearchRoot = "" )
{
    $DirectoryEntry = new-object System.DirectoryServices.DirectoryEntry -arg $SearchRoot
	$DirectorySearcher = new-object System.DirectoryServices.DirectorySearcher -arg $DirectoryEntry
    $DirectorySearcher.PropertiesToLoad.Add("userCertificate") | out-null
    $DirectorySearcher.Filter = "(&(objectClass=user)(objectCategory=person)(userCertificate=*))"
    $SearchResultCollection = $DirectorySearcher.FindAll()

    $SearchResultCollection | ForEach{$_.Properties} | ForEach {
        $obj = new-Object system.Management.Automation.PSObject
        $path = $_.adspath[0]
        $certs = $_.usercertificate
        $certcount = $certs.count
        add-member -inputobject $obj -membertype NoteProperty -name NumberOfCertificates -value $certcount
        add-member -inputobject $obj -membertype NoteProperty -name UserPath -value $path
        $obj
    } 
    $SearchResultCollection.Dispose()
}


DumpUsersAndCertCount -SearchRoot $SearchRoot 

