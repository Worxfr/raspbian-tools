raspbian-gen
============

apt-get install binfmt-support qemu qemu-user-static debootstrap kpartx lvm2 dosfstools

dd if=/dev/zero of=sd-4gb.bin bs=1k count=3917824

./build_rpi_sd_card.raspbian.sh sd-4gb.bin | tee ex.log
