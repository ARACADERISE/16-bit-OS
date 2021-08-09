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

mov ax, 0x07E0
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
mov al, 0x02
mov ch, 0x00
mov dh, 0x00
mov cl, 0x03
mov dl, 0x80
int 0x13
jc failed

jmp 0x0:0x8000

jmp $
retrying: db 0xa, 0xd, '    Retrying with floppy...', 0xa, 0xd, 0x0

print_str:
	mov ah, 0x0e
.loop:
	mov al, [si]
	cmp al, 0x00
	je ._end

	int 0x10
	add si, 1
	jmp .loop
._end:
	ret

failed:
	mov si, retrying
	call print_str

	; We will try it with floppy.
	mov ax, 0x07E0
	mov es, ax
	xor bx, bx

	mov ah, 0x02
	mov al, 0x01
	mov ch, 0x00
	mov cl, 0x02
	mov dh, 0x00
	mov dl, 0x00
	int 0x13

	jc failure

	mov ax, 0x0820
	mov es, ax
	xor bx, bx

	mov ah, 0x02
	mov al, 0x02
	mov ch, 0x00
	mov cl, 0x03
	mov dh, 0x00
	mov dl, 0x00
	int 0x13

	jc failure
    
	jmp 0x0000:0x8200
failure:
	mov ah, 0x0e
	mov al, 'E'
	int 0x10
	hlt

times 510 - ($ - $$) db 0
dw 0xaa55
