#######################################
# TITLE: listACL.ps1                  #
# AUTHOR: Santiago Fernandez Muñoz    #
#                                     #
# DESC: This script generate a HTML   #
# report show all ACLs asociated with #
# a Folder tree structure starting in #
# root specified by the user          #
#######################################
	
param ([string] $computer = 'localhost',
		[string] $path = $(if ($help -eq $false) {Throw "A path is needed."}),
		[int] $level = 0,
		[string] $scope = 'administrator', 
		[switch] $help = $false,
		[switch] $debug = $false
	)
	
#region Initializations and previous checkings
#region Initialization
$allowedLevels = 10
$Stamp = get-date -uformat "%Y%m%d"
$report = "$PWD\$computer.html"
$comparison = ""
$UNCPath = "\\" + $computer + "\" + $path + "\"
#endregion

#region Previous chekings
#require -version 2.0
if ($level -gt $allowedLevels -or $level -lt 0) {Throw "Level out of range."}
if ($computer -eq 'localhost' -or $computer -ieq $env:COMPUTERNAME) { $UNCPath = $path }
switch ($scope) {
	micro {
		$comparison = '($acl -notlike "*administrator*" -and $acl -notlike "*BUILTIN*" -and $acl -notlike "*NT AUTHORITY*")'
	}
	user {
		$comparison = '($acl -notlike "*administrator*" -and $acl -notlike "*BUILTIN*" -and $acl -notlike "*IT*" -and $acl -notlike "*NT AUTHORITY*" -and $acl -notlike "*All*")'
	}
}
#endregion
#endregion

#region Function definitions
function drawDirectory([ref] $directory) {
	$dirHTML = '
	<div class="'
		if ($directory.value.level -eq 0) { $dirHTML += 'he0_expanded' } else { $dirHTML += 'he' + $directory.value.level } 
		$dirHTML += '"><span class="sectionTitle" tabindex="0">Folder ' + $directory.value.Folder.FullName + '</span></div>
		<div class="container"><div class="he' + ($directory.value.level + 1) + '"><span class="sectionTitle" tabindex="0">Access Control List</span></div>
			<div class="container">
				<div class="heACL">
					<table class="info3" cellpadding="0" cellspacing="0">
						<thead>
							<th scope="col"><b>Owner</b></th>
							<th scope="col"><b>Privileges</b></th>
						</thead>
						<tbody>'
		foreach ($itemACL in $directory.value.ACL) {
			$acls = $null
			if ($itemACL.AccessToString -ne $null) {
				$acls = $itemACL.AccessToString.split("`n")
			}
			$dirHTML += '<tr><td>' + $itemACL.Owner + '</td>
			<td>
			<table>
				<thead>
					<th>User</th>
					<th>Control</th>
					<th>Privilege</th>
				</thead>
				<tbody>'
			foreach ($acl in $acls) {
				$temp = [regex]::split($acl, "(?<!(,|NT))\s{1,}")
				if ($debug) {
					write-host "ACL(" $temp.gettype().name ")[" $temp.length "]: " $temp
				}
				if ($temp.count -eq 1) {
					continue
				}
				if ($scope -ne 'administrator') {
					if ( Invoke-Expression $comparison ) {
						$dirHTML += "<tr><td>" + $temp[0] + "</td><td>" + $temp[1] + "</td><td>" + $temp[2] + "</td></tr>"
					}
				} else {
					$dirHTML += "<tr><td>" + $temp[0] + "</td><td>" + $temp[1] + "</td><td>" + $temp[2] + "</td></tr>"
				}
			}
			$dirHTML += '</tbody>
						</table>
						</td>
						</tr>'
		}
$dirHTML += '
						</tbody>
					</table>
				</div>
			</div>
		</div>'
	return $dirHTML
}

#endregion

#region Printing help message
if ($help) {
	Write-Host @"
/··················································\
· Script gather access control lists per directory ·
\··················································/

USAGE: ./listACL -computer <machine or IP> 
                 -path <path>
                 -level <0-10>
                 -help:[$false]
	
PARAMETERS:
	computer [OPTIONAL]     - Computer name or IP addres where folder is hosted (Default: localhost)
	path [REQUIRED]         - Folder's path to query.
	level [OPTIONAL]        - Level of folders to go down in the query. Allowd values are between 0 and $allowedLevels.
	                          0 show that there's no limit in the going down (Default: 0)
	scope [OPTIONAL]        - Sets the amount of information showd in the report. Allowd values are: 
                                  · user, show important information to the user.
                                  · micro, show user scope information plus important information for the IT Department.
                                  · administrator, show all information.
	help [OPTIONAL]         - This help.
"@
	exit 0
	
}
#endregion

if (Test-Path $report)
 {
  Remove-item $report
 }

#To normalize I check if last character in the path is the folder separator character
if ($path.Substring($path.Length - 1,1) -eq "\") { $path = $path.Substring(0,$path.Length - 1) }

#region Header, style and javascript functions needed by the html report
@"
<html dir="ltr" xmlns:v="urn:schemas-microsoft-com:vml" gpmc_reportInitialized="false">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-16" />
<title>Access Control List for $path in $computer</title>
<!-- Styles -->
<style type="text/css">
                body{ background-color:#FFFFFF; border:1px solid #666666; color:#000000; font-size:68%;	font-family:MS Shell Dlg; margin:0px 0px 10px 0px; }

                table{ font-size:100%; table-layout:fixed; width:100%; }

                td,th{ overflow:visible; text-align:left; vertical-align:top; white-space:normal; }

                .title{ background:#FFFFFF; border:none; color:#333333; display:block; height:24px; margin:0px 0px -1px 0px; padding-top:4px; position:relative; table-layout:fixed; width:100%; z-index:5; }

                .he0_expanded{ background-color:#FEF7D6; border:1px solid #BBBBBB; color:#3333CC; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:0px; margin-right:0px; padding-left:8px; padding-right:5em; padding-top:4px; position:relative; width:100%; }

                .he1_expanded{ background-color:#A0BACB; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:10px; margin-right:0px; padding-left:8px; padding-right:5em; padding-top:4px; position:relative; width:100%; }

                .he1{ background-color:#A0BACB; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:10px; margin-right:0px; padding-left:8px; padding-right:5em; padding-top:4px; position:relative; width:100%; }

                .he2{ background-color:#C0D2DE; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:20px; margin-right:0px; padding-left:8px; padding-right:5em; padding-top:4px; position:relative; width:100%; }

                .he3{ background-color:#D9E3EA; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:30px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }

                .he4{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:40px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }

                .he4h{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:45px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }

                .he4i{ background-color:#F9F9F9; border:1px solid #BBBBBB; color:#000000; display:block; font-family:MS Shell Dlg; font-size:100%; margin-bottom:-1px; margin-left:45px; margin-right:0px; padding-bottom:5px; padding-left:21px; padding-top:4px; position:relative; width:100%; }

                .he5{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:50px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }

                .he5h{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; padding-left:11px; padding-right:5em; padding-top:4px; margin-bottom:-1px; margin-left:55px; margin-right:0px; position:relative; width:100%; }

                .he5i{ background-color:#F9F9F9; border:1px solid #BBBBBB; color:#000000; display:block; font-family:MS Shell Dlg; font-size:100%; margin-bottom:-1px; margin-left:55px; margin-right:0px; padding-left:21px; padding-bottom:5px; padding-top: 4px; position:relative; width:100%; }

                .he6{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:55px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }

				.he7{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:60px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
				
				.he8{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:65px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
				
				.he9{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:70px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
				
				.he10{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:75px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
				
				.he11{ background-color:#E8E8E8; border:1px solid #BBBBBB; color:#000000; cursor:pointer; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:80px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
				
				.heACL { background-color:#ECFFD7; border:1px solid #BBBBBB; color:#000000; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:90px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
				
				DIV .expando{ color:#000000; text-decoration:none; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:normal; position:absolute; right:10px; text-decoration:underline; z-index: 0; }

                .he0 .expando{ font-size:100%; }

                .info, .info3, .info4, .disalign{ line-height:1.6em; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px; }

                .disalign TD{ padding-bottom:5px; padding-right:10px; }

                .info TD{ padding-right:10px; width:50%; }

                .info3 TD{ padding-right:10px; width:33%; }

                .info4 TD, .info4 TH{ padding-right:10px; width:25%; }
				
				.info5 TD, .info5 TH{ padding-right:0px; width:20%; }

                .info TH, .info3 TH, .info4 TH, .disalign TH{ border-bottom:1px solid #CCCCCC; padding-right:10px; }

                .subtable, .subtable3{ border:1px solid #CCCCCC; margin-left:0px; background:#FFFFFF; margin-bottom:10px; }

                .subtable TD, .subtable3 TD{ padding-left:10px; padding-right:5px; padding-top:3px; padding-bottom:3px; line-height:1.1em; width:10%; }

                .subtable TH, .subtable3 TH{ border-bottom:1px solid #CCCCCC; font-weight:normal; padding-left:10px; line-height:1.6em;  }

                .subtable .footnote{ border-top:1px solid #CCCCCC; }

                .subtable3 .footnote, .subtable .footnote{ border-top:1px solid #CCCCCC; }

                .subtable_frame{ background:#D9E3EA; border:1px solid #CCCCCC; margin-bottom:10px; margin-left:15px; }

                .subtable_frame TD{ line-height:1.1em; padding-bottom:3px; padding-left:10px; padding-right:15px; padding-top:3px; }

                .subtable_frame TH{ border-bottom:1px solid #CCCCCC; font-weight:normal; padding-left:10px; line-height:1.6em; }

                .subtableInnerHead{ border-bottom:1px solid #CCCCCC; border-top:1px solid #CCCCCC; }

                .explainlink{ color:#000000; text-decoration:none; cursor:pointer; }

                .explainlink:hover{ color:#0000FF; text-decoration:underline; }

                .spacer{ background:transparent; border:1px solid #BBBBBB; color:#FFFFFF; display:block; font-family:MS Shell Dlg; font-size:100%; height:10px; margin-bottom:-1px; margin-left:43px; margin-right:0px; padding-top: 4px; position:relative; }

                .filler{ background:transparent; border:none; color:#FFFFFF; display:block; font:100% MS Shell Dlg; line-height:8px; margin-bottom:-1px; margin-left:43px; margin-right:0px; padding-top:4px; position:relative; }

                .container{ display:block; position:relative; }

                .rsopheader{ background-color:#A0BACB; border-bottom:1px solid black; color:#333333; font-family:MS Shell Dlg; font-size:130%; font-weight:bold; padding-bottom:5px; text-align:center; }

                .rsopname{ color:#333333; font-family:MS Shell Dlg; font-size:130%; font-weight:bold; padding-left:11px; }

                .gponame{ color:#333333; font-family:MS Shell Dlg; font-size:130%; font-weight:bold; padding-left:11px; }

                .gpotype{ color:#333333; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; padding-left:11px; }

                #uri    { color:#333333; font-family:MS Shell Dlg; font-size:100%; padding-left:11px; }

                #dtstamp{ color:#333333; font-family:MS Shell Dlg; font-size:100%; padding-left:11px; text-align:left; width:30%; }

                #objshowhide { color:#000000; cursor:pointer; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; margin-right:0px; padding-right:10px; text-align:right; text-decoration:underline; z-index:2; }

                #gposummary { display:block; }

                #gpoinformation { display:block; }

</style>
</head>
<body>
<table class="title" cellpadding="0" cellspacing="0">
<tr><td colspan="2" class="gponame">Access Control List for $path on machine $computer</td></tr>
<tr>
    <td id="dtstamp">Data obtained on: $(Get-Date)</td>
    <td><div id="objshowhide" tabindex="0"></div></td>
</tr>
</table>
<div class="filler"></div>
"@ | Set-Content $report
#endregion

#region Information gathering
$colFiles = Get-ChildItem -path $UNCPath -Filter *. -Recurse -force -Verbose | Sort-Object FullName
$colACLs = @()
#We start going through the path pointed out by the user
foreach($file in $colFiles)
{
#To control the current level in the tree we are in it's needed to count the number of separator characters
#contained in the path. However in order to make the count correctly it's needed to delete the path 
#provided by the user (the parent). Once the parent has been deleted, the rest of the full name will be 
#string used to do the level count.
#It's needed to use a REGEX object to get ALL separator character matches.
$matches = (([regex]"\\").matches($file.FullName.substring($path.length, $file.FullName.length - $path.length))).count
if ($level -ne 0 -and ($matches - 1) -gt $level) {
	continue
}
if ($debug) {
	Write-Host $file.FullName "->" $file.Mode 
}
if ($file.Mode -notlike "d*") {
	continue
}
$myobj = "" | Select-Object Folder,ACL,level
$myobj.Folder = $file
$myobj.ACL = Get-Acl $file.FullName
$myobj.level = $matches - 1
$colACLs += $myobj
}
#endregion

#region Setting up the report
	'<div class="gposummary">' | Add-Content $report
	
	for ($i = 0; $i -lt $colACLs.count; $i++) {
		drawDirectory ([ref] $colACLs[$i]) | Add-Content $report
	}
	'</div></body></html>' | Add-Content $report
	
#endregion