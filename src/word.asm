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
extrn ShowMessage:far

; mouse.asm
extrn SetMousePosition:far
extrn ShowMouse:far

.data
    word_frequency  db "-[Word Frequency]-", '$'
    axis_x          db ?
    axis_y          db ?

.code

; WordCounterDriver
;
; Main program
;
WordCounterDriver proc far
    call SetVideoMode
    call ClearScreen
    call PrintWordFrequencyTitle
    call OpenFile
    ret
WordCounterDriver endp

; PrintWordFrequencyTitle
;
; Print the title of the program
;
PrintWordFrequencyTitle proc near
    ; push 0
    ; push 30
    ; push offset word_frequency
    ; call ShowMessage
    ; add sp, 6

    mov dh, 0
    mov dl, 30
    call SetMousePosition

    mov dx, offset word_frequency
    call PrintMessage
    ret
PrintWordFrequencyTitle endp

end