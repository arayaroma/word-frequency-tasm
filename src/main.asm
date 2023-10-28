; main.asm
; author: arayaroma
;
.8086
.model small
.stack 100h

; word.asm
extrn WordCounterDriver:far

.code 
    mov ax, @DATA            
    mov ds, ax 

    call WordCounterDriver
    mov ah, 4ch
    int 21h
end