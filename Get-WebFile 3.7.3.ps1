## Get-WebFile (aka wget for PowerShell)
##############################################################################################################
## Downloads a file or page from the web
## History:
## v3.7.3 - Checks to see if URL is formatted properly (contains http or https)
## v3.7.2 - Puts a try-catch block around $writer = new-object System.IO.FileStream and returns/breaks to 
##          prevent further execution if fso creation fails (e.g. if path is invalid). Note: known issue --
##          Script hangs if you try to connect to a good FQDN (e.g. www.google.com) with a bad port (e.g. 81).
##          It will work fine if you use "http://192.168.1.1:81" but hang/crash if you use 
##          "http://www.google.com:81".
## v3.7.1 - Puts a try-catch block around the $req.GetResponse() call to prevent further execution if
##          the page does not exist, cannot connect to server, can't resolve host, etc.
## v3.7 - [int] to [long] to support files larger than 2.0 GB
## v3.6 - Add -Passthru switch to output TEXT files 
## v3.5 - Add -Quiet switch to turn off the progress reports ...
## v3.4 - Add progress report for files which don't report size
## v3.3 - Add progress report for files which report their size
## v3.2 - Use the pure Stream object because StreamWriter is based on TextWriter:
##        it was messing up binary files, and making mistakes with extended characters in text
## v3.1 - Unwrap the filename when it has quotes around it
## v3   - rewritten completely using HttpWebRequest + HttpWebResponse to figure out the file name, if possible
## v2   - adds a ton of parsing to make the output pretty
##        added measuring the scripts involved in the command, (uses Tokenizer)
##############################################################################################################
function Get-WebFile {
   param( 
      $url = (Read-Host "The URL to download"),
      $fileName = $null,
      [switch]$Passthru,
      [switch]$quiet
   )
   
   if($url.contains("http"))
   {
   $req = [System.Net.HttpWebRequest]::Create($url);
   }
   else
   {
   $URL_Format_Error = [string]"Connection protocol not specified. Recommended action: Try again using protocol (for example 'http://" + $url + "') instead. Function aborting...";
   Write-Error $URL_Format_Error;
   return;
   }
   
   # http://stackoverflow.com/questions/518181/too-many-automatic-redirections-were-attempted-error-message-when-using-a-httpw
   $req.CookieContainer = New-Object System.Net.CookieContainer

   try{
   $res = $req.GetResponse();
   }
   catch
   {
   Write-Error $error[0].Exception.InnerException.Message;
   return;
   }
 
   if($fileName -and !(Split-Path $fileName)) {
      $fileName = Join-Path (Get-Location -PSProvider "FileSystem") $fileName
   } 
   elseif((!$Passthru -and ($fileName -eq $null)) -or (($fileName -ne $null) -and (Test-Path -PathType "Container" $fileName)))
   {
      [string]$fileName = ([regex]'(?i)filename=(.*)$').Match( $res.Headers["Content-Disposition"] ).Groups[1].Value
      $fileName = $fileName.trim("\/""'")
      if(!$fileName) {
         $fileName = $res.ResponseUri.Segments[-1]
         $fileName = $fileName.trim("\/")
         if(!$fileName) { 
            $fileName = Read-Host "Please provide a file name"
         }
         $fileName = $fileName.trim("\/")
         if(!([IO.FileInfo]$fileName).Extension) {
            $fileName = $fileName + "." + $res.ContentType.Split(";")[0].Split("/")[1]
         }
      }
      $fileName = Join-Path (Get-Location -PSProvider "FileSystem") $fileName
   }
   if($Passthru) {
      $encoding = [System.Text.Encoding]::GetEncoding( $res.CharacterSet )
      [string]$output = ""
   }
 
   if($res.StatusCode -eq 200) {
      [long]$goal = $res.ContentLength
      $reader = $res.GetResponseStream()
      if($fileName) {
         try{
         $writer = new-object System.IO.FileStream $fileName, "Create"
         }
         catch{
         Write-Error $error[0].Exception.InnerException.Message;
         return;
         }
      }
      [byte[]]$buffer = new-object byte[] 4096
      [long]$total = [long]$count = 0
      do
      {
         $count = $reader.Read($buffer, 0, $buffer.Length);
         if($fileName) {
            $writer.Write($buffer, 0, $count);
         } 
         if($Passthru){
            $output += $encoding.GetString($buffer,0,$count)
         } elseif(!$quiet) {
            $total += $count
            if($goal -gt 0) {
               Write-Progress "Downloading $url" "Saving $total of $goal" -id 0 -percentComplete (($total/$goal)*100)
            } else {
               Write-Progress "Downloading $url" "Saving $total bytes..." -id 0
            }
         }
      } while ($count -gt 0)
      
      $reader.Close()
      if($fileName) {
         $writer.Flush()
         $writer.Close()
      }
      if($Passthru){
         $output
      }
   }
   $res.Close(); 
   if($fileName) {
      ls $fileName
   }
}