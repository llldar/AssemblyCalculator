section .text
global mystart


mystart:

push dword lmsg1
push dword msg1
push dword 1

mov eax, 4
sub esp,4
int 80h;
add esp,16

push dword 0
mov eax,1h
sub esp,4
int 80h




section .data

msg1        db      '-Calculator-', 0xa
lmsg1       equ     $ - msg1