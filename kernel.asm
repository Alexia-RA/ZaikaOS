bits 16
org 0x1000

start_kernel:
	call clear

read:
	call prompt
	lea di, input_buffer
	mov cx, 0

.read_key:
	mov ah, 0x00
	int 0x16
	cmp al, 0x0D
	je .newline
	cmp al, 0x08
	je .backspace
	mov [di], al
	inc di
	inc cx
	mov ah, 0x0e
	int 0x10
	jmp .read_key

.newline:
	mov ah, 0x0e
	mov al, 0x0D
	int 0x10
	mov al, 0x0a
	int 0x10
	mov byte [di], 0
	call input_check
	jmp read

.backspace:
	cmp di, input_buffer
	je .read_key
	dec di
	dec cx
	mov ah, 0x0e
	mov al, 0x08
	int 0x10
	mov al, ' '
	int 0x10
	mov al, 0x08
	int 0x10
	jmp .read_key

file:
	pusha
	call clear
	mov si, guide
	call print
	mov ah, 0x0e
	mov al, 0x0D
	int 0x10
	mov al, 0x0a
	int 0x10
	lea di, file_buffer
	mov cx, 0

.read_key_file:
	mov ah, 0x00
	int 0x16
	cmp al, 0x08
	je .backspace_file
	cmp al, 0x0D
	je .newline_file
	cmp al, 0x09
	je .tab
	mov [di], al
	inc di
	inc cx
	mov ah, 0x0e
	int 0x10
	jmp .read_key_file

.backspace_file:
	cmp di, file_buffer
	je .read_key_file
	dec di
	dec cx
	mov ah, 0x0e
	mov al, 0x08
	int 0x10
	mov al, ' '
	int 0x10
	mov al, 0x08
	int 0x10
	jmp .read_key_file

.tab:
	mov ah, 0x0e
	mov al, 0x0D
	int 0x10
	mov al, 0x0a
	int 0x10
	mov byte [di], 0
	mov si, control
	call print
	mov ah, 0x00
	int 0x16
	cmp al, 0x78
	je .save
	cmp al, 0x71
	je .quit
	jmp .tab

.quit:
	jmp .end_file

.save:
	call write_file
	call clear
	jmp .end_file

.newline_file:
	mov ah, 0x0e
	mov al, 0x0D
	int 0x10
	mov al, 0x0a
	int 0x10
	mov byte [di], 0
	jmp .read_key_file

.end_file:
	popa
	ret

input_check:
        mov si, input_buffer
	mov di, clear_cmd
        call compare_clear
	mov si, input_buffer
	mov di, nano_cmd
	call compare_nano
	mov si, input_buffer
	mov di, cat_cmd
	call compare_cat
	ret


compare_clear:
        lodsb
        scasb
        jne not_equal
	cmp al, 0
        je clear
	jmp compare_clear

compare_nano:
	lodsb
	scasb
	jne not_equal
	cmp al, 0
	je nano
	jmp compare_nano


compare_cat:
	lodsb
	scasb
	jne not_equal
	cmp al, 0
	je read_file
	jmp compare_cat

clear:
        mov ah, 0x00
        mov al, 0x03
        int 0x10
	ret

nano:
	call file
	ret

not_equal:
        ret

prompt:
        mov si, prompt_text
        call print
        ret

print:
        pusha
        mov ah, 0x0e

.next_char:
        lodsb
        or al, al
        jz .done
        int 0x10
        jmp .next_char

.done:
        popa
        ret


write_file:
	mov ah, 0x03
	mov al, 8
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov bx, file_buffer
	mov ax, 0x0000
	mov es, ax
	int 0x13
	ret

read_file:
	mov ah, 0x02
	mov al, 8
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov bx, file_buffer
	mov ax, 0x0000
	mov es, ax
	int 0x13
	mov si, file_buffer
	call print
	mov ah, 0x0e
	mov al, 0x0D
	int 0x10
	mov al, 0x0a
	int 0x10
	ret




hang:
    hlt
    jmp hang



;Prompt
prompt_text db "zaikaos# ", 0

;Buffers
input_buffer times 4096 db 0
file_buffer times 4096 db 0



;Command variables
clear_cmd db "clear", 0
nano_cmd db "nano", 0
cat_cmd db "cat", 0

;Nano variables
guide db "Press tab to exit nano", 0
control db "Press q for exit without saving or x for exit saving"
