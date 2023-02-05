boot:
	# Boot.bin is our virtual hard disk
	nasm -f bin .src/boot/boot.asm -o ./bin/boot.bin

run: boot
	qemu-system-x86_64 -hda ./bin/boot.bin -display "type=gtk,grab-on-hover=off"

clean: 
	rm -rf ./bin/boot.bin
