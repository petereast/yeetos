ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; BIOS parameter block, 33 bytes excluding shortjump
_start:
	jmp short start
	nop

times 33 db 0; Create 33 bytes for the BIOS parameter block

start:
	jmp 0:step2; set our code segment to 0x7c0

step2:
	cli  ; Clear interrupts, disable interrupts so we can change the segment registers
	; Improves our changes 
	mov ax, 0x00 ; Can't move directly for some reason
	mov ds, ax
	mov es, ax
	mov ax, 0x00 ; set stack register to 0x7c00
	mov ss, ax
	mov sp, 0x7c00
	sti  ; Enables interrupts now that the segment registers are set

.load_protected:
	cli
	lgdt[gdt_descriptor] ; Loads descriptor table
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax
	jmp CODE_SEG:load32 ; Actually start running the kernel

  ; Create global descriptor table
  ; This is going to use the paging memory scheme
  ; Write a 32 bit kernel


; GDT - see https://wiki.osdev.org/Global_Descriptor_Table
gdt_start:
gdt_null:
  dd 0x0
  dd 0x0

; offset 0x8
gdt_code: ; CS Should point to this
  dw 0xffff ; Segment limit first 0-15 bits
  dw 0x0    ; Base first 0-15 bits
  db 0      ; Base 16-23 bits
  db 0x9a   ; Access byte
  db 11001111b ; High 4 bit flag and low 4 bit flags
  db 0      ; base 21-34 bits.

; offset 0x10
gdt_data: ; DS, SS, ES, FS, GS should point to this
  dw 0xffff ; Segment limit first 0-15 bits
  dw 0x0    ; Base first 0-15 bits
  db 0      ; Base 16-23 bits
  db 0x92   ; Access byte
  db 11001111b ; High 4 bit flag and low 4 bit flags
  db 0      ; base 21-34 bits.

gdt_end:
gdt_descriptor:
  dw gdt_end - gdt_start-1
  dd gdt_start

[BITS 32]
load32:
	mov eax, 1 ; Load from 1
	mov ecx, 100 ; Load total sectors
	mov edi, 0x0100000 ; Where do we want to load
	call ata_lba_read
	jmp CODE_SEG:0x0100000

ata_lba_read:
	mov ebx, eax ; Save the lba for later
	; send the highest 8 bits of the lba to the ATA controller
	shr eax, 24
	or eax, 0xE0 ; Select master drive
	mov dx, 0x1fc 
	out dx, al ; Write 8 bits to this port
	; Sent highest 8 bits to LBA
	; Send total sectors to read
	mov eax, ecx
	mov dx, 0x1F2
	out dx, al

	mov eax, ebx ; Restore LBA from earlier
	; send more bits of the LBA
	mov dx, 0x1F3
	out dx, al
	; Finished sending more bits

	mov dx, 0x1F4
	mov eax, ebx ; Restore LBA (again lol)
	shr eax, 8
	out dx, al ; Send more bits of LBA
	
	; Send upper 16 bits
	mov dx, 0x1F5
	mov eax, ebx
	shr eax, 16
	out dx, al
	; finish Send upper 16 bits
	
	mov dx, 0x1F7
	mov al, 0x20
	out dx, al

	; read all sectors into memory
.next_sector:
	push ecx

.try_again: ; Check if we need to read
	mov dx, 0x1F7
	in al, dx
	test al, 8
	jz .try_again

; Need to read 256 words at a time
	mov ecx, 256
	mov dx, 0x1F0
	rep insw ; Read a word into edi (0x0100000)
	; This will happen 256 times
	pop ecx 
	loop .next_sector

	;sectors read
	ret
	

times 510-($ - $$) db 0 ; Fill at least 510 bytes of data
dw 0xAA55

buffer:  ; Won't be loaded because it's out of the boot sector
