show:
    pusha
    mov si, INFO
    call print_str
    
    mov dx, ax
    mov si, reg
    call print_str
    call print_hex
    
    mov byte [reg + 4], 'b'
    mov dx, bx
    mov si, reg
    call print_str
    call print_hex
    
    mov byte [reg + 4], 'c'
    mov dx, cx
    mov si, reg
    call print_str
    call print_hex
    
    mov byte [reg + 4], 'd'
    mov dx, dx
    mov si, reg
    call print_str
    call print_hex
    
    mov word [reg + 4], 'si'
    mov dx, si
    mov si, reg
    call print_str
    call print_hex
    
    mov word [reg + 4], 'di'
    mov dx, di
    mov si, reg
    call print_str
    call print_hex
    
    mov word [reg + 4], 'bp'
    mov dx, bp
    mov si, reg
    call print_str
    call print_hex
    
    mov word [reg + 4], 'sp'
    mov dx, sp
    mov si, reg
    call print_str
    call print_hex
    
    mov word [reg + 4], 'es'
    mov dx, es
    mov si, reg
    call print_str
    call print_hex
    
    mov word [reg + 4], 'ds'
    mov dx, ds
    mov si, reg
    call print_str
    call print_hex
    
    popa
    ret

INFO: db 0xa, 0xd, '  REG         VAL', \
        0xa, 0xd, '  ----        ------', 0x0
                    
reg: db 0xa, 0xd, '  ax          ', 0x0
