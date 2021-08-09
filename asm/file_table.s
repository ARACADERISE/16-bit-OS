;org 0x7e00
;use16

filetable: db 'TestFile,5-File,6}'

times 512 - ($ - $$) db 0
