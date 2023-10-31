; word.asm
; author: arayaroma
;
.8086
.model small

public WordCounterDriver

; ascii.asm
extrn ConvertToASCII:far

; graphic.asm
extrn PrintMessage:far
extrn ClearScreen:far
extrn SetVideoMode:far
extrn ShowMessage:far

; file.asm
extrn OpenFile:far
extrn exclude_letters:byte
extrn exclude_letters_len
extrn buffer
extrn buffer_string

; mouse.asm
extrn SetMousePosition:far
extrn ShowMouse:far

.data
    word_frequency_title    db "-[Word Frequency]-", '$'
    word_frequency          db "Words: ", '$' 
    letter_frequency        db "Letters: ", '$'
    axis_x                  db ?
    axis_y                  db ?
    letters_count           dw 0
    words_count             db 0

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

    call CountLetters
    call PrintLetterFrequency

    ret
WordCounterDriver endp

; PrintWordFrequencyTitle
;
; Print the title of the program
;
PrintWordFrequencyTitle proc near
    mov dh, 0
    mov dl, 30
    call SetMousePosition

    mov dx, offset word_frequency_title
    call PrintMessage
    ret
PrintWordFrequencyTitle endp

PrintLetterFrequency proc near
    mov dh, 1
    mov dl, 30
    call SetMousePosition

    mov dx, offset letter_frequency
    call PrintMessage

    mov dh, 1
    mov dl, 42
    call SetMousePosition

    mov ax, [letters_count]
    call ConvertToASCII

    ret
PrintLetterFrequency endp

; CountLetters
;
; Count the number of letters in a buffer
;
CountLetters proc near
    mov si, offset buffer_string
    mov di, offset exclude_letters
    xor cx, cx

read_buffer:
    mov al, [si]
    cmp al, '$'
    je end_of_string

check_exclude_letters:
    mov dl, [di]
    cmp dl, al
    je skip_letter
    inc cx

skip_letter:
    inc di
    inc si
    jmp read_buffer

end_of_string:
    mov [letters_count], cx
    sub letters_count, 47h
    ret 
CountLetters endp

; CountWords
;
; Count the number of words in a buffer
;
CountWords proc near
    mov si, offset buffer_string
    xor cx, cx

read_buffer:
    mov al, [si]
    cmp al, '$'
    je return

return:
    ret
CountWords endp


end