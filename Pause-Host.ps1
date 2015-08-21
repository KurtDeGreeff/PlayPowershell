Function Pause-Host {
  param
  (
    $delay = 1
  )
  $counter = 0
  While(!$Host.UI.RawUI.KeyAvailable -and ($counter++ -lt $delay))
  {
  [Threading.Thread]::Sleep(10000)
  }
}