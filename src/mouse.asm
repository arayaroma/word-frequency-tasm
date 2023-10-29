; mouse.asm
; author: arayaroma
;
.8086
.model small
public IsMouseIn
public ShowMouse, HideMouse, SetMousePosition, GetMousePosition
public mouseX, mouseY, mouseXText, mouseYText
public is_mouse_in, mouseStatus

; graphics.asm
extrn PrintMessage:far

.data
    mouseXText      db "Mouse X: ", '$'
    mouseYText      db "Mouse Y: ", '$'
    mouseX          dw 0
    mouseY          dw 0
    mouseStatus     dw ?
    is_mouse_in     dw ?

.code

; ShowMouse
;
; int 33H
; ax = 01H 
;
ShowMouse proc far
    mov ax, 0001H
    int 33H
    ret
ShowMouse endp

; HideMouse
;
; int 33H
; ax = 02H
;
HideMouse proc far
    mov ax, 0002H
    int 33H
    ret
HideMouse endp

; GetMousePosition
;
; int 33H
; ax = 03H
; bx: button status
; cx: x position
; dx: y position
; 
; |8|7|6|5|4|3|2|1|0|
; (0) left button (1 = pressed)
; (1) right button (1 = pressed)
; (2-8) unused
;
GetMousePosition proc far
    mov ax, 03H
    int 33H
    mov [mouseX], cx
    mov [mouseY], dx
    mov [mouseStatus], bx
    ret
GetMousePosition endp

; SetMousePosition
;
; int 10H 
; ax = 02H
; bx = 00H
; dh = x position
; dl = y position
;
SetMousePosition proc far
    mov ah, 02H
    mov bh, 00H
    int 10H
    ret
SetMousePosition endp

; IsMouseIn
;
; cx = x position
; dx = y position
; [bp + 4] = x1
; [bp + 6] = x2
; [bp + 8] = y1
; [bp + 10] = y2
;
; is_mouse_in = 1 if mouse is in the box
; is_mouse_in = 0 if mouse is not in the box
;
IsMouseIn proc far
    push bp
    mov bp, sp

    cmp cx, word ptr [bp + 4]
    jl not_in
    cmp cx, word ptr [bp + 6]
    jg not_in

    cmp dx, word ptr [bp + 8]
    jl not_in
    cmp dx, word ptr [bp + 10]
    jg not_in

    mov [is_mouse_in], 1
    jmp return
not_in:
    mov [is_mouse_in], 0
    jmp return

return:
    pop bp
    ret
IsMouseIn endp

end