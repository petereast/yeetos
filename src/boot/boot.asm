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
	jmp CODE_SEG:load32

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
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov ebp, 0x00200000
	mov esp, ebp

	jmp $

times 510-($ - $$) db 0 ; Fill at least 510 bytes of data
dw 0xAA55

buffer:  ; Won't be loaded because it's out of the boot sector
