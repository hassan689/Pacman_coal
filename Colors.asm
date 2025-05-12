print_o:
    push di             ; Save column counter
    mov ax, si
    mov dx, 80
    mul dx              ; ax = row * 80
    add ax, di          ; ax = row * 80 + col
    shl ax, 1           ; multiply by 2 (char+attr)
    mov di, ax          ; DI now holds video memory offset
    mov ax, 0x0C00| 0xDB  ; attr 0x19, char 0xDB
    mov [es:di], ax
    pop di 
    jmp skip_print	
print_yellow:
    push di             ; Save column counter
    mov ax, si
    mov dx, 80
    mul dx              ; ax = row * 80
    add ax, di          ; ax = row * 80 + col
    shl ax, 1           ; multiply by 2 (char+attr)
    mov di, ax          ; DI now holds video memory offset

    mov ax, 0x0E00 | 0xDB  ; attr 0x19, char 0xDB
    mov [es:di], ax
    pop di 
    jmp skip_print
print_green:
    push di             ; Save column counter
    mov ax, si
    mov dx, 80
    mul dx              ; ax = row * 80
    add ax, di          ; ax = row * 80 + col
    shl ax, 1           ; multiply by 2 (char+attr)
    mov di, ax          ; DI now holds video memory offset

    mov ax, 0x0A00 | 0xDB  ; attr 0x19, char 0xDB
    mov [es:di], ax
    pop di 
    jmp skip_print
	
	
 ;mov ax, 0x0A00 | 0xDB	
print_Blue: 
    push di             ; Save column counter
    mov ax, si
    mov dx, 80
    mul dx              ; ax = row * 80
    add ax, di          ; ax = row * 80 + col
    shl ax, 1           ; multiply by 2 (char+attr)
    mov di, ax          ; DI now holds video memory offset

    mov ax, 0x1900 | 0xDB  ; attr 0x19, char 0xDB
    mov [es:di], ax

    pop di      
    	