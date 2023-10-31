; file.asm
; author: arayaroma
;
.8086
.model small

public OpenFile
public exclude_letters, exclude_letters_len
public buffer, buffer_string

; graphic.asm
extrn PrintMessage:far

; mouse.asm
extrn SetMousePosition:far

.data
    filename                db "..\files\text.txt"
    handle                  dw 0
    buffer                  db 450 dup(0)
    buffer_string           db 450 dup(0)
    open_error_message      db "Error opening file!", '$'
    read_error_message      db "Error reading file!", '$'
    at_symbol               db '@'
    exclude_symbols         db '!"#%&''()*+-/:;<=>?[\]^_`{|}~', '$'
    exclude_letters         db '!"#%&''()*+-/.,:;<=>?[\]^_`{|}~', '$'
    exclude_letters_len     equ $ - offset exclude_letters
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
    jc open_error

    call ReadFile
    jmp return

open_error:  
    call OpenError
    jmp return

return:
    ret
OpenFile endp

; ReadFile
;
; AH = 3Fh (read from file)
; BX = file handle
; CX = number of bytes to read
; DS:DX = address of buffer
;
ReadFile proc near
    mov handle, ax              ; save file handle
    xor si, si

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

    cmp al, at_symbol
    je check_at_symbol

check_symbols:
    cmp al, [di]
    je skip_char
    jne next_char
    inc di
    loop check_symbols

next_char:
    mov [buffer_string + si], al
    inc si

skip_char:
    jmp read_loop

check_at_symbol:
    mov al, at_symbol
    mov [buffer_string + si], al 
    inc si
    cmp al, '$'
    je print_buffer

print_buffer:
    mov al, '$'
    mov [buffer_string + si], al
    call PrintMessageBuffer
    je done_reading

done_reading:
    call CloseFile
    jmp _return

read_error:
    call ReadError
    jmp _return

_return:
    ret
ReadFile endp

; CloseFile
;
; AH = 3Eh (close file)
; BX = file handle
;
CloseFile proc near
    mov ah, 3Eh
    mov bx, handle
    int 21h
    ret
CloseFile endp

; PrintMessageBuffer
;
; Print buffer message
;
PrintMessageBuffer proc near
    mov dh, 5
    mov dl, 0
    call SetMousePosition

    mov dx, offset buffer_string
    call PrintMessage
    ret
PrintMessageBuffer endp

; ReadError
;
; Show error message when reading file
;
ReadError proc near
    mov dh, 0
    mov dl, 0
    call SetMousePosition

    mov dx, offset read_error_message
    call PrintMessage
    ret
ReadError endp

; OpenError
;
; Show error message when opening a file
;
OpenError proc near
    mov dh, 0
    mov dl, 0
    call SetMousePosition

    mov dx, offset open_error_message
    call PrintMessage
    ret
OpenError endp

end