boot:
	# Boot.bin is our virtual hard disk
	nasm -f bin ./boot.asm -o ./boot.bin
	dd if=./message.txt >> ./boot.bin
	dd if=/dev/zero bs=512 count=1 >> ./boot.bin

run: boot
	qemu-system-x86_64 -hda ./boot.bin -display "type=gtk,grab-on-hover=off"

burn:
	dd if=./boot.bin of=/output
