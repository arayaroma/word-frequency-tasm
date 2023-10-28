; ascii.asm
; author: arayaroma
;
.8086
.model small
public ConvertToASCII, DisplayASCII, ascii_buffer

.data
ascii_buffer db 12 dup(0)

.code

; DisplayASCII:     Displays an ASCII character
;
; Input:            AL = ASCII character to display
; Output:           AL, AH are modified
DisplayASCII proc far
    push ax dx
    mov ah, 02h
    mov dl, al
    int 21h
    pop dx ax
    ret
DisplayASCII endp

; ConvertToASCII:   Converts a number to ASCII and stores it in a buffer
;
; Input:            AX = number to convert
; Output:           ASCII characters are stored in the buffer
;                   CX = number of characters
;                   DI = pointer to the end of the buffer
;                   ASCII characters are stored in the buffer in reverse order
;                   AX, BX, CX, DX, DI are modified
ConvertToASCII proc far
    push ax bx cx dx di
    
    mov bx, 10              ; Divide by 10 to convert to ASCII
    xor cx, cx              ; Clear CX for count
    lea di, ascii_buffer    ; DI points to the end of the buffer

ConvertLoop:
    xor dx, dx
    div bx                  ; AX = AX / 10, DX = remainder

    add dl, '0'             ; Convert remainder to ASCII
    dec di

    mov [di], dl            ; Store the ASCII character in memory
    inc cx 
    test ax, ax
    jnz ConvertLoop

    ; Output the ASCII characters in reverse order
    mov si, di              ; SI points to the first character
OutputLoop:
    mov al, [si]            ; Load the ASCII character from memory
    call DisplayASCII
    inc si 
    loop OutputLoop 

    pop di dx cx bx ax
    ret
ConvertToASCII endp

end