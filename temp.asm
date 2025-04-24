[org 0x0100]
jmp start
row: dw 0      ; initial row position ( middle of screen )
col: dw 0      ; initial column position ( middle of screen )












oldisr: dd 0    ; space for saving old keyboard ISR
oldtimer: dd 0  ; space for saving old timer ISR
direction: db 0 ; 0=right, 1=left, 2=up, 3=down
mouth_state: db 0 ; 0=open, 1=closed
speed_counter: db 0 














; counter for movement speed control
;-------------------------------------------------------------------
; Keyboard   interrupt  service routine
;-------------------------------------------------------------------
kbisr:
    push ax
    in al, 0x60     
	; read a char from keyboard port    
    ; Check for key presses (scancodes)
    cmp al, 0x11    ; W key pressed (up)
    je change_up
    cmp al, 0x1F    ; S key pressed (down)
    je change_down
    cmp al, 0x1E    ; A key pressed (left)
    je change_left
    cmp al, 0x20    ; D key pressed (right)
    je change_right
    jmp nomatch     ; not our key, chain to old ISR

change_up:
    mov byte [direction], 2
    jmp exit_kb

change_down:
    mov byte [direction], 3
    jmp exit_kb

change_left:
    mov byte [direction], 1
    jmp exit_kb

change_right:
    mov byte [direction], 0
    jmp exit_kb

nomatch:
    pop ax
    jmp far [cs:oldisr] ; call the original ISR

exit_kb:
    mov al, 0x20
    out 0x20, al ; send EOI to PIC
    pop ax
    iret ; return from interrupt

;-------------------------------------------------------------------
; Timer interrupt service routine (for automatic movement)
;-------------------------------------------------------------------
timerisr:
    push ax
    push bx
    
    ; Only move every 8 timer ticks (adjust for speed)
    inc byte [speed_counter]
    cmp byte [speed_counter], 8
    jne skip_movement
    
    mov byte [speed_counter], 0
    
    ; Save current position
    mov bx, [row]
    push bx
    mov bx, [col]
    push bx
    
    ; Move according to current direction
    cmp byte [direction], 0
    je move_right_auto
    cmp byte [direction], 1
    je move_left_auto
    cmp byte [direction], 2
    je move_up_auto
    cmp byte [direction], 3
    je move_down_auto
    
move_right_auto:
    inc word [col]
    jmp update_position

move_left_auto:
    dec word [col]
    jmp update_position

move_up_auto:
    dec word [row]
    jmp update_position

move_down_auto:
    inc word [row]
    jmp update_position

update_position:
    ; Boundary checking (wrap around)
    cmp word [row], 0
    jge row_ok1
    mov word [row], 24
row_ok1:
    cmp word [row], 24
    jle row_ok2
    mov word [row], 0
row_ok2:
    cmp word [col], 0
    jge col_ok1
    mov word [col], 79
col_ok1:
    cmp word [col], 79
    jle col_ok2
    mov word [col], 0
    
col_ok2:
    ; Toggle mouth state
    xor byte [mouth_state], 1
    
    ; Erase at old position (saved on stack)
    pop bx          ; old col
    pop ax          ; old row
    push word [row] ; save new row
    push word [col] ; save new col
    mov [col], bx
    mov [row], ax
    call erase
    pop word [col]  ; restore new col
    pop word [row]  ; restore new row
    
    ; Draw at new position
    call print_pacman

skip_movement:
    pop bx
    pop ax
    jmp far [cs:oldtimer] ; chain to original timer ISR

;-------------------------------------------------------------------
; Subroutines
;-------------------------------------------------------------------
erase:
    push ax
    push es
    push di
    
    mov ax, 0xb800
    mov es, ax
    mov ax, 80
    mul word [row]
    add ax, [col]
    shl ax, 1
    mov di, ax
    mov word [es:di], 0x0720 ; space with normal attribute
    
    pop di
    pop es
    pop ax
    ret

print_pacman:
    push ax
    push es
    push di
    
    mov ax, 0xb800
    mov es, ax
    mov ax, 80
    mul word [row]
    add ax, [col]
    shl ax, 1
    mov di, ax
    
    ; Choose character based on direction and mouth state
    cmp byte [mouth_state], 0
    je mouth_open
    
    ; Closed mouth (circle)
    mov word [es:di], 0x0E0F ; yellow circle
    jmp done_drawing
    
mouth_open:
    ; Open mouth - direction determines which character
    cmp byte [direction], 0
    je face_right
    cmp byte [direction], 1
    je face_left
    cmp byte [direction], 2
    je face_up
    
    ; Face down
    mov word [es:di], 0x0E1E ; yellow down-facing pacman
    jmp done_drawing
    
face_right:
    mov word [es:di], 0x0E3E ; yellow right-facing pacman
    jmp done_drawing
    
face_left:
    mov word [es:di], 0x0E3C ; yellow left-facing pacman
    jmp done_drawing
    
face_up:
    mov word [es:di], 0x0E1F ; yellow up-facing pacman
    
done_drawing:
    pop di
    pop es
    pop ax
    ret

clrscr:
    push ax
    push es
    push di
    
    mov ax, 0xb800
    mov es, ax
    mov di, 0
    
nextloc:
    mov word [es:di], 0x0720
    add di, 2
    cmp di, 4000
    jne nextloc
    
    pop di 
    pop es
    pop ax
    ret

;-------------------------------------------------------------------
start:
    ; Save old keyboard ISR
    xor ax, ax
    mov es, ax
    mov ax, [es:9*4]
    mov [oldisr], ax
    mov ax, [es:9*4+2]
    mov [oldisr+2], ax
    
    ; Save old timer ISR
    mov ax, [es:8*4]
    mov [oldtimer], ax
    mov ax, [es:8*4+2]
    mov [oldtimer+2], ax
    
    ; Install new keyboard ISR
    cli
    mov word [es:9*4], kbisr
    mov [es:9*4+2], cs
    
    ; Install new timer ISR
    mov word [es:8*4], timerisr
    mov [es:8*4+2], cs
    sti
    
    ; Clear screen and print initial pacman
    call clrscr
    call print_pacman
    
    ; Terminate and stay resident
    mov dx, start
    add dx, 15
    mov cl, 4
    shr dx, cl
    mov ax, 0x3100
    int 0x21
	