.model tiny
.code
org 100h
start:

jmp ddddd
liau dw 16
     dw 16
     dw 16
     dw 16
     dw 16
     db 16
ddddd:
add liau, ax
mul cl
shl dx, 1
rcl ch, cl
out 12h, ax
out 11h, al

push liau
int 15h
inc liau
dec liau
neg liau
jmp ddddd
in ax, dx
in ax, +55
in al, +12
cmp liau, 0
je ddddd

end start