; file.asm
; author: arayaroma
;
.8086
.model small

public WaitForKey
public _backspace, _enter

.data
    _backspace  db 8
    _enter      db 13

.code

; WaitForKey
;
; Waits for a key to be pressed.
; Input:         AL = 0
; Output:        AL = ASCII code of key pressed
; Modifies:      AL, AH
;
WaitForKey proc far
    mov ah, 0
    int 16h
    ret
WaitForKey endp

end