use16
org 0x8000


mov ah, 0x00
mov al, 0x03
int 0x10

call action

jmp $

action:

    cmp cx, 1
    je warm_reboot
    
	call reset_screen

	mov si, MENU
	call print_str
    push di

.get_key:
	mov ah, 0x00
	int 0x16
    
    mov ah, 0x0e
	int 0x10

	cmp al, 0xD
	je .configure
    
    mov [di], al
    add di, 1
	
	jmp .get_key

.configure:
    pop di
    
    mov al, [di]
    cmp al, 'M'
    je show_mem
    cmp al, 'E'
    je end_all
    cmp al, 'R'
    je warm_reboot
    cmp al, 'G'
    je graphical
    cmp al, 'F'
    je filemenu
    
	jmp action
filemenu:
    xor cx, cx
    push si
    call reset_screen
    
    mov si, FILE_MENU
    call print_str
    
    mov si, 0x7E00
.print_loop:
    mov al, [si]
    
    cmp al, '}'
    je end_it
    cmp al, '-'
    je .next_file
    cmp al, ','
    je .sector_number
    
    int 0x10
    inc si
    
    jmp .print_loop
.next_file:
    xor cx, cx
    inc si
    
    mov ah, 0x0e
    mov al, 0x0a
    int 0x10
    
    mov al, 0x0d
    int 0x10
    jmp .print_loop
.sector_number:
    add si, 3
    jmp .print_loop
    
end_it:
    xor di, di
    mov di, [string]
    
    mov ah, 0x0e
    
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    int 0x10
    mov si, TAB
    call print_str
    
    mov al, '>'
    int 0x10
    xor cx, cx
    
floop:
    
    mov ah, 0x00
    int 0x16
    
    cmp al, 'E'
    je action
    
    cmp al, 0xD
    je run_it
    
    mov ah, 0x0e
    int 0x10
    
    mov [di], al
    inc di
    inc cx
    jmp floop
run_it:
    ;pop si
    mov byte [di], 0x0
    mov di, [string]
    
    mov si, 0x7E00
check_loop:
    cmp cx, 0
    je end_it
    mov al, [si]
    cmp al, '}'
    je not_found
    cmp al, [di]
    jne not_found
    
    inc si
    inc di
    dec cx
    jz found
    cmp byte [di], 0x0
    je not_found
    jmp check_loop
    
    mov ah, 0x00
    int 0x16
    
    jmp action
not_found:
    mov si, notfoundmsg
    call print_str
    
    jmp end_it
found:
    cmp byte [si], ','
    jne not_found
    inc si
    mov cl, 10
    xor al, al
get_sector_number:
    mov dl, [si]
    inc si
    cmp dl, '-'
    je load_program
    cmp dl, '}'
    je load_program
    cmp dl, 48
    jl action
    cmp dl, 57
    jg action
    sub dl, 48
    mul cl
    add al, dl
    jmp get_sector_number
load_program:
    
    mov cl, al
    
    mov ah, 0x00
    mov dl, 0x00
    int 0x13
    
    mov ax, 0x0840
    mov es, ax
    xor bx, bx
    
    mov ah, 0x02
    mov al, 0x01
    mov ch, 0x00
    mov dh, 0x00
    mov dl, 0x00
    int 0x13
    jc end_all
    
    mov cx, 0x01
    
    jmp 0x0:0x8400

graphical:
    
    mov ah, 0x00
    mov al, 0x13
    int 0x10
    
    mov cx, 0x15
    mov dx, 0x15

g_loop:
    mov ah, 0x0C
    mov bh, 0x00
    mov al, 0x01
    int 0x10
    
    add cx, 1
    cmp cx, 100
    jne g_loop
    
    mov cx, 0x15
    add dx, 1
    cmp dx, 100
    jne g_loop
    
    jmp g_done

g_done:
    
    mov si, PAK
    call print_str
    
    mov ah, 0x00
    int 0x16
    
    jmp action

warm_reboot:
    xor cx, cx
    call reset_screen
    mov si, rebooting_msg
    call print_str
    
    mov ax, 0x0040
    mov ds, ax
    mov word [0x0072], 0x1234
    jmp 0x0F000:0x0FFF0
show_mem:
	call reset_screen
    
    call show
    
    mov si, PAK
    call print_str
    
    mov ah, 0x00
    int 0x16
    
    jmp action

reset_screen:
    mov ah, 0x00
	mov al, 0x03
	int 0x10
    
    mov ah, 0x0B
    mov bh, 0x00
    mov bl, 0x01
    int 0x10
    
    xor si, si
    
    ret
end_all:
    mov ah, 0x00
    mov al, 0x13
    int 0x10
    
    mov si, come_again
    call print_str
    
    hlt

print_str:
	mov ah, 0x0e
.print:
	mov al, [si]
	cmp al, 0x0
	je .end_print
	int 0x10
	
	add si, 1

	jmp .print

.end_print:
	ret

include "tools/hex_print.s"
include "tools/show_mem.s"

disk_info: db 0x00, 0x01, 0x03, 0x02

string: db ''
TAB: db '    ', 0x0

welcomebk: db 'Rebooted, press any key to continue ', 0x0
notfoundmsg: db 0xa, 0xd, 'File not found', 0xa, 0xd, 0x0
founditmsg: db 0xa, 0xd, 'FOUND!', 0x0
FILE_MENU: db 0xa, 0xd, ' FILE', \
              0xa, 0xd, '------', 0xa, 0xd, 0x0
rebooting_msg: db 0xa, 0xd, 'Rebooting...', 0x0
come_again: db 0xa, 0xd, 'C o m e  A g a i n !', 0x0
MENU: db 0xa, 0xd,'    Welcome To MocaOS', 0xa, 0xd,\
	0xa, 0xd, '      Menu:', 0xa, 0xd, \
              '      ---------------------------------', 0xa, 0xd, \
	'        M) Show Memory Address', 0xa, 0xd, \
    '        E) Exit', 0xa, 0xd, \
    '        R) Warm Reboot', 0xa, 0xd, \
    '        G) Graphics', 0xa, 0xd, \
    '        F) File Menu', 0xa, 0xd, \
    '      ---------------------------------', 0xa, 0xd, 0xa, 0xd, \
    '      >', 0x0
PAK: db 0xa, 0xd, 'Press Any Key To Continue > ', 0x0
length: db ''
times 1536 - ($ - $$) db 0