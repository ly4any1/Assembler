laba4 SEGMENT
ASSUME CS:laba4,DS:laba4
org 100h
start:
jmp nerez
old dd ?
chec dw 0ABCDh
checunload db 0
ch1 dw 0
ch2 dw 0
ch3 dw 0
ch4 dw 0
rp1 db 13,10,'sectors per cluster: $'
rp2 db 13,10,'available clusters: $'
rp3 db 13,10,'byte per sector: $'
rp4 db 13,10,'total clusters: $'
mes_1 db 13,10,'Rezident is loaded $'
mes_2 db 13,10,'Rezident is already loaded $'
mes_3 db 13,10,'Rezident is unloaded $'
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
inter proc                             ; процедура обработчика прерываний от таймера
  pushf                            ; создание в стеке структуры для IRET
  call cs:old                 ; вызов старого обработчика прерываний
  push ds                       ; сохранение модифицируемых регистров
  push es
	push ax
  push bx
  push cx
  push dx
	push di
  push cs
  pop ds           
  mov ax,0200h     ;Выход при Ctrl+X
	int 16h     
  cmp al,00000100b      
  jne noact
  in al,60h
  cmp al,2Dh              ;Сравнение со скан кодом X (2Dh)        
  je unload
  cmp al,1Fh              ;Сравнение со скан кодом S (1Fh)
  je stat
noact:
  pop di                       ; восстановление модифицируемых регистров
  pop dx
  pop cx
  pop bx
  pop ax
  pop es
  pop ds
  cmp checunload,1
  je met
  iret
  inter endp
  jmp nerez
met:
  mov ax,4c00h
  int 21h
unload:
  xor ax,ax
  int 16h
  mov dx,offset mes_3
  call vivod_stroka
  mov ax, 2509h         ; Восстановление старого вектора 09h
  lds dx, old
  int 21h
  mov es, cs:[2ch]                 ; Освобождаем сегмент окружения
  mov ah, 49h
  int 21h
  push cs
  pop es                           ; Освобождаем программный сегмент
  mov ah, 49h
  int 21h
  mov checunload,1
  jmp noact
stat:
  xor ax,ax
  int 16h
  mov ax,3600h
  mov dx,0000h
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
  jmp noact
nerez:
  mov ax,3509h               ; получение адреса старого обработчика
  int 21h                    ; прерываний от таймера
  cmp word ptr es:[chec],0ABCDh
  je inst
  mov word ptr old,bx        ; сохранение смещения обработчика
  mov word ptr old+2,es    ; сохранение сегмента обработчика
  mov ax,2509h               ; установка адреса нашего обработчика
  mov dx,offset inter       ; указание смещения нашего обработчика
  int 21h                      ; вызов DOS
  mov dx,offset mes_1
  call vivod_stroka
  mov dx,offset nerez     ;Завершаем программу,
  int 27h                 ;оставляя резидентную часть
inst:
  mov dx,offset mes_2
  call vivod_stroka
  jmp met
laba4 ENDS
END start
