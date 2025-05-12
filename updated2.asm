[org 0x0100]
jmp start

%include "Gamemap.asm"

; Game state variables
row: dw 10   ; initial row position of Pacman
col: dw 40   ; initial column position of Pacman
direction: db 0  ; 0=right, 1=left, 2=up, 3=down
mouth_state: db 0 ; 0=open, 1=closed
speed_counter: db 0 
random_seed: dw 0xABCD  ; Seed for random number generator
ghosts:
    ; ghost 1
    dw 5, 20
    db 0
    db 0x4C     ; red
    ; ghost 2
    dw 5, 20
    db 1
    db 0x4C     ; yellow
    ; ghost 3
    dw 5, 20
    db 2
    db 0x4C     ; pink
    ; ghost 4
    dw 5, 20
    db 3
    db 0x4C     ; cyan
    ; ghost 5
    dw 15, 20
    db 0
    db 0x4C     ; red
    ; ghost 6
    dw 15, 20
    db 1
    db 0x4C     ; yellow
    ; ghost 7
    dw 15, 20
    db 2
    db 0x4C     ; pink
    ; ghost 8
    dw 15, 20
    db 3
    db 0x4C     ; cyan

oldisr: dd 0    ; space for saving old keyboard ISR
oldtimer: dd 0  ; space for saving old timer ISR

; -------------------------------------------------------------------
; Keyboard interrupt service routine
; -------------------------------------------------------------------

kbisr:
    push ax
    in al, 0x60     ; read a char from keyboard port    
    
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

; -------------------------------------------------------------------
; Timer interrupt service routine (for automatic movement)
; -------------------------------------------------------------------
timerisr:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    
    ; Only move every 8 timer ticks (adjust for speed)
    inc byte [speed_counter]
    cmp byte [speed_counter], 2
    jne skip_movement
    
    mov byte [speed_counter], 0
    
    ; ----------------------------
    ; Move Pacman
    ; ----------------------------
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
    jmp check_pacman_move

move_left_auto:
    dec word [col]
    jmp check_pacman_move

move_up_auto:
    dec word [row]
    jmp check_pacman_move

move_down_auto:
    inc word [row]
    
check_pacman_move:
    ; Check if new position is valid (path = 1)
    call check_position_valid
    jc invalid_pacman_move
    
    ; Position is valid
    jmp update_pacman_position
    
invalid_pacman_move:
    ; Restore old position
    pop word [col]
    pop word [row]
    push word [row]
    push word [col]
    
    ; Choose a new random direction that is valid
    call find_valid_direction
    mov [direction], al
    
update_pacman_position:
    ; Toggle mouth state
    xor byte [mouth_state], 1
    
    ; Erase at old position (saved on stack)
    pop bx          ; old col
    pop ax          ; old row
    push word [row] ; save new row
    push word [col] ; save new col
    mov [col], bx
    mov [row], ax
    call erase_pacman
    pop word [col]  ; restore new col
    pop word [row]  ; restore new row
    
    ; Draw at new position
    call print_pacman
    
    ; ----------------------------
    ; Move Ghosts
    ; ----------------------------
    mov si, ghosts
    mov cx, 8
    
ghost_loop:
    ; Save current ghost position
    push word [si]      ; row
    push word [si+2]    ; col
    
    ; 25% chance to change direction randomly
    call random_byte
    and al, 0x03       ; 0-3
    cmp al, 0          ; 25% chance
    jne no_dir_change
    
    ; Try to find a new valid direction
    call find_valid_direction
    mov [si+4], al     ; update ghost direction
    
no_dir_change:
    ; Move ghost according to its direction
    mov al, [si+4]      ; direction
    cmp al, 0
    je ghost_right
    cmp al, 1
    je ghost_left
    cmp al, 2
    je ghost_up
    cmp al, 3
    je ghost_down
    
ghost_right:
    inc word [si+2]     ; col++
    jmp check_ghost_move

ghost_left:
    dec word [si+2]     ; col--
    jmp check_ghost_move

ghost_up:
    dec word [si]       ; row--
    jmp check_ghost_move

ghost_down:
    inc word [si]       ; row++
    
check_ghost_move:
    ; Check if new position is valid (path = 1)
    mov ax, [si]
    mov bx, [si+2]
    call check_position_valid
    jc invalid_ghost_move
    
    ; Position is valid
    jmp update_ghost_position
    
invalid_ghost_move:
    ; Restore old position
    pop word [si+2]     ; col
    pop word [si]       ; row
    push word [si]      ; row
    push word [si+2]    ; col
    
    ; Find a new valid direction for this ghost
    call find_valid_direction
    mov [si+4], al      ; update ghost direction
    
update_ghost_position:
    ; Erase at old position (saved on stack)
    pop bx              ; old col
    pop ax              ; old row
    push word [si]      ; save new row
    push word [si+2]    ; save new col
    mov [si+2], bx      ; temp set to old col
    mov [si], ax        ; temp set to old row
    call erase_ghost
    pop word [si+2]     ; restore new col
    pop word [si]       ; restore new row
    
    ; Draw at new position
    call print_ghost
    
    ; Move to next ghost
    add si, 6
    loop ghost_loop
    
skip_movement:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    jmp far [cs:oldtimer] ; chain to original timer ISR

; -------------------------------------------------------------------
; Improved Random Functions
; -------------------------------------------------------------------

; Generate a random byte in AL using XOR shift algorithm
random_byte:
    push bx
    push dx
    
    mov ax, [random_seed]
    mov bx, ax
    shl ax, 7
    xor ax, bx
    mov bx, ax
    shr ax, 9
    xor ax, bx
    mov bx, ax
    shl ax, 8
    xor ax, bx
    mov [random_seed], ax
    
    pop dx
    pop bx
    ret

; Find a valid direction from current position (for ghosts and pacman)
; Input: SI points to entity (ghost or use [row],[col] for pacman)
; Output: AL = direction (0-3)
find_valid_direction:
    push cx
    push si
    
    ; Try up to 4 random directions until we find a valid one
    mov cx, 4
    
try_direction:
    call random_byte
    and al, 0x03       ; 0-3
    
    ; Check if this direction is valid
    push ax
    push bx
    
    ; Get current position
    cmp si, ghosts
    jb pacman_direction
    ; Ghost position
    mov bx, [si+2]     ; col
    mov ax, [si]       ; row
    jmp check_dir
    
pacman_direction:
    mov ax, [row]
    mov bx, [col]
    
check_dir:
    push bp         ; save old bp
    mov bp, sp      ; set up base pointer
    cmp byte [bp+2], 0
    je check_right
    cmp byte [bp+2], 1
    je check_left
    cmp byte [bp+2], 2
    je check_up
    pop bp          ; restore bp before continuing

    ; Check down
    inc ax
    jmp do_check
    
check_right:
    inc bx
    jmp do_check
    
check_left:
    dec bx
    jmp do_check
    
check_up:
    dec ax
    
do_check:
    call check_position_valid
    pop bx
    pop ax
    jnc valid_dir_found
    
    loop try_direction
    
    ; If all directions fail, return current direction (or random if pacman)
    cmp si, ghosts
    jb random_dir
    mov al, [si+4]     ; current ghost direction
    jmp dir_done
    
random_dir:
    call random_byte
    and al, 0x03
    
valid_dir_found:
dir_done:
    pop si
    pop cx
    ret

; Check if position (ax=row, bx=col) is valid (path = 1)
; Returns CF=1 if invalid, CF=0 if valid
check_position_valid:
    push ax
    push bx
    push si
    
    ; Boundary check
    cmp ax, 0
    jl invalid_position
    cmp ax, 24
    jg invalid_position
    cmp bx, 0
    jl invalid_position
    cmp bx, 79
    jg invalid_position
    
    ; Map check - must be path (1)
    mov si, ax
    mov ax, 80
    mul si
    add ax, bx
    lea si, [map]
    add si, ax
    cmp byte [si], 1   ; 1 is path
    jne invalid_position
    
    ; Position is valid
    clc
    jmp position_check_done
    
invalid_position:
    stc
    
position_check_done:
    pop si
    pop bx
    pop ax
    ret

; -------------------------------------------------------------------
; Drawing functions
; -------------------------------------------------------------------

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

erase_pacman:
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
    
    ; Check if we need to restore a wall or empty space
    mov ax, [row]
    mov bx, [col]
    call check_map_value
    cmp al, 1
    je restore_path
    
    ; Restore whatever was there originally
    cmp al, 2
    je restore_wall
    cmp al, 3
    je restore_red
    cmp al, 4
    je restore_yellow
    cmp al, 5
    je restore_green
    
    ; Default to empty space
    mov word [es:di], 0x0720
    jmp erase_done
    
restore_path:
    mov word [es:di], 0x0720 ; space
    jmp erase_done
    
restore_wall:
    mov word [es:di], 0x1900 | 0xDB ; blue wall
    jmp erase_done
    
restore_red:
    mov word [es:di], 0x0C00 | 0xDB ; red
    jmp erase_done
    
restore_yellow:
    mov word [es:di], 0x0E00 | 0xDB ; yellow
    jmp erase_done
    
restore_green:
    mov word [es:di], 0x0A00 | 0xDB ; green
    
erase_done:
    pop di
    pop es
    pop ax
    ret

print_ghost:
    ; SI points to ghost structure
    push ax
    push es
    push di
    
    mov ax, 0xb800
    mov es, ax
    mov ax, 80
    mul word [si]    ; row
    add ax, [si+2]  ; col
    shl ax, 1
    mov di, ax
    
    ; Print ghost (color from ghost structure)
    mov al, 0x01    ; smiley face character
    mov ah, [si+5]  ; ghost color
    mov [es:di], ax
    
    pop di
    pop es
    pop ax
    ret

erase_ghost:    
    push ax
    push es
    push di
    
    mov ax, 0xb800
    mov es, ax
    mov ax, 80
    mul word [si]    ; row
    add ax, [si+2]  ; col
    shl ax, 1
    mov di, ax
    
    ; Check what was originally there
    mov ax, [si]    ; row
    mov bx, [si+2]  ; col
    call check_map_value
    
    ; Restore original map element
    cmp al, 1
    je ghost_restore_path
    cmp al, 2
    je ghost_restore_wall
    cmp al, 3
    je ghost_restore_red
    cmp al, 4
    je ghost_restore_yellow
    cmp al, 5
    je ghost_restore_green
    
    ; Default to empty space
    mov word [es:di], 0x0720
    jmp ghost_erase_done
    
ghost_restore_path:
    mov word [es:di], 0x0720 ; space
    jmp ghost_erase_done
    
ghost_restore_wall:
    mov word [es:di], 0x1900 | 0xDB ; blue wall
    jmp ghost_erase_done
    
ghost_restore_red:
    mov word [es:di], 0x0C00 | 0xDB ; red
    jmp ghost_erase_done
    
ghost_restore_yellow:
    mov word [es:di], 0x0E00 | 0xDB ; yellow
    jmp ghost_erase_done
    
ghost_restore_green:
    mov word [es:di], 0x0A00 | 0xDB ; green
    
ghost_erase_done:
    pop di
    pop es
    pop ax
    ret

; Get map value at position (ax=row, bx=col)
; Returns al = map value
check_map_value:
    push si
    
    ; offset = row * 80 + col
    mov si, ax
    mov ax, 80
    mul si
    add ax, bx
    lea si, [map]
    add si, ax
    mov al, [si]
    
    pop si
    ret

; -------------------------------------------------------------------
; Initialization and main loop
; -------------------------------------------------------------------
start:
    ; Initialize random seed with timer value
    mov ah, 0x00
    int 0x1A
    mov [random_seed], dx
    
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
    
    ; Clear screen and print initial game state
    call clear_screen
    call print_map
    
    ; Place Pacman on a valid path position
    call place_on_valid_path
    mov [row], ax
    mov [col], bx
    call print_pacman
    
    ; Place ghosts on valid path positions
    mov si, ghosts
    mov cx, 8
place_ghosts:
    call place_on_valid_path
    mov [si], ax      ; row
    mov [si+2], bx    ; col
    call print_ghost
    add si, 6
    loop place_ghosts
    
    ; Terminate and stay resident
    mov dx, start
    add dx, 15
    mov cl, 4
    shr dx, cl
    mov ax, 0x3100
    int 0x21

; Find a random valid path position (1 in map)
; Returns: AX = row, BX = col
place_on_valid_path:
    push cx
    push dx
    push si
    
find_valid_spot:
    call random_byte
    and al, 0x1F      ; 0-31
    cmp al, 25
    jge find_valid_spot ; row must be 0-24
    mov ah, 0
    push ax            ; save row
    
    call random_byte
    and al, 0x7F      ; 0-127
    cmp al, 80
    jge find_valid_spot ; col must be 0-79
    mov bl, al
    mov bh, 0
    pop ax            ; restore row
    
    ; Check if this position is path (1)
    call check_map_value
    cmp al, 1
    jne find_valid_spot
    
    ; Found valid position
    pop si
    pop dx
    pop cx
    ret

; -------------------------------------------------------------------
; Screen and map drawing functions
; -------------------------------------------------------------------
clear_screen:
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

print_map:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    
    mov ax, 0xb800
    mov es, ax
    xor si, si          ; row = 0
    
outer_loop:
    cmp si, 25
    jg done_print
    
    xor di, di          ; col = 0

inner_loop:
    cmp di, 80
    jge next_row

    ; offset = row * 80 + col
    mov ax, si
    mov bx, 80
    mul bx              ; ax = row * 80
    add ax, di          ; ax = offset

    lea bx, [map]
    add bx, ax          ; bx = address of map[row][col]

    mov al, [bx]
    cmp al, 2
    je print_Blue 
    cmp al, 3 
    je print_o
    cmp al, 4 
    je print_yellow 
    cmp al, 5 
    je print_green
    cmp al, 10 
    je print_coins
    jmp skip_print
    
print_o:
    push di             ; Save column counter
    mov ax, si
    mov dx, 80
    mul dx              ; ax = row * 80
    add ax, di          ; ax = row * 80 + col
    shl ax, 1           ; multiply by 2 (char+attr)
    mov di, ax          ; DI now holds video memory offset
    mov ax, 0x0C00 | 0xDB  ; attr 0x0C (light red), char 0xDB
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
    mov ax, 0x0E00 | 0xDB  ; attr 0x0E (yellow), char 0xDB
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
    mov ax, 0x0A00 | 0xDB  ; attr 0x0A (green), char 0xDB
    mov [es:di], ax
    pop di 
    jmp skip_print
   
print_coins:
    push di             ; Save column counter
    mov ax, si
    mov dx, 80
    mul dx              ; ax = row * 80
    add ax, di          ; ax = row * 80 + col
    shl ax, 1           ; multiply by 2 (char+attr)
    mov di, ax          ; DI now holds video memory offset
    mov ax, 0x0E00 | 0x2A   ; yellow asterisk for coin
    mov [es:di], ax
    pop di 
    jmp skip_print
    
print_Blue: 
    push di             ; Save column counter
    mov ax, si
    mov dx, 80
    mul dx              ; ax = row * 80
    add ax, di          ; ax = row * 80 + col
    shl ax, 1           ; multiply by 2 (char+attr)
    mov di, ax          ; DI now holds video memory offset
    mov ax, 0x1900 | 0xDB  ; attr 0x19 (blue), char 0xDB
    mov [es:di], ax
    pop di      
    
skip_print:
    inc di
    jmp inner_loop

next_row:
    inc si
    jmp outer_loop

done_print:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret