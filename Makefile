boot:
	nasm -f bin ./boot.asm -o ./boot.bin

run:
	qemu-system-x86_64 -hda ./boot.bin

burn:
	dd if=./boot.bin of=/output
