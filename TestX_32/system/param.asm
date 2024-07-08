;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   SYSTEM: String Proc
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  String To DWORD  * * *
;------------------------------------------------
proc StrToWord

    xor  EDX, EDX
;   mov  ESI, EAX
;   mov  ESI, pBuffer
    test ESI, ESI
         jz jmpEnd@StrToWord

    mov ECX, EDX
    mov EBX, EDX
    mov BL,  10

jmpScan@StrToWord:
    lodsb
    cmp AL, '0'
        jb jmpEnd@StrToWord

    cmp AL, '9' 
        ja jmpEnd@StrToWord

    sub AL, '0'
    mov CL, AL

    mov EAX, EDX
    mul EBX 
    add EAX, ECX
    mov EDX, EAX
    jmp jmpScan@StrToWord

jmpEnd@StrToWord:
    mov EAX, EDX
    mov EBX, EDX
    ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------
