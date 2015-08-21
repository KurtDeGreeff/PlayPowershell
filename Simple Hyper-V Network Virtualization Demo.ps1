# --------------------------------- Meta Information for Microsoft Script Explorer for Windows PowerShell V1.0 ---------------------------------
# Title: Simple Hyper-V Network Virtualization Demo
# Author: RossOrt
# Description:  Hyper-V Network Virtualization in Windows Server 2012 provides a scalable, multi-tenant cloud solution by virtualizing the IP addresses used by Virtual Machines (VMs). Multiple customer networks can run on top of the same physical network. To learn more read the 
# Hyper-V Networ
# Date Published: 12/04/2012 21:26:10
# Source: http://gallery.technet.microsoft.com/scriptcenter/Simple-Hyper-V-Network-d3efb3b8
# Tags: Powershell;Virtualization;Hyper-V
# Search Terms: hyperv
# ------------------------------------------------------------------

Get-NetVirtualizationLookupRecord 
Get-NetVirtualizationCustomerRoute 
Get-NetVirtualizationProviderAddress 
Get-VM | Get-VMNetworkAdapter | fl VMName,VirtualSubnetID