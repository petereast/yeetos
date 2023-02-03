ORG 0x7c00
BITS 16

start:
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

