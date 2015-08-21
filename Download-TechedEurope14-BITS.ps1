# Download Teched Europe 14Content with BITS
# 
# Niklas Akerlund v 0.2 2014-10-31
# 
# Borrowed code from Peter Schmidt (Exchange MVP, blog: www.msdigest.net) DownloadTechEdEurope14VideoAndSlides.ps1
#
[CmdletBinding()]
param(
  [switch]$CDP,
  [switch]$WIN,
  [switch]$OFC,
  [switch]$FDN,
  [switch]$EM,
  [switch]$DEV,
  [switch]$DBI,
  [switch]$All,
  [switch]$PPT,
  [switch]$MP4,
  [string]$Dest='C:\Techedtest')

# Check if the folder exists
if(!(Get-Item $Dest -ErrorAction Ignore))
{
  New-Item -Path $Dest -ItemType Directory
}
$psessions = @()
$vsessions = @()
#$ = 'C:\techedtest'

if($CDP){
  $psessions =  Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/slides' | where comments -cmatch "CDP"
  $vsessions = Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/mp4high' | where comments -cmatch "CDP"
}

if($WIN){
  $psessions +=  Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/slides' | where comments -cmatch "WIN"
  $vsessions += Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/mp4high' | where comments -cmatch "WIN"
}

if($OFC){
  $psessions +=  Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/slides' | where comments -cmatch "OFC"
  $vsessions += Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/mp4high' | where comments -cmatch "OFC"
}

if($FDN){
  $psessions +=  Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/slides' | where comments -cmatch "FDN"
  $vsessions += Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/mp4high' | where comments -cmatch "FDN"
}

if($EM){
  $psessions +=  Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/slides' | where comments -cmatch "EM"
  $vsessions += Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/mp4high' | where comments -cmatch "EM"
}

if($DEV){
  $psessions +=  Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/slides' | where comments -cmatch "DEV"
  $vsessions += Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/mp4high' | where comments -cmatch "DEV"
}

if($DBI){
  $psessions +=  Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/slides' | where comments -cmatch "DBI"
  $vsessions += Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/mp4high' | where comments -cmatch "DBI"
}

if ($All){
  $psessions =  Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/slides' 
  $vsessions = Invoke-RestMethod 'http://channel9.msdn.com/Events/TechEd/Europe/2014/RSS/mp4high' 
}

#$psessions 

if($PPT){
  foreach ($psession in $psessions){
      # create folder
      $code = $psession.comments.split("/") | select -last 1	
      $folder = $code + " - " + $psession.title.Replace(":", "-").Replace("?", "").Replace("/", "-").Replace("<", "").Replace("|", "").Replace('"',"").Replace("*","")
		  $folder = $folder.substring(0, [System.Math]::Min(100, $folder.Length))
		  $folder = $folder.trim()
      $folder = $Dest + "\" + $folder
      if(!(Get-Item $folder -ErrorAction Ignore)){
          New-Item -Path $folder -ItemType Directory
      }
      #tage pptx
      [string]$pptx = $psession.GetElementsByTagName('enclosure').url 
      if(!(get-item ($folder +"\" + $code +".pptx") -ErrorAction Ignore)){
        Start-BitsTransfer -Source $pptx -Destination $folder 
      } else{
        Write-Output " $code ppt already downloaded"
      }
  }
}
if($MP4){
  foreach ($vsession in $vsessions){
      $code = $vsession.comments.split("/") | select -last 1	
      $folder = $code + " - " + $vsession.title.Replace(":", "-").Replace("?", "").Replace("/", "-").Replace("<", "").Replace("|", "").Replace('"',"").Replace("*","")
		  $folder = $folder.substring(0, [System.Math]::Min(100, $folder.Length))
		  $folder = $folder.trim()
      $folder = $Dest + "\" + $folder
      if(!(Get-Item $folder -ErrorAction Ignore)){
          New-Item -Path $folder -ItemType Directory
      }
      [string]$video = $vsession.GetElementsByTagName('enclosure').url
      #$video
      if(!(get-item ($folder +"\" + $code +".mp4") -ErrorAction Ignore)){
        Start-BitsTransfer -Source $video -Destination $folder
      }else{
        Write-Output " $code video already downloaded"
      }
  }
}