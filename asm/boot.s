use16
org 0x7C00

jmp 0x0000:init

init:
	xor ax, ax
	mov es, ax
	mov ds, ax

cli
mov bp, 0x7C00
mov sp, bp
mov ss, ax
sti

mov ah, 0x00
mov dl, 0x80
int 0x13

mov ax, 0x0500
mov es, ax
xor bx, bx

mov ah, 0x02
mov al, 0x01
mov ch, 0x00
mov cl, 0x02
mov dh, 0x00
mov dl, 0x80
int 0x13

jc failed

mov ax, 0x0800
mov es, ax
xor bx, bx
    
mov ah, 0x02
mov al, 0x03
mov ch, 0x00
mov dh, 0x00
mov cl, 0x03
mov dl, 0x80
int 0x13
jc failed

jmp 0x0:0x8000

jmp $
print_str:
	mov ah, 0x0e
.loop:
	mov al, [si]
	cmp al, 0x0
	je ._end
	
	int 0x10
	inc si
	jmp .loop
._end:
	ret

failed:
	mov si, failure
	call print_str

	cli
	hlt

failure: db 'Failed to read from disk', 0x0

times 510 - ($ - $$) db 0
dw 0xaa55
