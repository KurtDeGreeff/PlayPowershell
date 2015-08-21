function Test-ServiceResponding($ServiceName)
{
  $service = Get-WmiObject -Class Win32_Service -Filter "Name='$ServiceName'"
  $processID = $service.processID
  $process = Get-Process -Id $processID
  $process.Responding
}