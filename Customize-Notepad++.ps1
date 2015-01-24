####################################################################################
#  Script: customize-notepad++.ps1
# Purpose: Creates or modifies the userDefineLang.xml file used by Notepad++ to
#          include a language definition for PowerShell for syntax highlighting.
#          The language definition is reconstructed each time the script runs to
#          create or update the current language definition for PowerShell.  The
#          script also creates an auto-completion XML file for PowerShell.   
#  Author: Jason Fossen ( http://blogs.sans.org/windows-security/ )
# Version: 1.2
# Updated: 19.July.2009
#   Notes: If you already have a userDefineLang.xml file with other contents, this
#          script will not overwrite the file; however, the script will replace any
#          existing definition in the file named "PowerShell".  It's best if you 
#          close PowerShell, open a fresh shell, import any modules you use regularly,
#          and then run the script (script queries your current configuration).  It
#          is safe to run the script repeatedly if you need to refresh the settings.
#          After running the script, close Notepad++ and relaunch it to see changes.
#          Get Notepad++ from http://notepad-plus.sourceforge.net 
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################

if ($args.count -ne 0) {"`nScript takes no arguments, please read comments inside the script file.`n" ; exit }

if ($host.version.major -ge 2) 
{
	# Try to load the likely modules so that their cmdlets can be included.
	# What other common modules am I missing?
	import-module ServerManager -ea SilentlyContinue
	import-module ActiveDirectory -ea SilentlyContinue
	import-module BitsTransfer -ea SilentlyContinue
	import-module WebAdministration -ea SilentlyContinue
	import-module GroupPolicy -ea SilentlyContinue
	import-module AppLocker -ea SilentlyContinue
	import-module PowerBoots -ea SilentlyContinue
	import-module ExpressionEncoder -ea SilentlyContinue
}


# Build the words1 data from flow control keywords, aliases, cmdlet names and function names.
$words1 = "continue switch function if throw else elseif for foreach do ref while break"
get-command -CommandType cmdlet | foreach {$words1 += " " + $_.name}
get-command -CommandType function | where {$_.name.length -ge 4} | foreach {$words1 += " " + $_.name}
get-alias | foreach {$words1 += " " + $_.name}

# Build words2 data from all the operators and cmdlet parameters.
$words2 += " += -= *= /= %= = -ea -eq -ne -gt -lt -le -ge -match -notmatch -like -notlike -replace -is -isnot -as -bAND -bOR -bXOR -bNOT -and -or -xor -not "
$params =  get-command * -commandtype cmdlet | foreach { $_ | select -expand parametersets | foreach {$_.parameters} | foreach {$_.name}}
$params = "-" + [String]::Join(" -", $($params | sort -unique) )
$words2 += $params

# Build words3 from a query of WMI class names, but try to keep the total size down
# a bit by excluding WMI classes unlikely to be used much.
get-wmiobject -query "select * from meta_class" -namespace "root\cimv2" | 
where {$_.name -notlike "Win32_Perf*"} | 
foreach {$words3 += " " + $_.name}

# Build words4 from the default variables.  Actually, all the current variables
# will be used, so it's best to open a new fresh shell and then run the script.
# If you want to exclude items loaded by your $profile script, run
# "powershell.exe -NoProfile", but it's probably better to load the profile.
dir variable:\* | foreach {$words4 += " $" + $_.name}

# $userlang is the basic language definition template, feel free to edit
# in order to get a different font, font size, color, etc.
$userlang =
@"
<UserLang name="PowerShell" ext="ps1">
	<Settings>
		<Global caseIgnored="yes" />
		<TreatAsSymbol comment="no" commentLine="yes" />
		<Prefix words1="yes" words2="no" words3="no" words4="no" />
	</Settings>
	<KeywordLists>
		<Keywords name="Delimiters">&quot;00&quot;00</Keywords>
		<Keywords name="Folder+">{</Keywords>
		<Keywords name="Folder-">}</Keywords>
		<Keywords name="Operators">! &quot; % &amp; ( ) * / : ; ? @ [ \ ] ^ ` | ~ + &lt; &gt;</Keywords>
		<Keywords name="Comment"> 1&lt;# 1 2 2#&gt; 0#</Keywords>
		<Keywords name="Words1">$words1</Keywords>
		<Keywords name="Words2">$words2</Keywords>
		<Keywords name="Words3">$words3</Keywords>
		<Keywords name="Words4">$words4</Keywords>
	</KeywordLists>
	<Styles>
		<WordsStyle name="DEFAULT" styleID="11" fgColor="000000" bgColor="FFFFFF" fontName="Courier New" fontStyle="0" fontSize="11" />
		<WordsStyle name="FOLDEROPEN" styleID="12" fgColor="FF0000" bgColor="FFFFFF" fontName="Courier New" fontStyle="1" fontSize="11" />
		<WordsStyle name="FOLDERCLOSE" styleID="13" fgColor="FF0000" bgColor="FFFFFF" fontName="Courier New" fontStyle="1" fontSize="11" />
		<WordsStyle name="KEYWORD1" styleID="5" fgColor="0000FF" bgColor="FFFFFF" fontName="Courier New" fontStyle="1" fontSize="11" />
		<WordsStyle name="KEYWORD2" styleID="6" fgColor="800000" bgColor="FFFFFF" fontName="Courier New" fontStyle="1" fontSize="11" />
		<WordsStyle name="KEYWORD3" styleID="7" fgColor="800000" bgColor="FFFFFF" fontName="Courier New" fontStyle="1" fontSize="11" />
		<WordsStyle name="KEYWORD4" styleID="8" fgColor="000040" bgColor="FFFFFF" fontName="Courier New" fontStyle="1" fontSize="11" />
		<WordsStyle name="COMMENT" styleID="1" fgColor="008000" bgColor="FFFFFF" fontName="Courier New" fontStyle="1" fontSize="11" />
		<WordsStyle name="COMMENT LINE" styleID="2" fgColor="008000" bgColor="FFFFFF" fontName="Courier New" fontStyle="1" fontSize="11" />
		<WordsStyle name="NUMBER" styleID="4" fgColor="400080" bgColor="FFFFFF" fontName="Courier New" fontStyle="1" fontSize="11" />
		<WordsStyle name="OPERATOR" styleID="10" fgColor="DF0000" bgColor="FFFFFF" fontName="Courier New" fontStyle="1" fontSize="11" />
		<WordsStyle name="DELIMINER1" styleID="14" fgColor="800040" bgColor="FFFFFF" fontName="Courier New" fontStyle="0" fontSize="11" />
		<WordsStyle name="DELIMINER2" styleID="15" fgColor="000000" bgColor="FFFFFF" fontName="Courier New" fontStyle="0" fontSize="11" />
		<WordsStyle name="DELIMINER3" styleID="16" fgColor="000000" bgColor="FFFFFF" fontName="Courier New" fontStyle="0" fontSize="11" />
	</Styles>
</UserLang>
"@


# Create or update the $env:APPDATA\userDefineLang.xml file.
$path = "$env:APPDATA\Notepad++\userDefineLang.xml"
if (test-path $path) 
{
	#The file already exists, so remove current PowerShell lang def (if any) and replace it.
	# Load the userDefineLang.xml file and rename any lang defs named "PowerShell" to "DeleteMeNow".
	[xml] $userDefineLangXmlDoc = get-content $path
	$userDefineLangXmlDoc.NotepadPlus.UserLang | 
	foreach { if ($_.name -eq "PowerShell"){$_.SetAttribute("Name","DeleteMeNow") > $null } }
	
	#Cast new $userlang text as XML, import it into the loaded file, insert it as a new lang def.
	$userlangxml = [xml] $userlang
	$element = $userDefineLangXmlDoc.ImportNode( $userlangxml.UserLang, $true )	
	$userDefineLangXmlDoc.NotepadPlus.AppendChild($element) > $null

	#Now the renamed lang def can be deleted without raising an error (.NotepadPlus can't be empty).
	$userDefineLangXmlDoc.NotepadPlus.UserLang | 
	foreach { if ($_.name -eq "DeleteMeNow"){$userDefineLangXmlDoc.NotepadPlus.RemoveChild($_) > $null } }

	#Save new userDefineLang.xml file and overwrite the old one.
	$userDefineLangXmlDoc.Save($path)
	"`nUpdated the language definition file at $path (unless there was an error...)"
}   
else
{
	#The file does not exist, so create it and stick $userlang in it. 
	$userlang = "<NotepadPlus>`n" + $userlang + "`n</NotepadPlus>" 
	out-file -input $userlang -filepath $path -encoding ASCII 
	"`nCreated the language definition file at $path (unless there was an error...)"
}


# Create the PowerShell.xml data used for ctrl-space auto-completion.

$keywords  = $words1.split(" ")
$keywords += $words2.split(" ")
$keywords += $words3.split(" ")
$keywords += $words4.split(" ")
$keywords = $keywords | where {$_.length -gt 4} | sort -unique

$keywordtext = "<?xml version=`"1.0`" encoding=`"Windows-1252`" ?>`n<NotepadPlus>`n<AutoComplete language=`"PowerShell`">`n<Environment ignoreCase=`"yes`" />`n"  
$keywords | foreach {$keywordtext += "<KeyWord name=`"" + $_ + "`" />`n"} 
$keywordtext += "</AutoComplete>`n</NotepadPlus>"


# Try to find where Notepad++ is installed and save the PowerShell.xml file there.

$letters = Get-PSProvider FileSystem | select -expandproperty Drives | foreach {$_.Root}
$paths  = $letters | foreach {$_ + "PROGRA~1\Notepad++\plugins\APIs"}
$paths += $letters | foreach {$_ + "PROGRA~2\Notepad++\plugins\APIs"}

$foundpath = $false
$paths | foreach {
	if (test-path $_) {
		out-file -input $keywordtext -filepath $("$_" + "\PowerShell.xml") -force -encoding ASCII 
		"`nUpdated the PowerShell.xml file at $_ (unless there was an error...)`n"
		$foundpath = $true
		}
}

if (-not $foundpath) {"`nCould not find where Notepad++ is installed, couldn't save the auto-complete file.`n"}



