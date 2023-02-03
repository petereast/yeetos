ORG 0
BITS 16

start:
	cli  ; Clear interrupts, disable interrupts so we can change the segment registers
	mov ax, 0x7c0 ; Can't move directly for some reason
	mov ds, ax
	mov es, ax
	mov ax, 0x00 ; set stack register to 0x7c00
	mov ss, ax
	mov sp, 0x7c00
	sti  ; Enables interrupts now that the segment registers are set

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

