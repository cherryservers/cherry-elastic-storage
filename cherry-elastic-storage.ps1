param (
    [string]$vlanId = $(throw "-vlanId is required"),
    [string]$vlanIp = $(throw "-vlanIp is required"),
    [string]$portalIp = $(throw "-portalIp is required"),
    [string]$initiator = $(throw "-initiator is required")
)

$vlanIp2 = $vlanIp.split(".")
$portalIp2 = $portalIp.Split(".")

if ( $vlanIp -like "*10.168*" -or $vlanIp -like "*10.169*") {
    $vlan_ip_2 = "$($vlanIp2[0]).$($vlanIp2[1]-10).$($vlanIp2[2]).$($vlanIp2[3])"
    $portal_ip_2 = "$($portalIp2[0]).$($portalIp2[1]-10).$($portalIp2[2]).$($portalIp2[3])"
    
} elseif ( $vlanIp -like "*192.168*" ) {
    $vlan_ip_2 = "10.157.$($vlanIp2[2]).$($vlanIp2[3])"
    $portal_ip_2 = "10.157.$($portalIp2[2]).$($portalIp2[3])"
} else {
    Write-Host "Error: Unknown subnet!"
    exit 1
}

if ( Get-NetIPAddress | Select IPAddress |  ?{$_ -match $vlan_ip_2} | %{$_.IPAddress} ) {
    Write-Host "Secondary IP address already added. Skiping."
} else {
    Write-Host "Adding secondary private IP address"
    New-NetIPAddress -IPAddress $vlan_ip_2 -PrefixLength 24 -InterfaceAlias "Team interface $vlanId"
}

Add-WindowsFeature -Name 'Multipath-IO'
Start-Service msiscsi
Set-Service msiscsi -startuptype "automatic"

$initiator1 = Get-InitiatorPort -ConnectionType iSCSI|%{$_.NodeAddress}

Set-InitiatorPort -NodeAddress $initiator1 -NewNodeAddress $initiator

New-IscsiTargetPortal -TargetPortalAddress $portalIp -TargetPortalPortNumber 3260 -InitiatorPortalAddress $vlanIp
New-IscsiTargetPortal -TargetPortalAddress $portal_ip_2 -TargetPortalPortNumber 3260 -InitiatorPortalAddress $vlan_ip_2
 
New-MSDSMSupportedHW -VendorId MSFT2005 -ProductId iSCSIBusType_0x9
 
Get-IscsiTarget | Connect-IscsiTarget -IsMultipathEnabled $true -TargetPortalAddress $portalIp -InitiatorPortalAddress $vlanIp -IsPersistent $true
Get-IscsiTarget | Connect-IscsiTarget -IsMultipathEnabled $true -TargetPortalAddress $portal_ip_2 -InitiatorPortalAddress $vlan_ip_2 -IsPersistent $true
 
Set-MSDSMGlobalDefaultLoadBalancePolicy -Policy RR
