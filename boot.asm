ORG 0
BITS 16

; BIOS parameter block, 33 bytes excluding shortjump
_start:
	jmp short start
	nop

times 33 db 0; Create 33 bytes for the BIOS parameter block

start:
	jmp 0x7c0:step2; set our code segment to 0x7c0

handle_zero: ; div zero exception
	mov si, div_zero_message ; move addr of message to si register
	call print
	
	iret

step2:
	cli  ; Clear interrupts, disable interrupts so we can change the segment registers
	; Improves our changes 
	mov ax, 0x7c0 ; Can't move directly for some reason
	mov ds, ax
	mov es, ax
	mov ax, 0x00 ; set stack register to 0x7c00
	mov ss, ax
	mov sp, 0x7c00
	sti  ; Enables interrupts now that the segment registers are set

	mov word[ss:0x00], handle_zero ; Load the interrupt handler into the right place in the interrupt table
	mov word[ss:0x02], 0x7c0 ; Segment in the interrupt table to do thing

	; BIOS supports disk operations in bios mode with int 13h
	mov ah, 0x02 ; 02h?
	mov al, 0x01 ; read one sector
	; DL is already set to the drive number
	; Data read into EX:BX
	; CF set if error
	mov ch, 0x00 ; cylinder 0
	mov cl, 0x02 ; sector 2
	mov dh, 0x00 ; head no
	mov bx, buffer ; set buffer pointer

	int 0x13
	jc read_error ; If carry is set, jump to error

	mov si, buffer
	call print

	call end

print:
	mov bx, 0   ; set bg to 0
.loop:
	lodsb  	; load chars of si register into al register, incr si register
	cmp al, 0 ; if the char is null
	je .done ; jump if true
	call print_char
	jmp .loop
.done:
	ret

print_char:
	mov ah, 0eh ; 0eh is command to print char
	int 0x10    ; bios interrupt, prints char in AL register
	ret         ; retrurn to caller

end:
	jmp $

read_error:
	mov si, error_message
	call print
	call end

div_zero_message: db 'Computers cannot divide by zero!', 0
error_message: db 'Unable to load sector!', 0

times 510-($ - $$) db 0 ; Fill at least 510 bytes of data
dw 0xAA55

buffer:  ; Won't be loaded because it's out of the boot sector
