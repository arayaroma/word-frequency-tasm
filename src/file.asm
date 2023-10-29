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
    filename                db "..\files\text.txt"
    handle                  dw 0
    buffer                  db 512 dup(0)
    buffer_string           db 512 dup(0)
    open_error_message      db "Error opening file!", '$'
    read_error_message      db "Error reading file!", '$'
    at_symbol               db '@'
    exclude_symbols         db '!"#%&''()*+-/:;<=>?[\]^_`{|}~', '$'
    exclude_symbols_len     equ $ - offset exclude_symbols

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
    mov ah, 3Dh                 ; open a file
    mov al, 0                   ; read only
    lea dx, filename            ; load address of file
    int 21h
    ; jc open_error

    mov handle, ax              ; save file handle
    xor si, si                  ; clear si

read_loop:
    mov ah, 3Fh                 ; read from file
    mov bx, handle              ; file handle
    mov cx, 1                   ; number of bytes to read
    lea dx, buffer              ; load address of buffer
    int 21h
    jc read_error

    lea di, exclude_symbols
    mov cx, exclude_symbols_len

    mov al, [buffer]

check_symbols:
    cmp al, [di]
    je skip_char
    inc di
    loop check_symbols

    cmp al, at_symbol
    je check_at_symbol

    mov [buffer_string + si], al
    inc si

skip_char:
    jmp read_loop

check_at_symbol:
    mov al, at_symbol
    mov [buffer_string + si], al 
    inc si
    cmp al, '$'

    mov dh, 1
    mov dl, 0
    call SetMousePosition

    mov dx, offset buffer_string
    call PrintMessage
    je done_reading

done_reading:
    mov ah, 3Eh                 ; close file
    mov bx, handle              ; file handle
    int 21h
    jmp return

open_error:  
    mov dh, 0
    mov dl, 0
    call SetMousePosition

    mov dx, offset open_error_message
    call PrintMessage
    jmp return

read_error:
    mov dh, 0
    mov dl, 0
    call SetMousePosition

    mov dx, offset read_error_message
    call PrintMessage
    jmp return

return:
    ret
OpenFile endp

end