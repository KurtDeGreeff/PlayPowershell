<#Create Azure Dev and Test Environments
http://goo.gl/QtN9Au
Use Get-AzureSubscription to find your subscription ID and fill in admin username and password
#>

function Get-LatestVMImage
{
     param
     (
         [string]
         $imageFamily,

         [string]
         $location
     )

    #From https://michaelcollier.wordpress.com/2013/07/30/the-case-of-the-latest-windows-azure-vm-image/
    $images = Get-AzureVMImage | Where-Object { $_.ImageFamily -eq $imageFamily } |
    Where-Object { $_.Location.Split(';') -contains $location} |
    Sort-Object -Descending -Property PublishedDate 
    return $images[0].ImageName;
}
 
$prefix = 'mydemo'
$storageAccountName = ($prefix + 'storage')
$location = 'South Central US'
$vnetConfigFilePath = 'C:\temp\NetworkConfig.xml'
 
#$imageName = "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-Datacenter-201505.01-en.us-127GB.vhd"
$imageName = Get-LatestVMImage -imageFamily 'Windows Server 2012 R2 Datacenter' -location $location
$size = 'Small'
$adminUsername = 'YOUR_USERNAME_HERE'
$adminPassword = 'YOUR_PASSWORD_HERE'
$vnetName = ($prefix + 'vnet-southcentral')

#Use Get-AzureSubscription to find your subscription ID
$subscriptionID = 'YOUR_SUBSCRIPTION_ID_HERE'
 
#Set the current subscription
Select-AzureSubscription -SubscriptionId $subscriptionID -Current
 
#Create storage account
New-AzureStorageAccount -StorageAccountName $storageAccountName -Location $location
 
#Set the current storage account
Set-AzureSubscription -SubscriptionId $subscriptionID -CurrentStorageAccountName $storageAccountName
 
#Create virtual network
Set-AzureVNetConfig -ConfigurationPath $vnetConfigFilePath
 
 
#Development environment
$avSetName = 'AVSET-DEV'
$serviceName = ($prefix + 'DEV')
$subnetName = 'Subnet-1'
 
New-AzureService -ServiceName $serviceName -Location $location
                         
$vm1 = New-AzureVMConfig -Name 'DEV1' -InstanceSize $size -ImageName $imageName -AvailabilitySetName $avSetName
Add-AzureProvisioningConfig -VM $vm1 -Windows -AdminUsername $adminUsername -Password $adminPassword
Set-AzureSubnet -SubnetNames $subnetName -VM $vm1
 
$vm2 = New-AzureVMConfig -Name 'DEV2' -InstanceSize $size -ImageName $imageName -AvailabilitySetName $avSetName
Add-AzureProvisioningConfig -VM $vm2 -Windows -AdminUsername $adminUsername -Password $adminPassword
Set-AzureSubnet -SubnetNames $subnetName -VM $vm2
 
New-AzureVM -ServiceName $serviceName -VMs $vm1,$vm2 -VNetName $vnetName
 
 
#Staging environment
$avSetName = 'AVSET-STAGE'
$serviceName = ($prefix + 'STAGE')
$subnetName = 'Subnet-2'
 
New-AzureService -ServiceName $serviceName -Location $location
                         
$vm1 = New-AzureVMConfig -Name 'STAGE1' -InstanceSize $size -ImageName $imageName -AvailabilitySetName $avSetName
Add-AzureProvisioningConfig -VM $vm1 -Windows -AdminUsername $adminUsername -Password $adminPassword
Set-AzureSubnet -SubnetNames $subnetName -VM $vm1
 
$vm2 = New-AzureVMConfig -Name 'STAGE2' -InstanceSize $size -ImageName $imageName -AvailabilitySetName $avSetName
Add-AzureProvisioningConfig -VM $vm2 -Windows -AdminUsername $adminUsername -Password $adminPassword
Set-AzureSubnet -SubnetNames $subnetName -VM $vm2
 
New-AzureVM -ServiceName $serviceName -VMs $vm1,$vm2 -VNetName $vnetName
 
 
#Production environment
$avSetName = 'AVSET-PROD'
$serviceName = ($prefix + 'PROD')
$subnetName = 'Subnet-3'
 
New-AzureService -ServiceName $serviceName -Location $location
                         
$vm1 = New-AzureVMConfig -Name 'PROD1' -InstanceSize $size -ImageName $imageName -AvailabilitySetName $avSetName
Add-AzureProvisioningConfig -VM $vm1 -Windows -AdminUsername $adminUsername -Password $adminPassword
Set-AzureSubnet -SubnetNames $subnetName -VM $vm1
 
$vm2 = New-AzureVMConfig -Name 'PROD2' -InstanceSize $size -ImageName $imageName -AvailabilitySetName $avSetName
Add-AzureProvisioningConfig -VM $vm2 -Windows -AdminUsername $adminUsername -Password $adminPassword
Set-AzureSubnet -SubnetNames $subnetName -VM $vm2
 
New-AzureVM -ServiceName $serviceName -VMs $vm1,$vm2 -VNetName $vnetName
