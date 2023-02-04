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
	mov ah, 0eh
	mov al, 'A'
	mov bx, 0x00
	int 0x10
	iret

handle_one: ; div zero exception
	mov ah, 0eh
	mov al, 'A'
	mov bx, 0x00
	int 0x10
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
	mov word[ss:0x04], handle_zero ; Load the interrupt handler into the right place in the interrupt table
	mov word[ss:0x06], 0x7c0 ; Segment in the interrupt table to do thing

	mov ax 0x00
	div ax

	mov si, message ; move addr of message to si register
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

message: db 'Hello world!', 0

times 510-($ - $$) db 0 ; Fill at least 510 bytes of data
dw 0xAA55

