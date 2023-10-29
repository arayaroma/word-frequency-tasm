; graphic.asm
; author: arayaroma
;
.8086
.model small
public ClearScreen, PrintMessage, SetVideoMode, ShowMessage

; mouse.asm
extrn SetMousePosition:far

.data

.code

;   SetVideoMode
;
;   Sets the video mode to 16-color VGA 640x480
;   Input: none
;   Output: none
SetVideoMode proc far
    mov ax, 0012H
    int 10h
    ret
SetVideoMode endp

;   ClearScreen
;
;   Clears the screen
;   Input: none
;   Output: none
ClearScreen proc far
    mov ax, 0600H
    mov bh, 00H
    mov cx, 0000H
    mov dx, 184FH
    int 10H
    ret
ClearScreen endp

;   PrintMessage
;
;   Prints a message to the screen
;   Input: DS:DX -> message
;   Output: none
PrintMessage proc far
    mov ah, 09H
    int 21H
    ret
PrintMessage endp

ShowMessage proc far
    push bp
    mov bp, sp
    mov dh, [bp + 4]
    mov dl, [bp + 6]
    call SetMousePosition

    mov dx, [bp + 8] 
    call PrintMessage
    pop bp
    ret
ShowMessage endp

end