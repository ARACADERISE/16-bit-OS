print_hex:
	pusha
	xor cx, cx
.get:
	cmp cx, 0x04
	je .end

	mov ax, dx
	shr dx, 4
	and ax, 0xF

	cmp al, 0x09
	jle .add_it

	add al, 0x07
	;jmp .add_it

.add_it:
	add al, 0x30
	mov si, HEX_VAL + 5
	sub si, cx
	
	mov [si], al	

	add cx, 1
	jmp .get
.end:
	mov si, HEX_VAL
	call print_str
	
	popa
	ret

HEX_VAL: db '0x0000', 0
