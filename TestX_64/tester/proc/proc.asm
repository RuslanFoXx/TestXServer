;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   BASE: Procedures
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Get Random Items  * * *
;------------------------------------------------
proc GetRandValue

;   mov RSI, RandIndexScale
;   mov EBX, Max
;   mov RCX, Count
    mov R12, RSI
    mov R8,  RCX
    mov RDI, RSI
    xor EAX, EAX
    rep stosd

jmpScan@GetRandValue:
    add EAX, [DateRandom]
    rol EAX, 1
    add [DateRandom], EAX

    xor EDX, EDX
    div EBX
    mov EAX, EDX

jmpFind@GetRandValue:
    cmp EAX, EBX
        jb jmpGet@GetRandValue
        xor EAX, EAX

jmpGet@GetRandValue:
    mov RDI, R12    ;    RandIndexScale
    mov ECX, EBX
    inc EAX
    repne scasd
       je jmpFind@GetRandValue

    mov [RSI], EAX
    lodsd

    dec R8d
        jnz jmpScan@GetRandValue

;   xor EAX, EAX
    mov [RSI], ECX
    ret
endp
;------------------------------------------------
;       * * *  Get TableCheckData  * * *
;------------------------------------------------
proc GetTabCheck

;   mov RDI,  [pTabParam]
    mov RSI,  [TableDataBase.index]
    mov R15d, [TableDataBase.tests]
    mov R8b, SET_ITEM_TRUE
    xor R9, R9
    mov R9b, 2

jmpTabScan@GetTabCheck:
    mov ECX, [TableDataBase.items]
    xor EBX, EBX  
    mov EDX, EBX
    inc EDX
    add RSI, R9

jmpScan@GetTabCheck:
    lodsb
    test AL, R8b
         jz jmpSkip@GetTabCheck
         or EBX, EDX

jmpSkip@GetTabCheck:
    shl EDX, 1
    loop jmpScan@GetTabCheck

    mov EAX, EBX
    stosw
    dec R15d
        jnz jmpTabScan@GetTabCheck
    ret
endp
;------------------------------------------------
;       * * *  Sort Sprintgs  * * *
;------------------------------------------------
proc SetTabSort

;   mov R12, TabParam
;   mov RCX, index
    xor RCX, RCX
    mov R8,  RCX
    mov R8b, 8

jmpGet@SetTabSort:
    mov  RBX, R12
    mov  RAX,[RBX]
    test RAX, RAX
         jz jmpEnd@SetTabSort
         mov RDX, R12

jmpScan@SetTabSort:
         add  RBX, R8
         mov  RSI, [RBX] 
         test RSI, RSI
              jz jmpChang@SetTabSort

              mov RDI, [RDX] 
;             mov RSI, [RBX] 
              mov CL,  MAX_SORT_NAME
              repe cmpsb
                ja jmpScan@SetTabSort

                   mov RDX, RBX
                   jmp jmpScan@SetTabSort
;------------------------------------------------
jmpChang@SetTabSort:
         cmp RDX, R12
             je jmpNext@SetTabSort
             mov  RAX, [R12] 
             xchg RAX, [RDX] 
             mov [R12], RAX 

jmpNext@SetTabSort:
    add R12, R8
    jmp jmpGet@SetTabSort

jmpEnd@SetTabSort:
    ret
endp
;------------------------------------------------
;
;       * * *  User Table  * * *
;
;------------------------------------------------
proc TrimTabSpace

;   mov RBX, TabParam
;   mov RCX, Count
    xor R8,  R8
    mov R8b, 8

jmpScan@TrimTabSpace:
    mov RSI, [RBX]
    test RSI, RSI
         jz jmpNext@TrimTabSpace
         mov DL, ' '    ;       32

jmpLeft@TrimTabSpace:
         lodsb
         test AL, AL
              jz jmpEmpty@TrimTabSpace

              cmp AL, DL
                  jbe jmpLeft@TrimTabSpace
                  jmp jmpRight@TrimTabSpace
;------------------------------------------------
;       * * *  Empty
;------------------------------------------------
jmpEmpty@TrimTabSpace:
;        mov RAX, szSetError - 1
         xor RAX, RAX
         mov [RBX], RAX
         jmp jmpNext@TrimTabSpace
;------------------------------------------------
;       * * *  String
;------------------------------------------------
jmpRight@TrimTabSpace:
         dec RSI
         mov RDI, RSI
         mov [RBX], RSI

jmpFind@TrimTabSpace:
         lodsb

jmpContinue@TrimTabSpace:
         stosb
         test AL, AL
              jz jmpNext@TrimTabSpace

              cmp AL, DL
                  ja jmpFind@TrimTabSpace
                  je jmpSkip@TrimTabSpace

                  dec RDI
                  mov [RDI], DL

jmpSkip@TrimTabSpace:
              lodsb
              test AL, AL
                   jz jmpClose@TrimTabSpace
                   cmp AL, DL
                       jbe jmpSkip@TrimTabSpace
                       jmp jmpContinue@TrimTabSpace
;------------------------------------------------
;       * * *  Set Table
;------------------------------------------------
jmpClose@TrimTabSpace:
              mov [RDI], AL

jmpNext@TrimTabSpace:
    add RBX, R8
    loop jmpScan@TrimTabSpace
;   mov [RBX], RCX    ;    EndOfTable
    ret
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------

