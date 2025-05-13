[org 0x0100]
jmp start

; Game data variables
%include "Gamemap.asm"
row: dw 10      ; initial row position of Pacman
col: dw 40      ; initial column position of Pacman
direction: db 0 ; 0=right, 1=left, 2=up, 3=down
mouth_state: db 0 ; 0=open, 1=closed
speed_counter: db 0 
game_state: db 0 ; 0=menu, 1=playing, 2=game over
selected_option: db 0 ; 0=start, 1=instructions, 2=exit
blink_counter: db 0 ; Counter for blinking effect
score: dw 0     ; Player score
dots_eaten: db 0 ; Count of dots eaten

; ASCII art and menu text
title_line1: db ".______      ___         ______ .___   ___.      ___      . __    __.", 0
title_line2: db "|   _  \\   /   \\     /       ||   \\/   |     /   \\     |  \\ |  |", 0
title_line3: db "|  |_)  |  /  ^  \\   |  ,----' |  \\  /  |    /  ^  \\    |   \\|  |", 0
title_line4: db "|   ___/  /  /_\\ \\  |  |      |  |\\/|  |   /  /_\\ \\   |  . `   |", 0
title_line5: db "|  |     /  ____ _ \\ |  `----. |  |   |  |  /  _____  \\  |  |\\   |", 0
title_line6: db "| _|    /__/     \\_\\ \\______||__|   |__| /__/     \\_\\ |__| \\__|", 0

menu_start: db 'START GAME', 0
menu_instructions: db 'INSTRUCTIONS', 0
menu_exit: db 'EXIT', 0
instructions_text: db 'USE WASD KEYS TO MOVE', 0
instructions_text2: db 'ESC TO RETURN TO MENU', 0
instructions_text3: db 'EAT DOTS, AVOID GHOSTS!', 0
game_over_text: db 'GAME OVER!', 0
press_any_key: db 'PRESS ANY KEY', 0
score_text: db 'SCORE: ', 0
team_names: db 'TEAM: HASSAN KHAN & MINAHIL', 0
roll_numbers: db 'ROLL NO: 23L-0800 & 23L-0877', 0

; Ghost data
ghosts:
    dw 5, 20, 0, 0x4C ; row, col, direction, color
    dw 5, 30, 1, 0x4E
    dw 5, 40, 2, 0x4D
    dw 5, 50, 3, 0x4B

; Interrupt vectors
oldtimer: dd 0
oldkbisr: dd 0

; Clear screen function
clear_screen:
    push ax
    push es
    push di
    mov ax, 0xb800
    mov es, ax
    mov di, 0
    mov ax, 0x0720 ; space with normal attribute
    mov cx, 2000
    rep stosw
    pop di
    pop es
    pop ax
    ret

print_string:
    push ax
    push si
    push di
    push es
    push bx
    mov bx, 0xb800
    mov es, bx
    
    cmp bl, 1
    jne .print_loop
    or ah, 0x80 ; Set blink bit
    
.print_loop:
    lodsb
    cmp al, 0
    je .done
    stosw
    jmp .print_loop
.done:
    pop bx
    pop es
    pop di
    pop si
    pop ax
    ret

; Draw menu selection indicator
draw_selection:
    push ax
    push di
    mov ax, 0xb800
    mov es, ax
    

    mov di, (14*80 + 35)*2 
    mov word [es:di-4], 0x0720
    mov di, (16*80 + 35)*2 
    mov word [es:di-4], 0x0720
    mov di, (18*80 + 35)*2 
    mov word [es:di-4], 0x0720
    

    cmp byte [selected_option], 0
    je .start_selected
    cmp byte [selected_option], 1
    je .instructions_selected
    jmp .exit_selected
    
.start_selected:
    mov di, (14*80 + 35)*2
    jmp .draw
.instructions_selected:
    mov di, (16*80 + 35)*2
    jmp .draw
.exit_selected:
    mov di, (18*80 + 35)*2
    
.draw:
    mov word [es:di-4], 0x0E3E 
    pop di
    pop ax
    ret

; Show main menu
show_menu:
    call clear_screen
    
    inc byte [blink_counter]
    and byte [blink_counter], 0x0F
    
    ; Draw title
    mov si, title_line1
    mov di, (3*80 + 5)*2
    mov ah, 0x0E
    mov bl, 0
    call print_string
    
    mov si, title_line2
    mov di, (4*80 + 5)*2
    mov ah, 0x0E
    mov bl, 1
    call print_string
    
    mov si, title_line3
    mov di, (5*80 + 5)*2
    mov ah, 0x0E
    mov bl, 0
    call print_string
    
    mov si, title_line4
    mov di, (6*80 + 5)*2
    mov ah, 0x0E
    mov bl, 1
    call print_string
    
    mov si, title_line5
    mov di, (7*80 + 5)*2
    mov ah, 0x0E
    mov bl, 0
    call print_string
    
    mov si, title_line6
    mov di, (8*80 + 5)*2
    mov ah, 0x0E
    mov bl, 1
    call print_string
    
    ; Draw team info
    mov si, team_names
    mov di, (10*80 + 28)*2
    mov ah, 0x0B
    mov bl, 0
    call print_string
    
    mov si, roll_numbers
    mov di, (12*80 + 28)*2
    mov ah, 0x0B
    mov bl, 0
    call print_string
    
    ; Draw menu options
    mov si, menu_start
    mov di, (14*80 + 35)*2
    mov ah, 0x0F
    mov bl, 0
    call print_string
    
    mov si, menu_instructions
    mov di, (16*80 + 35)*2
    mov ah, 0x0F
    mov bl, 0
    call print_string
    
    mov si, menu_exit
    mov di, (18*80 + 35)*2
    mov ah, 0x0F
    mov bl, 0
    call print_string
    
    call draw_selection
    ret

; Show instructions screen
show_instructions:
    call clear_screen
    
    mov si, title_line1
    mov di, (3*80 + 11)*2
    mov ah, 0x0E
    mov bl, 0
    call print_string
    
    mov si, team_names
    mov di, (5*80 + 28)*2
    mov ah, 0x0B
    mov bl, 0
    call print_string
    
    mov si, instructions_text
    mov di, (10*80 + 30)*2
    mov ah, 0x0F
    mov bl, 0
    call print_string
    
    mov si, instructions_text2
    mov di, (12*80 + 30)*2
    mov ah, 0x0F
    mov bl, 0
    call print_string
    
    mov si, instructions_text3
    mov di, (14*80 + 30)*2
    mov ah, 0x0F
    mov bl, 0
    call print_string
    
    mov si, press_any_key
    mov di, (22*80 + 34)*2
    mov ah, 0x0A
    mov bl, 0
    call print_string
    
    ret

; Show game over screen
show_game_over:
    call clear_screen
    
    mov si, game_over_text
    mov di, (10*80 + 35)*2
    mov ah, 0x0C
    mov bl, 0
    call print_string
    
    mov si, team_names
    mov di, (12*80 + 28)*2
    mov ah, 0x0B
    mov bl, 0
    call print_string
    
    ; Display final score
    mov si, score_text
    mov di, (14*80 + 35)*2
    mov ah, 0x0F
    mov bl, 0
    call print_string
    
  
    mov ax, [score]
    mov di, (14*80 + 42)*2
    call display_number
    
    mov si, press_any_key
    mov di, (16*80 + 34)*2
    mov ah, 0x0A
    mov bl, 0
    call print_string
    
    ret


display_number:
    push ax
    push bx
    push cx
    push dx
    push di
    
    mov bx, 10
    mov cx, 0
    

    cmp ax, 0
    jne .convert
    mov word [es:di], 0x0F30 ; '0' in white
    jmp .done
    
.convert:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz .convert
    
.display:
    pop ax
    mov ah, 0x0F ; white color
    stosw
    loop .display
    
.done:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret


check_position_valid:
    push ax
    push bx
    push si
    

    mov si, map
    mov dx, 80
    mul dx
    add ax, bx
    add si, ax
    

    cmp byte [si], 1
    je .valid
    cmp byte [si], 10
    je .valid
    jmp .invalid
    
.valid:
    cmp byte [si], 10
    jne .not_dot

    mov byte [si], 1
    add word [score], 10 ; Add 10 points for each dot
    inc byte [dots_eaten]
    
.not_dot:
    xor ax, ax ; Set zero flag
    jmp .done
    
.invalid:
    or ax, 1 ; Clear zero flag
    
.done:
    pop si
    pop bx
    pop ax
    ret

; Keyboard interrupt handler
kbisr:
    push ax
    push es
    
    in al, 0x60
    
    cmp byte [game_state], 0
    je .menu_controls
    cmp byte [game_state], 1
    je .game_controls
    jmp .exit
    
.menu_controls:
    cmp al, 0x48 ; up arrow
    je .up_pressed
    cmp al, 0x50 ; down arrow
    je .down_pressed
    cmp al, 0x1C ; enter
    je .enter_pressed
    jmp .exit
    
.up_pressed:
    cmp byte [selected_option], 0
    jle .exit
    dec byte [selected_option]
    call draw_selection
    jmp .exit
    
.down_pressed:
    cmp byte [selected_option], 2
    jge .exit
    inc byte [selected_option]
    call draw_selection
    jmp .exit
    
.enter_pressed:
    cmp byte [selected_option], 0
    je .start_game
    cmp byte [selected_option], 1
    je .show_instr
    jmp .exit_game
    
.start_game:
    mov byte [game_state], 1
    call clear_screen
    ; Initialize game state here
    mov word [row], 10
    mov word [col], 40
    mov byte [direction], 0
    mov word [score], 0
    mov byte [dots_eaten], 0
    jmp .exit
    
.show_instr:
    call show_instructions
    jmp .exit
    
.exit_game:
    mov ax, 0x4c00
    int 0x21
    
.game_controls:
    cmp al, 0x01 ; ESC
    je .return_to_menu
    cmp al, 0x11 ; W key
    je .up_pressed_game
    cmp al, 0x1F ; S key
    je .down_pressed_game
    cmp al, 0x1E ; A key
    je .left_pressed_game
    cmp al, 0x20 ; D key
    je .right_pressed_game
    jmp .exit
    
.return_to_menu:
    mov byte [game_state], 0
    call show_menu
    jmp .exit
    
.up_pressed_game:
    mov byte [direction], 2
    jmp .exit
.down_pressed_game:
    mov byte [direction], 3
    jmp .exit
.left_pressed_game:
    mov byte [direction], 1
    jmp .exit
.right_pressed_game:
    mov byte [direction], 0
    
.exit:
    mov al, 0x20
    out 0x20, al
    pop es
    pop ax
    iret


update_pacman:
    push ax
    push bx
    

    inc byte [speed_counter]
    cmp byte [speed_counter], 5
    jb .skip_mouth_update
    mov byte [speed_counter], 0
    xor byte [mouth_state], 1
.skip_mouth_update:


    mov ax, [row]
    mov bx, [col]
    
    mov cl, [direction]
    cmp cl, 0
    je .check_right
    cmp cl, 1
    je .check_left
    cmp cl, 2
    je .check_up
    cmp cl, 3
    je .check_down
    jmp .done
    
.check_right:
    inc bx
    call check_position_valid
    jnz .done
    inc word [col]
    jmp .done
.check_left:
    dec bx
    call check_position_valid
    jnz .done
    dec word [col]
    jmp .done
.check_up:
    dec ax
    call check_position_valid
    jnz .done
    dec word [row]
    jmp .done
.check_down:
    inc ax
    call check_position_valid
    jnz .done
    inc word [row]
    
.done:
    pop bx
    pop ax
    ret


calculate_screen_position:
    push ax
    push bx
    push dx
    
    mov di, 0xb800
    mov es, di
    
    mov di, 80
    mul di
    add ax, bx
    shl ax, 1
    mov di, ax
    
    pop dx
    pop bx
    pop ax
    ret

; Draw the game map
draw_map:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, 0xb800
    mov es, ax          ; Set ES to video memory

    mov si, map         ; SI points to the map data
    xor bx, bx          ; Row index

.row_loop:
    cmp bx, 25
    jge .done

    xor cx, cx          ; Column index

.col_loop:
    cmp cx, 80
    jge .next_row

    ; Calculate screen offset: (row * 80 + col) * 2
    mov ax, bx
    mov dx, 80
    mul dx
    add ax, cx
    shl ax, 1
    mov di, ax          ; DI holds video memory offset

    ; Get map value
    mov al, [si]
    inc si

    cmp al, 1
    je .path_tile
    cmp al, 2
    je .print_blue
    cmp al, 3
    je .print_o
    cmp al, 4
    je .print_yellow
    cmp al, 5
    je .print_green
    cmp al, 10
    je .print_dot
    jmp .skip_print     

.print_blue:
    mov ax, 0x1900 | 0xDB   
    mov [es:di], ax
    jmp .skip_print

.print_o:
    mov ax, 0x0C00 | 0xDB    
    mov [es:di], ax
    jmp .skip_print

.print_yellow:
    mov ax, 0x0E00 | 0xDB    
    mov [es:di], ax
    jmp .skip_print

.print_green:
    mov ax, 0x0A00 | 0xDB    
    mov [es:di], ax
    jmp .skip_print

.path_tile:
    mov ax, 0x0700 | ' '    
    mov [es:di], ax
    jmp .skip_print

.print_dot:
    mov ax, 0x0E00 | 0x2A   
    mov [es:di], ax

.skip_print:
    inc cx
    jmp .col_loop

.next_row:
    inc bx
    jmp .row_loop

.done:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    
; Draw Pacman
draw_pacman:
    push ax
    push bx
    push di
    
    mov ax, [row]
    mov bx, [col]
    call calculate_screen_position
    
    mov ax, 0x0E43
    cmp byte [mouth_state], 1
    jne .draw
    mov ax, 0x0E4F
.draw:
    mov [es:di], ax
    
    pop di
    pop bx
    pop ax
    ret

; Draw score
draw_score:
    push ax
    push si
    push di
    
    mov si, score_text
    mov di, (0*80 + 70)*2
    mov ah, 0x0F
    mov bl, 0
    call print_string
    
    mov ax, [score]
    mov di, (0*80 + 77)*2
    call display_number
    
    pop di
    pop si
    pop ax
    ret















; Main game initialization
init_game:
    xor ax, ax
    mov es, ax
    mov ax, [es:9*4]
    mov [oldkbisr], ax
    mov ax, [es:9*4+2]
    mov [oldkbisr+2], ax
    
    cli
    mov word [es:9*4], kbisr
    mov [es:9*4+2], cs
    sti
    
    mov byte [game_state], 0
    mov byte [selected_option], 0
    call show_menu
    ret

; Main game loop
game_loop:
    cmp byte [game_state], 0
    je .menu_state
    cmp byte [game_state], 1
    je .game_state
    jmp .game_over_state
    
.menu_state:
    jmp .end_loop
    
.game_state:
    call update_pacman
  ;  call clear_screen
    call draw_map 
	;call draw_Ghosts
    call draw_pacman
    call draw_score
   
    
    jmp .end_loop
    
.game_over_state:
    call show_game_over
    mov ah, 0
    int 0x16
    mov byte [game_state], 0
    call show_menu
    
.end_loop:
    ; Delay loop
    mov cx, 0xFFFF
.delay:
    loop .delay
    
    jmp game_loop

start:
    mov ax, cs
    mov ds, ax
    call init_game
    call game_loop
    
    ; Cleanup (shouldn't reach here normally)
    xor ax, ax
    mov es, ax
    mov ax, [oldkbisr]
    mov [es:9*4], ax
    mov ax, [oldkbisr+2]
    mov [es:9*4+2], ax
    
    mov ax, 0x4c00
    int 0x21
