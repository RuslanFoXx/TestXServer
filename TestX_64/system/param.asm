;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   SYSTEM: String Proc
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  String To DWORD  * * *
;------------------------------------------------
proc StrToWord

    xor  RDX, RDX
    mov  R8b, '0'
    mov  R9b, '9'
;   mov  RSI, RAX
;   mov  RSI, [pBuffer]
    test RSI, RSI
         jz jmpEnd@StrToWord

    mov RCX, RDX
    mov RBX, RDX
    mov BL,  10

jmpScan@StrToWord:
    lodsb
    cmp AL, R8b  ;  '0'
        jb jmpEnd@StrToWord

    cmp AL, R9b  ;  '9'
        ja jmpEnd@StrToWord

    sub AL, R8b  ;  '0'
    mov CL, AL

    mov RAX, RDX
    mul RBX 
    add RAX, RCX
    mov RDX, RAX
    jmp jmpScan@StrToWord

jmpEnd@StrToWord:
    mov RAX, RDX
    mov RBX, RDX
    ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------
