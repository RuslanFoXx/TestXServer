;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   SYSTEM: Hash
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
HIGH_BIT  equ 8000h
FIRST_BIT equ 01h
REG_BITS  equ 16
REG_STEP  equ  4   ;   ( REG_BITS / 8 )
;------------------------------------------------
;       * * *  Data To Hash  * * *
;------------------------------------------------
proc DataToHash

;   push EBX     ;   value
    push EAX     ;   code
    mov EDI, EBX
    xor ECX, ECX
    mov EDX, ECX
    mov CL,  REG_BITS
;------------------------------------------------
;       * * *  Register1 To Hash
;------------------------------------------------
jmpData1@DataToHash:
    test AL, FIRST_BIT
         jz jmpNext1@DataToHash
         shl DX, 1

         mov ESI, EBX
         and BL,  FIRST_BIT
          or DL,  BL
         mov EBX, ESI

jmpNext1@DataToHash:
    shr AX, 1
    shr BX, 1
    loop jmpData1@DataToHash

    mov CL, REG_BITS
    pop EAX      ;   code
;   pop EBX      ;   value
    mov EBX, EDI
;------------------------------------------------
;       * * *  Register0 To Hash
;------------------------------------------------
jmpData0@DataToHash:
    test AL, FIRST_BIT
         jnz jmpNext0@DataToHash
         shl DX, 1

         mov ESI, EBX
         and BL,  FIRST_BIT
          or DL,  BL
         mov EBX, ESI

jmpNext0@DataToHash:
    shr AX, 1
    shr BX, 1
    loop jmpData0@DataToHash
;   mov EAX, EDX    ;    hash
    ret
endp
;------------------------------------------------
;       * * *  Hash To Data  * * *
;------------------------------------------------
proc HashToData

;   push EAX     ;   code
;   push EBX     ;   hash
    mov EDI, EAX
    xor ECX, ECX
    mov EDX, ECX
    mov CL,  REG_BITS
;------------------------------------------------
;       * * *  Register1 To Data
;------------------------------------------------
jmpHash1@HashToData:
    shr DX, 1

    test AL, FIRST_BIT
         jz jmpNext1@HashToData

         mov ESI, EBX
         and BX,  HIGH_BIT
          or DX,  BX
         mov EBX, ESI
         shl BX, 1

jmpNext1@HashToData: 
    shr AX, 1
    loop jmpHash1@HashToData

    mov CL,  REG_BITS
    mov EAX, EDI
    mov EDI, EDX
    xor EDX, EDX
;------------------------------------------------
;       * * *  Register0 To Data
;------------------------------------------------
jmpHash0@HashToData:
    shr DX, 1

    test AL, FIRST_BIT
         jnz jmpNext0@HashToData

         mov ESI, EBX
         and BX,  HIGH_BIT
          or DX,  BX
         mov EBX, ESI
         shl BX, 1

jmpNext0@HashToData: 
    shr AX, 1
    loop jmpHash0@HashToData

     or EDX, EDI
;   mov EAX, EDX    ;    value
    ret
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
