param([Switch] $ShowProgress, [switch] $OpenCompletedResult)

$filePathTemplate = "C:\users\public\pictures\scanned\scan {0} {1}.{2}";
$time = get-date -uformat "%Y-%m-%d";

[void]([reflection.assembly]::loadfile( "C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.Drawing.dll"))

$deviceManager = new-object -ComObject WIA.DeviceManager
$device = $deviceManager.DeviceInfos.Item(1).Connect();

foreach ($item in $device.Items) {
	$fileIdx = 0;
	while (test-path ($filePathTemplate -f $time,$fileIdx,"*")) {
		[void](++$fileIdx);
	}

	if ($ShowProgress) { "Scanning..." }

	$image = $item.Transfer();
	$fileName = ($filePathTemplate -f $time,$fileIdx,$image.FileExtension);
	$image.SaveFile($fileName);
	clear-variable image

	if ($ShowProgress) { "Running OCR..." }

	$modiDocument = new-object -comobject modi.document;
	$modiDocument.Create($fileName);
	$modiDocument.OCR();
	if ($modiDocument.Images.Count -gt 0) {
		$ocrText = $modiDocument.Images.Item(0).Layout.Text.ToString().Trim();
		$modiDocument.Close();
		clear-variable modiDocument

		if (!($ocrText.Equals(""))) {
			$fileAsImage = New-Object -TypeName system.drawing.bitmap -ArgumentList $fileName
			if (!($fileName.EndsWith(".jpg") -or $fileName.EndsWith(".jpeg"))) {
				if ($ShowProgress) { "Converting to JPEG..." }

				$newFileName = ($filePathTemplate -f $time,$fileIdx,"jpg");
				$fileAsImage.Save($newFileName, [System.Drawing.Imaging.ImageFormat]::Jpeg);
				$fileAsImage.Dispose();
				del $fileName;

				$fileAsImage = New-Object -TypeName system.drawing.bitmap -ArgumentList $newFileName 
				$fileName = $newFileName
			}

			if ($ShowProgress) { "Saving OCR Text..." }

			$property = $fileAsImage.PropertyItems[0];
			$property.Id = 40092;
			$property.Type = 1;
			$property.Value = [system.text.encoding]::Unicode.GetBytes($ocrText);
			$property.Len = $property.Value.Count;
			$fileAsImage.SetPropertyItem($property);
			$fileAsImage.Save(($fileName + ".new"));
			$fileAsImage.Dispose();
			del $fileName;
			ren ($fileName + ".new") $fileName
		}
	}
	else {
		$modiDocument.Close();
		clear-variable modiDocument
	}

	if ($ShowProgress) { "Done." }

	if ($OpenCompletedResult) {
		. $fileName;
	}
	else {
		$result = dir $fileName;
		$result | add-member -membertype noteproperty -name OCRText -value $ocrText
		$result
	}
}