;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   BASE: Procedures
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Get Random Items  * * *
;------------------------------------------------
proc GetRandValue

local Scale dd ?
;------------------------------------------------
;   mov EBX, Max
;   mov ECX, Count
    mov EDX, ECX
    mov [Scale], ESI   ;   RandIndexScale
    mov EDI, ESI
    xor EAX, EAX
    rep stosd
    mov ECX, EDX

jmpScan@GetRandValue:
    push ECX

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
    mov EDI, [Scale]  ;   RandIndexScale
    mov ECX, EBX
    inc EAX
    repne scasd
       je jmpFind@GetRandValue

    mov [ESI], EAX
    lodsd

    pop ECX
    loop jmpScan@GetRandValue
;   xor EAX, EAX
    mov [ESI], ECX
    ret
endp
;------------------------------------------------
;       * * *  Get TableCheckData  * * *
;------------------------------------------------
proc GetTabCheck

;   mov EDI, [pTabParam]
    mov ESI, [TableDataBase.index]
    mov ECX, [TableDataBase.tests]

jmpTabScan@GetTabCheck:
    push ECX
    mov ECX, [TableDataBase.items]

    xor EBX, EBX  
    mov EDX, EBX
    inc EDX
    add ESI, 2

jmpScan@GetTabCheck:
    lodsb
    test AL, SET_ITEM_TRUE
         jz jmpSkip@GetTabCheck
         or EBX, EDX

jmpSkip@GetTabCheck:
    shl EDX, 1
    loop jmpScan@GetTabCheck

    mov EAX, EBX
    stosw

    pop ECX
    loop jmpTabScan@GetTabCheck
    ret
endp
;------------------------------------------------
;       * * *  Sort Sprintgs  * * *
;------------------------------------------------
proc SetTabSort

;   mov EDX, TabParam
;   mov index, [EAX]

jmpGet@SetTabSort:

    mov  EBX, EDX
    mov  EAX,[EBX] 
    test EAX, EAX
         jz jmpEnd@SetTabSort
         push EDX

jmpScan@SetTabSort:
         add  EBX, 4
         mov  ESI, [EBX] 
         test ESI, ESI
              jz jmpChang@SetTabSort

              mov EDI, [EDX] 
;             mov ESI, [EBX]
              mov CL,  MAX_SORT_NAME
              repe cmpsb
                ja jmpScan@SetTabSort

                   mov EDX, EBX
                   jmp jmpScan@SetTabSort

jmpChang@SetTabSort:
         mov EDI, EDX
         pop EDX
         cmp EDX, EDI
            je jmpNext@SetTabSort

             mov  EAX, [EDX] 
             xchg EAX, [EDI] 
             mov [EDX], EAX  

jmpNext@SetTabSort:
    add EDX, 4
    jmp jmpGet@SetTabSort

jmpEnd@SetTabSort:
    ret
endp
;------------------------------------------------
;       * * *  User Table  * * *
;------------------------------------------------
proc TrimTabSpace
;------------------------------------------------
;   mov EBX, TabParam
;   mov ECX, Count

jmpScan@TrimTabSpace:
    mov ESI, [EBX]
    test ESI, ESI
         jz jmpNext@TrimTabSpace
;------------------------------------------------
         mov DL, ' '    ;       32
;------------------------------------------------
jmpLeft@TrimTabSpace:
         lodsb
         test AL, AL
              jz jmpEmpty@TrimTabSpace
              cmp AL, DL
                  ja  jmpRight@TrimTabSpace
                  jbe jmpLeft@TrimTabSpace
;------------------------------------------------
;       * * *  Empty
;------------------------------------------------
jmpEmpty@TrimTabSpace:
;        mov EAX, szSetError - 1
         xor EAX, EAX
         mov [EBX], EAX
         jmp jmpNext@TrimTabSpace
;------------------------------------------------
;       * * *  String
;------------------------------------------------
jmpRight@TrimTabSpace:
         dec ESI
         mov EDI, ESI
         mov [EBX], ESI

jmpFind@TrimTabSpace:
         lodsb

jmpContinue@TrimTabSpace:
         stosb
         test AL, AL
              jz jmpNext@TrimTabSpace
              cmp AL, DL
                  ja jmpFind@TrimTabSpace
                  je jmpSkip@TrimTabSpace
                  dec EDI
                  mov [EDI], DL

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
              mov [EDI], AL

jmpNext@TrimTabSpace:
    add EBX, 4
    loop jmpScan@TrimTabSpace

;   mov [RBX], RCX    ;    EndOfTable
    ret
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------

