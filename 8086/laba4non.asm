laba4 SEGMENT
ASSUME CS:laba4, DS:laba4

ch1 dw 0
ch2 dw 0
ch3 dw 0
ch4 dw 0
rp1 db 13,10,'sectors per cluster: $'
rp2 db 13,10,'available clusters: $'
rp3 db 13,10,'byte per sector: $'
rp4 db 13,10,'total clusters: $'
rp5 db 13,10,'$'

vivod_stroka proc
  mov ax,0900h
  int 21h
  ret
vivod_stroka endp

printdec proc
  push cx
  push dx
  push bx
  push si
  xor si,si
  mov bx,10
  xor cx,cx
  test ax,ax
  jns @@m1
  neg ax
  inc si
@@m1:
  xor dx,dx
  div bx
  push dx
  inc cx
  test ax,ax
  jnz @@m1
  test si,si
  jz @@m22
  push -3
  inc cx
@@m22:
  mov ah,2
@@m2:
  pop dx
  add dl,'0'
  int 21h
  loop @@m2
  pop si
  pop bx
  pop dx
  pop cx
  ret
printdec endp

Start:
push cs
pop ds
mov ah,36h
mov dl,0
int 21h
mov ch1,ax
mov ch2,bx
mov ch3,cx
mov ch4,dx
mov dx,offset rp1
call vivod_stroka
mov ax,ch1
call printdec
mov dx,offset rp2
call vivod_stroka
mov ax,ch2
call printdec
mov dx,offset rp3
call vivod_stroka
mov ax,ch3
call printdec
mov dx,offset rp4
call vivod_stroka
mov ax,ch4
call printdec
mov dx,offset rp5
call vivod_stroka
mov ax,4C01h
int 21h

laba4 ENDS
End start
