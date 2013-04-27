raspbian-gen
============

Requirement
-----------

You need at least a fresh install of a wheezy debian :
http://cdimage.debian.org/cdimage/weekly-builds/amd64/iso-cd/debian-testing-amd64-netinst.iso
http://cdimage.debian.org/cdimage/weekly-builds/i386/iso-cd/debian-testing-i386-netinst.iso

And also, you need to add this package for cross-compiling :

> apt-get install binfmt-support qemu qemu-user-static debootstrap kpartx lvm2 dosfstools

Go Go Go
--------

Prepare an empty SD Image

> dd if=/dev/zero of=sd-4gb.bin bs=1k count=3917824

And let's go !! 

> ./build_rpi_sd_card.raspbian.sh sd-4gb.bin | tee gen.log
