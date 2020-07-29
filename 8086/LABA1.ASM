lab1 segment
assume cs:lab1, ds:lab1
mas db 30 dup(0)
min db 255
mas1 db 15 dup(0)
i db 1
l db 1
d db 10,13,'$'
vivod proc
aam
add ax,3030h
mov dl,ah
mov dh,al
mov ah,02
int 21h
mov dl,dh
int 21h
mov dl,' '
int 21h
ret
vivod endp
stroka proc
lea dx, d
mov ah,9
int 21h
ret
stroka endp
start:
push cs
pop ds
mov cl,30
mov si,0
mov bl,2
m1:
mov al,i
mul bl
div l
add al,10
sub al,i
mov mas[si],al
call vivod
inc si
inc i
loop m1
call stroka
mov cl,30
dec si
m2:
mov al,mas[si]
cmp min,al
jae mm
mm:
mov al,mas[si]
mov min,al
dec si
loop m2
call vivod
call stroka
mov cl,30
inc si
mov di,0
m3:
mov al,mas[si]
cbw
div bl
cmp ah,0
je mmm
jne mmmm
mmm:
mov al,mas[si]
mov mas1[di],al
call vivod
inc di
mmmm:
inc si
loop m3
mov ax,4c01h
int 21h
lab1 ends
end start
