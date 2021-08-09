setup:
    mov [width], ax
    mov [height], bx
    mov [bpp], cl
    
    sti
    
    push es
    mov ax, 0x4F00
    mov di, vbe_info_block
    int 0x10
    pop es
    
    ;cmp ax, 0x4F
    ;jne failed
    
    mov ax, word [vbe_info_block.video_mode_ptr]
    mov [offset], ax
    mov ax, word [vbe_info_block.video_mode_ptr + 2]
    mov [t_segment], ax
    
    mov ax, [t_segment]
    mov fs, ax
    mov si, [offset]
    
    .find_mode:
        mov dx, [fs:si]
        add si, 2
        
        mov [offset], si
        mov [mode], dx
        xor ax, ax
        mov fs, ax
        
        ;cmp dx, word 0xFFFF
        ;je failed
        
        push es
        mov ax, 0x4F01
        mov cx, [mode]
        mov di, model_info
        int 0x10
        pop es
        
        ;cmp ax, 0x4F
        ;jne failed
        
        mov dx, [model_info.x_res]
        call print_hex
        mov ax, 0x0e20
        int 0x10
        hlt

failed:
    mov si, f
    call print_str
    hlt
    
f: db 'Failed', 0

width:      dw 0
height:     dw 0
bpp:        db 0
t_segment:    dw 0
offset:     dw 0
mode:       dw 0

vbe_info_block:
    .sig:               db "VBE2"
    .vbe_version:       dw 0x0300
    .oem_string_ptr:    dd 0
    .capabilities:      dd 0
    .video_mode_ptr:    dd 0
    .total_memory:      dw 0
    .oem_srev:          dw 0
    .oem_vendor_nptr:   dd 0
    .oem_product_nptr:  dd 0
    .oem_product_rptr:  dd 0
    .reserved:          times 222 db 0
    .oem_data:          times 256 db 0

model_info:
    .mode_attr:         dw 0
    .win_a_attr:        db 0
    .win_b_attr:        db 0
    .win_gran:          dw 0
    .win_size:          dw 0
    .win_a_seg:         dw 0
    .win_b_seg:         dw 0
    .win_func_ptr:      dd 0
    .bytes_per_sl:      dw 0
    .x_res:             dw 0
    .y_res:             dw 0
    .x_char_size:       db 0
    .y_char_size:       db 0
    .num_of_planes:     db 0
    .bpp:               db 0
    .number_of_banks:   db 0
    .memory_model:      db 0
    .bank_size:         db 0
    .num_of_ip:         db 0
    .reserved1:         db 1
    .red_mask_size:     db 0
    .red_field_pos:     db 0
    .green_mask_size:   db 0
    .green_field_pos:   db 0
    .blue_mask_size:    db 0
    .blue_field_pos:    db 0
    .rsvd_mask_size:    db 0
    .rsved_field_pos:   db 0
    .dir_color_mi:      db 0
    .phys_base_ptr:     dd 0
    .reserved2:         dd 0
    .reserved3:         dw 0
    .lin_bytes_psl:     dw 0
    .bnk_num_of_ip:     db 0
    .lin_num_of_ip:     db 0
    .lin_red_mask_size: db 0
    .lin_red_field_pos: db 0
    .lin_green_mask_s:  db 0
    .lin_green_fp:      db 0
    .lin_blue_mask_s:   db 0
    .lin_blue_fp:       db 0
    .lin_rsved_ms:      db 0
    .lin_rsved_fp:      db 0
    .max_pixel_clock:   dd 0
    .reserved4:         times 190 db 0