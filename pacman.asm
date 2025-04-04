[org 0x0100]
jmp start 
 row: dw 0
 col: dw 0

map: 
    db 1, 1, 1, 1, 1, 1, 1, 1
    db 1, 1, 1, 1, 1, 1, 1, 1   
    db 1, 1, 1, 1, 1, 1, 1, 1
    db 1, 1, 1, 1, 1, 1, 1, 1
    db 1, 1, 1, 1, 1, 1, 1, 1
    db 1, 1, 1, 1, 1, 1, 1, 1
    db 1, 1, 1, 1, 1, 1, 1, 1
    db 1, 1, 1, 1, 1, 1, 1, 1
start :
; this is the main of the code

call clear_screen
call print_map
call move_loop
call Move_down

call terminate
 
;address = base_address + (row_index * num_columns + column_index) * element_size
;mov eax, [array2d + (1 * 4 + 2) * 4]  ; Accesses row 1, column 2 (value 7 in first example)
print_map:
    push es
    push ax
    push bx
    push cx
    push si
    push di
    
    mov ax, 0xb800      ; Video memory segment
    mov es, ax
    
    xor si, si           ; SI = row counter (0-3)
    mov di, 250       
    
row_loop:
    xor bx, bx          
    
col_loop:
    mov al , 8 
	mul si 
    mov al, [map + si  + bx]
    cmp al, 1
    je print_wall
    cmp al, 2
    je print_path
    jmp next_col
    
print_wall:
    mov ax,  0x1900 | 0xDB       
    jmp print_char
    
print_path:
    mov ax, 0x0720   
    
print_char:
    mov [es:di], ax     ; Write to screen
    add di, 2           ; Move to next screen position
    
next_col:
    inc bx              ; Next column
    cmp bx, 8
    jl col_loop
    add di, 160 - (8 * 2)
    
    inc si              ; Next row
    cmp si, 8
    jl row_loop
    
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    pop es
    ret

;___________________________________________
clear_screen:
    
   push es 
   push ax 
   push di 
   mov ax , 0xb800
   mov es , ax 
   mov di , 0 
nextloc :
   mov word[es : di] , 0x0720
   add di , 2 
   cmp di , 4000
   jne nextloc
   pop di 
   pop ax 
   pop es 
   ret 
;_____________________________________________
move_loop:
    call delay
    inc word[col]     
    cmp word[col], 79
    je Move_down
    call Print_star   
    jmp move_loop
Move_down:
    call delay
    
    inc word[row]
    cmp word[row], 20 
    je Move_back 
    call Print_star
    jmp Move_down
Move_back:
    call delay
  
    dec word[col]
    cmp word[col], 0 
    je Move_UP 
    call Print_star
    jmp Move_back
	
Move_UP: 
      call delay

    dec word[row]
    cmp word[row], 0 
    je move_loop 
    call Print_star
    jmp  Move_UP
delay:      push cx
			mov cx, 0xFFFF
loop1:		loop loop1
			mov cx, 0xFFFF
loop2:		loop loop2
			pop cx
			ret


Print_star:
    mov ax, 0xb800
    mov es, ax
    mov ax, 80
    mul word[row]    
    add ax, [col]     
    shl ax, 1         
    mov di, ax
    mov word [es:di],0x1900 | 0xDB 
    ret


terminate :
   mov ax , 0x4c00
   int 0x21 