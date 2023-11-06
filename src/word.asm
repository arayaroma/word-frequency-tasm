; word.asm
; author: arayaroma
;
.8086
.model small

public WordCounterDriver
public letters_count, words_count

; ascii.asm
extrn ConvertToASCII:far

; keyboard.asm
extrn WaitForKey:far
extrn _backspace:byte
extrn _enter:byte

; mouse.asm
extrn SetMousePosition:far
extrn ShowMouse:far
extrn ClearOffset:far
extrn x_offset:byte
extrn y_offset:byte

; graphic.asm
extrn PrintMessage:far
extrn ClearScreen:far
extrn SetVideoMode:far
extrn ShowMessage:far

; file.asm
extrn OpenFile:far
extrn filename:byte
extrn exclude_letters:byte
extrn exclude_letters_len
extrn buffer
extrn buffer_string
extrn is_open_error:byte
extrn is_read_error:byte

.data
    word_frequency_title    db "-[Word Frequency]-", '$'
    word_frequency          db "Words: ", '$' 
    letter_frequency        db "Letters: ", '$'
    letters_count           dw 0
    words_count             dw 0

    filename_prompt         db "Enter the filename: ", '$'
    filename_prompt_len     equ $ - filename_prompt
    name_of_file            db 20 dup(0), '$'
    letter_counter          db 0
    files_directory         db "..\files\", '$'
    read_another_file       db "Read another file? (Y/N): ", '$'
    end_message             db "Program ended...", '$'

.code

; ConcatenateFilename
;
; Concatenate the name of the file with the directory
;
ConcatenateFilename proc near
    mov si, offset files_directory
    mov di, offset filename

copy_loop:
    mov al, [si]
    cmp al, '$'
    je done_copying

    mov [di], al
    inc si
    inc di
    jmp copy_loop

done_copying:
    mov si, offset name_of_file

concatenate:
    mov al, [si]
    cmp al, 0
    je end_concatenation

    mov [di], al
    inc si
    inc di
    jmp concatenate 

end_concatenation:
    mov byte ptr [di - 1], 0
    ret
ConcatenateFilename endp

; AskForFilename
;
; Ask for a filename and store it in a buffer
;
AskForFilename proc near
start_over:
    call SetVideoMode
    call ClearScreen
    call PrintWordFrequencyTitle

    mov di, offset name_of_file

    mov x_offset, 1
    mov y_offset, 31

    mov dh, [x_offset]
    mov dl, [y_offset]
    call SetMousePosition

    mov dx, offset filename_prompt
    call PrintMessage

    mov y_offset, 31 + filename_prompt_len
writing_loop:
    call WaitForKey
    inc letter_counter  

    cmp al, _backspace
    je delete_character

    ; add letter to filename
    mov [di], al
    add y_offset, 1

    mov dh, [x_offset]
    mov dl, [y_offset]
    call SetMousePosition

    mov dx, di
    call PrintMessage
    inc di

    cmp al, _enter
    je end_loop_name
    jne writing_loop

middle_jump:
    jmp start_over

delete_character:
    cmp di, offset name_of_file
    je writing_loop

    dec di

    call ClearScreen
    call ClearOffset
    call PrintWordFrequencyTitle

    mov x_offset, 1
    mov y_offset, 31

    dec letter_counter
    mov dh, [x_offset]
    mov dl, [y_offset]
    call SetMousePosition

    mov dx, offset filename_prompt
    call PrintMessage

    add y_offset, filename_prompt_len - 1

    mov dh, [x_offset]
    mov dl, [y_offset]
    call SetMousePosition

    mov byte ptr [di], 0

    mov dx, offset name_of_file
    call PrintMessage

    add y_offset, offset letter_counter
    mov dh, [x_offset]
    mov dl, [y_offset]
    call SetMousePosition
    jmp writing_loop

semi_middle_jump:
    jmp middle_jump

end_loop_name:
    call ConcatenateFilename
    call OpenFile

    call ClearScreen
    call ClearOffset
    call PrintWordFrequencyTitle

    mov x_offset, 1
    mov y_offset, 31

    mov dh, [x_offset]
    mov dl, [y_offset]
    call SetMousePosition

    mov dx, offset filename_prompt
    call PrintMessage

    add y_offset, filename_prompt_len

    mov dh, [x_offset]
    mov dl, [y_offset]
    call SetMousePosition

    mov dx, offset filename
    call PrintMessage

    call CountLetters
    call PrintLetterFrequency

    call CountWords
    call PrintWordFrequency

another_file_loop:
    mov dh, 5
    mov dl, 1
    call SetMousePosition

    mov dx, offset read_another_file
    call PrintMessage

    call WaitForKey
    cmp al, 'Y'
    cmp al, 'y'
    je semi_middle_jump

    cmp al, 'N'
    cmp al, 'n'
    je program_end

program_end:
    call ClearScreen
    call PrintWordFrequencyTitle

    mov dh, 5
    mov dl, 1
    call SetMousePosition

    mov dx, offset end_message
    call PrintMessage
    ret
AskForFilename endp

; WordCounterDriver
;
; Main program
;
WordCounterDriver proc far
    call SetVideoMode
    call ClearScreen

    call PrintWordFrequencyTitle
    call AskForFilename
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

; PrintLetterFrequency
;
; Print the number of letters in a buffer
;
PrintLetterFrequency proc near
    mov dh, 2
    mov dl, 31
    call SetMousePosition

    mov dx, offset letter_frequency
    call PrintMessage

    mov dh, 2
    mov dl, 41
    call SetMousePosition

    mov ax, [letters_count]
    call ConvertToASCII
    ret
PrintLetterFrequency endp

; PrintWordFrequency
;
; Print the number of words in a buffer
;
PrintWordFrequency proc near
    mov dh, 3
    mov dl, 31
    call SetMousePosition

    mov dx, offset word_frequency
    call PrintMessage

    mov dh, 3
    mov dl, 41
    call SetMousePosition

    mov ax, [words_count]
    call ConvertToASCII
    ret
PrintWordFrequency endp

; CountLetters
;
; Count the number of letters in a buffer
;
CountLetters proc near
    cmp [is_open_error], 1
    je _error
    cmp [is_read_error], 1
    je _error

    mov si, offset buffer_string
    mov di, offset exclude_letters
    xor cx, cx

read_buffer:
    mov al, [si]
    cmp al, ' '
    je skip_letter

    cmp al, '@'
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
    inc cx
    mov [letters_count], cx
    jmp _return

_error:
    xor cx, cx
    mov [letters_count], cx
    mov [words_count], cx
    jmp _return

_return:
    ret 
CountLetters endp

; CountWords
;
; Count the number of words in a buffer
;
CountWords proc near

    cmp [is_open_error], 1
    je __error
    cmp [is_read_error], 1
    je __error

    mov si, offset buffer_string
    xor cx, cx

read_word_buffer:
    mov al, [si]
    cmp al, '$'
    je return

    cmp al, '.'
    je skip_space

    cmp al, ','
    je skip_space

    cmp al, ' '
    je skip_space
    jne next_char

skip_space:
    inc si
    inc cx
    jmp read_word_buffer

next_char:
    inc si
    jmp read_word_buffer

__error:
    xor cx, cx
    mov [letters_count], cx
    mov [words_count], cx
    jmp return

return:
    mov [words_count], cx
    ret
CountWords endp

end