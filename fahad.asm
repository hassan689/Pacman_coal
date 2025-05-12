; [org 0x0100]

; jmp start 

; tick_counter dw 0          ; Tracks timer ticks (1 tick ≈ 55 ms)
; second_counter dw 0        ; Tracks seconds passed
; oldisr: dd 0               ; Stores old interrupt vector




; print:
    ; push bp
    ; mov bp, sp
    ; push es
    ; push ax
    ; push bx
    ; push cx
    ; push dx
    ; push di
    ; mov ax, 0xb800
    ; mov es, ax
    ; mov ax, [bp+4]
    ; mov bx, 10
    ; mov cx, 0

; nextDigit:
    ; mov dx, 0
    ; div bx
    ; add dl, 0x30
    ; push dx
    ; inc cx
    ; cmp ax, 0
    ; jnz nextDigit

    ; mov di, 300

; nextPos:
    ; pop dx
    ; mov dh, 0x74
    ; mov [es:di], dx
    ; add di, 2
    ; loop nextPos

    ; pop di
    ; pop dx
    ; pop cx
    ; pop bx
    ; pop ax
    ; pop es
    ; pop bp
    ; ret 2

; timer:
    ; push ax
    ; push bx
    ; inc word [cs:tick_counter]
    ; mov ax, [cs:tick_counter]
    ; cmp ax, 18               ; Check if 18 ticks (≈ 1 second) have elapsed
    ; jl skip_increment        ; If not, skip incrementing the second counter
    ; mov word [cs:tick_counter], 0 ; Reset tick counter
    ; inc word [cs:second_counter]  ; Increment second counter
    ; push word [cs:second_counter]
    ; call print               ; Print the updated second counter
; skip_increment:
    ; mov al, 0x20
    ; out 0x20, al
    ; pop bx
    ; pop ax
    ; iret
                 







                 
; clearScreen:
    ; mov ax, 0B800h        
    ; mov es, ax            
    ; xor di, di             
    ; mov cx, 2000           
    ; mov ax, 0x7420        
; clearLoop:
    ; stosw                 
    ; loop clearLoop        
    ; ret



; printString:

    ; mov ax, 0xB800      
    ; mov es, ax           

; nextChar:

    ; lodsb                ; Load the next character from [DS:SI] into AL and advance SI
    ; cmp al, 0            ; Check if it's the null terminator
    ; je done              ; If null terminator, stop printing

    ; mov [es:di], al      
    ; mov byte [es:di + 1], 0x74	
    ; add di, 2            

    ; jmp nextChar         

; done:
           
    ; ret                




; waitForEnter:
    ; mov ah, 00h           ; BIOS function for reading a keypress
    ; int 16h               ; Wait for a key press
    ; cmp al, 0Dh           ; Check if it's Enter (0Dh is ASCII for Enter)
    ; jne waitForEnter      ; If not Enter, wait again
    ; ret
  

; mainMenu:
    ; call clearScreen      
    ; mov si, menuMsg       
    ; call printString   
    ; ret

; quitGame:
    ; mov ax, 4C00h         ; Terminate the program
    ; int 21h

; printThickBorder:

    ; mov si, thickBorder    
    ; call printString         
    ; ret

; printRowBlock1:
    ; mov si, row1
    ; mov di, 1320 
    ; call printString
    ; mov si, row2
    ; mov di, 1480
    ; call printString
    ; mov si, row3
    ; mov di, 1640
    ; call printString
    ; ret

; printRowBlock2:
    ; mov si, row4
    ; mov di, 1960
    ; call printString
    ; mov si, row5
    ; mov di, 2120
    ; call printString
    ; mov si, row6
    ; mov di, 2280
    ; call printString
    ; ret

; printRowBlock3:
    ; mov si, row7 
    ; mov di, 2600
    ; call printString
    ; mov si, row8
    ; mov di, 2760
    ; call printString
    ; mov si, row9
    ; mov di, 2920
    ; call printString

    ; ret

; printRowBlock4:
    ; mov si, row10
    ; mov di, 3240
    ; call printString
    ; ret


; printGrid:



    ; mov si, tim
    ; mov di, 288         ; Set DI to position
    ; call printString



    ; mov si, topRow       
    ; mov di, 488           
    ; call printString         


    ; mov si, bottomRow    ; Load address of the bottom row string
    ; mov di, 808 
    ; call printString     ; Print the bottom row




    ; mov si, undo
    ; mov di, 648        ; Set DI to position
    ; call printString




    ; mov si, topRow       
    ; mov di, 610           
    ; call printString         


    ; mov si, bottomRow    ; Load address of the bottom row string
    ; mov di, 930
    ; call printString     ; Print the bottom row



    ; mov si, hint
    ; mov di, 770         ; Set DI to position 
    ; call printString




    ; mov si, mistakes 
    ; mov di, 170         ; Set DI to position 
    ; call printString

    ; mov si, score
    ; mov di, 10         ; Set DI to position 
    ; call printString
   


    ; mov di , 1160
    ; call printThickBorder
    ; call printRowBlock1
    ; mov di , 1800
    ; call printThickBorder
    ; call printRowBlock2
    ; mov di , 2440
    ; call printThickBorder
    ; call printRowBlock3
    ; mov di , 3080
    ; call printThickBorder
    ; call printRowBlock4
    ; mov di , 3400
    ; call printThickBorder
    ; ret

; printGameOver:

    ; mov si, gameOverMsg  
    ; mov di , 196      
    ; call printString 


    ; mov si, winner 
    ; mov di, 1506         ; Set DI to position
    ; call printString

    ; mov si, score 
    ; mov di, 1666         ; Set DI to position
    ; call printString

    ; mov si, newGame 
    ; mov di, 1826         ; Set DI to position 
    ; call printString

    ; mov si, endMain 
    ; mov di, 1986         ; Set DI to position 
    ; call printString

    ; mov si, quit 
    ; mov di, 2146         ; Set DI to position 
    ; call printString

    ; ret



; printMenu:
    
    ; mov si, sudoku
    ; mov di, 226         
    ; call printString

    ; mov si, menuMsg 
    ; mov di, 1506         ; Set DI to position
    ; call printString

    ; mov si, startGameMsg
    ; mov di, 1666         ; Set DI to position
    ; call printString

    ; mov si, instructionsMsg
    ; mov di, 1826         ; Set DI to position 
    ; call printString

    ; mov si, highscoreMsg
    ; mov di, 1986         ; Set DI to position 
    ; call printString

    ; mov si, exitMsg
    ; mov di, 2146         ; Set DI to position 
    ; call printString
   
    ; ret



; difficultyMenu:
    


    ; mov si, difficulty
    ; mov di, 1006         ; Set DI to position
    ; call printString



    ; mov si, topRow       
    ; mov di, 1506           
    ; call printString         


    ; mov si, bottomRow    ; Load address of the bottom row string
    ; mov di, 1826 
    ; call printString     ; Print the bottom row

    ; mov si, easy
    ; mov di, 1666         ; Set DI to position
    ; call printString



    ; mov si, topRow       
    ; mov di, 2146
    ; call printString         


    ; mov si, bottomRow    ; Load address of the bottom row string
    ; mov di, 2466
    ; call printString     ; Print the bottom row

  

    ; mov si, medium
    ; mov di, 2306         ; Set DI to position 
    ; call printString






    ; mov si, topRow       
    ; mov di, 2786         
    ; call printString         


    ; mov si, bottomRow    ; Load address of the bottom row string
    ; mov di, 3106
    ; call printString     ; Print the bottom row

    ; mov si, hard
    ; mov di, 2946         ; Set DI to position 
    ; call printString


; ret


; PlaceInRow:
; push bp
; mov bp, sp
; pusha
; mov bx, [bp + 4]
; add bx, 2
; mov di, [bp + 6]
; mov cx, 9
; placement:
; cmp byte[buffer + di], 0
; je letGo
; mov al, [buffer + di]
; add al, 48
; mov [bx], al
; letGo:
; add bx, 4
; inc di
; loop placement
; mov [bp + 6], di
; popa
; pop bp
; ret 2

; PlaceOnBoard:
; push bp
; mov bp, sp
; pusha
; mov cx, 9
; mov bx, row1
; xor si, si
; xor di, di
; allLines:
; push di
; push bx
; call PlaceInRow
; pop di
; add bx, 38
; loop allLines
; popa
; pop bp
; ret


; checkPrev:
; push bp
; mov bp, sp
; pusha
; checkAll:
; cmp si, di
; je stop
; mov al, [buffer + si]
; cmp al, bl
; je correct
; inc si
; jmp checkAll
; stop:
; mov word[bp + 4], 1
; jmp exit
; correct:
; mov word[bp + 4], 0
; exit:
; popa
; pop bp
; ret

; boardGeneration:		;for easy dificulty(54 numbers)
; push bp
; mov bp, sp
; pusha
; xor si, si
; xor di, di 
; mov ax, 54
; mov bx, 9
; xor dx, dx
; div bx
; xor cx, cx


; l1:
; push 2
; call rand
; pop bx
; cmp bx, 0
; jne skip
; redo:
; push 9
; call rand
; pop bx
; inc bl
; push 0xCCCC
; call checkPrev
; pop dx
; cmp dx, 0
; je redo
; mov byte[buffer + di], bl
; inc di
; inc cx
; cmp cx, ax
; jne l1
; add si, 9
; mov di, si
; mov cx, 0
; cmp si, 81
; jne redo
; popa
; pop bp
; ret
; skip:
; inc di
; jmp l1

; seed_generator:		; Generating a seed to add variability in the random function( equivalent to int t = time(NULL); and srand(t); in c++
; push bp
; mov bp, sp
; push 0xCCCC			; local variable
; pusha
	; mov ah, 0x02
	; int 0x1A		; syscall to obtain cimputer time in hours, minutes and seconds
	; mov al, ch		; ch has hours, cl minutes and dh seconds
	; mov ch, dh
	; mov bx, 3600
	; mul bx
	; mov [bp - 2], ax
	; mov al, cl
	; mov dx, 60
	; mul dx
	; add al, ch
	; mov bx, [bp - 2]
	; add ax, bx
	; mov [seed], ax
; popa
; pop bp
; pop bp
; ret

; rand:
; push bp
; mov bp, sp
; pusha
	; ; Calculate new seed
	; mov ax, [seed]
    ; mov bx, 21401          ; Set multiplier (214013 / 100)
    ; mul bx            ; ax = seed * 214013 (scaled down)
    ; add ax, 25311          ; Add increment (2531011 / 100)
    
    ; ; Store the new seed
    ; mov [seed], ax         ; Update the seed

    ; ; Return value in ax
    ; mov bx, [bp + 4]   ; Assuming RAND_MAX is defined somewhere
    ; xor dx, dx             ; Clear dx for division
    ; div bx                  ; ax = ax / (RAND_MAX + 1)
	; mov [bp + 4], dx
; popa
; pop bp
	; ret









; sudoku db 'Sudoku Game!', 0
; welcomeMsg db 'Welcome to Sudoku', 0
; menuMsg db 'Main Menu:', 0
; startGameMsg db 'Start Game', 0
; instructionsMsg db 'Instructions', 0
; highscoreMsg db 'Highscore', 0
; exitMsg db 'Exit', 0

; difficulty db 'Please choose your difficulty: ', 0
; easy db '|  Easy  |', 0
; medium db '| Medium |', 0
; hard db '|  Hard  |', 0



; tim db 'Timer:', 0
; hint db '|  HINT  |', 0
; undo db '|  UNDO  |', 0
; mistakes db 'Mistakes:', 0
; topRow    db 218, 196, 196, 196, 196, 196, 196, 196, 196, 191, 0   ; ┌─────────┐
; bottomRow db 192, 196, 196, 196, 196, 196, 196, 196, 196, 217, 0   ; └─────────┘


; buffer times 81 db 0

; seed dw 0



; gameOverMsg db ' G A M E  O V E R!  THANK YOU FOR PLAYING. ', 0

; winner db 'Winner:', 0
; score db 'Score: ', 0
; time db 'Time: ', 0
; newGame db  '1) New Game', 0
; endMain db  '2) Main Menu', 0
; quit db  '3) Quit',0



; thickBorder db '+---+---+---+---+---+---+---+---+---+', 0
; numberCards: db 1,2,3,4,5,6,7,8,9

; row1: db '|   |   |   |   |   |   |   |   |   |', 0
; row2: db '|   |   |   |   |   |   |   |   |   |', 0
; row3: db '|   |   |   |   |   |   |   |   |   |', 0

; row4: db '|   |   |   |   |   |   |   |   |   |', 0
; row5: db '|   |   |   |   |   |   |   |   |   |', 0
; row6: db '|   |   |   |   |   |   |   |   |   |', 0

; row7: db '|   |   |   |   |   |   |   |   |   |', 0
; row8: db '|   |   |   |   |   |   |   |   |   |', 0
; row9: db '|   |   |   |   |   |   |   |   |   |', 0 
; row10: db '| 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |', 0

    


; start:

    ; call clearScreen        
    ; call printMenu 
    ; call waitForEnter 
    ; call clearScreen
    ; call difficultyMenu
    ; call waitForEnter 
    ; call clearScreen
	; call boardGeneration
	; call PlaceOnBoard
    ; call printGrid 



    ; xor ax,ax
    ; mov es,ax


; mov ax, [es:8*4]
; mov [oldisr], ax
; mov ax,  [es:8*4+2]
; mov [oldisr+2], ax


; cli 

; mov word [es:8*4] , timer
; mov word [es:8*4+2], cs

; sti

          
    ; call waitForEnter   



; mov ax, [oldisr]
; mov bx , [oldisr+2]

; cli 

; mov word [es:8*4] , ax
; mov word [es:8*4+2], bx

; sti
    
    ; call clearScreen              
    ; call printGameOver
    
    ; mov ax, 4C00h            
    ; int 21h
	
[org 0x0100]
jmp start

;Global Variables
musical_Score:dw 1140, 3415, 1140, 3415, 905, 3415, 761, 3415, 761, 3415, 761, 3415, 678, 3415, 761, 3415, 905, 3415, 1140, 3415, 1140
dw 3415, 1356, 3415, 1208, 3415, 1208, 3415, 854, 3415, 1140, 3415, 1140, 3415, 854, 3415, 905, 3415, 854, 3415, 905, 3415, 854
dw 3415, 1140, 3415, 1140, 3415, 905, 3415, 761, 3415, 761, 3415, 761, 3415, 678, 3415, 761, 3415, 905, 3415, 1140

duration: dw 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40
		dw 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40
		dw 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 8
dur: dw 0
endSp: db 0        ;Saves the off state of speaker
PresSp: db 0       ;Saves the curr state of speaker
note: dw 0
; PCB layout:
; ax,bx,cx,dx,si,di,ip,cs,ds,flags,next,dummy
; 0, 2, 4, 6, 8,10,12,14,16,18 , 20 , 22-30
pcb: times 2*16 dw 0
current: dw 0
buffer: times 4000 db 0
Random: dw 0
PipeGap: dw 7
BirdFlag: dw 0
BirdPosition: dw 13
PillarCol1: dw 30
PillarCol2: dw 55
PillarCol3: dw 80
GroundCol: dw 1
oldisr: dd 0
oldtimer: dd 0
StartFlag: dw 0
PauseFlag: dw 0
PlayerOutFlag: dw 0
Skipspawn: dw 0
RandomSeed: dw 0
string:  db 'Press "S" Key To Start, "Exit" To Pause, "SpaceBar" To Move Bird'
string2: db 'Do You Want to Exit'
string3: db '   Yes        No   '
string4: db 'Score: '
string5: db '      You Lose         '
string6: db 'Your Score:     '
Introstr1: db 'Enter your Name: '
Introstr2: db 'Enter your Name: '
Tickcount: dw 0
score: dw 0
Created: db 'Created by'
Name1: db 'Arham Zeeshan'
Name2: db 'Faizan Shamshaad'
Rollno1: db '23L-0896'
Rollno2: db '23L-0729'
Semester: db 'Fall 2024'
Press: db 'Press "Enter" to Continue'
Loading: db 'Loading...'
buffer1: db 80
        db 0
		times 80 db 0
	
GenerateRandomNumber:
    PUSHAD
    mov ax, [cs:RandomSeed] ; Use custom random seed
    mov dx, 0               ; Reset DX
    mov bx, 10              ; Random number between 0 and 10

    cmp bx, 0               ; Check if BX is zero
    je NoDivide             ; If zero, skip division

    div bx                  ; Divide AX by BX
    mov ax, dx              ; Store remainder as random number

NoDivide:
    add ax, 4               ; Ensure the height is at least 4
    mov [Random], ax        ; Save the random number
    POPAD
    ret

delay:
push cx
mov cx,0xFFFF
d1:
loop d1
mov cx,0xFFFF
d2:
loop d2
pop cx
ret

PrintScreen:          ;Buffer-Printing
PUSHAD
mov si,buffer
mov ax,0xB800
mov es,ax
mov cx,2000
mov di,0
cld
rep movsw
POPAD
ret

PrintSquare:
    mov bp,sp
	
	;Saving States
	push ax
	push cx
	push bx
	push si
	push di
	push es
	
	;Seting starting Coordinates
	mov al,80          ;Colums per row
	mul byte[bp+4]     ;80*R
	add ax,[bp+2]      ;(80*R)+c
	shl ax,1           ;((80*R)+c)*2
	
	mov di,buffer      ;Set Buffer
	add di,ax          ;Adjust Buffer
	
	;Setting RPG
	mov ax,[bp+10]        ;red background, red foreground, with spaces
	
	;Define Square
	mov cx,[bp+8]           ;Height
	mov bx,[bp+6]           ;Width
	
OuterLoop:
    push cx            ;Save Height
	mov cx,bx          ;Set Width
    mov si,di          ;Cell starting index
	innerLoop:
	    mov word[ds:si],ax
		add si,2
		loop innerLoop                   ;Upto cx
	add di,160                           ;Move to next Row (80*2)
	pop cx                               ;Restore Height
	loop OuterLoop
	
	pop es
	pop di
	pop si
	pop bx
	pop cx
	pop ax
	ret 10                                ;Five Parameters cleared
	
PrintSquare2:
    mov bp,sp
	
	;Saving States
	push ax
	push cx
	push bx
	push si
	push di
	push es
	
	mov ax,0xB800
	mov es,ax
	
	;Seting starting Coordinates
	mov al,80          ;Colums per row
	mul byte[bp+4]     ;80*R
	add ax,[bp+2]      ;(80*R)+c
	shl ax,1           ;((80*R)+c)*2
	
	mov di,ax
	
	;Setting RPG
	mov ax,[bp+10]        ;red background, red foreground, with spaces
	
	;Define Square
	mov cx,[bp+8]           ;Height
	mov bx,[bp+6]           ;Width
	
OuterLoopp:
    push cx            ;Save Height
	mov cx,bx          ;Set Width
    mov si,di          ;Cell starting index
	innerLoopp:
	    mov word[es:si],ax
		add si,2
		loop innerLoopp                   ;Upto cx
	add di,160                           ;Move to next Row (80*2)
	pop cx                               ;Restore Height
	loop OuterLoopp
	
	call delay
	pop es
	pop di
	pop si
	pop bx
	pop cx
	pop ax
	ret 10                                ;Five Parameters cleared

DrawBackground:
PUSHAD

mov si,buffer
mov cx,2000
mov ax,0x3F20
l1:
mov [ds:si],ax
add si,2
loop l1

POPAD
ret

DrawStars:
PUSHAD
mov cx,6               ;Number of stars
mov si,5

starloop:
mov ah,0xBF            ;Attribute: Blue blinking background, white foreground
mov al,'*'             ;With asteriks
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,2               ;Row no
push ax                ;bp+4
mov ax,si              ;Column no
push ax                ;bp+
call PrintSquare
add si,300
loop starloop

POPAD
ret

DrawBird:
PUSHAD

mov ax,0x4420          ;Attribute: red background, red foreground, with spaces
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,2               ;Width
push ax                ;bp+6
mov ax,[BirdPosition]  ;Row no
sub ax,1
push ax                ;bp+4
mov ax,41              ;Column no
push ax                ;bp+2
call PrintSquare

mov ax,0xFF20          ;Attribute: red background, red foreground, with spaces
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,[BirdPosition]  ;Row no
sub ax,1
push ax                ;bp+4
mov ax,43              ;Column no
push ax                ;bp+2
call PrintSquare

mov ax,0x4420          ;Attribute: red background, red foreground, with spaces
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,4               ;Width
push ax                ;bp+6
mov ax,[BirdPosition]  ;Row no
push ax                ;bp+4
mov ax,40              ;Column no
push ax                ;bp+2
call PrintSquare

mov ah,0x40            ;Attribute: red background, Black foreground
mov al,'>'
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,[BirdPosition]  ;Row no
push ax                ;bp+4
mov ax,43              ;Column no
push ax                ;bp+2
call PrintSquare

mov ah,0x70            ;Attribute: red background, Black foreground
mov al,'.'
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,[BirdPosition]  ;Row no
sub ax,1
push ax                ;bp+4
mov ax,43              ;Column no
push ax                ;bp+2
call PrintSquare

POPAD
ret

DrawGround:
PUSHAD
mov ax,0x6620          ;Attribute: Brown background, Brown foreground, with spaces
push ax                ;bp+10
mov ax,2               ;Height
push ax                ;bp+8
mov ax,80              ;Width
push ax                ;bp+6
mov ax,23              ;Row no
push ax                ;bp+4
mov ax,0               ;Column no
push ax                ;bp+2
call PrintSquare
POPAD
ret

MainScreen:
PUSHAD
;Printing background
call DrawBackground

;PrintingStars
call DrawStars

;Printing Bird
call DrawBird

;Printing Ground
call DrawGround

POPAD
ret

Animation:
PUSHAD

Wait_For_Start:               ;Wait until any key is pessed
mov ax,[StartFlag]
cmp ax,0
je Wait_For_Start

;Generate Random Heights
call GenerateRandomNumber
mov si,[Random]
call GenerateRandomNumber
mov cx,[Random]
call GenerateRandomNumber
mov dx,[Random]

loop1:

Wait_Pause:
mov ax,[PauseFlag]
cmp ax,1                      ;If Pause then stop
je Wait_Pause

;Pillar no 1
mov ax,0x2220          ;Attribute: Green background, Green foreground, with spaces
push ax                ;bp+10
mov ax,si              ;Height
push ax                ;bp+8
mov ax,3               ;Width
push ax                ;bp+6
mov ax,0               ;Row no
push ax                ;bp+4
mov ax,[PillarCol1]    ;Column no
push ax                ;bp+2
call DrawPillars

add bx,25
;Pillar no 2
mov ax,0x2220          ;Attribute: Green background, Green foreground, with spaces
push ax                ;bp+10
mov ax,cx              ;Height
push ax                ;bp+8
mov ax,3               ;Width
push ax                ;bp+6
mov ax,0               ;Row no
push ax                ;bp+4
mov ax,[PillarCol2]    ;Column no
push ax                ;bp+2
call DrawPillars

add bx,25
;Pillar no 3
mov ax,0x2220          ;Attribute: Green background, Green foreground, with spaces
push ax                ;bp+10
mov ax,dx              ;Height
push ax                ;bp+8
mov ax,3               ;Width
push ax                ;bp+6
mov ax,0               ;Row no
push ax                ;bp+4
mov ax,[PillarCol3]    ;Column no
push ax                ;bp+2
call DrawPillars

;Draw GroundDesign
push si
push cx
mov si,[GroundCol]     ;Starting column
mov cx,15              ;Number of tiles
PrintLoop1:
mov ah,0x6E            ;Attribute: Brown background, Yellow foreground
mov al,'|'             ;With brown beads
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,23              ;Row no
push ax                ;bp+4
mov ax,si              ;Column no
push ax                ;bp+2
call PrintSquare
add si,5
loop PrintLoop1
pop cx
pop si

;Bird Movement
push si
mov si,[BirdFlag]
cmp si,1
je UpBird
cmp si,0
je DownBird

Exit:
pop si

call PrintScreen
call delay
;call delay
call MainScreen

cmp word[PlayerOutFlag],1
je Exit2
;Pillar1 Checks
push ax
mov ax,[PillarCol1]
sub ax,1
cmp ax,0
je Update1
mov [PillarCol1],ax

;Pillar2 Checks
back1:
mov ax,[PillarCol2]
sub ax,1
cmp ax,0
je Update2
mov [PillarCol2],ax

;Pillar3 Checks
back2:
mov ax,[PillarCol3]
sub ax,1
cmp ax,0
je Update3
mov [PillarCol3],ax

;Ground Generation Checks
back3:
mov ax,[GroundCol]
sub ax,1
cmp ax,0
je Change
back:
mov [GroundCol],ax
pop ax

Exit2:
;Collision Detection with pillars
call Collision

;Score Mechanism
call ScoreMechanism
;PrintScore
call PrintNum

jmp loop1

POPAD
ret

ScoreMechanism:
PUSHAD
cmp word[PillarCol1],38        ;Comparing with bird position(x)
je Increment1
ComeBack1:
cmp word[PillarCol2],38
je Increment2
ComeBack2:
cmp word[PillarCol3],38
je Increment3
ComeBack3:
POPAD
ret

Increment1:
inc word[score]
jmp ComeBack1

Increment2:
inc word[score]
jmp ComeBack2

Increment3:
inc word[score]
jmp ComeBack3

PrintNum:
PUSHAD
call PrintString2        ;Print 'Score: '
mov ax,[score]
mov bx, 10               ; use base 10 for division
mov cx, 0                ; initialize count of digits
nextdigit: mov dx, 0     ; zero upper half of dividend
div bx                   ; divide by 10
add dl, 0x30             ; convert digit into ascii value
push dx                  ; save ascii value on stack
inc cx                   ; increment count of values
cmp ax, 0                ; is the quotient zero
jnz nextdigit            ; if no divide it again
mov di, 140              ; point di to 70th column
nextpos: pop dx          ; remove a digit from the stack
mov dh, 0x3F             ; use normal attribute
mov si,buffer
add si,di
mov [ds:si], dx          ; print char on screen
add di, 2                ; move to next screen location
loop nextpos
POPAD
ret

PrintNum2:
PUSHAD
mov ax,0xB800
mov es,ax
mov ax,[score]
mov bx, 10               ; use base 10 for division
mov cx, 0                ; initialize count of digits
nextdigit1: mov dx, 0    ; zero upper half of dividend
div bx                   ; divide by 10
add dl, 0x30             ; convert digit into ascii value
push dx                  ; save ascii value on stack
inc cx                   ; increment count of values
cmp ax, 0                ; is the quotient zero
jnz nextdigit1           ; if no divide it again
mov di, 2010             ; point di to 70th column
nextpos1: pop dx         ; remove a digit from the stack   
mov dh, 0x0A             ; use normal attribute
mov [es:di], dx          ; print char on screen
add di, 2                ; move to next screen location
loop nextpos1
POPAD
ret

Collision:
PUSHAD
mov ax,80
mov di,[BirdPosition] ;Birds y pos
mul di
add ax,40             ;Birds x pos
shl ax,1
mov di,ax             ;Birds current pos
mov ax,0xB800
mov es,ax
mov ax,[es:di+10]
cmp ah,0x22           ;If green color(Pillars)
je Quit
cmp ah,0x66           ;If Brown color(Ground)
je Quit2
Exit1:
POPAD
ret

Quit:
mov word[BirdFlag],0
mov word[PlayerOutFlag],1
jmp Exit1

Quit2:
mov word[PauseFlag],1
call EndScreen
jmp Exit1

Update1:
;Generate Random Heights
call GenerateRandomNumber
mov si,[Random]
push ax
mov ax,80
mov [PillarCol1],ax
pop ax
jmp back1

Update2:
;Generate Random Heights
call GenerateRandomNumber
mov cx,[Random]
push ax
mov ax,80
mov [PillarCol2],ax
pop ax
jmp back2

Update3:
;Generate Random Heights
call GenerateRandomNumber
mov dx,[Random]
push ax
mov ax,80
mov [PillarCol3],ax
pop ax
jmp back3

Change:
mov ax,5
jmp back

UpBird:
push ax
mov ax,[BirdPosition]
sub ax,1
mov [BirdPosition],ax
cmp ax,0
pop ax
jmp Exit

DownBird:
push ax
cmp word[Skipspawn],0
jne Stay
mov ax,[BirdPosition]
add ax,1
mov [BirdPosition],ax
pop ax
jmp Exit
Stay:
dec word[Skipspawn]
pop ax
jmp Exit

DrawPillars:
mov bp,sp
push ax               ;Saving States
push bx
push cx
push dx
push si
push di

;Setting Coordinates
mov ax,80        ;80
mul word[bp+4]   ;80*R
add ax,[bp+2]    ;(80*R)+C
shl ax,1         ;((80*R)+C)*2

mov di,buffer    ;Setting buffer
add di,ax        ;Adjusting

;Setting RPG
mov ax,[bp+10]   
	
;Define Pillar
mov cx,[bp+8]           ;Height
mov bx,[bp+6]           ;Width

;UpperPillar
OuterLoop2:
    push cx            ;Save Height
	mov cx,bx          ;Set Width
    mov si,di          ;Cell starting index
	innerLoop2:
	    mov word[ds:si],ax
		add si,2
		loop innerLoop2                   ;Upto cx
	add di,160                           ;Move to next Row (80*2)
	pop cx                               ;Restore Height
	loop OuterLoop2
	
;Lower Pillar
mov ax,[PipeGap]
mov bx,160
mul bx
add di,ax

;Setting RPG
mov ax,[bp+10]

;Define Pillar
mov bx,[bp+6]           ;Width

OuterLoop3:
	mov cx,bx          ;Set Width
    mov si,di          ;Cell starting index
	innerLoop3:
	    mov word[ds:si],ax
		add si,2
		loop innerLoop3                  ;Upto cx
	add di,160                           ;Move to next Row (80*2)
	cmp di,4270                          ;Draw upto Ground
	jna OuterLoop3
	
pop di
pop si
pop dx
pop cx
pop bx
pop ax
ret 10                 ;Five Parameters Cleared

PrintString:
PUSHAD
mov ax,0xB800
mov es,ax
mov di,660
mov si,string
mov cx,64
mov ah,0x30
cld           ;auto increment
l5:
lodsb
stosw
loop l5
POPAD
ret

PrintString2:
PUSHAD
push ds
pop es
mov di,buffer
add di,128
mov si,string4
mov cx,7
mov ah,0x3F
cld           ;auto increment
l2:
lodsb
stosw
loop l2
POPAD
ret

PrintString3:
PUSHAD
push ds
pop es
mov di,buffer
add di,230
mov si,Loading
mov cx,10
mov ah,0x0E
cld           ;auto increment
l8:
lodsb
stosw
loop l8
POPAD
ret

ExitScreen:
PUSHAD
mov ax,0xB800
mov es,ax

mov bx,7           ;Starting Row no
mov di,23          ;Starting Coll no

mov ax,80
mul bx
add ax,di
shl ax,1
mov si,ax        ;Initial Position

mov bx,8         ;height
mov dx,35        ;Width
mov cx,bx
mov ax,0x0120
OL:
push cx
mov cx,dx
mov di,si
rep stosw
add si,160
pop cx
loop OL

mov cx,20
mov di,1340
mov si,string2
mov ah,0x0C
cld           ;auto increment
l3:
lodsb
stosw
loop l3

mov cx,18
mov di,1980
mov si,string3
mov ah,0x0E
cld           ;auto increment
l4:
lodsb
stosw
loop l4
    in al, 0x61
    mov ah, al
	mov al, [endSp]
	out 0x61, al
	mov [PresSp], ah
POPAD
ret

EndScreen:
PUSHAD
mov ax,0xB800
mov es,ax

mov bx,7           ;Starting Row no
mov di,23          ;Starting Coll no

mov ax,80
mul bx
add ax,di
shl ax,1
mov si,ax        ;Initial Position

mov bx,8         ;height
mov dx,35        ;Width
mov cx,bx
mov ax,0x0120
OLe:
push cx
mov cx,dx
mov di,si
rep stosw
add si,160
pop cx
loop OLe

mov cx,20
mov di,1340
mov si,string5
mov ah,0x0C
cld           ;auto increment
l3e:
lodsb
stosw
loop l3e

mov cx,14
mov di,1980
mov si,string6
mov ah,0x09
cld           ;auto increment
l4e:
lodsb
stosw
loop l4e

call PrintNum2

POPAD
mov al, [endSp]
out 0x61, al
;End Game
cli
push es
xor ax, ax
mov es, ax
mov ax, [oldisr]
mov word[es:9*4], ax
mov ax, [oldisr + 2]
mov word[es:9*4+2], ax
mov ax, [oldtimer]
mov word[es:8*4], ax
mov ax, [oldtimer + 2]
mov word[es:8*4+2], ax
pop es
sti
mov ax,0x4c00
int 0x21
ret

clrscreen:
PUSHAD
mov si,buffer
mov cx,2000
mov ax,0x0A20
l6:
mov [ds:si],ax
add si,2
loop l6
POPAD
ret

IntroScreen:
PUSHAD

call clrscreen
call PrintString3

;Borders
mov ax,0xCC20          ;Attribute
push ax                ;bp+10
mov ax,2               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,12              ;Row no
push ax                ;bp+4
mov ax,12              ;Column no
push ax                ;bp+2
call PrintSquare

mov ax,0xCC20          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,51              ;Width
push ax                ;bp+6
mov ax,11              ;Row no
push ax                ;bp+4
mov ax,12              ;Column no
push ax                ;bp+2
call PrintSquare

mov ax,0xCC20          ;Attribute
push ax                ;bp+10
mov ax,2               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,12              ;Row no
push ax                ;bp+4
mov ax,62              ;Column no
push ax                ;bp+2
call PrintSquare

mov ax,0xCC20          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,51              ;Width
push ax                ;bp+6
mov ax,14              ;Row no
push ax                ;bp+4
mov ax,12              ;Column no
push ax                ;bp+2
call PrintSquare
;loading screen
mov si,13
mov cx,49
l7:
mov ax,0xAA20          ;Attribute
push ax                ;bp+10
mov ax,2               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,12              ;Row no
push ax                ;bp+4
mov ax,si              ;Column no
push ax                ;bp+2
call PrintSquare
call PrintScreen       ;Print from buffer to screen
call delay
add si,1
loop l7
call clrscreen
call PrintScreen       ;Print from buffer to screen

;Printing Flappy Bird
;F
mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,7               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,5               ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,7               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,5              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,6               ;Row no
push ax                ;bp+4
mov ax,5              ;Column no
push ax                ;bp+2
call PrintSquare2
;L
mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,7               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,13              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,9               ;Row no
push ax                ;bp+4
mov ax,13              ;Column no
push ax                ;bp+2
call PrintSquare2
;A
mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,7               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,19              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,19              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,6               ;Row no
push ax                ;bp+4
mov ax,19              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,7               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,24              ;Column no
push ax                ;bp+2
call PrintSquare2
;P
mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,7               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,26              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,26              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,6               ;Row no
push ax                ;bp+4
mov ax,26              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,4               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,31              ;Column no
push ax                ;bp+2
call PrintSquare2
;P
mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,7               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,33              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,33              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,6               ;Row no
push ax                ;bp+4
mov ax,33              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,4               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,38              ;Column no
push ax                ;bp+2
call PrintSquare2
;Y
mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,4               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,40              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,6               ;Row no
push ax                ;bp+4
mov ax,40              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,7               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,45              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,9               ;Row no
push ax                ;bp+4
mov ax,40              ;Column no
push ax                ;bp+2
call PrintSquare2
;B
mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,7               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,50              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,50              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,6               ;Row no
push ax                ;bp+4
mov ax,50              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,9               ;Row no
push ax                ;bp+4
mov ax,50              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,7               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,55              ;Column no
push ax                ;bp+2
call PrintSquare2
;I
mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,7               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,57              ;Column no
push ax                ;bp+2
call PrintSquare2

;R
mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,7               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,59              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,59              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,6               ;Row no
push ax                ;bp+4
mov ax,59              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,4               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,64              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,4               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,6               ;Row no
push ax                ;bp+4
mov ax,63              ;Column no
push ax                ;bp+2
call PrintSquare2
;D
mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,7               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,66              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,66              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,1               ;Height
push ax                ;bp+8
mov ax,5               ;Width
push ax                ;bp+6
mov ax,9               ;Row no
push ax                ;bp+4
mov ax,66              ;Column no
push ax                ;bp+2
call PrintSquare2

mov ax,0x4420          ;Attribute
push ax                ;bp+10
mov ax,7               ;Height
push ax                ;bp+8
mov ax,1               ;Width
push ax                ;bp+6
mov ax,3               ;Row no
push ax                ;bp+4
mov ax,71              ;Column no
push ax                ;bp+2
call PrintSquare2

;Credits
mov ah,0x13
mov al,0        ;Cursor
mov bh,0        ;Pg no
mov bl,0x0A     ;Attribute
mov cx,10       ;Length
mov dx,0x0C20   ;Row,Column
push ds
pop es
mov bp,Created
int 0x10

mov ah,0x13
mov al,0        ;Cursor
mov bh,0        ;Pg no
mov bl,0x0E     ;Attribute
mov cx,13       ;Length
mov dx,0x0F12   ;Row,Column
push ds
pop es
mov bp,Name1
int 0x10

mov ah,0x13
mov al,0        ;Cursor
mov bh,0        ;Pg no
mov bl,0x0E     ;Attribute
mov cx,16       ;Length
mov dx,0x0F2B   ;Row,Column
push ds
pop es
mov bp,Name2
int 0x10

mov ah,0x13
mov al,0        ;Cursor
mov bh,0        ;Pg no
mov bl,0x0E     ;Attribute
mov cx,8        ;Length
mov dx,0x1212   ;Row,Column
push ds
pop es
mov bp,Rollno1
int 0x10

mov ah,0x13
mov al,0        ;Cursor
mov bh,0        ;Pg no
mov bl,0x0E     ;Attribute
mov cx,8        ;Length
mov dx,0x122B   ;Row,Column
push ds
pop es
mov bp,Rollno2
int 0x10

mov ah,0x13
mov al,0        ;Cursor
mov bh,0        ;Pg no
mov bl,0x0D     ;Attribute
mov cx,9        ;Length
mov dx,0x1420   ;Row,Column
push ds
pop es
mov bp,Semester
int 0x10

mov ah,0x13
mov al,0        ;Cursor
mov bh,0        ;Pg no
mov bl,0x0B     ;Attribute
mov cx,25       ;Length
mov dx,0x1718   ;Row,Column
push ds
pop es
mov bp,Press
int 0x10

;Input
mov dx,buffer1
mov ah,0x0A
int 0x21

mov word[StartFlag],0

POPAD
ret

; Timer Interrupt service routine
timer:
inc word[RandomSeed]
cmp word[cs:Skipspawn],0
jg flying
inc word[cs:Tickcount]
cmp word[cs:Tickcount],12
jl endTimer
mov word[cs:Skipspawn],1          ;skip bird spawn downward
mov word[cs:Tickcount],0
jmp endTimer

flying:
mov word[cs:Tickcount],0

endTimer:
inc word[dur]
	push ds
	push bx
	push cs
	pop ds ; initialize ds to data segment
	mov bx, [current] ; read index of current in bx
	shl bx, 1
	shl bx, 1
	shl bx, 1
	shl bx, 1
	shl bx, 1 ; multiply by 32 for pcb start
	mov [pcb+bx+0], ax ; save ax in current pcb
	mov [pcb+bx+4], cx ; save cx in current pcb
	mov [pcb+bx+6], dx ; save dx in current pcb
	mov [pcb+bx+8], si ; save si in current pcb
	mov [pcb+bx+10], di ; save di in current pcb
	pop ax ; read original bx from stack
	mov [pcb+bx+2], ax ; save bx in current pcb
	pop ax ; read original ds from stack
	mov [pcb+bx+16], ax ; save ds in current pcb
	pop ax ; read original ip from stack
	mov [pcb+bx+12], ax ; save ip in current pcb
	pop ax ; read original cs from stack
	mov [pcb+bx+14], ax ; save cs in current pcb
	pop ax ; read original flags from stack
	mov [pcb+bx+18], ax ; save flags in current pcb
	mov bx, [pcb+bx+20] ; read next pcb of this pcb
	mov [current], bx ; update current to new pcb
	mov cl, 5
	shl bx, cl ; multiply by 32 for pcb start
	mov cx, [pcb+bx+4] ; read cx of new process
	mov dx, [pcb+bx+6] ; read dx of new process
	mov si, [pcb+bx+8] ; read si of new process
	mov di, [pcb+bx+10] ; read di of new process
	push word [pcb+bx+18] ; push flags of new process
	push word [pcb+bx+14] ; push cs of new process
	push word [pcb+bx+12] ; push ip of new process
	push word [pcb+bx+16] ; push ds of new process
	mov al, 0x20
	out 0x20, al ; send EOI to PIC
	mov ax, [pcb+bx+0] ; read ax of new process
	mov bx, [pcb+bx+2] ; read bx of new process
	pop ds ; read ds of new process
iret

play_note:
    cmp byte[PauseFlag], 1
	je endNote
	mov ax, [dur]
	mov si, [note]
	cmp ax, [duration + si]
	jb continue
	cmp word[note], 122
	jb playNow
	mov word[note], -2
playNow:
	add word[note], 2
    mov bx, [musical_Score + si] ; Access the divisor for the current note (using SI as index)
	mov word[dur], 0
    ; Enable the speaker and connect it to channel 2
    or al, 3h
    out 61h, al

    ; Set channel 2 (PIT)
    mov al, 0b6h    ; Select mode 3 (square wave) for channel 2
    out 43h, al

    ; Send the divisor to the PIT
    mov ax, bx      ; Load the divisor into AX
    out 42h, al     ; Send the LSB (lower byte)
    mov al, ah      ; Get the MSB (higher byte)
    out 42h, al     ; Send the MSB (higher byte)
continue:
endNote:
    jmp play_note

; keyboard interrupt service routine
kbisr:		push ax
			push es

			in al, 0x60						; read a char from keyboard port
            
			cmp al,0x38                     ;Check that alt and shift and Enter are out of range
			je nomatch
			cmp al,0x36
			je nomatch
			cmp al,0xB8
			je nomatch
			cmp al,0xB6
			je nomatch
			
			cmp al, 0x39					; is the key SpaceBar
			jne nextcomp1				    ; no, try next comparison
			mov word[BirdFlag],1            ; Set bird upward
			jmp nomatch
			
nextcomp1:
            cmp al,0x01                     ;If Exit Button
			jne nextcomp2
			mov word[PauseFlag],1
			call ExitScreen
			jmp nomatch
			
nextcomp2:
            cmp al,0x31                     ;If Press 'n' then resume game
			jne nextcomp3
			mov word[PauseFlag],0
			jmp nomatch
			
nextcomp3:
            cmp al,0x15                     ;If Press 'y' then Exit game
			jne nextcomp4
			call EndScreen
			jmp nomatch
			
nextcomp4:
            cmp al,0x1f
			jne nextcomp5
            mov word[StartFlag],1           ;On any key press
			jmp nomatch

nextcomp5:
            mov word[BirdFlag],0            ;Set bird downward

nomatch:	
			pop es
			pop ax
			jmp far [cs:oldisr]				; call the original ISR
			
initPCB:
push bp
mov bp, sp
push bx
mov word[pcb + 20], 1
mov bx, 32
mov word[pcb + bx + 12], play_note
mov word[pcb + bx + 14], cs
mov word[pcb + bx + 16], ds
mov word[pcb + bx + 18], 0x0200
mov word[pcb + bx + 20], 0
pop bx
pop bp
ret

start:
call initPCB
mov ax, 16384
out 0x40, al
mov al, ah
out 0x40, al
xor ax, ax
            mov ax,0
			mov es, ax								; point es to IVT base
			
			mov ax, [es:9*4]
			mov [oldisr], ax						; save offset of old routine
			mov ax, [es:9*4+2]
			mov [oldisr+2], ax						; save segment of old routine
			
			mov ax, [es:8*4]
			mov [oldtimer], ax						; save offset of old routine
			mov ax, [es:8*4+2]
			mov [oldtimer+2], ax			    	; save segment of old routine

			cli										; disable interrupts
			mov word [es:9*4], kbisr				;Hooking keyboard
			mov [es:9*4+2], cs						
			mov word [es:8*4], timer				; Hooking Timer
			mov [es:8*4+2], cs						
			sti										; enable interrupts

call IntroScreen

call MainScreen
call PrintScreen
call PrintString

call Animation

mov ax,0x4c00
int 0x21