.586
.model flat, C
public fun1
_data segment
strmas db 11 dup(?)
dec1 dd 10
_data ends
_text segment
fun1 proc par1:dword
lea ebx, strmas
push ebx
mov ecx, 11
metka1:
    mov byte ptr[ebx],'_'
    inc ebx
    loop metka1
mov eax, par1
push eax
or eax,eax
jns metka2
neg eax
metka2:
    xor edx, edx
    div dec1
    add dx, '0'
    dec ebx
    mov byte ptr[ebx],dl
    ;inc ecx
    or eax, eax
    jnz metka2
pop eax
or eax,eax
jns metka3
dec ebx
mov byte ptr[ebx], '_'
;inc ecx
metka3:
    pop ebx
    mov eax,ebx
ret
fun1 endp
_text ends
end
