use16
org 0x8400

pusha

mov ah, 0x00
mov al, 0x02
int 0x10

get_command:
    mov si, message
    call print_str
restart:
    mov ah, 0x0e
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    int 0x10
    mov al, ' '
    int 0x10
    mov al, '>'
    int 0x10
    
    mov di, [command]
    xor cx, cx
.com_loop:
    
    mov ah, 0x00
    int 0x16
    
    cmp al, 0xD
    je check_command
    
    mov ah, 0x0e
    int 0x10
    
    mov [di], al
    inc di
    inc cx
    
    jmp .com_loop
check_command:
    cmp cx, 0
    je restart
    ;mov byte [di], 0x0
    mov di, [command]
    
    mov si, commands
.check_loop:
    mov al, [si]
    cmp al, '}'
    je .end
    cmp al, [di]
    jne .end
    
    inc si
    inc di
    dec cx
    jz .found
    jmp .check_loop
.found:
    mov cl, 10
    xor al, al
    inc si
.floop:
    mov dl, [si]
    inc si
    cmp dl, ','
    je run_command
    cmp dl, '}'
    je restart
    cmp dl, 48
    jl restart
    cmp dl, 57
    jg restart
    sub dl, 48
    mul cl
    add al, dl
    
    jmp .floop
.end:
    inc si
    jmp .check_loop

run_command:
    cmp al, 1
    je go_back
    cmp al, 2
    je get_help
    cmp al, 3
    je clear_screen
    cmp al, 4
    je create_file
create_file:
    mov si, filenmsg
    call print_str
    mov di, [filename]
.filenameloop:
    
    mov ah, 0x00
    int 0x16
    
    cmp al, 0xD
    je create
    
    mov ah, 0x0e
    int 0x10
    
    mov [di], al
    inc di
    jmp .filenameloop
create:
    mov byte [di], 0x0
    mov di, [filename]
    
    jmp editor

editor:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    
    mov ah, 0x0B
    mov bh, 0x03
    mov bl, 0x00
    int 0x10
    
    mov ah, 0x0e
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    int 0x10
    mov al, ' '
    int 0x10
    mov al, ' '
    int 0x10
    mov al, ' '
    int 0x10
    mov si, di
    call print_str
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    int 0x10
    xor cx, cx
.lineloop:
    mov al, '-'
    int 0x10
    
    inc cx
    cmp cx, 0x50
    je .dorest
    jmp .lineloop
.dorest:
    mov word [mem_loc], bx
    mov si, 0x5000
.assign:
    mov al, [si]
    cmp al, '}'
    je .separate
    
    inc si
    jmp .assign
.separate:
    sub si, 2
    xor al, al
.get_number:
    mov dl, [si]
    inc si
    cmp dl, '-'
    je .sep
    cmp dl, '}'
    je .sep
    cmp dl, 48
    jl restart
    cmp dl, 57
    jg restart
    sub dl, 48
    mul cl
    add al, dl
    jmp .get_number
.sep:
    mov cl, al
    inc cl
    dec si
    mov byte [si], '-'
    inc si
    mov [filename], di
    jmp .assignit
.assignit:
    mov al, [di]
    cmp al, 0x00
    je .do
    mov byte [si], al
    
    inc di
    inc si
    jmp .assignit
.do:    
    or cl, '0'
    mov byte [si], ','
    inc si
    mov byte [si], '0'
    inc si
    mov byte [si], cl
    inc si
    mov byte [si], '}'
    inc si
    mov byte [si], 0x0
    inc si
    
    xor ax, ax
    mov es, ax
    
    mov ah, 0x03
    mov al, 0x01
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    mov dl, 0x80
    mov bx, 0x5000
    int 0x13
    jc .failure

    mov ah, 0x00
    int 0x16
    
    cmp al, 0x1B
    je restart
    .failure:
        mov ah, 0x0e
        mov al, 'E'
        int 0x10
        cli
        hlt
    cli
    hlt
get_help:
    mov si, help
    call print_str
    
    jmp restart
go_back:
    popa
    
    jmp 0x0:0x8000
clear_screen:
    mov ah, 0x00
    mov al, 0x02
    int 0x10
    jmp restart
endit:
    mov si, nocommand
    call print_str
    jmp restart
jmp $

print_str:
    mov ah, 0x0e
.loop:
    mov al, [si]
    cmp al, 0x0
    je .end
    
    int 0x10
    inc si
    jmp .loop
.end:
    ret

filenmsg: db 0xa, 0xd, 'Filename: ', 0x0
help: db 0xa, 0xd, 'back - go back', 0xa, 0xd, \
                   'clear - clear screen', 0xa, 0xd, 0x0
nocommand: db 'Not a command', 0xa, 0xd, 0x0
found: db 'Found Command!', 0x0
message: db 0xa, 0xd, '  Moca Terminal', 0xa, 0xd, 0xa, 0xd, 0x0

commands: db 'back-01,help-02,clear-03,create-04,}'
command: db ''
filename: db ''
mem_loc: dw 0

include "tools/hex_print.s"

times 1024 - ($ - $$) db 0
