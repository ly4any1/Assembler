CODE segment
ASSUME CS:CODE, DS:CODE
ORG 100H

HAH: jmp start
KEY DW 5555H ; yacheyka 103h (100h byte PSP + 3 byte of JMP Start

OLDVECT DD 0
UNLOAD DB 'UNLOAD SUCCESSFULL$'
chec db 0

do_colon proc ;near
push ax
push dx
mov ah,02
mov dl,':'
int 21h
pop dx
pop ax
ret
do_colon endp

VIVOD1 proc
;mov al,ah
;out 61h,al
mov ax,2c00h ;ПРЕРЫВАНИЕ ВРЕМЕНИ
int 21h
;CH HOURS
;CL MINS
;DH SECS
;DL CENTISECS
PUSH DX
PUSH CX ;ТУТ СОХРАНИЛИСЬ ЗНАЧЕНИЯ ОТ ВРЕМЕНИ
mov ah,0
mov al,ch
mov cl,10
div cl
push ax
ADD AL,'0'
mov dl,al
mov ah,02h
int 21h
pop ax
ADD ah,'0'
mov dl,ah
mov ah,02h
int 21h

call do_colon
pop cx ;restore minutes
mov ah,0
mov al,cl
mov cl,10
div cl
push ax ;save quotient & remainder
ADD AL,'0' ;tens of minutes to ascii
mov dl,al
mov ah,02h
int 21h
pop ax ;restore quotient & remainder
ADD ah,'0' ;units of minutes to ascii
mov dl,ah
mov ah,02h
int 21h

call do_colon
pop dx ;restore secs & cent-secs
push dx ;& save it again
mov ah,0
mov al,dh ;secs
mov cl,10
div cl
push ax ;save tens & units of secs
ADD al,'0' ;tens of secs to ascii
mov dl,al
mov ah,02h
int 21h
pop ax
ADD ah,'0' ;units of secs to ascii
mov dl,ah
mov ah,02h
int 21h

call do_colon
pop dx ;restore secs & centi-secs
mov ah,0
mov al,dl ;centi-secs
mov cl,10
div cl
push ax ;save tens & units of centisecs
ADD al,'0' ;tens of centi-secs to ascii
mov dl,al
mov ah,02h
int 21h
pop ax
ADD ah,'0' ;units of centi-secs to ascii
mov dl,ah
mov ah,02h
int 21h

MOV DL,13 ; perehod na novuyu stroku
INT 21h ; i vozvrat karetki
MOV DL,10 ;
INT 21h
ret
vivod1 endp

time PROC
pushf
call cs:OLDVECT
PUSH AX
PUSH ES
PUSH BX
PUSH CX
PUSH DX
PUSH SI
;xor bx,bx

;comand:
;xor ax,ax
;int 16h
;MOV AX,20h ;signal
;OUT 20h,ax 😰 konce
;XOR AX,AX ;prerivaniya
mov ax,0200h
int 16h
CMP AL,00000100b
JE next ;равны=>символ есть
Jmp return
next:
in al,60h
CMP AL,1Fh ;ctrl+S
JE VIVOD
cmp al,2Dh ;ctrl+X
je VIHOD
cmp al,12h ;ctrl+E
JE clean
jmp return

;nonono:
;mov al,ah
;out 61h,al
;jmp return

vivod :
xor ax,ax
int 16h
call vivod1
jmp return



RETURN:
;MOV AX,20h ;signal
;OUT 20h,ax 😰 konce
;XOR AX,AX ;prerivaniya
;xor ax,ax
POP SI
POP DX
POP CX
POP BX
POP ES
POP AX
iret
cmp chec,1
je exir
JMP ex
exir:
mov ax,4c00h
int 21h
;jmp time

clean:
xor ax,ax
int 16h
mov ah, 00h ;clean screen
mov al, 03h
int 10h
jmp return

VIHOD:
xor ax,ax
int 16h
MOV AH,02h
MOV DL,13 ; perehod na novuyu stroku
INT 21h ; i vozvrat karetki
MOV DL,10 ;
INT 21h
MOV AX,3509h
INT 21h
MOV AX,2509h
LDS DX,ES:OLDVECT
INT 21H
MOV AH,49H
INT 21h
MOV AX,CS
MOV DS,AX
MOV DX,OFFSET UNLOAD
MOV AH,9
INT 21h
MOV AH,02h
MOV DL,13 ; perehod na novuyu stroku
INT 21h ; i vozvrat karetki
MOV DL,10 ;
INT 21h
mov chec,1
jmp return
;MOV AX,20h ;signal
;OUT 20h,ax 😰 konce -говорит,что обработка завершена
;XOR AX,AX ;prerivaniya

;POP SI
;POP DX
;POP CX
;POP BX
;POP ES
;POP AX
ex: ;возврат из обработчика
time ENDP

start:
MOV AH,35H ;AH sodershit nomer funkcii
MOV AL,09H ;AL ukazivaet nomer prerivaniya
;addres kotorogo nushno poluchit
INT 21h

CMP WORD PTR ES:[103H],5555H
JZ ZAGR

MOV WORD PTR OLDVECT,BX ;получение вектора штатного обработчика
MOV WORD PTR OLDVECT+2,ES

;Perehvat prerivaniya
MOV AX,2509h ;адрес нашего обработчика
MOV DX,OFFSET time ;DS:DX указывает на смещение обработчика
int 21h

MOV DX,OFFSET START
INT 27H ;завершение прерывания,сохр резидента

ZAGR:
MOV AH,09
MOV DX,OFFSET INSTSTROKA
INT 21H
jmp exir
INSTSTROKA DB 'PROGRAM HAS BEEN ALREADY INSTALLED$'

CODE ENDS
END HAH
