$server = "PrintServer"
$printdriver = [wmiclass]"Win32_PrinterDriver"
$driver = $printdriver.CreateInstance()
$driver.Name="HP2420"
$driver.DriverPath = "\\$server\drivers\printers\hp\lj2420"
$driver.Infname = "\\$server\drivers\printers\hp\lj2420\hpc24x0c.inf"
$printdriver.AddPrinterDriver($driver)
$printdriver.Put()