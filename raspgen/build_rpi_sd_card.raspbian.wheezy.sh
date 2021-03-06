#!/bin/bash

# build your own Raspberry Pi SD card
#
# by Klaus M Pfeiffer, http://blog.kmp.or.at, 2012-06-16

# 2012-06-16
#	improoved handling of local debian mirror
#	added hint for dosfstools (thanks to Mike)
#	added vchiq & snd_bcm2835 to /etc/modules (thanks to Tony Jones)
#	take the value fdisk suggests for the boot partition to start (thanks to Mike)
# 2012-06-02
#       improoved to directly generate an image file with the help of kpartx
#	added deb_local_mirror for generating images with correct sources.list
# 2012-05-27
#	workaround for https://github.com/Hexxeh/rpi-update/issues/4 just touching /boot/start.elf before running rpi-update
# 2012-05-20
#	back to wheezy, http://bugs.debian.org/672851 solved, http://packages.qa.debian.org/i/ifupdown/news/20120519T163909Z.html
# 2012-05-19
#	stage3: remove eth* from /lib/udev/rules.d/75-persistent-net-generator.rules
#	initial

# you need at least
# apt-get install binfmt-support qemu qemu-user-static debootstrap kpartx dosfstools

#deb_mirror="http://archive.raspbian.org/raspbian/"
deb_mirror="http://archive.raspberrypi.org/debian/"
ras_mirror="http://mirrordirector.raspbian.org/raspbian/"
#deb_mirror="http://ftp.debian.org/debian/"
#deb_local_mirror="http://debian.kmp.or.at:3142/debian/"
#http_proxy="http://10.0.0.1:3128"


bootsize="64M"
deb_release="wheezy"

device=$1
bootp=${device}1
rootp=${device}2
pwd=`pwd`
buildenv=${pwd}/test
rootfs="${buildenv}/rootfs"
bootfs="${rootfs}/boot"

mydate=`date +%Y%m%d`

if [ "$deb_local_mirror" == "" ]; then
  deb_local_mirror=$ras_mirror  
fi

image=""


if [ $EUID -ne 0 ]; then
  echo "this tool must be run as root"
  exit 1
fi

mkdir -p $buildenv
image="$device"
device=`losetup -f --show $image`
echo "image $image created and mounted as $device"
dd if=/dev/zero of=$device bs=512 count=1

fdisk $device << EOF
n
p
1

+$bootsize
t
c
n
p
2


w
EOF


  echo "losetup detach begin"
  dmsetup remove_all
  losetup -d $device
  echo "losetup detach end"
  device=`kpartx -va $image | sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1`
  device="/dev/mapper/${device}"
  bootp=${device}p1
  rootp=${device}p2

mkfs.vfat $bootp
mkfs.ext4 $rootp

mkdir -p $rootfs

mount $rootp $rootfs
echo "mount $rootp $rootfs"

echo "pwd=`pwd`"
echo "rootfs=$rootfs"
cd $rootfs
echo "pwd=`pwd`"
echo "http_proxy=$http_proxy"
export http_proxy=$http_proxy 
wget http://archive.raspbian.org/raspbian.public.key -O - | apt-key add -
debootstrap --verbose --keyring /etc/apt/trusted.gpg --foreign --arch=armhf $deb_release $rootfs $deb_local_mirror
echo "Suite"
cp /usr/bin/qemu-arm-static usr/bin/
LANG=C chroot $rootfs /debootstrap/debootstrap  --verbose --second-stage

mount $bootp $bootfs

echo "deb $deb_local_mirror $deb_release  main contrib non-free rpi
" > etc/apt/sources.list

echo "dwc_otg.lpm_enable=0 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait" > boot/cmdline.txt

echo "proc            /proc           proc    defaults        0       0
/dev/mmcblk0p1  /boot           vfat    defaults        0       0
" > etc/fstab

echo "pico" > etc/hostname

echo "auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
" > etc/network/interfaces

echo "vchiq
snd_bcm2835
" >> /etc/modules

echo "#!/bin/bash
export http_proxy=$http_proxy
apt-get update 
apt-get -y install git-core binutils ca-certificates curl
wget http://goo.gl/1BOfJ -O /usr/bin/rpi-update
chmod +x /usr/bin/rpi-update
mkdir -p /lib/modules/3.1.11+
touch /boot/start.elf
http_proxy=$http_proxy SKIP_BACKUP=1 rpi-update
apt-get -y install locales console-common ntp openssh-server less vim
dpkg-reconfigure tzdata
apt-get clean
echo \"root:plop\" | chpasswd
sed -i -e 's/KERNEL\!=\"eth\*|/KERNEL\!=\"/' /lib/udev/rules.d/75-persistent-net-generator.rules
rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -f third-stage
" > third-stage
chmod +x third-stage
LANG=C chroot $rootfs /third-stage

echo "deb $ras_mirror $deb_release  main contrib non-free rpi
deb $deb_mirror $deb_release main
" > etc/apt/sources.list

echo "#!/bin/bash
export http_proxy=$http_proxy
wget http://archive.raspbian.org/raspbian.public.key -O - | apt-key add -
wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key -O - | apt-key add -
aptitude update
aptitude clean
apt-get clean
rm -f cleanup
" > cleanup
chmod +x cleanup
LANG=C chroot $rootfs /cleanup

cd

device=`losetup -a | cut -d":" -f1`


umount $bootp
umount $rootp

  kpartx -d $image
  echo "created image $image"

dmsetup remove_all || echo "dmsetup failed"
losetup -d $device || echo "losetup failed"


rm -Rf $buildenv

echo "done."

