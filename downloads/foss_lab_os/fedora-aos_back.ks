# Kickstart file to build the appliance operating
# system for fedora.
# This is based on the work at http://www.thincrust.net
lang C
keyboard us
timezone US/Eastern
auth --useshadow --enablemd5
selinux --disabled
firewall --disabled
#By default we just bump into runlevel 3
bootloader --timeout=1 --append="acpi=force 3" 
#network --bootproto=dhcp --device=eth0 --onboot=on
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

part / --size 2024 --fstype ext4 --ondisk sda

#
# Repositories
#
#repo --name=rawhide --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=rawhide&arch=$basearch

repo --name=fedora --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch

#Fix pyparted: https://bugzilla.redhat.com/show_bug.cgi?id=711573
repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch

repo --name=custom-repo --baseurl=file:///home/zer0c00l/custom-repo/
#repo --name=updates-testing --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-testing-f$releasever&arch=$basearch





#
# Add all the packages after the base packages
#
%packages --excludedocs --nobase

#
#Fonts, metacity and base-x are needed for anaconda
#Anaconda does not support text based installation as of now
#

@Fonts
-lohit-assamese-fonts
-lohit-bengali-fonts
-lohit-devanagari-fonts
-lohit-gujarati-fonts
-lohit-kannada-fonts
-lohit-oriya-fonts
-lohit-punjabi-fonts
-lohit-telugu-fonts
-paktype-naqsh-fonts
-paktype-tehreer-fonts
-paratype-pt-sans-fonts
-sil-abyssinica-fonts
-sil-padauk-fonts
-smc-meera-fonts
-stix-fonts
-thai-scalable-waree-fonts
-un-core-dotum-fonts
-wqy-zenhei-fonts

@base-x
-authconfig-gtk
-desktop-backgrounds-basic
dbus
dbus-python
glibc
grep
metacity
basesystem
kbd
bash
kernel
grub
e2fsprogs
passwd
chkconfig
system-config-keyboard
openssh
openssh-server
rootfiles
filesystem
rsyslog
setuptool
device-mapper
cracklib-python
rpm
systemd
yum
vim-minimal
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
authconfig
#-rhpl
-wireless-tools


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
-lib

# Things it would be nice to loose
fedora-logos
#generic-logos
-fedora-release-notes

# Added by Arun SAG
@Development Tools
-git
-automake14
-automake15
-automake16
-automake17
-byacc
-ccache
-cscope
-ctags
-cvs
-diffstat
-doxygen
-gcc-gfortran
-indent
-intltool
-ltrace
-oprofile
-oprofile-gui
-patchutils
-python-ldap
-systemtap
-texinfo
-valgrind
anaconda
rcs
cvs
subversion
fuse-devel
createrepo
mysql-server
MySQL-python
python
perl

%end

#
# Add custom post scripts after the base post.
#



	