laba4 segment       ; определение кодового сегмента
assume CS:laba4,DS:laba4  ; CS и DS указывают на сегмент кода
org 100h            ; размер PSP для COM программы
start:
jmp nerez           ; переход на нерезидентную часть

old dd ?            ; определение ячейки памяти для хранения адреса системного обработчика
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
  xor cx,cx           ; Количество цифр будем держать в CX.
  mov bx, 10          ; основание сс. 10 для десятеричной и т.п.
  oi2:
    xor dx,dx
    div bx            ; Делим число на основание сс. В остатке получается последняя цифра.
    push dx           ; Сразу выводить её нельзя, поэтому сохраним её в стэке.
    inc cx            ; А с частным повторяем то же самое, отделяя от него очередную
    test ax,ax        ; цифру справа, пока не останется ноль, что значит, что дальше
    jnz oi2           ; слева только нули.
    mov ah,02h        ; Теперь приступим к выводу.
  oi3:
    pop dx            ; Извлекаем очередную цифру, переводим её в символ и выводим.
    add dl,'0'
    int 21h
    loop oi3          ; Повторим ровно столько раз, сколько цифр насчитали.
  ret
printdec endp

stat proc
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
  ret
stat endp

unload proc
  xor ax,ax
  int 16h
  mov ax, 2509h           ; Восстановление старого вектора 09h
  lds dx, old
  int 21h
  mov es, cs:[2ch]        ; Освобождаем сегмент окружения
  mov ah, 49h
  int 21h
  push cs
  pop es                  ; Освобождаем программный сегмент
  mov ah, 49h
  int 21h
  push cs
  pop ds
  mov dx,offset mes_3
  call vivod_stroka
  mov checunload,1
  ret
unload endp

inter proc               ; процедура обработчика прерываний от клавиатуры
  pushf                  ; создание в стеке структуры для IRET
  call cs:old            ; вызов системного обработчика
  push ds                ; сохранение модифицируемых регистров
  push es
	push ax
  push bx
  push cx
  push dx
	push di
  push cs
  pop ds 
           
  mov ax,0200h
	int 16h     
  cmp al,00000100b        ; проверка нажат ли Ctrl      
  jne noact
  in al,60h
  cmp al,2Dh              ; cравнение со скан кодом X (2Dh)        
  je unload1
  cmp al,1Fh              ; cравнение со скан кодом S (1Fh)
  je stat1
  jmp noact

  unload1:
    call unload
    jmp noact

  stat1:
    call stat
    jmp noact

  noact:
    pop di                  ; восстановление модифицируемых регистров
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    pop ds

  iret                      ; возврат из обработчика
  cmp checunload,1
  je exit
inter endp                  ; конец процедуры обработчика
nerez:                       ; метка для определения размера резидентной части программы
  mov ax,3509h               ; получение адреса системного обработчика
  int 21h                    ; прерываний от клавиатуры
  cmp word ptr es:[chec],0ABCDh
  je inst
  mov word ptr old,bx         ; сохранение смещения обработчика
  mov word ptr old+2,es       ; сохранение сегмента обработчика
  mov ax,2509h                ; установка адреса нового обработчика
  mov dx,offset inter         ; указание смещения новго обработчика
  int 21h                     ; вызов DOS
  mov dx,offset mes_1
  call vivod_stroka
  mov dx,offset nerez         ;Завершаем программу,
  int 27h                     ;оставляя резидентную часть
inst:
  mov dx,offset mes_2
  call vivod_stroka
exit:
  mov ax,4c00h
  int 21h
laba4 ENDS
END start
