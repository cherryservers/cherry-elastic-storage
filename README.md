# cherry-elastic-storage

----
## Quick overview
This script helps in attaching or detaching CherryServers.com elastic storage volume to desired server. Use it at your own risk and always have a backup!

# Supported distributions
* CentOS 6, 7, 8
* Ubuntu 14, 16, 18, 20
* Debian 8, 9, 10
* openSUSE Leap 15
* AlmaLinux 8

# Features
* Attach elastic storage block device
* Detach elastic storage block device

## Installation

```
git clone https://github.com/cherryservers/cherry-elastic-storage.git
cd ./cherry-elastic-storage && cp ./cherry-elastic-storage /usr/local/bin/
chmod +x /usr/local/bin/cherry-elastic-storage
```

## Usage

**Attach a volume**
1. Create a volume under the Storage tab in CherryServers.com portal.
2. Click on a volume configuration button and click on Attach menu.
3. Select desired server to attach a volume.
4. Execute cherry-elastic-storage from the server you with volume to be attached.
5. Partition block device.
6. Make file system on block device.
7. Mount the block device on desired mount point on your system.

Example:

```
vlan_id="ZZZZ"
vlan_ip="xxx.xxx.xxx.xxx" # your VLAN private IP, assigned to your server
portal_ip="yyy.yyy.yyy.yyy" # portal IP address
initiator="iqn.2019-03.com.cherryservers:initiator-XXXXXXX-YYYYYYY" # initiator name provided for your server

cherry-elastic-storage -v $vlan_id -z $vlan_ip -d $portal_ip -i $initiator -e
```

**Detach a volume**

1. Unmount a block device from mount point.
2. Execute cherry-elastic-storage from the server you want volume to be detached.
3. Detach a volume from CherryServers client portal

Example:

```
vlan_ip="xxx.xxx.xxx.xxx" # your VLAN private IP, assigned to your server
portal_ip="yyy.yyy.yyy.yyy" # portal IP address

cherry-elastic-storage -z $vlan_ip -d $portal_ip -q
```