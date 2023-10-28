; word.asm
; author: arayaroma
;
.8086
.model small

public WordCounterDriver

; file.asm
extrn OpenFile:far

; graphic.asm
extrn PrintMessage:far
extrn ClearScreen:far
extrn SetVideoMode:far

; mouse.asm
extrn SetMousePosition:far
extrn ShowMouse:far

.data
word_frequency db "-[Word Frequency]-", '$'
axis_x db ?
axis_y db ?

.code

WordCounterDriver proc far
    call SetVideoMode
    call ClearScreen

    mov axis_x, 0
    mov axis_y, 30

    mov dh, [axis_x]
    mov dl, [axis_y]
    call SetMousePosition

    mov dx, offset word_frequency
    call PrintMessage

    call OpenFile

    ret
WordCounterDriver endp

end