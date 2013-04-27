raspbian-gen
============

Based work from "Klaus Maria Pfeiffer", thanks to him !
> http://blog.kmp.or.at/2012/05/build-your-own-raspberry-pi-image/

For squeeze version, I just made change to generate to a file, and not directly with a SDCard. 

* Arch armel
* Official armel Debian repository

armhf cross-compiling seems to not be possible with squeeze

For wheezy version, i use official raspbian repository.

* Arch armhf
* Official armhf of raspbian repository

Requirement
-----------

###Wheezy version :

You need at least a fresh install of a wheezy debian :

* http://cdimage.debian.org/cdimage/weekly-builds/amd64/iso-cd/debian-testing-amd64-netinst.iso
* http://cdimage.debian.org/cdimage/weekly-builds/i386/iso-cd/debian-testing-i386-netinst.iso

And also, you need to add this package for cross-compiling :

> apt-get install binfmt-support qemu qemu-user-static debootstrap kpartx lvm2 dosfstools

###Squeeze version :

You need at least an install of Squeeze:

And also, you need to add this package for cross-compiling :

> apt-get install binfmt-support qemu qemu-user-static debootstrap kpartx lvm2 dosfstools

Go Go Go
--------

Prepare an empty SD Image

> dd if=/dev/zero of=sd-4gb.bin bs=1k count=3917824

And let's go !! 

###Squeeze version :

> ./build_rpi_sd_card.raspbian.squeeze.sh sd-4gb.bin | tee gen.log

###Wheezy version :

> ./build_rpi_sd_card.raspbian.wheezy.sh sd-4gb.bin | tee gen.log
