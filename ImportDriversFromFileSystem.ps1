$DriverStore = "C:\Drivers"
$MDTDSRoot = "C:\MDTBuildLab"
$PSDriveName = "DS001"

Add-PSSnapIn Microsoft.BDD.PSSnapIn
New-PSDrive -Name "$PSDriveName" -PSProvider MDTProvider -Root $MDTDSRoot

# Proces each of the operating systems folders
Get-ChildItem "$DriverStore" | foreach {

    # Display the folder we are processing
    Write-Host "Processing $($_.FullName)" -ForeGroundColor green;Write-Host ""

    # Create the operating system folder in the MDT 2010 Deployment Workbench
    new-item -path $PSDriveName":\Out-of-Box Drivers" -enable "True" -Name "$($_.Name)" -ItemType "folder" -Verbose

    # Process each of the vendor folders
    $OSFolder = $_
    Get-ChildItem $_.FullName | foreach {

        # Display the folder we are processing
        Write-Host "Processing $($_.FullName)" -ForeGroundColor green;Write-Host "" 

        # Create the vendor folder in the MDT 2010 Deployment Workbench
        new-item -path $PSDriveName":\Out-of-Box Drivers\$OSFolder" -enable "True" -Name "$($_.Name)" -ItemType "folder" -Verbose

            # Process each of the model folders
            $VendorFolder = $_
            Get-ChildItem $_.FullName | foreach {
            
                # Display the folder we are processing
                Write-Host "";Write-Host "Processing $($_.FullName)" -ForeGroundColor green;Write-Host "" 

                # Create the model folder in the MDT 2010 Deployment Workbench
                new-item -path $PSDriveName":\Out-of-Box Drivers\$OSFolder\$VendorFolder" -enable "True" -Name "$($_.Name)" -ItemType "folder" -Verbose

                # Import the drivers into MDT 2010 Deployment Workbench
                Import-MDTDriver -Path $PSDriveName":\Out-of-Box Drivers\$OSFolder\$VendorFolder\$($_.Name)" -SourcePath "$($_.FullName)" -Verbose
                
            }

    } 
}