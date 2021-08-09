;org 0x7e00
;use16

filetable: db 'Terminal,06}'

times 512 - ($ - $$) db 0
