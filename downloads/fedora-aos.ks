# Kickstart file to build the appliance operating
# system for fedora.
# This is based on the work at http://www.thincrust.net
cmdline
lang C
keyboard us
timezone US/Eastern
auth --useshadow --enablemd5
selinux --disabled
firewall --disabled
bootloader --timeout=1 --append="acpi=force 3" 
network --bootproto=dhcp --device=eth0 --onboot=on
services --enabled=network

# Uncomment the next line
# to make the root password be thincrust
# By default the root password is emptied
#rootpw --iscrypted $1$uw6MV$m6VtUWPed4SqgoW6fKfTZ/

#
# Partition Information. Change this as necessary
# This information is used by appliance-tools but
# not by the livecd tools.
#
#part / --size 2024 --fstype ext4 --ondisk sda

#
# Repositories
#
#repo --name=rawhide --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=rawhide&arch=$basearch

repo --name=fedora --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
#exclude pyparted: https://bugzilla.redhat.com/show_bug.cgi?id=711573
repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch

repo --name=custom-repo --baseurl=file:///home/zer0c00l/custom-repo/
#repo --name=updates-testing --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-testing-f$releasever&arch=$basearch



#repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch --exclude kernel*debug* --exclude kernel-kdump* --exclude syslog-ng --exclude java-1.5.0-gcj-devel --exclude astronomy-bookmarks --exclude generic* --exclude java-1.5.0-gcj-javadoc --exclude btanks* --exclude GConf2-dbus* --exclude bluez-gnome --exclude pyparted


#repo --name=fedora --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch --exclude kernel*debug* --exclude kernel-kdump* --exclude syslog-ng --exclude java-1.5.0-gcj-devel --exclude astronomy-bookmarks --exclude generic* --exclude java-1.5.0-gcj-javadoc --exclude btanks* --exclude GConf2-dbus* --exclude bluez-gnome



#
# Add all the packages after the base packages
#
%packages --excludedocs --nobase
@core
bash
kernel
grub
e2fsprogs
passwd
policycoreutils
chkconfig
openssh
openssh-server
rootfiles
yum
vim-enhanced
acpid
#needed to disable selinux
lokkit

#Allow for dhcp access
dhclient
iputils

#
# Packages to Remove
#

# no need for kudzu if the hardware doesn't change
#-kudzu
-prelink
-setserial
-ed

# Remove the authconfig pieces
-authconfig
#-rhpl
-wireless-tools

# Remove the kbd bits
-kbd
-usermode

# these are all kind of overkill but get pulled in by mkinitrd ordering
#-mkinitrd
-kpartx
-dmraid
-mdadm
-lvm2


# selinux toolchain of policycoreutils, libsemanage, ustr
-policycoreutils
-checkpolicy
-selinux-policy*
-libselinux-python
-libselinux

# Things it would be nice to loose
fedora-logos
#generic-logos
-fedora-release-notes

# Added by Arun SAG
@Development Tools
-git
lighttpd
anaconda
rcs
cvs
subversion
fuse-devel
createrepo
mysql-server
MySQL-python
python
ipython
perl

%end

#
# Add custom post scripts after the base post.
#



	