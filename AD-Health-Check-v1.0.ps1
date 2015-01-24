#Requires -Version 3.0
#This File is in Unicode format.  Do not edit in an ASCII editor.

<#
    .SYNOPSIS
    Perform an Active Directory Health Check.
    .DESCRIPTION
    Perform an Active Directory Health Check based on LDAP queries.
    These are based on my personal best practices.
    No rights can be claimed by this report!

    Founding guidelines for all checks in this script:
        *) Must work for all domains in a forest tree.
        *) Must work on PowerShell v2 or above.
        *) Must work without module dependencies, except for the PowerShell core modules.
        *) Must work without Administrator privileges.
        *) Must work with Microsoft Office Word 2007 and above.
    .PARAMETER Sites
        Only perform the checks related to Sites.
    .PARAMETER OrganisationalUnit
        Only perform the checks related to OrganisationalUnits.
    .PARAMETER Users
        Only perform the checks related to Users.
    .PARAMETER Computers
        Only perform the checks related to Computers.
    .PARAMETER Groups
        Only perform the checks related to Groups.
    .PARAMETER All
        Perform all checks.
        This parameter is the default if no other selection parameters are used.
    .PARAMETER Log
        Generates a log file for the purpose of troubleshooting.
    .PARAMETER UserName
	    User name to use for the Cover Page and Footer.
	    Default value is contained in $env:username
	    This parameter has an alias of UN.
    .PARAMETER CompanyName
        Companyname to use for the coverpage.
        Default value is contained in HKCU:\Software\Microsoft\Office\Common\UserInfo\CompanyName
        or HKCU:\Software\Microsoft\Office\Common\UserInfo\Company, whichever is populated on the
        computer running the script.
        This parameter has an alias of CN.
        If either registry key does not exist and tis parameter is not specified, the report will
        use the default value of JeffWouters.nl
    .PARAMETER Coverpage
	    What Microsoft Word Cover Page to use.
    	(default cover pages in Word en-US)
	    Valid input is:
		    Alphabet (Word 2007/2010. Works)
    		Annual (Word 2007/2010. Doesn't really work well for this report)
	    	Austere (Word 2007/2010. Works)
		    Austin (Word 2010/2013. Doesn't work in 2013, mostly works in 2007/2010 but Subtitle/Subject & Author fields need to me moved after title box is moved up)
    		Banded (Word 2013. Works)
	    	Conservative (Word 2007/2010. Works)
		    Contrast (Word 2007/2010. Works)
    		Cubicles (Word 2007/2010. Works)
	    	Exposure (Word 2007/2010. Works if you like looking sideways)
		    Facet (Word 2013. Works)
    		Filigree (Word 2013. Works)
	    	Grid (Word 2010/2013.Works in 2010)
		    Integral (Word 2013. Works)
    		Ion (Dark) (Word 2013. Top date doesn't fit, box needs to be manually resized or font changed to 8 point)
		    Ion (Light) (Word 2013. Top date doesn't fit, box needs to be manually resized or font changed to 8 point)
    		Mod (Word 2007/2010. Works)
	    	Motion (Word 2007/2010/2013. Works if top date is manually changed to 36 point)
		    Newsprint (Word 2010. Works but date is not populated)
    		Perspective (Word 2010. Works)
	    	Pinstripes (Word 2007/2010. Works)
		    Puzzle (Word 2007/2010. Top date doesn't fit, box needs to be manually resized or font changed to 14 point)
    		Retrospect (Word 2013. Works)
	    	Semaphore (Word 2013. Works)
		    Sideline (Word 2007/2010/2013. Doesn't work in 2013, works in 2007/2010)
    		Slice (Dark) (Word 2013. Doesn't work)
	    	Slice (Light) (Word 2013. Doesn't work)
		    Stacks (Word 2007/2010. Works)
    		Tiles (Word 2007/2010. Date doesn't fit unless changed to 26 point)
	    	Transcend (Word 2007/2010. Works)
		    ViewMaster (Word 2013. Works)
		    Whisp (Word 2013. Works)
    	Default value is Austin.
	    This parameter has an alias of CP.
    .PARAMETER Mgmt
        Provides a page at the end of the PDF or DOCX file with information for your manager.
        Listed is the name of the check performed and the number of results found by the check.
    .PARAMETER MSWord
        SaveAs DOCX file.
	    This parameter is set True if no other output format is selected.
    .PARAMETER PDF
	    SaveAs PDF file instead of DOCX file.
	    This parameter is disabled by default.
    	For Word 2007, the Microsoft add-in for saving as a PDF muct be installed.
	    For Word 2007, please see http://www.microsoft.com/en-us/download/details.aspx?id=9943
    	The PDF file is roughly 5X to 10X larger than the DOCX file.
    .PARAMETER HTML
        Creates an HTML file with an .html extension.
	    This parameter is disabled by default.
    .PARAMETER AddDateTime
    	Adds a date time stamp to the end of the file name.
	    Time stamp is in the format of yyyy-MM-dd_HHmm.
    	June 1, 2014 at 6PM is 2014-06-01_1800.
	    Output filename will be ReportName_2014-06-01_1800.docx (or .pdf).
    	This parameter is disabled by default.
    .PARAMETER Visible
        Shows Microsoft Word while creating the report.
        This parameter is disabled by default.
    .EXAMPLE
        PS D:\> & '.\AD Health Check v1.0.ps1' -Visible -MSWord

        This will generate a DOCX document with all the checks included.
        Microsoft Word will be visible while creating the DOCX file.
        The file is created at the location of the script that is executed.
    .EXAMPLE
        PS D:\> & '.\AD Health Check v1.0.ps1' -Visible -MSWord -Log -CSV

        This will generate a DOCX document with all the checks included.
        Microsoft Word will be visible while creating the DOCX file.
        For each check, a seperate CSV file will be created with the results.
        A log file is created for the purpose of troubleshooting.
        All files are created at the location of the script that is executed.
    .EXAMPLE
        PS D:\> & '.\AD Health Check v1.0.ps1' -MSWord -Sites -Users -Groups

        This will generate a DOCX document with the checks for Sites, Users and Groups.
    .INPUTS
	    None.  You cannot pipe objects to this script.
    .OUTPUTS
    	No objects are output from this script.  This script creates a Word, PDF or HTML document.
    .NOTES
    NAME        :   AD Health Check.ps1
    AUTHOR      :   Jeff Wouters [MVP Windows PowerShell]
    VERSION     :   1.0
    LAST EDIT   :   17th of July 2014

    The Word file generation part of the script is based upon the work done by:
    
    Carl Webster  | http://www.carlwebster.com | @CarlWebster
    Iain Brighton | http://virtualengine.co.uk | @IainBrighton
    Jeff Wouters  | http://www.jeffwouters.nl  | @JeffWouters

    The Active Directory checks are written by:
    
    Jeff Wouters  | http://www.jeffwouters.nl  | @JeffWouters
#>

[CmdletBinding(DefaultParameterSetName='All',SupportsShouldProcess=$False,ConfirmImpact="None") ]
param (
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [switch]$Groups,
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [switch]$Sites,
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [switch]$OrganisationalUnit,
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [switch]$Users,
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [switch]$Computers,
    [parameter(mandatory=$false,ParameterSetName='All')]
    [switch]$All=$true,
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [parameter(mandatory=$false,ParameterSetName='All')]
    [Alias("UN")][ValidateNotNullOrEmpty()]
    [string]$UserName=$env:username,
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [parameter(mandatory=$false,ParameterSetName='All')]
    [Alias("CP")][ValidateNotNullOrEmpty()]
    [string]$CoverPage="Sideline", 
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [parameter(mandatory=$false,ParameterSetName='All')]
    [switch]$Mgmt=$false,
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [parameter(mandatory=$false,ParameterSetName='All')]
    $CompanyName="jeffwouters.nl",
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [parameter(mandatory=$false,ParameterSetName='All')]
    [switch]$Visible=$false,
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [parameter(mandatory=$false,ParameterSetName='All')]
    [switch]$Log=$false,
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [parameter(mandatory=$false,ParameterSetName='All')]
    [switch]$CSV=$false,
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [parameter(mandatory=$false,ParameterSetName='All')]
    [Switch]$PDF=$false,
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [parameter(mandatory=$false,ParameterSetName='All')]
    [Switch]$MSWord=$false,
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [parameter(mandatory=$false,ParameterSetName='All')]
    [Switch]$HTML=$false,
    [parameter(mandatory=$false,ParameterSetName='Specific')]
    [parameter(mandatory=$false,ParameterSetName='All')]
    [Switch]$AddDateTime=$false
)
Set-StrictMode -Version 2

#force -verbose on
$PSDefaultParameterValues = @{"*:Verbose"=$True}
$SaveEAPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
$Script:ThisScriptPath = $(Split-Path ((Get-PSCallStack)[0]).ScriptName)

if ($PSBoundParameters.ContainsKey('Log')) {
    $Script:LogPath = "$Script:ThisScriptPath\ADHealthCheck.log"
    if ((Test-Path $Script:LogPath) -eq $true) {
        Write-Verbose "$(Get-Date): Transcript/Log $Script:LogPath already exists"
        $Script:StartLog = $false
    } else {
        try {
            Start-Transcript -Path $LogPath -Force -Verbose:$false | Out-Null
            Write-Verbose "$(Get-Date): Transcript/log started at $Script:LogPath"
            $Script:StartLog = $true
        } catch {
            Write-Verbose "$(Get-Date): Transcript/log failed at $Script:LogPath"
            $Script:StartLog = $false
        }
    }
}

If($PDF -eq $Null)
{
	$PDF = $False
}
If($Text -eq $Null)
{
	$Text = $False
}
If($MSWord -eq $Null)
{
	$MSWord = $False
}
If($HTML -eq $Null)
{
	$HTML = $False
}
If($AddDateTime -eq $Null)
{
	$AddDateTime = $False
}
If($Hardware -eq $Null)
{
	$Hardware = $False
}
If($ComputerName -eq $Null)
{
	$ComputerName = "LocalHost"
}

If(!(Test-Path Variable:PDF))
{
	$PDF = $False
}
If(!(Test-Path Variable:Text))
{
	$Text = $False
}
If(!(Test-Path Variable:MSWord))
{
	$MSWord = $False
}
If(!(Test-Path Variable:HTML))
{
	$HTML = $False
}
If(!(Test-Path Variable:AddDateTime))
{
	$AddDateTime = $False
}
If(!(Test-Path Variable:Hardware))
{
	$Hardware = $False
}
If(!(Test-Path Variable:ComputerName))
{
	$ComputerName = "LocalHost"
}

If($MSWord -eq $Null)
{
	If($Text -or $HTML -or $PDF)
	{
		$MSWord = $False
	}
	Else
	{
		$MSWord = $True
	}
}

If($MSWord -eq $False -and $PDF -eq $False -and $Text -eq $False -and $HTML -eq $False)
{
	$MSWord = $True
}

Write-Verbose "$(Get-Date): Testing output parameters"

If($MSWord)
{
	Write-Verbose "$(Get-Date): MSWord is set"
}
ElseIf($PDF)
{
	Write-Verbose "$(Get-Date): PDF is set"
}
ElseIf($Text)
{
	Write-Verbose "$(Get-Date): Text is set"
}
ElseIf($HTML)
{
	Write-Verbose "$(Get-Date): HTML is set"
}
Else
{
	$ErrorActionPreference = $SaveEAPreference
	Write-Verbose "$(Get-Date): Unable to determine output parameter"
	If($MSWord -eq $Null)
	{
		Write-Verbose "$(Get-Date): MSWord is Null"
	}
	ElseIf($PDF -eq $Null)
	{
		Write-Verbose "$(Get-Date): PDF is Null"
	}
	ElseIf($Text -eq $Null)
	{
		Write-Verbose "$(Get-Date): Text is Null"
	}
	ElseIf($HTML -eq $Null)
	{
		Write-Verbose "$(Get-Date): HTML is Null"
	}
	Else
	{
		Write-Verbose "$(Get-Date): MSWord is " $MSWord
		Write-Verbose "$(Get-Date): PDF is " $PDF
		Write-Verbose "$(Get-Date): Text is " $Text
		Write-Verbose "$(Get-Date): HTML is " $HTML
	}
	Write-Error "Unable to determine output parameter.  Script cannot continue"
	Exit
}

If($MSWord -or $PDF)
{
	#try and fix the issue with the $CompanyName variable
	$CoName = $CompanyName
	Write-Verbose "$(Get-Date): CoName is $CoName"
	
	#the following values were attained from 
	#http://groovy.codehaus.org/modules/scriptom/1.6.0/scriptom-office-2K3-tlb/apidocs/
	#http://msdn.microsoft.com/en-us/library/office/aa211923(v=office.11).aspx
	[int]$wdAlignPageNumberRight = 2
	[long]$wdColorGray15 = 14277081
	[long]$wdColorGray05 = 15987699 
	[int]$wdMove = 0
	[int]$wdSeekMainDocument = 0
	[int]$wdSeekPrimaryFooter = 4
	[int]$wdStory = 6
	[int]$wdColorRed = 255
	[int]$wdColorBlack = 0
	[int]$wdWord2007 = 12
	[int]$wdWord2010 = 14
	[int]$wdWord2013 = 15
	[int]$wdFormatDocumentDefault = 16
	[int]$wdSaveFormatPDF = 17
	#http://blogs.technet.com/b/heyscriptingguy/archive/2006/03/01/how-can-i-right-align-a-single-column-in-a-word-table.aspx
	#http://msdn.microsoft.com/en-us/library/office/ff835817%28v=office.15%29.aspx
	[int]$wdAlignParagraphLeft = 0
	[int]$wdAlignParagraphCenter = 1
	[int]$wdAlignParagraphRight = 2
	#http://msdn.microsoft.com/en-us/library/office/ff193345%28v=office.15%29.aspx
	[int]$wdCellAlignVerticalTop = 0
	[int]$wdCellAlignVerticalCenter = 1
	[int]$wdCellAlignVerticalBottom = 2
	#http://msdn.microsoft.com/en-us/library/office/ff844856%28v=office.15%29.aspx
	[int]$wdAutoFitFixed = 0
	[int]$wdAutoFitContent = 1
	[int]$wdAutoFitWindow = 2
	#http://msdn.microsoft.com/en-us/library/office/ff821928%28v=office.15%29.aspx
	[int]$wdAdjustNone = 0
	[int]$wdAdjustProportional = 1
	[int]$wdAdjustFirstColumn = 2
	[int]$wdAdjustSameWidth = 3

	[int]$PointsPerTabStop = 36
	[int]$Indent0TabStops = 0 * $PointsPerTabStop
	[int]$Indent1TabStops = 1 * $PointsPerTabStop
	[int]$Indent2TabStops = 2 * $PointsPerTabStop
	[int]$Indent3TabStops = 3 * $PointsPerTabStop
	[int]$Indent4TabStops = 4 * $PointsPerTabStop

	# http://www.thedoctools.com/index.php?show=wt_style_names_english_danish_german_french
	[int]$wdStyleHeading1 = -2
	[int]$wdStyleHeading2 = -3
	[int]$wdStyleHeading3 = -4
	[int]$wdStyleHeading4 = -5
	[int]$wdStyleNoSpacing = -158
	[int]$wdTableGrid = -155

	#http://groovy.codehaus.org/modules/scriptom/1.6.0/scriptom-office-2K3-tlb/apidocs/org/codehaus/groovy/scriptom/tlb/office/word/WdLineStyle.html
	[int]$wdLineStyleNone = 0
	[int]$wdLineStyleSingle = 1

	[int]$wdHeadingFormatTrue = -1
	[int]$wdHeadingFormatFalse = 0 

	[string]$RunningOS = (Get-WmiObject -class Win32_OperatingSystem -EA 0).Caption
}

Function SetWordHashTable
{
	Param([string]$CultureCode)
	$hash = @{}
	    
	# DE and FR translations for Word 2010 by Vladimir Radojevic
	# Vladimir.Radojevic@Commerzreal.com

	# DA translations for Word 2010 by Thomas Daugaard
	# Citrix Infrastructure Specialist at edgemo A/S

	# CA translations by Javier Sanchez 
	# CEO & Founder 101 Consulting

	#ca - Catalan
	#da - Danish
	#de - German
	#en - English
	#es - Spanish
	#fi - Finnish
	#fr - French
	#nb - Norwegian
	#nl - Dutch
	#pt - Portuguese
	#sv - Swedish

	Switch ($CultureCode)
	{
		'ca-'	{
				$hash.($($CultureCode)) = @{
					'Word_TableOfContents' = 'Taula automÃ¡tica 2'
				}
			}

		'da-'	{
				$hash.($($CultureCode)) = @{
					'Word_TableOfContents' = 'Automatisk tabel 2'
				}
			}

		'de-'	{
				$hash.($($CultureCode)) = @{
					'Word_TableOfContents' = 'Automatische Tabelle 2'
				}
			}

		'en-'	{
				$hash.($($CultureCode)) = @{
					'Word_TableOfContents'  = 'Automatic Table 2'
				}
			}

		'es-'	{
				$hash.($($CultureCode)) = @{
					'Word_TableOfContents' = 'Tabla automÃ¡tica 2'
				}
			}

		'fi-'	{
				$hash.($($CultureCode)) = @{
					'Word_TableOfContents' = 'Automaattinen taulukko 2'
				}
			}

		'fr-'	{
				$hash.($($CultureCode)) = @{
					'Word_TableOfContents' = 'Sommaire Automatique 2'
				}
			}

		'nb-'	{
				$hash.($($CultureCode)) = @{
					'Word_TableOfContents' = 'Automatisk tabell 2'
				}
			}

		'nl-'	{
				$hash.($($CultureCode)) = @{
					'Word_TableOfContents' = 'Automatische inhoudsopgave 2'
				}
			}

		'pt-'	{
				$hash.($($CultureCode)) = @{
					'Word_TableOfContents' = 'SumÃ¡rio AutomÃ¡tico 2'
				}
			}

		'sv-'	{
				$hash.($($CultureCode)) = @{
					'Word_TableOfContents' = 'Automatisk innehÃ¥llsfÃ¶rteckning2'
				}
			}

		Default	{$hash.('en-') = @{
					'Word_TableOfContents'  = 'Automatic Table 2'
				}
			}
	}

	$Script:myHash = $hash.$CultureCode

	If($Script:myHash -eq $Null)
	{
		$Script:myHash = $hash.('en-')
	}

	$Script:myHash.Word_NoSpacing = $wdStyleNoSpacing
	$Script:myHash.Word_Heading1 = $wdStyleheading1
	$Script:myHash.Word_Heading2 = $wdStyleheading2
	$Script:myHash.Word_Heading3 = $wdStyleheading3
	$Script:myHash.Word_Heading4 = $wdStyleheading4
	$Script:myHash.Word_TableGrid = $wdTableGrid
}

Function GetCulture
{
	Param([int]$WordValue)
	
	#codes obtained from http://support.microsoft.com/kb/221435
	#http://msdn.microsoft.com/en-us/library/bb213877(v=office.12).aspx
	$CatalanArray = 1027
	$DanishArray = 1030
	$DutchArray = 2067, 1043
	$EnglishArray = 3081, 10249, 4105, 9225, 6153, 8201, 5129, 13321, 7177, 11273, 2057, 1033, 12297
	$FinnishArray = 1035
	$FrenchArray = 2060, 1036, 11276, 3084, 12300, 5132, 13324, 6156, 8204, 10252, 7180, 9228, 4108
	$GermanArray = 1031, 3079, 5127, 4103, 2055
	$NorwegianArray = 1044, 2068
	$PortugueseArray = 1046, 2070
	$SpanishArray = 1034, 11274, 16394, 13322, 9226, 5130, 7178, 12298, 17418, 4106, 18442, 19466, 6154, 15370, 10250, 20490, 3082, 14346, 8202
	$SwedishArray = 1053, 2077

	#ca - Catalan
	#da - Danish
	#de - German
	#en - English
	#es - Spanish
	#fi - Finnish
	#fr - French
	#nb - Norwegian
	#nl - Dutch
	#pt - Portuguese
	#sv - Swedish

	Switch ($WordValue)
	{
		{$CatalanArray -contains $_} {$CultureCode = "ca-"}
		{$DanishArray -contains $_} {$CultureCode = "da-"}
		{$DutchArray -contains $_} {$CultureCode = "nl-"}
		{$EnglishArray -contains $_} {$CultureCode = "en-"}
		{$FinnishArray -contains $_} {$CultureCode = "fi-"}
		{$FrenchArray -contains $_} {$CultureCode = "fr-"}
		{$GermanArray -contains $_} {$CultureCode = "de-"}
		{$NorwegianArray -contains $_} {$CultureCode = "nb-"}
		{$PortugueseArray -contains $_} {$CultureCode = "pt-"}
		{$SpanishArray -contains $_} {$CultureCode = "es-"}
		{$SwedishArray -contains $_} {$CultureCode = "sv-"}
		Default {$CultureCode = "en-"}
	}
	
	Return $CultureCode
}

Function ValidateCoverPage
{
	Param([int]$xWordVersion, [string]$xCP, [string]$CultureCode)
	
	$xArray = ""
	
	Switch ($CultureCode)
	{
		'ca-'	{
				If($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("Austin", "En bandes", "Faceta", "Filigrana",
					"Integral", "IÃ³ (clar)", "IÃ³ (fosc)", "LÃ­nia lateral",
					"Moviment", "QuadrÃ­cula", "Retrospectiu", "Sector (clar)",
					"Sector (fosc)", "SemÃ for", "VisualitzaciÃ³", "Whisp")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Alfabet", "Anual", "Austin", "Conservador",
					"Contrast", "Cubicles", "DiplomÃ tic", "ExposiciÃ³",
					"LÃ­nia lateral", "Mod", "Mosiac", "Moviment", "Paper de diari",
					"Perspectiva", "Piles", "QuadrÃ­cula", "Sobri",
					"Transcendir", "Trencaclosques")
				}
				ElseIf($xWordVersion -eq $wdWord2007)
				{
					$xArray = ("Alfabet", "Anual", "Conservador", "Contrast",
					"Cubicles", "DiplomÃ tic", "En mosaic", "ExposiciÃ³", "LÃ­nia lateral",
					"Mod", "Moviment", "Piles", "Sobri", "Transcendir", "Trencaclosques")
				}
			}

		'da-'	{
				If($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("BevÃ¦gElse", "Brusen", "Ion (lys)", "Filigran",
					"Retro", "Semafor", "Visningsmaster", "Integral",
					"Facet", "Gitter", "Stribet", "Sidelinje", "Udsnit (lys)",
					"Udsnit (mÃ¸rk)", "Ion (mÃ¸rk)", "Austin")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("BevÃ¦gElse", "Moderat", "Perspektiv", "Firkanter",
					"Overskrid", "Alfabet", "Kontrast", "Stakke", "Fliser", "GÃ¥de",
					"Gitter", "Austin", "Eksponering", "Sidelinje", "Enkel",
					"NÃ¥lestribet", "Ã…rlig", "Avispapir", "Tradionel")
				}
				ElseIf($xWordVersion -eq $wdWord2007)
				{
					$xArray = ("Alfabet", "Ã…rlig", "BevÃ¦gElse", "Eksponering",
					"Enkel", "Firkanter", "Fliser", "GÃ¥de", "Kontrast",
					"Mod", "NÃ¥lestribet", "Overskrid", "Sidelinje", "Stakke",
					"Tradionel")
				}
			}

		'de-'	{
				If($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("Semaphor", "Segment (hell)", "Ion (hell)",
					"Raster", "Ion (dunkel)", "Filigran", "RÃ¼ckblick", "Pfiff",
					"ViewMaster", "Segment (dunkel)", "Verbunden", "Bewegung",
					"Randlinie", "Austin", "Integral", "Facette")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Alphabet", "Austin", "Bewegung", "Durchscheinend",
					"Herausgestellt", "JÃ¤hrlich", "Kacheln", "Kontrast", "Kubistisch",
					"Modern", "Nadelstreifen", "Perspektive", "Puzzle", "Randlinie",
					"Raster", "Schlicht", "Stapel", "Traditionell", "Zeitungspapier")
				}
				ElseIf($xWordVersion -eq $wdWord2007)
				{
					$xArray = ("Alphabet", "Bewegung", "Durchscheinend", "Herausgestellt",
					"JÃ¤hrlich", "Kacheln", "Kontrast", "Kubistisch", "Modern",
					"Nadelstreifen", "Puzzle", "Randlinie", "Raster", "Schlicht", "Stapel",
					"Traditionell")
				}
			}

		'en-'	{
				If($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("Austin", "Banded", "Facet", "Filigree", "Grid",
					"Integral", "Ion (Dark)", "Ion (Light)", "Motion", "Retrospect",
					"Semaphore", "Sideline", "Slice (Dark)", "Slice (Light)", "ViewMaster",
					"Whisp")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Alphabet", "Annual", "Austere", "Austin", "Conservative",
					"Contrast", "Cubicles", "Exposure", "Grid", "Mod", "Motion", "Newsprint",
					"Perspective", "Pinstripes", "Puzzle", "Sideline", "Stacks", "Tiles", "Transcend")
				}
				ElseIf($xWordVersion -eq $wdWord2007)
				{
					$xArray = ("Alphabet", "Annual", "Austere", "Conservative", "Contrast",
					"Cubicles", "Exposure", "Mod", "Motion", "Pinstripes", "Puzzle",
					"Sideline", "Stacks", "Tiles", "Transcend")
				}
			}

		'es-'	{
				If($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("Whisp", "Vista principal", "Filigrana", "Austin",
					"Slice (luz)", "Faceta", "SemÃ¡foro", "Retrospectiva", "CuadrÃ­cula",
					"Movimiento", "Cortar (oscuro)", "LÃ­nea lateral", "Ion (oscuro)",
					"Ion (claro)", "Integral", "Con bandas")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Alfabeto", "Anual", "Austero", "Austin", "Conservador",
					"Contraste", "CuadrÃ­cula", "CubÃ­culos", "ExposiciÃ³n", "LÃ­nea lateral",
					"Moderno", "Mosaicos", "Movimiento", "Papel periÃ³dico",
					"Perspectiva", "Pilas", "Puzzle", "Rayas", "Sobrepasar")
				}
				ElseIf($xWordVersion -eq $wdWord2007)
				{
					$xArray = ("Alfabeto", "Anual", "Austero", "Conservador",
					"Contraste", "CubÃ­culos", "ExposiciÃ³n", "LÃ­nea lateral",
					"Moderno", "Mosaicos", "Movimiento", "Pilas", "Puzzle",
					"Rayas", "Sobrepasar")
				}
			}

		'fi-'	{
				If($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("Filigraani", "Integraali", "Ioni (tumma)",
					"Ioni (vaalea)", "Opastin", "Pinta", "Retro", "Sektori (tumma)",
					"Sektori (vaalea)", "VaihtuvavÃ¤rinen", "ViewMaster", "Austin",
					"Kiehkura", "Liike", "Ruudukko", "Sivussa")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Aakkoset", "Askeettinen", "Austin", "Kontrasti",
					"Laatikot", "Liike", "Liituraita", "Mod", "Osittain peitossa",
					"Palapeli", "Perinteinen", "Perspektiivi", "Pinot", "Ruudukko",
					"Ruudut", "Sanomalehtipaperi", "Sivussa", "Vuotuinen", "Ylitys")
				}
				ElseIf($xWordVersion -eq $wdWord2007)
				{
					$xArray = ("Aakkoset", "Alttius", "Kontrasti", "Kuvakkeet ja tiedot",
					"Liike" , "Liituraita" , "Mod" , "Palapeli", "Perinteinen", "Pinot",
					"Sivussa", "TyÃ¶pisteet", "Vuosittainen", "Yksinkertainen", "Ylitys")
				}
			}

		'fr-'	{
				If($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("ViewMaster", "Secteur (foncÃ©)", "SÃ©maphore",
					"RÃ©trospective", "Ion (foncÃ©)", "Ion (clair)", "IntÃ©grale",
					"Filigrane", "Facette", "Secteur (clair)", "Ã€ bandes", "Austin",
					"Guide", "Whisp", "Lignes latÃ©rales", "Quadrillage")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("MosaÃ¯ques", "Ligne latÃ©rale", "Annuel", "Perspective",
					"Contraste", "Emplacements de bureau", "Moderne", "Blocs empilÃ©s",
					"Rayures fines", "AustÃ¨re", "Transcendant", "Classique", "Quadrillage",
					"Exposition", "Alphabet", "Mots croisÃ©s", "Papier journal", "Austin", "Guide")
				}
				ElseIf($xWordVersion -eq $wdWord2007)
				{
					$xArray = ("Alphabet", "Annuel", "AustÃ¨re", "Blocs empilÃ©s", "Blocs superposÃ©s",
					"Classique", "Contraste", "Exposition", "Guide", "Ligne latÃ©rale", "Moderne",
					"MosaÃ¯ques", "Mots croisÃ©s", "Rayures fines", "Transcendant")
				}
			}

		'nb-'	{
				If($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("Austin", "BevegElse", "Dempet", "Fasett", "Filigran",
					"Integral", "Ion (lys)", "Ion (mÃ¸rk)", "Retrospekt", "Rutenett",
					"Sektor (lys)", "Sektor (mÃ¸rk)", "Semafor", "Sidelinje", "Stripet",
					"ViewMaster")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Alfabet", "Ã…rlig", "Avistrykk", "Austin", "Avlukker",
					"BevegElse", "Engasjement", "Enkel", "Fliser", "Konservativ",
					"Kontrast", "Mod", "Perspektiv", "Puslespill", "Rutenett", "Sidelinje",
					"Smale striper", "Stabler", "Transcenderende")
				}
				ElseIf($xWordVersion -eq $wdWord2007)
				{
					$xArray = ("Alfabet", "Ã…rlig", "Avlukker", "BevegElse", "Engasjement",
					"Enkel", "Fliser", "Konservativ", "Kontrast", "Mod", "Puslespill",
					"Sidelinje", "Smale striper", "Stabler", "Transcenderende")
				}
			}

		'nl-'	{
				If($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("Austin", "Beweging", "Facet", "Filigraan", "Gestreept",
					"Integraal", "Ion (donker)", "Ion (licht)", "Raster",
					"Segment (Light)", "Semafoor", "Slice (donker)", "Spriet",
					"Terugblik", "Terzijde", "ViewMaster")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Aantrekkelijk", "Alfabet", "Austin", "Bescheiden",
					"Beweging", "Blikvanger", "Contrast", "Eenvoudig", "Jaarlijks",
					"Krantenpapier", "Krijtstreep", "Kubussen", "Mod", "Perspectief",
					"Puzzel", "Raster", "Stapels",
					"Tegels", "Terzijde")
				}
				ElseIf($xWordVersion -eq $wdWord2007)
				{
					$xArray = ("Aantrekkelijk", "Alfabet", "Bescheiden", "Beweging",
					"Blikvanger", "Contrast", "Eenvoudig", "Jaarlijks", "Krijtstreep",
					"Mod", "Puzzel", "Stapels", "Tegels", "Terzijde", "Werkplekken")
				}
			}

		'pt-'	{
				If($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("AnimaÃ§Ã£o", "Austin", "Em Tiras", "ExibiÃ§Ã£o Mestra",
					"Faceta", "Fatia (Clara)", "Fatia (Escura)", "Filete", "Filigrana",
					"Grade", "Integral", "Ãon (Claro)", "Ãon (Escuro)", "Linha Lateral",
					"Retrospectiva", "SemÃ¡foro")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Alfabeto", "AnimaÃ§Ã£o", "Anual", "Austero", "Austin", "Baias",
					"Conservador", "Contraste", "ExposiÃ§Ã£o", "Grade", "Ladrilhos",
					"Linha Lateral", "Listras", "Mod", "Papel Jornal", "Perspectiva", "Pilhas",
					"Quebra-cabeÃ§a", "Transcend")
				}
				ElseIf($xWordVersion -eq $wdWord2007)
				{
					$xArray = ("Alfabeto", "AnimaÃ§Ã£o", "Anual", "Austero", "Baias", "Conservador",
					"Contraste", "ExposiÃ§Ã£o", "Ladrilhos", "Linha Lateral", "Listras", "Mod",
					"Pilhas", "Quebra-cabeÃ§a", "Transcendente")
				}
			}

		'sv-'	{
				If($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("Austin", "Band", "Fasett", "Filigran", "Integrerad", "Jon (ljust)",
					"Jon (mÃ¶rkt)", "Knippe", "RutnÃ¤t", "RÃ¶rElse", "Sektor (ljus)", "Sektor (mÃ¶rk)",
					"Semafor", "Sidlinje", "VisaHuvudsida", "Ã…terblick")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("AlfabetmÃ¶nster", "Austin", "Enkelt", "Exponering", "Konservativt",
					"Kontrast", "Kritstreck", "Kuber", "Perspektiv", "Plattor", "Pussel", "RutnÃ¤t",
					"RÃ¶rElse", "Sidlinje", "Sobert", "Staplat", "Tidningspapper", "Ã…rligt",
					"Ã–vergÃ¥ende")
				}
				ElseIf($xWordVersion -eq $wdWord2007)
				{
					$xArray = ("AlfabetmÃ¶nster", "Ã…rligt", "Enkelt", "Exponering", "Konservativt",
					"Kontrast", "Kritstreck", "Kuber", "Ã–vergÃ¥ende", "Plattor", "Pussel", "RÃ¶rElse",
					"Sidlinje", "Sobert", "Staplat")
				}
			}

		Default	{
					If($xWordVersion -eq $wdWord2013)
					{
						$xArray = ("Austin", "Banded", "Facet", "Filigree", "Grid", "Integral",
						"Ion (Dark)", "Ion (Light)", "Motion", "Retrospect", "Semaphore",
						"Sideline", "Slice (Dark)", "Slice (Light)", "ViewMaster", "Whisp")
					}
					ElseIf($xWordVersion -eq $wdWord2010)
					{
						$xArray = ("Alphabet", "Annual", "Austere", "Austin", "Conservative",
						"Contrast", "Cubicles", "Exposure", "Grid", "Mod", "Motion", "Newsprint",
						"Perspective", "Pinstripes", "Puzzle", "Sideline", "Stacks", "Tiles", "Transcend")
					}
					ElseIf($xWordVersion -eq $wdWord2007)
					{
						$xArray = ("Alphabet", "Annual", "Austere", "Conservative", "Contrast",
						"Cubicles", "Exposure", "Mod", "Motion", "Pinstripes", "Puzzle",
						"Sideline", "Stacks", "Tiles", "Transcend")
					}
				}
	}
	
	If($xArray -contains $xCP)
	{
		$xArray = $Null
		Return $True
	}
	Else
	{
		$xArray = $Null
		Return $False
	}
}

Function CheckWordPrereq
{
	If((Test-Path  REGISTRY::HKEY_CLASSES_ROOT\Word.Application) -eq $False)
	{
		$ErrorActionPreference = $SaveEAPreference
		Write-Host "`n`n`t`tThis script directly outputs to Microsoft Word, please install Microsoft Word`n`n"
		Exit
	}

	#find out our session (usually "1" except on TS/RDC or Citrix)
	$SessionID = (Get-Process -PID $PID).SessionId
	
	#Find out if winword is running in our session
	[bool]$wordrunning = ((Get-Process 'WinWord' -ea 0)|?{$_.SessionId -eq $SessionID}) -ne $Null
	If($wordrunning)
	{
		$ErrorActionPreference = $SaveEAPreference
		Write-Host "`n`n`tPlease close all instances of Microsoft Word before running this report.`n`n"
		Exit
	}
}

Function CheckWord2007SaveAsPDFInstalled
{
	If((Test-Path  REGISTRY::HKEY_CLASSES_ROOT\Installer\Products\000021090B0090400000000000F01FEC) -eq $False)
	{
		Write-Host "`n`n`t`tWord 2007 is detected and the option to SaveAs PDF was selected but the Word 2007 SaveAs PDF add-in is not installed."
		Write-Host "`n`n`t`tThe add-in can be downloaded from http://www.microsoft.com/en-us/download/details.aspx?id=9943"
		Write-Host "`n`n`t`tInstall the SaveAs PDF add-in and rerun the script."
		Return $False
	}
	Return $True
}

Function ValidateCompanyName
{
	[bool]$xResult = Test-RegistryValue "HKCU:\Software\Microsoft\Office\Common\UserInfo" "CompanyName"
	If($xResult)
	{
		Return Get-RegistryValue "HKCU:\Software\Microsoft\Office\Common\UserInfo" "CompanyName"
	}
	Else
	{
		$xResult = Test-RegistryValue "HKCU:\Software\Microsoft\Office\Common\UserInfo" "Company"
		If($xResult)
		{
			Return Get-RegistryValue "HKCU:\Software\Microsoft\Office\Common\UserInfo" "Company"
		}
		Else
		{
			Return ""
		}
	}
}

#http://stackoverflow.com/questions/5648931/test-if-registry-value-exists
# This Function just gets $True or $False
Function Test-RegistryValue($path, $name)
{
	$key = Get-Item -LiteralPath $path -EA 0
	$key -and $Null -ne $key.GetValue($name, $Null)
}

# Gets the specified registry value or $Null if it is missing
Function Get-RegistryValue($path, $name)
{
	$key = Get-Item -LiteralPath $path -EA 0
	If($key)
	{
		$key.GetValue($name, $Null)
	}
	Else
	{
		$Null
	}
}

Function line
#function created by Michael B. Smith, Exchange MVP
#@essentialexchange on Twitter
#http://TheEssentialExchange.com
#for creating the formatted text report
#created March 2011
#updated March 2014
{
	Param( [int]$tabs = 0, [string]$name = '', [string]$value = '', [string]$newline = "`r`n", [switch]$nonewline )
	While( $tabs -gt 0 ) { $Global:Output += "`t"; $tabs--; }
	If( $nonewline )
	{
		$Global:Output += $name + $value
	}
	Else
	{
		$Global:Output += $name + $value + $newline
	}
}
	
Function WriteWordLine
#Function created by Ryan Revord
#@rsrevord on Twitter
#Function created to make output to Word easy in this script
#updated 27-Mar-2014 to include font name, font size, italics and bold options
{
	Param([int]$style=0, 
	[int]$tabs = 0, 
	[string]$name = '', 
	[string]$value = '', 
	[string]$fontName=$Null,
	[int]$fontSize=0,
	[bool]$italics=$False,
	[bool]$boldface=$False,
	[Switch]$nonewline)
	
	#Build output style
	[string]$output = ""
	Switch ($style)
	{
		0 {$Script:Selection.Style = $myHash.Word_NoSpacing}
		1 {$Script:Selection.Style = $myHash.Word_Heading1}
		2 {$Script:Selection.Style = $myHash.Word_Heading2}
		3 {$Script:Selection.Style = $myHash.Word_Heading3}
		4 {$Script:Selection.Style = $myHash.Word_Heading4}
		Default {$Script:Selection.Style = $myHash.Word_NoSpacing}
	}
	
	#build # of tabs
	While($tabs -gt 0)
	{ 
		$output += "`t"; $tabs--; 
	}
 
	If(![String]::IsNullOrEmpty($fontName)) 
	{
		$Script:Selection.Font.name = $fontName
	} 

	If($fontSize -ne 0) 
	{
		$Script:Selection.Font.size = $fontSize
	} 
 
	If($italics -eq $True) 
	{
		$Script:Selection.Font.Italic = $True
	} 
 
	If($boldface -eq $True) 
	{
		$Script:Selection.Font.Bold = $True
	} 

	#output the rest of the parameters.
	$output += $name + $value
	$Script:Selection.TypeText($output)
 
	#test for new WriteWordLine 0.
	If($nonewline)
	{
		# Do nothing.
	} 
	Else 
	{
		$Script:Selection.TypeParagraph()
	}
}

Function _SetDocumentProperty 
{
	#jeff hicks
	Param([object]$Properties,[string]$Name,[string]$Value)
	#get the property object
	$prop = $properties | ForEach { 
		$propname=$_.GetType().InvokeMember("Name","GetProperty",$Null,$_,$Null)
		If($propname -eq $Name) 
		{
			Return $_
		}
	} #ForEach

	#set the value
	$Prop.GetType().InvokeMember("Value","SetProperty",$Null,$prop,$Value)
}

Function AbortScript
{
	$Word.quit()
	Write-Verbose "$(Get-Date): System Cleanup"
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Word) | Out-Null
	If(Test-Path variable:global:word)
	{
		Remove-Variable -Name word -Scope Global
	}
	[gc]::collect() 
	[gc]::WaitForPendingFinalizers()
	Write-Verbose "$(Get-Date): Script has been aborted"
	$ErrorActionPreference = $SaveEAPreference
	Exit
}

Function FindWordDocumentEnd
{
	#return focus to main document    
	$Script:Doc.ActiveWindow.ActivePane.view.SeekView = $wdSeekMainDocument
	#move to the end of the current document
	$Script:Selection.EndKey($wdStory,$wdMove) | Out-Null
}

<#
.Synopsis
	Add a table to a Microsoft Word document
.DESCRIPTION
	This function adds a table to a Microsoft Word document from either an array of
	Hashtables or an array of PSCustomObjects.

	Using this function is quicker than setting each table cell individually but can
	only utilise the built-in MS Word table autoformats. Individual tables cells can
	be altered after the table has been appended to the document (a table reference
	is returned).
.EXAMPLE
	AddWordTable -Hashtable $HashtableArray

	This example adds table to the MS Word document, utilising all key/value pairs in
	the array of hashtables. Column headers will display the key names as defined.
	Note: the columns might not be displayed in the order that they were defined. To
	ensure columns are displayed in the required order utilise the -Columns parameter.
.EXAMPLE
	AddWordTable -Hashtable $HashtableArray -List

	This example adds table to the MS Word document, utilising all key/value pairs in
	the array of hashtables. No column headers will be added, in a ListView format.
	Note: the columns might not be displayed in the order that they were defined. To
	ensure columns are displayed in the required order utilise the -Columns parameter.
.EXAMPLE
	AddWordTable -CustomObject $PSCustomObjectArray

	This example adds table to the MS Word document, utilising all note property names
	the array of PSCustomObjects. Column headers will display the note property names.
	Note: the columns might not be displayed in the order that they were defined. To
	ensure columns are displayed in the required order utilise the -Columns parameter.
.EXAMPLE
	AddWordTable -Hashtable $HashtableArray -Columns FirstName,LastName,EmailAddress

	This example adds a table to the MS Word document, but only using the specified
	key names: FirstName, LastName and EmailAddress. If other keys are present in the
	array of Hashtables they will be ignored.
.EXAMPLE
	AddWordTable -CustomObject $PSCustomObjectArray -Columns FirstName,LastName,EmailAddress -Headers "First Name","Last Name","Email Address"

	This example adds a table to the MS Word document, but only using the specified
	PSCustomObject note properties: FirstName, LastName and EmailAddress. If other note
	properties are present in the array of PSCustomObjects they will be ignored. The
	display names for each specified column header has been overridden to display a
	custom header. Note: the order of the header names must match the specified columns.
#>
Function AddWordTable
{
	[CmdletBinding()]
	Param
	(
		# Array of Hashtable (including table headers)
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='Hashtable', Position=0)]
		[ValidateNotNullOrEmpty()] [System.Collections.Hashtable[]] $Hashtable,
		# Array of PSCustomObjects
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='CustomObject', Position=0)]
		[ValidateNotNullOrEmpty()] [PSCustomObject[]] $CustomObject,
		# Array of Hashtable key names or PSCustomObject property names to include, in display order.
		# If not supplied then all Hashtable keys or all PSCustomObject properties will be displayed.
		[Parameter(ValueFromPipelineByPropertyName=$true)] [AllowNull()] [string[]] $Columns = $null,
		# Array of custom table header strings in display order.
		[Parameter(ValueFromPipelineByPropertyName=$true)] [AllowNull()] [string[]] $Headers = $null,
		# AutoFit table behavior.
		[Parameter(ValueFromPipelineByPropertyName=$true)] [AllowNull()] [int] $AutoFit = -1,
		# List view (no headers)
		[Switch] $List,
		# Grid lines
		[Switch] $NoGridLines=$false,
		# Built-in Word table formatting style constant
		# Would recommend only $wdTableFormatContempory for normal usage (possibly $wdTableFormatList5 for List view)
		[Parameter(ValueFromPipelineByPropertyName=$true)] [int] $Format = '-231'
	)

	Begin 
	{
		Write-Debug ("Using parameter set '{0}'" -f $PSCmdlet.ParameterSetName);
		## Check if -Columns wasn't specified but -Headers were (saves some additional parameter sets!)
		If(($Columns -eq $null) -and ($Headers -ne $null)) 
		{
			Write-Warning "No columns specified and therefore, specified headers will be ignored.";
			$Columns = $null;
		}
		ElseIf(($Columns -ne $null) -and ($Headers -ne $null)) 
		{
			## Check if number of specified -Columns matches number of specified -Headers
			If($Columns.Length -ne $Headers.Length) 
			{
				Write-Error "The specified number of columns does not match the specified number of headers.";
			}
		} ## end elseif
	} ## end Begin

	Process
	{
		## Build the Word table data string to be converted to a range and then a table later.
        [System.Text.StringBuilder] $WordRangeString = New-Object System.Text.StringBuilder;

		Switch ($PSCmdlet.ParameterSetName) 
		{
			'CustomObject' 
			{
				If($Columns -eq $null) 
				{
					## Build the available columns from all availble PSCustomObject note properties
					[string[]] $Columns = @();
					## Add each NoteProperty name to the array
					ForEach($Property in ($CustomObject | Get-Member -MemberType NoteProperty)) 
					{ 
						$Columns += $Property.Name; 
					}
				}

				## Add the table headers from -Headers or -Columns (except when in -List(view)
				If(-not $List) 
				{
					Write-Debug ("$(Get-Date): `t`tBuilding table headers");
					If($Headers -ne $null) 
					{
                        $WordRangeString.AppendFormat("{0}`n", [string]::Join("`t", $Headers));
					}
					Else 
					{ 
                        $WordRangeString.AppendFormat("{0}`n", [string]::Join("`t", $Columns));
					}
				}

				## Iterate through each PSCustomObject
				Write-Debug ("$(Get-Date): `t`tBuilding table rows");
				ForEach($Object in $CustomObject) 
				{
					$OrderedValues = @();
					## Add each row item in the specified order
					ForEach($Column in $Columns) 
					{ 
						$OrderedValues += $Object.$Column; 
					}
					## Use the ordered list to add each column in specified order
                    $WordRangeString.AppendFormat("{0}`n", [string]::Join("`t", $OrderedValues));
				} ## end foreach
				Write-Debug ("$(Get-Date): `t`t`tAdded '{0}' table rows" -f ($CustomObject.Count));
			} ## end CustomObject

			Default 
			{   ## Hashtable
				If($Columns -eq $null) 
				{
					## Build the available columns from all available hashtable keys. Hopefully
					## all Hashtables have the same keys (they should for a table).
					$Columns = $Hashtable[0].Keys;
				}

				## Add the table headers from -Headers or -Columns (except when in -List(view)
				If(-not $List) 
				{
					Write-Debug ("$(Get-Date): `t`tBuilding table headers");
					If($Headers -ne $null) 
					{ 
                        $WordRangeString.AppendFormat("{0}`n", [string]::Join("`t", $Headers));
					}
					Else 
					{
                        $WordRangeString.AppendFormat("{0}`n", [string]::Join("`t", $Columns));
					}
				}
                
				## Iterate through each Hashtable
				Write-Debug ("$(Get-Date): `t`tBuilding table rows");
				ForEach($Hash in $Hashtable) 
				{
					$OrderedValues = @();
					## Add each row item in the specified order
					ForEach($Column in $Columns) 
					{ 
						$OrderedValues += $Hash.$Column; 
					}
					## Use the ordered list to add each column in specified order
                    $WordRangeString.AppendFormat("{0}`n", [string]::Join("`t", $OrderedValues));
				} ## end foreach

				Write-Debug ("$(Get-Date): `t`t`tAdded '{0}' table rows" -f $Hashtable.Count);
			} ## end default
		} ## end switch

		## Create a MS Word range and set its text to our tab-delimited, concatenated string
		Write-Debug ("$(Get-Date): `t`tBuilding table range");
		$WordRange = $Script:Doc.Application.Selection.Range;
		$WordRange.Text = $WordRangeString.ToString();

		## Create hash table of named arguments to pass to the ConvertToTable method
		$ConvertToTableArguments = @{ Separator = [Microsoft.Office.Interop.Word.WdTableFieldSeparator]::wdSeparateByTabs; }

		## Negative built-in styles are not supported by the ConvertToTable method
		If($Format -ge 0) 
		{
			$ConvertToTableArguments.Add("Format", $Format);
			$ConvertToTableArguments.Add("ApplyBorders", $true);
			$ConvertToTableArguments.Add("ApplyShading", $true);
			$ConvertToTableArguments.Add("ApplyFont", $true);
			$ConvertToTableArguments.Add("ApplyColor", $true);
			If(!$List) 
			{ 
				$ConvertToTableArguments.Add("ApplyHeadingRows", $true); 
			}
			$ConvertToTableArguments.Add("ApplyLastRow", $true);
			$ConvertToTableArguments.Add("ApplyFirstColumn", $true);
			$ConvertToTableArguments.Add("ApplyLastColumn", $true);
		}

		## Invoke ConvertToTable method - with named arguments - to convert Word range to a table
		## See http://msdn.microsoft.com/en-us/library/office/aa171893(v=office.11).aspx
		Write-Debug ("$(Get-Date): `t`tConverting range to table");
		## Store the table reference just in case we need to set alternate row coloring
		$WordTable = $WordRange.GetType().InvokeMember(
			"ConvertToTable",                               # Method name
			[System.Reflection.BindingFlags]::InvokeMethod, # Flags
			$null,                                          # Binder
			$WordRange,                                     # Target (self!)
			([Object[]]($ConvertToTableArguments.Values)),  ## Named argument values
			$null,                                          # Modifiers
			$null,                                          # Culture
			([String[]]($ConvertToTableArguments.Keys))     ## Named argument names
		);

		## Implement grid lines (will wipe out any existing formatting
		If($Format -lt 0) 
		{
			Write-Debug ("$(Get-Date): `t`tSetting table format");
			$WordTable.Style = $Format;
		}

		## Set the table autofit behavior
		If($AutoFit -ne -1) 
		{ 
			$WordTable.AutoFitBehavior($AutoFit); 
		}

		#the next line causes the heading row to flow across page breaks
		$WordTable.Rows.First.Headingformat = $wdHeadingFormatTrue;

		If(!$NoGridLines) 
		{
			$WordTable.Borders.InsideLineStyle = $wdLineStyleSingle;
			$WordTable.Borders.OutsideLineStyle = $wdLineStyleSingle;
		}

		Return $WordTable;

	} ## end Process
}

<#
.Synopsis
	Sets the format of one or more Word table cells
.DESCRIPTION
	This function sets the format of one or more table cells, either from a collection
	of Word COM object cell references, an individual Word COM object cell reference or
	a hashtable containing Row and Column information.

	The font name, font size, bold, italic , underline and shading values can be used.
.EXAMPLE
	SetWordCellFormat -Hashtable $Coordinates -Table $TableReference -Bold

	This example sets all text to bold that is contained within the $TableReference
	Word table, using an array of hashtables. Each hashtable contain a pair of co-
	ordinates that is used to select the required cells. Note: the hashtable must
	contain the .Row and .Column key names. For example:
	@ { Row = 7; Column = 3 } to set the cell at row 7 and column 3 to bold.
.EXAMPLE
	$RowCollection = $Table.Rows.First.Cells
	SetWordCellFormat -Collection $RowCollection -Bold -Size 10

	This example sets all text to size 8 and bold for all cells that are contained
	within the first row of the table.
	Note: the $Table.Rows.First.Cells returns a collection of Word COM cells objects
	that are in the first table row.
.EXAMPLE
	$ColumnCollection = $Table.Columns.Item(2).Cells
	SetWordCellFormat -Collection $ColumnCollection -BackgroundColor 255

	This example sets the background (shading) of all cells in the table's second
	column to red.
	Note: the $Table.Columns.Item(2).Cells returns a collection of Word COM cells objects
	that are in the table's second column.
.EXAMPLE
	SetWordCellFormat -Cell $Table.Cell(17,3) -Font "Tahoma" -Color 16711680

	This example sets the font to Tahoma and the text color to blue for the cell located
	in the table's 17th row and 3rd column.
	Note: the $Table.Cell(17,3) returns a single Word COM cells object.
#>
Function SetWordCellFormat 
{
	[CmdletBinding(DefaultParameterSetName='Collection')]
	Param (
		# Word COM object cell collection reference
		[Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName='Collection', Position=0)] [ValidateNotNullOrEmpty()] $Collection,
		# Word COM object individual cell reference
		[Parameter(Mandatory=$true, ParameterSetName='Cell', Position=0)] [ValidateNotNullOrEmpty()] $Cell,
		# Hashtable of cell co-ordinates
		[Parameter(Mandatory=$true, ParameterSetName='Hashtable', Position=0)] [ValidateNotNullOrEmpty()] [System.Collections.Hashtable[]] $Coordinates,
		# Word COM object table reference
		[Parameter(Mandatory=$true, ParameterSetName='Hashtable', Position=1)] [ValidateNotNullOrEmpty()] $Table,
		# Font name
		[Parameter()] [AllowNull()] [string] $Font = $null,
		# Font color
		[Parameter()] [AllowNull()] $Color = $null,
		# Font size
		[Parameter()] [ValidateNotNullOrEmpty()] [int] $Size = 0,
		# Cell background color
		[Parameter()] [AllowNull()] $BackgroundColor = $null,
		# Force solid background color
		[Switch] $Solid,
		[Switch] $Bold,
		[Switch] $Italic,
		[Switch] $Underline
	)

	Begin 
	{
		Write-Debug ("Using parameter set '{0}'." -f $PSCmdlet.ParameterSetName);
	}

	Process 
	{
		Switch ($PSCmdlet.ParameterSetName) 
		{
			'Collection' {
				ForEach($Cell in $Collection) 
				{
					If($BackgroundColor -ne $null) { $Cell.Shading.BackgroundPatternColor = $BackgroundColor; }
					If($Bold) { $Cell.Range.Font.Bold = $true; }
					If($Italic) { $Cell.Range.Font.Italic = $true; }
					If($Underline) { $Cell.Range.Font.Underline = 1; }
					If($Font -ne $null) { $Cell.Range.Font.Name = $Font; }
					If($Color -ne $null) { $Cell.Range.Font.Color = $Color; }
					If($Size -ne 0) { $Cell.Range.Font.Size = $Size; }
					If($Solid) { $Cell.Shading.Texture = 0; } ## wdTextureNone
				} # end foreach
			} # end Collection
			'Cell' 
			{
				If($Bold) { $Cell.Range.Font.Bold = $true; }
				If($Italic) { $Cell.Range.Font.Italic = $true; }
				If($Underline) { $Cell.Range.Font.Underline = 1; }
				If($Font -ne $null) { $Cell.Range.Font.Name = $Font; }
				If($Color -ne $null) { $Cell.Range.Font.Color = $Color; }
				If($Size -ne 0) { $Cell.Range.Font.Size = $Size; }
				If($BackgroundColor -ne $null) { $Cell.Shading.BackgroundPatternColor = $BackgroundColor; }
				If($Solid) { $Cell.Shading.Texture = 0; } ## wdTextureNone
			} # end Cell
			'Hashtable' 
			{
				ForEach($Coordinate in $Coordinates) 
				{
					$Cell = $Table.Cell($Coordinate.Row, $Coordinate.Column);
					If($Bold) { $Cell.Range.Font.Bold = $true; }
					If($Italic) { $Cell.Range.Font.Italic = $true; }
					If($Underline) { $Cell.Range.Font.Underline = 1; }
					If($Font -ne $null) { $Cell.Range.Font.Name = $Font; }
					If($Color -ne $null) { $Cell.Range.Font.Color = $Color; }
					If($Size -ne 0) { $Cell.Range.Font.Size = $Size; }
					If($BackgroundColor -ne $null) { $Cell.Shading.BackgroundPatternColor = $BackgroundColor; }
					If($Solid) { $Cell.Shading.Texture = 0; } ## wdTextureNone
				}
			} # end Hashtable
		} # end switch
	} # end process
}

<#
.Synopsis
	Sets alternate row colors in a Word table
.DESCRIPTION
	This function sets the format of alternate rows within a Word table using the
	specified $BackgroundColor. This function is expensive (in performance terms) as
	it recursively sets the format on alternate rows. It would be better to pick one
	of the predefined table formats (if one exists)? Obviously the more rows, the
	longer it takes :'(

	Note: this function is called by the AddWordTable function if an alternate row
	format is specified.
.EXAMPLE
	SetWordTableAlternateRowColor -Table $TableReference -BackgroundColor 255

	This example sets every-other table (starting with the first) row and sets the
	background color to red (wdColorRed).
.EXAMPLE
	SetWordTableAlternateRowColor -Table $TableReference -BackgroundColor 39423 -Seed Second

	This example sets every other table (starting with the second) row and sets the
	background color to light orange (weColorLightOrange).
#>
Function SetWordTableAlternateRowColor 
{
	[CmdletBinding()]
	Param (
		# Word COM object table reference
		[Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)] [ValidateNotNullOrEmpty()] $Table,
		# Alternate row background color
		[Parameter(Mandatory=$true, Position=1)] [ValidateNotNull()] [int] $BackgroundColor,
		# Alternate row starting seed
		[Parameter(ValueFromPipelineByPropertyName=$true, Position=2)] [ValidateSet('First','Second')] [string] $Seed = 'First'
	)

	Process 
	{
		$StartDateTime = Get-Date;
		Write-Debug ("{0}: `t`tSetting alternate table row colors.." -f $StartDateTime);

		## Determine the row seed (only really need to check for 'Second' and default to 'First' otherwise
		If($Seed.ToLower() -eq 'second') 
		{ 
			$StartRowIndex = 2; 
		}
		Else 
		{ 
			$StartRowIndex = 1; 
		}

		For($AlternateRowIndex = $StartRowIndex; $AlternateRowIndex -lt $Table.Rows.Count; $AlternateRowIndex += 2) 
		{ 
			$Table.Rows.Item($AlternateRowIndex).Shading.BackgroundPatternColor = $BackgroundColor;
		}

		## I've put verbose calls in here we can see how expensive this functionality actually is.
		$EndDateTime = Get-Date;
		$ExecutionTime = New-TimeSpan -Start $StartDateTime -End $EndDateTime;
		Write-Debug ("{0}: `t`tDone setting alternate row style color in '{1}' seconds" -f $EndDateTime, $ExecutionTime.TotalSeconds);
	}
}


Function ShowScriptOptions
{
	Write-Verbose "$(Get-Date): "
	Write-Verbose "$(Get-Date): "
	Write-Verbose "$(Get-Date): Company Name : $($Script:CoName)"
	Write-Verbose "$(Get-Date): Cover Page   : $($CoverPage)"
	Write-Verbose "$(Get-Date): User Name    : $($UserName)"
	Write-Verbose "$(Get-Date): Save As PDF  : $($PDF)"
	Write-Verbose "$(Get-Date): Save As TEXT : $($TEXT)"
	Write-Verbose "$(Get-Date): Save As WORD : $($MSWORD)"
	Write-Verbose "$(Get-Date): Save As HTML : $($HTML)"
	Write-Verbose "$(Get-Date): Add DateTime : $($AddDateTime)"
	Write-Verbose "$(Get-Date): HW Inventory : $($Hardware)"
	Write-Verbose "$(Get-Date): Filename1    : $($Script:FileName1)"
	If($PDF)
	{
		Write-Verbose "$(Get-Date): Filename2    : $($Script:FileName2)"
	}
	Write-Verbose "$(Get-Date): OS Detected  : $($RunningOS)"
	Write-Verbose "$(Get-Date): PSUICulture  : $($PSUICulture)"
	Write-Verbose "$(Get-Date): PSCulture    : $($PSCulture)"
	Write-Verbose "$(Get-Date): Word version : $($Script:WordProduct)"
	Write-Verbose "$(Get-Date): Word language: $($Script:WordLanguageValue)"
	Write-Verbose "$(Get-Date): PoSH version : $($Host.Version)"
	Write-Verbose "$(Get-Date): "
	Write-Verbose "$(Get-Date): Script start : $($Script:StartTime)"
	Write-Verbose "$(Get-Date): "
	Write-Verbose "$(Get-Date): "
}

Function validStateProp( [object] $object, [string] $topLevel, [string] $secondLevel )
{
	#function created 8-jan-2014 by Michael B. Smith
	if( $object )
	{
		If( ( gm -Name $topLevel -InputObject $object ) )
		{
			If( ( gm -Name $secondLevel -InputObject $object.$topLevel ) )
			{
				Return $True
			}
		}
	}
	Return $False
}

Function SetupWord
{
	Write-Verbose "$(Get-Date): Setting up Word"
    
	# Setup word for output
	Write-Verbose "$(Get-Date): Create Word comObject.  If you are not running Word 2007, ignore the next message."
	$Script:Word = New-Object -comobject "Word.Application" -EA 0

	If(!$? -or $Script:Word -eq $Null)
	{
		Write-Warning "The Word object could not be created.  You may need to repair your Word installation."
		$ErrorActionPreference = $SaveEAPreference
		Write-Error "`n`n`t`tThe Word object could not be created.  You may need to repair your Word installation.`n`n`t`tScript cannot continue.`n`n"
		Exit
	}

	Write-Verbose "$(Get-Date): Determine Word language value"
	If( ( validStateProp $Script:Word Language Value__ ) )
	{
		[int]$Script:WordLanguageValue = [int]$Script:Word.Language.Value__
	}
	Else
	{
		[int]$Script:WordLanguageValue = [int]$Script:Word.Language
	}

	If(!($Script:WordLanguageValue -gt -1))
	{
		$ErrorActionPreference = $SaveEAPreference
		Write-Error "`n`n`t`tUnable to determine the Word language value.`n`n`t`tScript cannot continue.`n`n"
		AbortScript
	}
	Write-Verbose "$(Get-Date): Word language value is $($Script:WordLanguageValue)"
	
	$Script:WordCultureCode = GetCulture $Script:WordLanguageValue
	
	SetWordHashTable $Script:WordCultureCode
	
	[int]$Script:WordVersion = [int]$Script:Word.Version
	If($Script:WordVersion -eq $wdWord2013)
	{
		$Script:WordProduct = "Word 2013"
	}
	ElseIf($Script:WordVersion -eq $wdWord2010)
	{
		$Script:WordProduct = "Word 2010"
	}
	ElseIf($Script:WordVersion -eq $wdWord2007)
	{
		$Script:WordProduct = "Word 2007"
	}
	Else
	{
		$ErrorActionPreference = $SaveEAPreference
		Write-Error "`n`n`t`tYou are running an untested or unsupported version of Microsoft Word.`n`n`t`tScript will end.`n`n`t`tPlease send info on your version of Word to webster@carlwebster.com`n`n"
		AbortScript
	}

	If($PDF -and $Script:WordVersion -eq $wdWord2007)
	{
		Write-Verbose "$(Get-Date): Verify the Word 2007 Save As PDF add-in is installed"
		If(CheckWord2007SaveAsPDFInstalled)
		{
			Write-Verbose "$(Get-Date): The Word 2007 Save As PDF add-in is installed"
		}
		Else
		{
			AbortScript
		}
	}

	#only validate CompanyName if the field is blank
	If([String]::IsNullOrEmpty($CoName))
	{
		Write-Verbose "$(Get-Date): Company name is blank.  Retrieve company name from registry."
		$TmpName = ValidateCompanyName
		
		If([String]::IsNullOrEmpty($TmpName))
		{
			Write-Warning "`n`n`t`tCompany Name is blank so Cover Page will not show a Company Name."
			Write-Warning "`n`t`tCheck HKCU:\Software\Microsoft\Office\Common\UserInfo for Company or CompanyName value."
			Write-Warning "`n`t`tYou may want to use the -CompanyName parameter if you need a Company Name on the cover page.`n`n"
		}
		Else
		{
			$Script:CoName = $TmpName
			Write-Verbose "$(Get-Date): Updated company name to $($Script:CoName)"
		}
	}

	If($Script:WordCultureCode -ne "en-")
	{
		Write-Verbose "$(Get-Date): Check Default Cover Page for $($WordCultureCode)"
		[bool]$CPChanged = $False
		Switch ($Script:WordCultureCode)
		{
			'ca-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "LÃ­nia lateral"
						$CPChanged = $True
					}
				}

			'da-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Sidelinje"
						$CPChanged = $True
					}
				}

			'de-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Randlinie"
						$CPChanged = $True
					}
				}

			'es-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "LÃ­nea lateral"
						$CPChanged = $True
					}
				}

			'fi-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Sivussa"
						$CPChanged = $True
					}
				}

			'fr-'	{
					If($CoverPage -eq "Sideline")
					{
						If($Script:WordVersion -eq $wdWord2013)
						{
							$CoverPage = "Lignes latÃ©rales"
							$CPChanged = $True
						}
						Else
						{
							$CoverPage = "Ligne latÃ©rale"
							$CPChanged = $True
						}
					}
				}

			'nb-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Sidelinje"
						$CPChanged = $True
					}
				}

			'nl-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Terzijde"
						$CPChanged = $True
					}
				}

			'pt-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Linha Lateral"
						$CPChanged = $True
					}
				}

			'sv-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Sidlinje"
						$CPChanged = $True
					}
				}
		}

		If($CPChanged)
		{
			Write-Verbose "$(Get-Date): Changed Default Cover Page from Sideline to $($CoverPage)"
		}
	}

	Write-Verbose "$(Get-Date): Validate cover page $($CoverPage) for culture code $($Script:WordCultureCode)"
	[bool]$ValidCP = $False
	
	$ValidCP = ValidateCoverPage $Script:WordVersion $CoverPage $Script:WordCultureCode
	
	If(!$ValidCP)
	{
		$ErrorActionPreference = $SaveEAPreference
		Write-Verbose "$(Get-Date): Word language value $($Script:WordLanguageValue)"
		Write-Verbose "$(Get-Date): Culture code $($Script:WordCultureCode)"
		Write-Error "`n`n`t`tFor $($Script:WordProduct), $($CoverPage) is not a valid Cover Page option.`n`n`t`tScript cannot continue.`n`n"
		AbortScript
	}

	ShowScriptOptions

	$Script:Word.Visible = $Visible

	#http://jdhitsolutions.com/blog/2012/05/san-diego-2012-powershell-deep-dive-slides-and-demos/
	#using Jeff's Demo-WordReport.ps1 file for examples
	Write-Verbose "$(Get-Date): Load Word Templates"

	[bool]$Script:CoverPagesExist = $False
	[bool]$BuildingBlocksExist = $False

	$Script:Word.Templates.LoadBuildingBlocks()
	If($Script:WordVersion -eq $wdWord2007)
	{
		$BuildingBlocksCollection = $Script:Word.Templates | Where {$_.name -eq "Building Blocks.dotx"}
	}
	Else
	{
		#word 2010/2013
		$BuildingBlocksCollection = $Script:Word.Templates | Where {$_.name -eq "Built-In Building Blocks.dotx"}
	}

	Write-Verbose "$(Get-Date): Attempt to load cover page $($CoverPage)"
	$part = $Null

	$BuildingBlocksCollection | 
	ForEach{
		If ($_.BuildingBlockEntries.Item($CoverPage).Name -eq $CoverPage) 
		{
			$BuildingBlocks = $_
		}
	}        

	If($BuildingBlocks -ne $Null)
	{
		$BuildingBlocksExist = $True

		Try 
		{
			$part = $BuildingBlocks.BuildingBlockEntries.Item($CoverPage)
		}

		Catch
		{
			$part = $Null
		}

		If($part -ne $Null)
		{
			$Script:CoverPagesExist = $True
		}
	}

	If(!$Script:CoverPagesExist)
	{
		Write-Verbose "$(Get-Date): Cover Pages are not installed or the Cover Page $($CoverPage) does not exist."
		Write-Warning "Cover Pages are not installed or the Cover Page $($CoverPage) does not exist."
		Write-Warning "This report will not have a Cover Page."
	}

	Write-Verbose "$(Get-Date): Create empty word doc"
	$Script:Doc = $Script:Word.Documents.Add()
	If($Script:Doc -eq $Null)
	{
		Write-Verbose "$(Get-Date): "
		$ErrorActionPreference = $SaveEAPreference
		Write-Error "`n`n`t`tAn empty Word document could not be created.`n`n`t`tScript cannot continue.`n`n"
		AbortScript
	}

	$Script:Selection = $Script:Word.Selection
	If($Script:Selection -eq $Null)
	{
		Write-Verbose "$(Get-Date): "
		$ErrorActionPreference = $SaveEAPreference
		Write-Error "`n`n`t`tAn unknown error happened selecting the entire Word document for default formatting options.`n`n`t`tScript cannot continue.`n`n"
		AbortScript
	}

	#set Default tab stops to 1/2 inch (this line is not from Jeff Hicks)
	#36 = .50"
	$Script:Word.ActiveDocument.DefaultTabStop = 36

	#Disable Spell and Grammar Check to resolve issue and improve performance (from Pat Coughlin)
	Write-Verbose "$(Get-Date): Disable grammar and spell checking"
	#bug reported 1-Apr-2014 by Tim Mangan
	#save current options first before turning them off
	$Script:CurrentGrammarOption = $Script:Word.Options.CheckGrammarAsYouType
	$Script:CurrentSpellingOption = $Script:Word.Options.CheckSpellingAsYouType
	$Script:Word.Options.CheckGrammarAsYouType = $False
	$Script:Word.Options.CheckSpellingAsYouType = $False

	If($BuildingBlocksExist)
	{
		#insert new page, getting ready for table of contents
		Write-Verbose "$(Get-Date): Insert new page, getting ready for table of contents"
		$part.Insert($Script:Selection.Range,$True) | Out-Null
		$Script:Selection.InsertNewPage()

		#table of contents
		Write-Verbose "$(Get-Date): Table of Contents - $($myHash.Word_TableOfContents)"
		$toc = $BuildingBlocks.BuildingBlockEntries.Item($myHash.Word_TableOfContents)
		If($toc -eq $Null)
		{
			Write-Verbose "$(Get-Date): "
			Write-Verbose "$(Get-Date): Table of Content - $($myHash.Word_TableOfContents) could not be retrieved."
			Write-Warning "This report will not have a Table of Contents."
		}
		Else
		{
			$toc.insert($Script:Selection.Range,$True) | Out-Null
		}
	}
	Else
	{
		Write-Verbose "$(Get-Date): Table of Contents are not installed."
		Write-Warning "Table of Contents are not installed so this report will not have a Table of Contents."
	}

	#set the footer
	Write-Verbose "$(Get-Date): Set the footer"
	[string]$footertext = "Report created by $username"

	#get the footer
	Write-Verbose "$(Get-Date): Get the footer and format font"
	$Script:Doc.ActiveWindow.ActivePane.view.SeekView = $wdSeekPrimaryFooter
	#get the footer and format font
	$footers = $Script:Doc.Sections.Last.Footers
	ForEach ($footer in $footers) 
	{
		If($footer.exists) 
		{
			$footer.range.Font.name = "Calibri"
			$footer.range.Font.size = 8
			$footer.range.Font.Italic = $True
			$footer.range.Font.Bold = $True
		}
	} #end ForEach
	Write-Verbose "$(Get-Date): Footer text"
	$Script:Selection.HeaderFooter.Range.Text = $footerText

	#add page numbering
	Write-Verbose "$(Get-Date): Add page numbering"
	$Script:Selection.HeaderFooter.PageNumbers.Add($wdAlignPageNumberRight) | Out-Null

	FindWordDocumentEnd
	Write-Verbose "$(Get-Date):"
	#end of Jeff Hicks 
}

Function SaveandCloseDocumentandShutdownWord
{
	#bug fix 1-Apr-2014
	#reset Grammar and Spelling options back to their original settings
	$Script:Word.Options.CheckGrammarAsYouType = $Script:CurrentGrammarOption
	$Script:Word.Options.CheckSpellingAsYouType = $Script:CurrentSpellingOption

	Write-Verbose "$(Get-Date): Save and Close document and Shutdown Word"
	If($Script:WordVersion -eq $wdWord2007)
	{
		If($PDF)
		{
			Write-Verbose "$(Get-Date): Saving as DOCX file first before saving to PDF"
		}
		Else
		{
			Write-Verbose "$(Get-Date): Saving DOCX file"
		}
		If($AddDateTime)
		{
			$Script:FileName1 += "_$(Get-Date -f yyyy-MM-dd_HHmm).docx"
			If($PDF)
			{
				$Script:FileName2 += "_$(Get-Date -f yyyy-MM-dd_HHmm).pdf"
			}
		}
		Write-Verbose "$(Get-Date): Running Word 2007 and detected operating system $($RunningOS)"
		If($RunningOS.Contains("Server 2008 R2") -or $RunningOS.Contains("Server 2012"))
		{
			$SaveFormat = "microsoft.office.interop.word.WdSaveFormat" -as [type] 
			$Script:Doc.SaveAs($Script:FileName1, $SaveFormat)
			If($PDF)
			{
				Write-Verbose "$(Get-Date): Now saving as PDF"
				$SaveFormat = $wdSaveFormatPDF
				$Script:Doc.SaveAs($Script:FileName2, $SaveFormat)
			}
		}
		Else
		{
			#works for Server 2008 and Windows 7
			$saveFormat = [Enum]::Parse([Microsoft.Office.Interop.Word.WdSaveFormat], "wdFormatDocumentDefault")
			$Script:Doc.SaveAs([REF]$Script:FileName1, [ref]$SaveFormat)
			If($PDF)
			{
				Write-Verbose "$(Get-Date): Now saving as PDF"
				$saveFormat = [Enum]::Parse([Microsoft.Office.Interop.Word.WdSaveFormat], "wdFormatPDF")
				$Script:Doc.SaveAs([REF]$Script:FileName2, [ref]$saveFormat)
			}
		}
	}
	ElseIf($Script:WordVersion -eq $wdWord2010)
	{
		#the $saveFormat below passes StrictMode 2
		#I found this at the following two links
		#http://blogs.technet.com/b/bshukla/archive/2011/09/27/3347395.aspx
		#http://msdn.microsoft.com/en-us/library/microsoft.office.interop.word.wdsaveformat(v=office.14).aspx
		If($PDF)
		{
			Write-Verbose "$(Get-Date): Saving as DOCX file first before saving to PDF"
		}
		Else
		{
			Write-Verbose "$(Get-Date): Saving DOCX file"
		}
		If($AddDateTime)
		{
			$Script:FileName1 += "_$(Get-Date -f yyyy-MM-dd_HHmm).docx"
			If($PDF)
			{
				$Script:FileName2 += "_$(Get-Date -f yyyy-MM-dd_HHmm).pdf"
			}
		}
		$saveFormat = [Enum]::Parse([Microsoft.Office.Interop.Word.WdSaveFormat], "wdFormatDocumentDefault")
		$Script:Doc.SaveAs([REF]$Script:FileName1, [ref]$SaveFormat)
		If($PDF)
		{
			Write-Verbose "$(Get-Date): Now saving as PDF"
			$saveFormat = [Enum]::Parse([Microsoft.Office.Interop.Word.WdSaveFormat], "wdFormatPDF")
			$Script:Doc.SaveAs([REF]$Script:FileName2, [ref]$saveFormat)
		}
	}
	ElseIf($Script:WordVersion -eq $wdWord2013)
	{
		If($PDF)
		{
			Write-Verbose "$(Get-Date): Saving as DOCX file first before saving to PDF"
		}
		Else
		{
			Write-Verbose "$(Get-Date): Saving DOCX file"
		}
		If($AddDateTime)
		{
			$Script:FileName1 += "_$(Get-Date -f yyyy-MM-dd_HHmm).docx"
			If($PDF)
			{
				$Script:FileName2 += "_$(Get-Date -f yyyy-MM-dd_HHmm).pdf"
			}
		}
		Write-Verbose "$(Get-Date): Running Word 2013 and detected operating system $($RunningOS)"
		#$saveFormat = [Enum]::Parse([Microsoft.Office.Interop.Word.WdSaveFormat], "wdFormatDocumentDefault")
		$Script:Doc.SaveAs2([REF]$Script:FileName1, [ref]$wdFormatDocumentDefault)
		If($PDF)
		{
			Write-Verbose "$(Get-Date): Now saving as PDF"
			#$saveFormat = [Enum]::Parse([Microsoft.Office.Interop.Word.WdSaveFormat], "wdFormatPDF")
			$Script:Doc.SaveAs([REF]$Script:FileName2, [ref]$wdFormatPDF)
		}
	}

	Write-Verbose "$(Get-Date): Closing Word"
	$Script:Doc.Close()
	$Script:Word.Quit()
	If($PDF)
	{
		Write-Verbose "$(Get-Date): Deleting $($Script:FileName1) since only $($Script:FileName2) is needed"
		Remove-Item $Script:FileName1
	}
	Write-Verbose "$(Get-Date): System Cleanup"
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Script:Word) | Out-Null
	If(Test-Path variable:global:word)
	{
		Remove-Variable -Name word -Scope Global
	}
	$SaveFormat = $Null
	[gc]::collect() 
	[gc]::WaitForPendingFinalizers()
}

Function SaveandCloseTextDocument
{
	If($AddDateTime)
	{
		$Script:FileName1 += "_$(Get-Date -f yyyy-MM-dd_HHmm).txt"
	}

	Write-Output $Global:Output | Out-File $Script:Filename1
}

Function SaveandCloseHTMLDocument
{
	If($AddDateTime)
	{
		$Script:FileName1 += "_$(Get-Date -f yyyy-MM-dd_HHmm).html"
	}
}

Function SetFileName1andFileName2
{
	Param([string]$OutputFileName)
	$pwdpath = $pwd.Path

	If($pwdpath.EndsWith("\"))
	{
		#remove the trailing \
		$pwdpath = $pwdpath.SubString(0, ($pwdpath.Length - 1))
	}

	#set $filename1 and $filename2 with no file extension
	If($AddDateTime)
	{
		[string]$Script:FileName1 = "$($pwdpath)\$($OutputFileName)"
		If($PDF)
		{
			[string]$Script:FileName2 = "$($pwdpath)\$($OutputFileName)"
		}
	}

	If($MSWord -or $PDF)
	{
		CheckWordPreReq

		If(!$AddDateTime)
		{
			[string]$Script:FileName1 = "$($pwdpath)\$($OutputFileName).docx"
			If($PDF)
			{
				[string]$Script:FileName2 = "$($pwdpath)\$($OutputFileName).pdf"
			}
		}

		SetupWord
	}
	ElseIf($Text)
	{
		If(!$AddDateTime)
		{
			[string]$Script:FileName1 = "$($pwdpath)\$($OutputFileName).txt"
		}
	}
	ElseIf($HTML)
	{
		If(!$AddDateTime)
		{
			[string]$Script:FileName1 = "$($pwdpath)\$($OutputFileName).html"
		}
	}
}

#Script begins

$script:startTime = Get-Date

#The function SetFileName1andFileName2 needs your script output filename
SetFileName1andFileName2 "ADHealthCheck"

#change title for your report
[string]$Script:Title = "Active Directory Health Check"

###REPLACE AFTER THIS SECTION WITH YOUR SCRIPT###

function Split-IntoGroups {
    # Written by 'The Masked Avenger with the Cheetos'
    [CmdletBinding()]
    param (
        [parameter(mandatory=$true,position=0,valuefrompipeline=$true)][Object[]]$InputObject,
        [parameter(mandatory=$false,position=1)][ValidateRange(1, ([int]::MaxValue))][int]$Number=10000
    )
    begin {
        $currentGroup = New-Object System.Collections.ArrayList($Number)
    } process {
        foreach ($object in $InputObject) {
            $index = $currentGroup.Add($object)
            if ($index -ge $Number - 1) {
                ,$currentGroup.ToArray()
                $currentGroup.Clear()
            }
        }
    } end {
        if ($currentGroup.Count -gt 0) {
            ,$currentGroup.ToArray()
        }
    }
}

Function Generate-CheckListResults {
    [cmdletbinding()]
    param (
        [parameter()]$Name,
        [parameter()]$Count
    )
    $Object = New-Object -TypeName PSObject
    $Object | Add-Member -MemberType NoteProperty -Name 'Check' -value $Name
    $Object | Add-Member -MemberType NoteProperty -Name 'Results' -value $Count
    $Object
}

function Write-ToCSV {
    [cmdletbinding()]
    param (
        [parameter(mandatory=$false,position=2)][string]$Path=$($Script:ThisScriptPath),
        [parameter(mandatory=$true,position=1)][string]$Name,
        [parameter(mandatory=$true,position=0,valuefrompipeline=$true)]$Content
    )
    $Script:CSVList += "$Path\$Name.csv"
    try {
        $Content | ConvertTo-Csv | Out-File "$Path\$Name.csv"
        Write-Verbose "$([datetime]::now):      Writing '$Path\$Name.csv'"
    } catch {
        Write-Verbose "$([datetime]::now):      Error writing '$Path\$Name.csv'"
    }
}

function Write-ToWord {
    [cmdletbinding()]
    param (
        [parameter(mandatory=$true,position=0)]$TableContent,
        [parameter(mandatory=$true,position=1)][string]$Name
    )
    Write-Verbose "$([datetime]::now):      Writing '$Name' to Word"
    WriteWordLine -Style 3 -Tabs 0 -Name $Name
    FindWordDocumentEnd
    $TableContent | Split-IntoGroups | foreach {
        AddWordTable -CustomObject ($TableContent) | Out-Null
        FindWordDocumentEnd
        WriteWordLine -Style 0 -Tabs 0 -Name ''
    }
    WriteWordLine -Style 0 -Tabs 0 -Name ''
}

function ConvertTo-FQDN {
    param (
        [parameter(mandatory=$true,position=1)]$domainFQDN
    )
    $Split = $DomainFQDN.Split(".")
    $DomainDN = ''
    $FQDNlength = $Split.length
    for ($i=0;$i -lt ($FQDNlength);$i++) {
        [string]$DomainDN += "DC=" + $Split[$i] + ','
    }
    $DomainDN.Substring(0,$DomainDN.Length-1)
}

function Get-ADDomains {
    $Domains = ([System.DirectoryServices.ActiveDirectory.forest]::GetCurrentForest().domains)
    foreach ($Domain in $Domains) {
        $DomName = $Domain.Name
        $ADObject = [adsi]"LDAP://$DomName"
        $Object = New-Object -TypeName PSObject
        $Object | Add-Member -MemberType NoteProperty -Name 'Name' -Value $(ConvertTo-FQDN $Domain.Name)
        $Object | Add-Member -MemberType NoteProperty -Name 'FQDN' -Value $Domain.Name
        $Object | Add-Member -MemberType NoteProperty -Name 'ObjectSID' -Value $(New-Object System.Security.Principal.SecurityIdentifier($ADObject.objectSid[0], 0)).Value
        $Object
    }
}

function Get-PriviledgedGroupsMemberCount {
    param (
        [parameter(mandatory=$true,position=0,ValueFromPipeline=$true)]$Domains
    )
    foreach ($Domain in $Domains) {
        $DomainSIDValue = $Domain.ObjectSID
        $DomainName = $Domain.Name
        $PriviledgedGroups = @("S-1-5-32-544";"S-1-5-32-548";"S-1-5-32-549";"S-1-5-32-551";"$DomainSIDValue-519";"$DomainSIDValue-518")
        foreach ($PriviledgedGroup in $PriviledgedGroups) {
            $Source = New-Object DirectoryServices.DirectorySearcher("LDAP://$DomainName")
            $source.SearchScope = 'Subtree'
            $source.PageSize = 100000
            $Source.filter = "(objectSID=$PriviledgedGroup)"
            $Groups = $Source.FindAll()
            foreach ($Group in $Groups) {
                $DistinguishedName = $($Group.Properties.Item("distinguishedname"))
                $Source.Filter = "(memberOf:1.2.840.113556.1.4.1941:=$DistinguishedName)"
                $Users = try {$Source.FindAll()} catch {}
                if ($Users -ne $null) {
                    $Object = New-Object -TypeName PSObject
                    $Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $Domain.FQDN
                    $Object | Add-Member -MemberType NoteProperty -Name 'Group' -Value $($Group.Properties.Item("Name"))
                    $Members = $Users | Where-Object {$_.Properties.Item("objectclass") -contains 'user'}
                    if ($Members -ne $null) {
                        [array]$UserMembers = $Members | Where-Object {$_.Properties.Item("objectclass") -contains 'user'}
                        if ($UserMembers -ne $null) {
                            if (($UserMembers).Count -ne $null) {
                                [int]$Count = ($UserMembers).Count
                            } else {
                                [int]$Count = 0
                            }
                        }
                    } else {
                        [int]$Count = 0
                    }
                    $Object | Add-Member -MemberType NoteProperty -Name 'Members' -Value $Count
                    $Object
                }
            }
        }
    }
}

function Get-AllADDomainControllers {
    [cmdletbinding()]
    param (
        [parameter(mandatory=$true,position=0,ValueFromPipeline=$true)]$Domain
    )
    $DomainName = $Domain.Name
    $adsiSearcher = New-Object DirectoryServices.DirectorySearcher("LDAP://$DomainName")
    $adsiSearcher.filter = "(&(objectCategory=computer)(userAccountControl:1.2.840.113556.1.4.803:=8192))"
    $Servers = $adsiSearcher.findall() 
    foreach ($Server in $Servers) {
        $Object = New-Object -TypeName 'PSObject'
        $Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
        $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -Value $($Server.Properties.item('name'))
        $Object | Add-Member -MemberType 'NoteProperty' -Name 'LastContact' -Value $($Server.Properties.item('whenchanged'))
        $Object
    }
}

function Get-AllADMemberServers {
	[cmdletbinding()]
    param (
        [parameter(mandatory=$true,position=0,ValueFromPipeline=$true)]$Domain
    )
	$DomainName = $Domain.Name
    $adsiSearcher = New-Object DirectoryServices.DirectorySearcher("LDAP://$DomainName")
    $adsiSearcher.filter = "(&(objectCategory=computer)(operatingSystem=*server*)(!(userAccountControl:1.2.840.113556.1.4.803:=8192)))"
    $Servers = $adsiSearcher.findall() 
    foreach ($Server in $Servers) {
        $Object = New-Object -TypeName 'PSObject'
		$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
        $Object | Add-Member -MemberType 'NoteProperty' -Name 'ComputerName' -Value $($Server.Properties.item('name'))
        $Object
    }
}

function Get-AllADMemberServerObjects {
    [cmdletbinding()]
    param (
        [parameter(mandatory=$true,parametersetname='PasswordNeverExpires')][switch]$PasswordNeverExpires,
        [parameter(mandatory=$true,parametersetname='PasswordExpiration')][int]$PasswordExpiration,
        [parameter(mandatory=$true,parametersetname='AccountNeverExpires')][switch]$AccountNeverExpires,
        [parameter(mandatory=$true,parametersetname='Disabled')][switch]$Disabled,
		[parameter(mandatory=$true,position=1,ValueFromPipeline=$true,parametersetname='PasswordNeverExpires')]
		[parameter(mandatory=$true,position=1,ValueFromPipeline=$true,parametersetname='PasswordExpiration')]
		[parameter(mandatory=$true,position=1,ValueFromPipeline=$true,parametersetname='AccountNeverExpires')]
		[parameter(mandatory=$true,position=1,ValueFromPipeline=$true,parametersetname='Disabled')]
		$Domain
    )
	$DomainName = $Domain.Name
    $source = New-Object system.directoryservices.directorysearcher("LDAP://$DomainName")
    $source.SearchScope = "Subtree"
    $source.PageSize = 100000
    switch ($PSCmdlet.ParameterSetName) {
        "PasswordNeverExpires" {
            $source.filter = "(&(objectCategory=computer)(operatingSystem=*server*)(!(userAccountControl:1.2.840.113556.1.4.803:=8192))(userAccountControl:1.2.840.113556.1.4.803:=65536))"
        }
        "PasswordExpiration" {
            $source.filter = "(&(objectCategory=computer)(operatingSystem=*server*)(!(userAccountControl:1.2.840.113556.1.4.803:=8192)))"
        }
        "AccountNeverExpires" {
            $source.filter = "(&(objectCategory=computer)(operatingSystem=*server*)(!(userAccountControl:1.2.840.113556.1.4.803:=8192))(|(accountExpires=0)(accountExpires=9223372036854775807)))"
        }
        "Disabled" {
            $source.filter = "(&(objectCategory=computer)(operatingSystem=*server*)(!(userAccountControl:1.2.840.113556.1.4.803:=8194)))"
        }
    }
    if ($PSCmdlet.ParameterSetName -eq 'PasswordExpiration') {
        try {
            $source.findall() | foreach {
                if (([datetime]::fromfiletime($_.properties.pwdlastset[0]) -lt ([datetime]::Now).addmonths(-$PasswordExpiration)) -and ([datetime]::fromfiletime($_.properties.pwdlastset[0]) -ne $null)) {
                    $Object = New-Object -TypeName 'PSObject'
			    	$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
                    $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -value $($_.properties.item("name"))
                    $Object | Add-Member -MemberType 'NoteProperty' -Name 'PasswordLastSet' -value ([datetime]::fromfiletime($_.properties.pwdlastset[0]))
                    $Object
                }
            }     
        }catch {
        }
    } else {
        try {
            $source.findall() | foreach {
                $Object = New-Object -TypeName 'PSObject'
		    	$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -value $($_.properties.item("name"))
                $Object
            }
        } catch {
        }
    }
}

function Get-ADUserObjects {
    [cmdletbinding()]
    param (
        [parameter(mandatory=$true,parametersetname='PasswordNeverExpires')][switch]$PasswordNeverExpires,
        [parameter(mandatory=$true,parametersetname='PasswordNotRequired')][switch]$PasswordNotRequired,
        [parameter(mandatory=$true,parametersetname='PasswordChangeAtNextLogon')][switch]$PasswordChangeAtNextLogon,
        [parameter(mandatory=$true,parametersetname='PasswordExpiration')][int]$PasswordExpiration,
        [parameter(mandatory=$true,parametersetname='NotRequireKerbereosAuthentication')][switch]$NotRequireKerbereosAuthentication,
        [parameter(mandatory=$true,parametersetname='AccountNoExpire')][switch]$AccountNoExpire,
        [parameter(mandatory=$true,parametersetname='Disabled')][switch]$Disabled,
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true,parametersetname='PasswordNeverExpires')]
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true,parametersetname='PasswordNotRequired')]
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true,parametersetname='PasswordChangeAtNextLogon')]
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true,parametersetname='PasswordExpiration')]
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true,parametersetname='NotRequireKerbereosAuthentication')]
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true,parametersetname='AccountNoExpire')]
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true,parametersetname='Disabled')]
		$Domain
    )
	$DomainName = $Domain.Name
    $source = New-Object system.directoryservices.directorysearcher("LDAP://$DomainName")
    $source.searchscope = [system.directoryservices.searchscope]::Base
    $source.SearchScope = "Subtree"
    $source.PageSize = 100000
    switch ($PSCmdlet.ParameterSetName) {
        "PasswordNeverExpires" {
            $source.filter = "(&(sAMAccountType=805306368)(userAccountControl:1.2.840.113556.1.4.803:=65536))"
        }
        "PasswordNotRequired" {
            $source.filter = "(&(sAMAccountType=805306368)(userAccountControl:1.2.840.113556.1.4.803:=32))"
        }
        "PasswordChangeAtNextLogon" {
            $source.filter = "(&(sAMAccountType=805306368)(pwdLastSet=0))"
        }
        "PasswordExpiration" {
            $source.filter = "(&(sAMAccountType=805306368)(pwdLastSet>=0))"
        }
        "NotRequireKerbereosAuthentication" {
            $source.filter = "(&(sAMAccountType=805306368)(userAccountControl:1.2.840.113556.1.4.803:=4194304))"
        }
        "AccountNoExpire" {
            $source.filter = "(&(sAMAccountType=805306368)(|(accountExpires=0)(accountExpires=9223372036854775807)))"
        }
        "Disabled" {
            $source.filter = "(&(sAMAccountType=805306368)(userAccountControl:1.2.840.113556.1.4.803:=2))"
        }
    }
    if ($PSCmdlet.ParameterSetName -eq 'PasswordExpiration') {
        try {
            $source.findall() | foreach {
                if (([datetime]::fromfiletime($_.properties.pwdlastset[0]) -lt ([datetime]::Now).addmonths(-$PasswordExpiration)) -and ([datetime]::fromfiletime($_.properties.pwdlastset[0]) -ne $null)) {
                    $Object = New-Object -TypeName 'PSObject'
			    	$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
                    $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -value $($_.properties.item("name"))
                    $Object | Add-Member -MemberType 'NoteProperty' -Name 'PasswordLastSet' -value ([datetime]::fromfiletime($_.properties.pwdlastset[0]))
                    $Object
                }
            }
        } catch {
        }
    } else {
        try {
            $source.findall() | foreach {
                $Object = New-Object -TypeName 'PSObject'
		    	$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -value $($_.properties.item("name"))
                $Object
            }
        } catch {
        }
    }
}

function Get-OUGPInheritanceBlocked {
	[cmdletbinding()]
	param (
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true)]$Domain
	)
	$DomainName = $Domain.Name
    $source = New-Object System.DirectoryServices.DirectorySearcher("LDAP://$DomainName")
    $source.SearchScope = 'Subtree'
    $source.PageSize = 100000
    $source.filter = "(&(objectclass=OrganizationalUnit)(gpoptions=1))"
    try {
        $source.findall() | foreach { 
            $Object = New-Object -TypeName 'PSObject'
            $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -Value $($_.Properties.Item("Name"))
            $Object
        }
    } catch {
    }
}

function Get-ADSites {
	[cmdletbinding()]
	param (
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true)]$Domain
	)
	$DomainName = $Domain.Name
    $ADEntry = [system.directoryservices.directoryentry]([ADSI]"LDAP://$DomainName")
    $source = New-Object System.DirectoryServices.DirectorySearcher
    $source.SearchScope = 'Subtree'
    $source.SearchRoot = "LDAP://CN=Sites,CN=Configuration,$DomainName"
    $source.PageSize = 100000
    $source.filter = "(objectclass=site)"
    try {
        $source.findall() | foreach {
            $Object = New-Object -TypeName 'PSObject'
		    $Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
            $Object | Add-Member -MemberType 'NoteProperty' -Name 'Site' -Value $($_.properties.item("Name"))
            $Object | Add-Member -MemberType 'NoteProperty' -Name 'Description' -Value $($_.properties.item("Description"))
            $Object | Add-Member -MemberType 'NoteProperty' -Name 'Subnets' -Value ($($_.Properties.Item("siteObjectBL") -split ',' -replace 'CN=','')[0])
            $Object
        }
    } catch {
    }
}

function Get-ADSiteServer {
	[cmdletbinding()]
    param (
        [parameter(mandatory=$true,position=0,ValueFromPipeline=$true)]$Domain,
		[parameter(mandatory=$true)]$Site
    )
	$DomainName = $Domain.Name
    $ADEntry = [system.directoryservices.directoryentry]([ADSI]"LDAP://$DomainName")
    $source = New-Object System.DirectoryServices.DirectorySearcher
    $source.SearchRoot = "LDAP://CN=Servers,CN=$Site,CN=Sites,CN=Configuration,$DomainName"
    $source.SearchScope = 'Subtree'
    $source.PageSize = 100000
    $source.filter = "(objectclass=server)"
    try {
        $SiteServers = $source.findall()
        if ($SiteServers -ne $null) {
            foreach ($SiteServer in $SiteServers) {
                $Object = New-Object -TypeName 'PSObject'
    			$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'Site' -Value $Site
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -Value $($SiteServer.properties.item("Name"))
                $Object
            }
        } else {
            $Object = New-Object -TypeName 'PSObject'
    		$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
            $Object | Add-Member -MemberType 'NoteProperty' -Name 'Site' -Value $Site
            $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -Value ''
            $Object            
        }
    } catch {
    }
}

function Get-ADSiteConnection {
	[cmdletbinding()]
    param (
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true)]$Domain,
        [parameter(mandatory=$true)]$Site
    )
    $DomainName = $Domain.Name
    $ADEntry = [system.directoryservices.directoryentry]([ADSI]"LDAP://$DomainName")
    $source = New-Object System.DirectoryServices.DirectorySearcher
    $source.SearchRoot = "LDAP://CN=$Site,CN=Sites,CN=Configuration,$DomainName"
    $source.SearchScope = 'Subtree'
    $source.PageSize = 100000
    $source.filter = "(objectclass=nTDSConnection)"
    try {
        $SiteConnections = $source.findall()
        if ($SiteConnections -ne $null) {
            foreach ($SiteConnection in $SiteConnections) {
                $Object = New-Object -TypeName 'PSObject'
    			$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'Site' -Value $Site
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -Value $($SiteConnection.Properties.Item("Name"))
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'FromServer' -Value $($SiteConnection.Properties.Item("fromserver") -split ',' -replace 'CN=','')[3]
                $Object
            }
        } else {
            $Object = New-Object -TypeName 'PSObject'
		    $Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
            $Object | Add-Member -MemberType 'NoteProperty' -Name 'Site' -Value $Site
            $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -Value ''
            $Object | Add-Member -MemberType 'NoteProperty' -Name 'FromServer' -Value ''
            $Object        
        }
    } catch {
    }
}

function Get-ADSiteLink {
	[cmdletbinding()]
    param (
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true)]$Domain
	)
    $DomainName = $Domain.Name
    $ADEntry = [system.directoryservices.directoryentry]([ADSI]"LDAP://$DomainName")
    $source = New-Object System.DirectoryServices.DirectorySearcher
    $source.SearchRoot = "LDAP://CN=Sites,CN=Configuration,$DomainName"
    $source.SearchScope = 'Subtree'
    $source.PageSize = 100000
    $source.filter = "(objectclass=sitelink)"
    try {
        $SiteLinks = $source.findall()
        foreach ($SiteLink in $SiteLinks) {
    	    $Sites = ($SiteLink.Properties.item("sitelist") -split ',' -replace 'CN=','')[0]
            if ($Sites -ne $null) {
            	foreach ($Site in $Sites) {
                	$Object = New-Object -TypeName 'PSObject'
			    	$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
                    $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -Value $($SiteLink.properties.item("name"))
                    $Object | Add-Member -MemberType 'NoteProperty' -Name 'Description' -Value $($SiteLink.properties.item("Description"))
                    $Object | Add-Member -MemberType 'NoteProperty' -Name 'ReplicationInterval' -Value $($SiteLink.properties.item("replinterval"))
                    $Object | Add-Member -MemberType 'NoteProperty' -Name 'Site' -Value $(($SiteLink.Properties.item("sitelist") -split ',' -replace 'CN=','')[0])
                    $Object | Add-Member -MemberType 'NoteProperty' -Name 'SiteCount' -Value ($SiteLink.Properties.item("sitelist")).count
                    $Object
                }
            } else {
            	$Object = New-Object -TypeName 'PSObject'
			    $Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -Value $($SiteLink.properties.item("name"))
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'Description' -Value $($SiteLink.properties.item("Description"))
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'ReplicationInterval' -Value $($SiteLink.properties.item("replinterval"))
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'Site' -Value ''
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'SiteCount' -Value '0'
                $Object
            }
        }
    } catch {
    }
}

function Get-ADSiteSubnet {
	[cmdletbinding()]
	param (
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true)]$Domain
	)
	$DomainName = $Domain.Name
    $ADEntry = [system.directoryservices.directoryentry]([ADSI]"LDAP://$DomainName")
    $source = New-Object System.DirectoryServices.DirectorySearcher
    $source.SearchRoot = "LDAP://CN=Subnets,CN=Sites,CN=Configuration,$DomainName"
    $source.SearchScope = 'Subtree'
    $source.PageSize = 100000
    $source.filter = "(objectclass=subnet)"
    try {
        $source.findall() | foreach {
            $Object = New-Object -TypeName 'PSObject'
		    $Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
            $Object | Add-Member -MemberType 'NoteProperty' -Name 'Site' -Value $(($_.Properties.item("SiteObject") -split ',' -replace 'CN=','')[0])
            $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -Value $($_.properties.item("Name"))
            $Object | Add-Member -MemberType 'NoteProperty' -Name 'Description' -Value $($_.properties.item("Description"))
            $Object
        }
    } catch {
    }
}

function Get-ADEmptyGroups {
	[cmdletbinding()]
	param (
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true)]$Domain
	)
	$DomainName = $Domain.Name
    $source = New-Object DirectoryServices.DirectorySearcher("LDAP://$DomainName")
    $source.SearchScope = 'Subtree'
    $source.PageSize = 100000
    $source.filter = "(&(objectCategory=group)(!(groupType:1.2.840.113556.1.4.803:=1)))"
    try {
        $source.findall() | foreach {
            if (($($_.Properties.Item('Member'))) -eq $null) {
                $Object = New-Object -TypeName 'PSObject'
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -Value $($_.Properties.Item('Name'))
                $Object
            }
        }
    } catch {
    }
}

function Get-ADDomainLocalGroups {
	[cmdletbinding()]
	param (
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true)]$Domain
	)
	$DomainName = $Domain.Name
    $search = New-Object system.directoryservices.directorysearcher("LDAP://$DomainName")
    $search.SearchScope = "Subtree"
    $search.PageSize = 100000
    $search.filter = "(&(groupType:1.2.840.113556.1.4.803:=4)(!(groupType:1.2.840.113556.1.4.803:=1)))"
    try {
        $search.findall() | foreach {
            $Object = New-Object -TypeName 'PSObject'
    		$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
            $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -value $($_.properties.item("name"))
            $Object | Add-Member -MemberType 'NoteProperty' -Name 'DistinguishedName' -value $($_.properties.item("distinguishedname"))
            $Object
        }
    } catch {
    }
}

function Get-ADUsersInDomainLocalGroups {
    [cmdletbinding()]
    param (
		[parameter(mandatory=$true,position=0,ValueFromPipeline=$true)]$Domain
    )
    $DomainName = $Domain.Name
    $search = New-Object DirectoryServices.DirectorySearcher("LDAP://$DomainName")
    $search.SearchScope = "Subtree"
    $search.PageSize = 100000
    $search.Filter = "(&(groupType:1.2.840.113556.1.4.803:=4)(!(groupType:1.2.840.113556.1.4.803:=1)))"
    try {
        $search.FindAll() | foreach {
            $GroupName = $($_.Properties.Item("Name"))
            $DistinguishedName = $($_.Properties.Item("DistinguishedName"))
            $search.filter = "(&(memberOf=$DistinguishedName)(objectclass=User))"
            $search.findall() | foreach {
                $Object = New-Object -TypeName 'PSObject'
    	    	$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'Group' -Value $GroupName
                $Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -value $($_.properties.item("name"))
                $Object
            }
        }
    } catch {
    }
}

#region Content
$Script:MgmtPage = @()
FindWordDocumentEnd
$Script:Selection.InsertNewPage()
Write-Verbose "$([datetime]::now): Get domains" 
$Domains = Get-ADDomains
if ($Domains -ne $null) {
    foreach ($Domain in $Domains) {
        $FQDN = $Domain.FQDN
        Write-Verbose "$(Get-Date): Domain $FQDN"
        WriteWordLine -Style 1 -Tabs 0 -Name "Domain $FQDN"
        FindWordDocumentEnd
        if (($PSBoundParameters.ContainsKey('Sites')) -or ($PSCmdlet.ParameterSetName -eq 'All')) {
            #Sites
            $Script:Selection.InsertNewPage()
            FindWordDocumentEnd
            Write-Verbose "$([datetime]::now):  Sites"
            WriteWordLine -Style 2 -Tabs 0 -Name 'Sites'
            FindWordDocumentEnd
            $TableContentTemp = Get-ADSites -Domain $Domain
            #Sites - Description empty
            $CheckTitle = 'Sites - Without a description'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            if ($TableContentTemp -ne $null) {
                $TableContent = $TableContentTemp | Where-Object {$_.Description -eq $null}
                if ($TableContent -ne $null) {
                    if ($PSBoundParameters.ContainsKey('CSV')) {
                        $TableContent | Write-ToCSV -Name $CheckTitle
                    }
                    Write-ToWord -Name $CheckTitle -TableContent $TableContent
                    if ($PSBoundParameters.ContainsKey('Mgmt')) {
                        $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                    }
                }
                #Sites - No subnet
                $CheckTitle = 'Sites - Without one or more subnet(s)'
                Write-Verbose "$([datetime]::now):   $CheckTitle"
                $TableContent = $TableContentTemp | Where-Object {$_.Subnets -eq $null}
                if ($TableContent -ne $null) {
                    if ($PSBoundParameters.ContainsKey('CSV')) {
                        $TableContent | Write-ToCSV -Name $CheckTitle
                    }
                    Write-ToWord -Name $CheckTitle -TableContent $TableContent
                    if ($PSBoundParameters.ContainsKey('Mgmt')) {
                        $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                    }
                }
                #Sites - No server
                $CheckTitle = 'Sites - No server(s)'
                Write-Verbose "$([datetime]::now):   $CheckTitle"
                $TableContent = $TableContentTemp | foreach { Get-ADSiteServer -Site $_.Site -Domain $Domain } | Where-Object {$_.Name -eq $null}
                if ($TableContent -ne $null) {
                    if ($PSBoundParameters.ContainsKey('CSV')) {
                        $TableContent | Write-ToCSV -Name $CheckTitle
                    }
                    Write-ToWord -Name $CheckTitle -TableContent $TableContent
                    if ($PSBoundParameters.ContainsKey('Mgmt')) {
                        $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                    }
                }
                #Sites - No connection
                $CheckTitle = 'Sites - Without a connection'
                Write-Verbose "$([datetime]::now):   $CheckTitle"
                $TableContent = $TableContentTemp | foreach { Get-ADSiteConnection -Site $_.site -Domain $Domain } | Where-Object {$_.Name -eq $null}
                WriteWordLine -Style 3 -Tabs 0 -Name $CheckTitle
                FindWordDocumentEnd
                if ($TableContent -ne $null) {
                    if ($PSBoundParameters.ContainsKey('CSV')) {
                        $TableContent | Write-ToCSV -Name $CheckTitle
                    }
                    Write-ToWord -Name $CheckTitle -TableContent $TableContent
                    if ($PSBoundParameters.ContainsKey('Mgmt')) {
                        $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                    }
                }
                WriteWordLine -Style 0 -Tabs 0 -Name ''
                FindWordDocumentEnd
            }
            #Sites - No sitelink
            $CheckTitle = 'Sites - No sitelink(s)'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-ADSiteLink -Domain $Domain | Where-Object {$_.SiteCount -eq '0'}
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            #Sitelinks - One site
            $CheckTitle = 'Sites - With one sitelink'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-ADSiteLink -Domain $Domain | Where-Object {$_.SiteCount -eq '1'}
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            #Sitelinks - More than two sites
            $CheckTitle = 'SiteLinks - More than two sitelinks'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-ADSiteLink -Domain $Domain | Where-Object {$_.SiteCount -gt '2'}
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            #Sitelinks - No description
            $CheckTitle = 'SiteLinks - Without a description'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-ADSiteLink -Domain $Domain | Where-Object {$_.Description -eq $null}
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            #ADSubnets - Available but not in use
            $CheckTitle = 'Subnets in Sites - Not in use'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $AvailableSubnets = Get-ADSiteSubnet -Domain $Domain | select -ExpandProperty 'name'
            $InUseSubnets = Get-ADSites -Domain $Domain | select -ExpandProperty 'subnets'
            if (($AvailableSubnets -ne $Null) -and ($InUseSubnets -ne $null)) {
                $TableContent = Compare-Object -DifferenceObject $InUseSubnets -ReferenceObject $AvailableSubnets
                if ($TableContent -ne $null) {
                    if ($PSBoundParameters.ContainsKey('CSV')) {
                        $TableContent | Write-ToCSV -Name $CheckTitle
                    }
                    Write-ToWord -Name $CheckTitle -TableContent $TableContent
                    if ($PSBoundParameters.ContainsKey('Mgmt')) {
                        $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                    }
                }
            }
        }
        if (($PSBoundParameters.ContainsKey('OrganisationalUnit')) -or ($PSCmdlet.ParameterSetName -eq 'All')) {
            #OrganisationalUnit
            $Script:Selection.InsertNewPage()
            FindWordDocumentEnd
            Write-Verbose "$([datetime]::now):  OU"
            WriteWordLine -Style 2 -Tabs 0 -Name 'Organisational Units'
            #OU - GPO inheritance blocked
            $CheckTitle = 'OU - GPO inheritance blocked'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-OUGPInheritanceBlocked -Domain $Domain
            WriteWordLine -Style 3 -Tabs 0 -Name $CheckTitle
            FindWordDocumentEnd
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
        }
        if (($PSBoundParameters.ContainsKey('Computers')) -or ($PSCmdlet.ParameterSetName -eq 'All')) {
            #Domain Controllers
            $Script:Selection.InsertNewPage()
            FindWordDocumentEnd
            Write-Verbose "$([datetime]::now):  Domain Controllers"
            WriteWordLine -Style 2 -Tabs 0 -Name 'Domain Controllers'
            FindWordDocumentEnd
            #Domain Controllers - No contact
            $CheckTitle = 'Domain Controllers - No contact in the last 3 months'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-AllADDomainControllers -Domain $Domain | Where-Object {$_.LastContact -lt (([datetime]::Now).AddMonths(-6))} | Sort-Object -Property LastContact -Descending 
            WriteWordLine -Style 3 -Tabs 0 -Name $CheckTitle
            FindWordDocumentEnd
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            WriteWordLine -Style 0 -Tabs 0 -Name ''
            FindWordDocumentEnd
            #Member Servers
            Write-Verbose "$([datetime]::now):  Member Servers"
            WriteWordLine -Style 2 -Tabs 0 -Name 'Member Servers'
            FindWordDocumentEnd
            #Member Servers - Password never expires
            $CheckTitle = 'Member Servers - Password never expires'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-AllADMemberServerObjects -Domain $Domain -PasswordNeverExpires 
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            #Computers - Password expired
            $CheckTitle = 'Member Servers - Password more than 6 months old'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-AllADMemberServerObjects -Domain $Domain -PasswordExpiration '6' 
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            #Member Servers - Account never expires
            $CheckTitle = 'Member Servers - Account never expires'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-AllADMemberServerObjects -Domain $Domain -AccountNeverExpires 
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            #Member Servers - Account disabled
            $CheckTitle = 'Member Servers - Account disabled'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-AllADMemberServerObjects -Domain $Domain -Disabled 
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
        }
        if (($PSBoundParameters.ContainsKey('Users')) -or ($PSCmdlet.ParameterSetName -eq 'All')) {
            #Users
            $Script:Selection.InsertNewPage()
            FindWordDocumentEnd
            Write-Verbose "$([datetime]::now):  Users"
            WriteWordLine -Style 2 -Tabs 0 -Name 'Users'
            FindWordDocumentEnd
            #Users in Domain Local Groups
            $CheckTitle = 'Users - Direct member of a Domain Local Group'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-ADUsersInDomainLocalGroups -Domain $Domain 
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            #Users - Password never expires
            $CheckTitle = 'Users - Password never expires'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-ADUserObjects -Domain $Domain -PasswordNeverExpires
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            #Users - Password not required
            $CheckTitle = 'Users - Password not required'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-ADUserObjects -Domain $Domain -PasswordNotRequired
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            #Users - Password needs to be changed at next logon
            $CheckTitle = 'Users - Change password at next logon'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-ADUserObjects -Domain $Domain -PasswordChangeAtNextLogon
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            #Users - Password not changed in last 12 months
            $CheckTitle = 'Users - Password not changed in last 12 months'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-ADUserObjects -Domain $Domain -PasswordExpiration '12'
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            #Users - Account without expiration date
            $CheckTitle = 'Users - Account without expiration date'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-ADUserObjects -Domain $Domain -AccountNoExpire
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            #Users - Do not require kerberos preauthentication
            $CheckTitle = 'Users - Do not require kerberos preauthentication'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-ADUserObjects -Domain $Domain -NotRequireKerbereosAuthentication
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
            #Users - Disabled
            $CheckTitle = 'Users - Disabled'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-ADUserObjects -Domain $Domain -Disabled
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name $CheckTitle
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
        }
        if (($PSBoundParameters.ContainsKey('Groups')) -or ($PSCmdlet.ParameterSetName -eq 'All')) {
            #Groups
            Write-Verbose "$([datetime]::now):  Groups"
            $Script:Selection.InsertNewPage()
            FindWordDocumentEnd
            WriteWordLine -Style 2 -Tabs 0 -Name 'Groups'
            FindWordDocumentEnd
            #Priviledged Groups
            Write-Verbose "$([datetime]::now):   Groups - Priviledged groups"
            $TableContentTemp = Get-PriviledgedGroupsMemberCount -Domains $Domain
            #Groups - Priviledged with many members
            $CheckTitle = 'Groups - Priviledged - More than 5 members'
            Write-Verbose "$([datetime]::now):    $CheckTitle"
            if ($TableContentTemp -ne $null) {
                $Content = $TableContent | Where {$_.Members -gt '5'} 
                if ($TableContent -ne $Null) {
                    if ($PSBoundParameters.ContainsKey('CSV')) {
                        $TableContent | Write-ToCSV -Name $CheckTitle
                    }
                    Write-ToWord -Name $CheckTitle -TableContent $TableContent
                    if ($PSBoundParameters.ContainsKey('Mgmt')) {
                        $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                    }
                }
            }
            #Groups - Priveledged with no members
            $CheckTitle = 'Groups - Priviledged - No members'
            Write-Verbose "$([datetime]::now):    $CheckTitle"
            if ($TableContentTemp -ne $null) {
                $Content = $TableContent | Where {$_.Members -eq '0'} 
                if ($TableContent -ne $Null) {
                    if ($PSBoundParameters.ContainsKey('CSV')) {
                        $TableContent | Write-ToCSV -Name $CheckTitle
                    }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
                }
            }
            #Groups - Empty
            $CheckTitle = 'Groups - Empty (no members)'
            Write-Verbose "$([datetime]::now):   $CheckTitle"
            $TableContent = Get-ADEmptyGroups -Domain $Domain
            if ($TableContent -ne $null) {
                if ($PSBoundParameters.ContainsKey('CSV')) {
                    $TableContent | Write-ToCSV -Name 'Groups - Empty (no members)'
                }
                Write-ToWord -Name $CheckTitle -TableContent $TableContent
                if ($PSBoundParameters.ContainsKey('Mgmt')) {
                    $MgmtPage += Generate-CheckListResults -Name $CheckTitle -Count ($TableContent).Count
                }
            }
        }
        $CheckTitle = 'Management'
        Write-Verbose "$([datetime]::now):   $CheckTitle"
        if ($PSBoundParameters.ContainsKey('Mgmt')) {
            if ($PSBoundParameters.ContainsKey('CSV')) {
                $MgmtPage | Write-ToCSV -Name $CheckTitle                
            }
            $Script:Selection.InsertNewPage()
            FindWordDocumentEnd
            WriteWordLine -Style 2 -Tabs 0 -Name $CheckTitle
            FindWordDocumentEnd
            Write-ToWord -Name 'Table' -TableContent $MgmtPage
        }
    }
} else {
    Write-Verbose "$([datetime]::now): No domain(s) found"
}
#endregion Content

###REPLACE BEFORE THIS SECTION WITH YOUR SCRIPT###

Write-Verbose "$(Get-Date): Finishing up document"
#end of document processing

###Change the two lines below for your script
$AbstractTitle = "AD Health Check Report"
$SubjectTitle = "Active Directory Health Check Report"
UpdateDocumentProperties $AbstractTitle $SubjectTitle

If($MSWORD -or $PDF)
{
    SaveandCloseDocumentandShutdownWord
}
ElseIf($Text)
{
    SaveandCloseTextDocument
}
ElseIf($HTML)
{
    SaveandCloseHTMLDocument
}

Write-Verbose "$(Get-Date): Script has completed"
Write-Verbose "$(Get-Date): "

If($PDF)
{
	If(Test-Path "$($Script:FileName2)")
	{
		Write-Verbose "$(Get-Date): $($Script:FileName2) is ready for use"
	}
	Else
	{
		Write-Warning "$(Get-Date): Unable to save the output file, $($Script:FileName2)"
		Write-Error "Unable to save the output file, $($Script:FileName2)"
	}
}
Else
{
	If(Test-Path "$($Script:FileName1)")
	{
		Write-Verbose "$(Get-Date): $($Script:FileName1) is ready for use"
	}
	Else
	{
		Write-Warning "$(Get-Date): Unable to save the output file, $($Script:FileName1)"
		Write-Error "Unable to save the output file, $($Script:FileName1)"
	}
}

Write-Verbose "$(Get-Date): "

#http://poshtips.com/measuring-elapsed-time-in-powershell/
Write-Verbose "$(Get-Date): Script started: $($Script:StartTime)"
Write-Verbose "$(Get-Date): Script ended: $(Get-Date)"
$runtime = $(Get-Date) - $Script:StartTime
$Str = [string]::format("{0} days, {1} hours, {2} minutes, {3}.{4} seconds",
	$runtime.Days,
	$runtime.Hours,
	$runtime.Minutes,
	$runtime.Seconds,
	$runtime.Milliseconds)
Write-Verbose "$(Get-Date): Elapsed time: $($Str)"
$runtime = $Null
$Str = $Null
$ErrorActionPreference = $SaveEAPreference

if ($PSBoundParameters.ContainsKey('Log')) {
    if ($Script:StartLog -eq $true) {
        try {
            Stop-Transcript | Out-Null
            Write-Verbose "$(Get-Date): $Script:LogPath is ready for use"
        } catch {
            Write-Verbose "$(Get-Date): Transcript/log stop failed"
        }
    }
}
# SIG # Begin signature block
# MIIOeAYJKoZIhvcNAQcCoIIOaTCCDmUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUgL6k490ELnsWw2w18dEKh8IC
# Kfagggu9MIIFEjCCA/qgAwIBAgIQCENfm9cK1CGQfGW1InLeAjANBgkqhkiG9w0B
# AQUFADBvMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMS4wLAYDVQQDEyVEaWdpQ2VydCBBc3N1cmVk
# IElEIENvZGUgU2lnbmluZyBDQS0xMB4XDTE0MDcwNzAwMDAwMFoXDTE1MDcxNTEy
# MDAwMFowaDELMAkGA1UEBhMCTkwxFjAUBgNVBAgTDU5vb3JkLUJyYWJhbnQxEzAR
# BgNVBAcTClpvZXRlcm1lZXIxFTATBgNVBAoTDEplZmYgV291dGVyczEVMBMGA1UE
# AxMMSmVmZiBXb3V0ZXJzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# l1Sa+tGZtGfWiCpAPkNitxbDb6QbQ2vLtJrNPrLQDfvdPylLzYvkoJbcHwHQbrUu
# 5Ii/UHRufviQPZmzGcJkfu/5pjz6naRtaqf5TGPv8qDI6J3b6iGNIsLOIGxKr4dT
# r9FDjb6Vn5gq88N7287Ef4k/QwRUdzuQdvMLZHb8+tGVkuHctHHJfE3v2wB9AR2n
# qYy4ojYvehGig8aAx3iG8yceWkzHZgZgk3m4GV9HogB7HRuyIh78qEsVmCRxx6gf
# V5Ai4vMvUdcDaEzvNU0IUZ+lgIyDYsjcMWydJ2Ys1b+l1BIa6/6Zw7K+c/RbYwPe
# QBj9hxLBafIpd/fnAu52AwIDAQABo4IBrzCCAaswHwYDVR0jBBgwFoAUe2jOKarA
# F75JeuHlP9an90WPNTIwHQYDVR0OBBYEFJ5hrKZG5h4uOfuRr2K0tSNaNyRrMA4G
# A1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzBtBgNVHR8EZjBkMDCg
# LqAshipodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vYXNzdXJlZC1jcy1nMS5jcmww
# MKAuoCyGKmh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9hc3N1cmVkLWNzLWcxLmNy
# bDBCBgNVHSAEOzA5MDcGCWCGSAGG/WwDATAqMCgGCCsGAQUFBwIBFhxodHRwczov
# L3d3dy5kaWdpY2VydC5jb20vQ1BTMIGCBggrBgEFBQcBAQR2MHQwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBMBggrBgEFBQcwAoZAaHR0cDov
# L2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEQ29kZVNpZ25p
# bmdDQS0xLmNydDAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEBBQUAA4IBAQBgAHTx
# oD86Cq1h/uxytBblYOWxYJ4fhXWBDJGEATC6dxXKm5gENw55pbTNLJy/IjV+wyMW
# floir6i8d+SuE5t/fG9P/DL9g2Dc9zAuk7tZvaIHpB+qcJ1bSDUMZ86MfQibmKYq
# CpEEjg4TqMCgMHV4zOUiPJhilQ4zYRxBzKvb+JRuOWWWGP+hAXBGBYsHBv/9HfdF
# 7nhWKg2Di3lzslMQWJ6SFgW6DQq9ZygHHWGRC54AWLTuLKyRiyIhLgU5Ud9FaD8M
# 832OU5iFFRsT+SkbiqhYbESKdW6Th1c6Al/iFv+bI84CvXoOpr+gMuUIkJU+l93c
# zNN9R5mMD9ux8lMMMIIGozCCBYugAwIBAgIQD6hJBhXXAKC+IXb9xextvTANBgkq
# hkiG9w0BAQUFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBB
# c3N1cmVkIElEIFJvb3QgQ0EwHhcNMTEwMjExMTIwMDAwWhcNMjYwMjEwMTIwMDAw
# WjBvMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMS4wLAYDVQQDEyVEaWdpQ2VydCBBc3N1cmVkIElE
# IENvZGUgU2lnbmluZyBDQS0xMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
# AQEAnHz5oI8KyolLU5o87BkifwzL90hE0D8ibppP+s7fxtMkkf+oUpPncvjxRoaU
# xasX9Hh/y3q+kCYcfFMv5YPnu2oFKMygFxFLGCDzt73y3Mu4hkBFH0/5OZjTO+tv
# aaRcAS6xZummuNwG3q6NYv5EJ4KpA8P+5iYLk0lx5ThtTv6AXGd3tdVvZmSUa7uI
# SWjY0fR+IcHmxR7J4Ja4CZX5S56uzDG9alpCp8QFR31gK9mhXb37VpPvG/xy+d8+
# Mv3dKiwyRtpeY7zQuMtMEDX8UF+sQ0R8/oREULSMKj10DPR6i3JL4Fa1E7Zj6T9O
# SSPnBhbwJasB+ChB5sfUZDtdqwIDAQABo4IDQzCCAz8wDgYDVR0PAQH/BAQDAgGG
# MBMGA1UdJQQMMAoGCCsGAQUFBwMDMIIBwwYDVR0gBIIBujCCAbYwggGyBghghkgB
# hv1sAzCCAaQwOgYIKwYBBQUHAgEWLmh0dHA6Ly93d3cuZGlnaWNlcnQuY29tL3Nz
# bC1jcHMtcmVwb3NpdG9yeS5odG0wggFkBggrBgEFBQcCAjCCAVYeggFSAEEAbgB5
# ACAAdQBzAGUAIABvAGYAIAB0AGgAaQBzACAAQwBlAHIAdABpAGYAaQBjAGEAdABl
# ACAAYwBvAG4AcwB0AGkAdAB1AHQAZQBzACAAYQBjAGMAZQBwAHQAYQBuAGMAZQAg
# AG8AZgAgAHQAaABlACAARABpAGcAaQBDAGUAcgB0ACAAQwBQAC8AQwBQAFMAIABh
# AG4AZAAgAHQAaABlACAAUgBlAGwAeQBpAG4AZwAgAFAAYQByAHQAeQAgAEEAZwBy
# AGUAZQBtAGUAbgB0ACAAdwBoAGkAYwBoACAAbABpAG0AaQB0ACAAbABpAGEAYgBp
# AGwAaQB0AHkAIABhAG4AZAAgAGEAcgBlACAAaQBuAGMAbwByAHAAbwByAGEAdABl
# AGQAIABoAGUAcgBlAGkAbgAgAGIAeQAgAHIAZQBmAGUAcgBlAG4AYwBlAC4wEgYD
# VR0TAQH/BAgwBgEB/wIBADB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYD
# VR0fBHoweDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDAdBgNVHQ4EFgQUe2jOKarA
# F75JeuHlP9an90WPNTIwHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8w
# DQYJKoZIhvcNAQEFBQADggEBAHtyHWT/iMg6wbfp56nEh7vblJLXkFkz+iuH3qhb
# gCU/E4+bgxt8Q8TmjN85PsMV7LDaOyEleyTBcl24R5GBE0b6nD9qUTjetCXL8Kvf
# xSgBVHkQRiTROA8moWGQTbq9KOY/8cSqm/baNVNPyfI902zcI+2qoE1nCfM6gD08
# +zZMkOd2pN3yOr9WNS+iTGXo4NTa0cfIkWotI083OxmUGNTVnBA81bEcGf+PyGub
# nviunJmWeNHNnFEVW0ImclqNCkojkkDoht4iwpM61Jtopt8pfwa5PA69n8SGnIJH
# QnEyhgmZcgl5S51xafVB/385d2TxhI2+ix6yfWijpZCxDP8xggIlMIICIQIBATCB
# gzBvMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMS4wLAYDVQQDEyVEaWdpQ2VydCBBc3N1cmVkIElE
# IENvZGUgU2lnbmluZyBDQS0xAhAIQ1+b1wrUIZB8ZbUict4CMAkGBSsOAwIaBQCg
# eDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEE
# AYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJ
# BDEWBBSYTx4RezRZlCrQbIzCPMtuityDSzANBgkqhkiG9w0BAQEFAASCAQAIwjAS
# H7CfC4ZwOG4XRyqVYlJPtyHqjfYL0vD9mOsiz/9AOgHxs1sWEgONttZJCkwR2ctq
# L4I0apR+g3eGoEdgGqwEY34kUvUbfkjxtrtV4BcwKLL1/yHvFw59k5HBhzwf3uZk
# zsychxRarb3fuCwuywjlgYtcOqTgyS3CDzgoFcMkADfSYmdC4bysVCzQhBtxQvvA
# HjSAq63AA8d6X8R/6rd475gKCqw2QMXFZywyEqVCjvJT7JjBBtlrlnDizIPlM/uA
# 7J1uZN2MzgBpdpwdwdrMKuRSKhvHCwCYEJclp5GZfQWDSLSzBA3mEmJ9xJCheefn
# hDsRKTcD4vbtuCx8
# SIG # End signature block
