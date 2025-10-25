bits 16
org 0x7c00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    mov bx, 0x1000
    mov es, ax

    mov ah, 0x02
    mov al, 0x20 ;extended the size available for the kernel for a more simple development, when kernel is done the idea is to adapt the number of sectors to the size
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00

    int 0x13
    jc disk_error

    jmp 0x0000:0x1000

disk_error:
    hlt
    jmp disk_error

times 510-($-$$) db 0
dw 0xAA55
