; file.asm
; author: arayaroma
;
.8086
.model small

public OpenFile

; graphic.asm
extrn PrintMessage:far

; mouse.asm
extrn SetMousePosition:far

.data
    filename db "text", 0
    buffer db 100 dup(?)
    bytes_read dw ?
    error_message db "Error opening file!", '$'

.code

; OpenFile
; 
; AL = 0 (read only), 1 (write only), 2 (read/write)
; AH = 3Dh (open file)
; BX = file handle
; CX = number of bytes to read
; DS:DX = address of buffer
;
OpenFile proc far
    mov ah, 3dh         ; open a file
    lea dx, filename    ; load address of file
    mov al, 0           ; read only
    int 21h
    jc error

    mov bx, ax          ; save file handle

    mov ah, 3fh         ; read from file
    mov cx, 100         ; number of bytes to read
    lea dx, buffer      ; load address of buffer
    int 21h
    jc error

    mov bytes_read, ax  ; save number of bytes read
    mov ah, 3eh         ; close file
    int 21h

    mov dh, 0
    mov dl, 0
    call SetMousePosition

    mov dx, offset buffer
    call PrintMessage
    ret

error:  
    mov dh, 0
    mov dl, 0
    call SetMousePosition

    mov dx, offset error_message
    call PrintMessage
    ret
OpenFile endp

end