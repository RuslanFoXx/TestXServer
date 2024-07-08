;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   SYSTEM: Type To String
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Copy String  * * *
;------------------------------------------------
proc CopyString1

;   mov RBX, String
    mov RDX, RDI
    mov RDI, RBX
    mov RAX, RAX
    mov RCX, RAX
    mov CL,  MAX_STRING_LENGTH
    repnz scasb

    mov RSI, RBX     ;     string
    mov RCX, RDI
    inc RBX
    sub RCX, RBX
    mov RDI, RDX
    mov RDX, RCX     ;     length
    rep movsb
    ret
endp
;------------------------------------------------
;       * * *  Trim Of String  * * *
;------------------------------------------------
proc StrTrim

;   mov RSI, pNew
    mov BL, 32

jmpFind@StrTrim:
    lodsb
    test AL, AL
         jz jmpZero@StrTrim

    cmp AL, BL
        jbe jmpFind@StrTrim

    dec RSI
    mov RDI, RSI
    mov ECX, FILEPATH_SIZE
    xor EAX, EAX
    repne scasb

jmpZero@StrTrim:
    dec RDI
    cmp [RDI], BL
        ja jmpEnd@StrTrim

    cmp RDI, RSI
        jae jmpZero@StrTrim

jmpEnd@StrTrim:
    inc RDI
    xor EAX, EAX
    mov [RDI], AL
;   stosb
    ret
endp
;------------------------------------------------
;       * * *  Index To String  * * *
;------------------------------------------------
proc IndexToStr

;   mov RDI, String
;   mov EBX, Index
    xor RAX, RAX
    mov RCX, RAX
    mov RDX, RAX
    mov AX,  BX
    mov CL,  10

;   xor EDX, EDX
    div ECX
    mov BL, DL
    shl EBX, 8

    xor EDX, EDX
    div ECX
    mov BL, DL
    shl EBX, 8

    xor EDX, EDX
    div ECX
    mov BL, DL
    shl EBX, 8

    xor EDX, EDX
    div ECX
    mov BL, DL
;   shl EBX, 8
;------------------------------------------------
;       * * *  Insert
;------------------------------------------------
    mov EDX, '0000'
    add AL, DL
    stosb

    add EBX, EDX
    mov EAX, EBX
    stosd

    xor RCX, RCX    ;   for form rep movs
    ret
endp
;------------------------------------------------
;       * * *  HEX To String  * * *
;------------------------------------------------
proc HexToStr

;   mov RDI,  pBuffer
    mov RSI,  sHexScaleChar
;   mov RDX,  Value
    xor RCX,  RCX
    mov RBX,  RCX
    mov CL,   16
    mov R8b,  0Fh

jmpScan@HexToStr:
    rol RDX, 4
    mov BL,  DL
    and BL,  R8b  ;   0Fh
    mov AL, [RSI+RBX]
    stosb
    loop jmpScan@HexToStr

;   mov [RDI], CL
    ret
;   sHexScaleChar DB "0123456789ABCDEF"
endp
;------------------------------------------------
;       * * *  dd-Index To String  * * *
;------------------------------------------------
proc ByteToStr

;   mov EAX, Byte
    mov AX, word[sStrByteScale+2+EAX*4]
    mov BX, AX
    cmp AL, '0'
        je jmpSkip@CharToStr
        stosw
        ret

jmpSkip@CharToStr:
    mov AL, AH
    stosb
    ret
endp
;------------------------------------------------
;       * * *  INT To String  * * *
;------------------------------------------------
proc DecToStr

;   mov RDI, pBuffer
;   mov EBX, Value
;   mov RCX, Zero [15]

    mov RSI, RDI
;   xor ECX, ECX
;   mov CL,  AL
    mov R8b, '0'
    and ECX, 0Fh 

    mov AL, R8b
    rep stosb 

    mov CL,  10
    xor RAX, RAX
    mov EAX, EBX

jmpScan@DecToStr:
    inc RSI
    xor RDX, RDX
    div ECX

    test EAX, EAX
         jnz jmpScan@DecToStr

    cmp RDI, RSI
        ja jmpEnd@DecToStr
        mov RDI, RSI

jmpEnd@DecToStr:
    mov RSI, RDI 
    mov [RDI], AL
    mov EAX, EBX

jmpDiv@DecToStr:
    dec RDI
    xor RDX, RDX
    div ECX

    add DL, R8b
    mov [RDI], DL

    test EAX, EAX
         jnz jmpDiv@DecToStr
-
    mov RDI, RSI 
    xor RCX, RCX    ;   for form rep movs
    ret
endp
;------------------------------------------------
;       * * *  INT To String  * * *
;------------------------------------------------
proc WordToStr

;   mov RDI, pBuffer
;   mov EBX, Value
    xor RAX, RAX
    mov RCX, RAX
    mov CL,  10
    mov R8b, '0'
    mov EAX, EBX

jmpScan@WordToStr:
    inc RDI
    xor RDX, RDX
    div ECX

    test RAX, RAX
         jnz jmpScan@WordToStr

    mov RSI, RDI
;   mov [RDI], AL
    mov EAX, EBX

jmpDiv@WordToStr:
    dec RDI
    xor RDX, RDX
    div ECX

    add DL, R8b
    mov [RDI],DL

    test RAX, RAX
         jnz jmpDiv@WordToStr

    mov RDI, RSI 
    xor RCX, RCX    ;   for form rep movs
    ret
endp
;------------------------------------------------
;       * * *  INT To String  * * *
;------------------------------------------------
proc IntToStr

;   mov  RDI, pBuffer
;   mov  RCX, Value
;   test RCX, RCX
;        jns jmpSet@IntToStr
;        mov AL, '-'
;        stosb
;        neg RCX

jmpSet@IntToStr:
    xor RBX, RBX
;   mov R8,  RBX
    mov R8b, '0'
    mov BL,  10
    mov RAX, RCX

jmpScan@IntToStr:
    inc RDI
    xor RDX, RDX
    div RBX
    test RAX, RAX
         jnz jmpScan@IntToStr

    mov RSI, RDI
;   mov [RDI], AL
    mov RAX, RCX

jmpDiv@IntToStr:
    dec RDI
    xor RDX, RDX
    div RBX

    add DL, R8b  ;  '0'
    mov [RDI], DL
    test RAX, RAX
         jnz jmpDiv@IntToStr

    mov RDI, RSI 
    xor RCX, RCX
    ret
endp
;------------------------------------------------
;       * * *  Percent To String  * * *
;------------------------------------------------
proc StrPercent

;   mov RDI, Buffer
;   mov RCX, total
;   mov RAX, part
    mov R8w, '00'

    jECXz jmpErr@StrPercent

    cmp EAX, ECX
        ja jmpErr@StrPercent
        jb jmpSet@StrPercent

        mov EAX, '100.'
        stosd
        mov EAX, R8d
        stosw
        ret

jmpErr@StrPercent:
        mov EAX, ERROR_PARAM
        stosd
        ret

jmpSet@StrPercent:
    xor RBX, RBX
    mov BX,  10000
    mul EBX

    xor RDX, RDX
    div ECX

    mov BX,  100
    xor EDX, EDX
    div EBX
    mov RSI, RDX    ;    100.xx%

;   mov BL,  100
    xor EDX, EDX
    div EBX
    test AL, AL
         jz jmpDec2@StrPercent

         add AL, R8b  ;  '0'
         stosb

jmpDec2@StrPercent:
 mov RBX, RSI
 mov ESI, sStrByteScale + 2

 mov AX, [ESI+EDX*4] ;    000.xx%
 cmp AL, '0'
     je jmpDec3@StrPercent
     stosb

jmpDec3@StrPercent:
    mov AL, AH
    mov AH, '.'
    stosw

    mov AX, [ESI+EBX*4] ;    xxx.00% 
    stosw

jmpEnd@StrPercent:
    xor RCX, RCX    ;   for form rep movs
    ret
endp
;------------------------------------------------
;       * * *  Seconds To String  * * *
;------------------------------------------------
proc StrSecond

;   mov EAX, Seconds
    mov ESI, sStrByteScale + 2
    mov EBX, 60
    xor EDX, EDX
    div EBX
    mov R8d, EDX
    xor EDX, EDX
    div EBX
;------------------------------------------------
;       * * *  Time Hours
;------------------------------------------------
    test AL, AL
         jz jmpMin@StrSecond
         add AL, '0'
         mov AH, ':'
         stosw
;------------------------------------------------
;       * * *  Time Minutes
;------------------------------------------------
jmpMin@StrSecond:
    mov AX, [ESI+EDX*4] ;    wHour
    stosw

    mov AL,  ':' 
    stosb

    mov AX, [ESI+R8d*4] ;    wHour
    stosw

;   xor ECX, ECX    ;   for form rep movs
    ret
endp
;------------------------------------------------
;       * * *  Date To String  * * *
;------------------------------------------------
proc StrDate

;   mov ECX, Date
    mov ESI, sStrByteScale + 2
    mov EBX, ECX
    shr EBX, 17
    and EBX, 31  
    mov AX, [ESI+EBX*4] ;    wDay
    stosw

    mov AL,  '-' 
    stosb

    mov EBX, ECX
    shr EBX, 22
    and EBX, 15   
    mov AX, [ESI+EBX*4] ;    wMonth
    stosw

    mov EAX, '-20'
    stosd
    dec EDI

    mov EBX, ECX
    shr EBX, 26
    add BL,  ADD_YEAR_VALUE 
    mov AX, [ESI+EBX*4] ;    wYear
    stosw

    xor RCX, RCX    ;   for form rep movs
    ret
endp
;------------------------------------------------
;       * * *  Time Of String  * * *
;------------------------------------------------
proc StrTime

;   mov ECX, Date
    mov ESI, sStrByteScale + 2
    mov EBX, ECX
    shr EBX, 12
    and EBX, 31  
    mov AX, [ESI+EBX*4] ;    wHour
    stosw

    mov AL,  ':' 
    stosb

    mov EBX, ECX
    shr EBX, 6
    and EBX, 63   
    mov AX, [ESI+EBX*4] ;    wMinute
    stosw

    mov AL,  ':' 
    stosb

    mov EBX, ECX
    and EBX, 63   
    mov AX, [ESI+EBX*4] ;    wSecond
    stosw

    xor RCX, RCX    ;   for form rep movs
    ret
endp
;------------------------------------------------
;       * * *  DATE To String  * * *
;------------------------------------------------
proc HeaderDateToStr
;------------------------------------------------
;           * * *  Set Date = Www, DD Mmm YYYY
;------------------------------------------------
    xor RAX, RAX
    mov RCX, RAX
    mov RSI, RAX
;   mov ESI, ServerTime
    mov ESI, LocalTime
    mov EBX, sStrByteScale + 2

    lodsw
    sub AX, DELTA_ZERO_YEAR
    mov AX, [EBX+EAX*4]
    mov EDX, EAX
    mov EAX, ECX
    lodsw
    dec EAX
    mov EAX, dword[sMonthDateHeader+EAX*4]
    mov R8d, EAX

    mov EAX, ECX
    lodsw
    mov EAX, dword[sWeekDateHeader+EAX*4]
    stosd               ;    wDayOfWeek

    mov CL, ' '
    mov EAX, ECX
    stosb

    lodsw
    mov AX, [EBX+EAX*4] ;    wDay
    stosw

    mov EAX, ECX
    stosb

    mov EAX, R8d        ;    wMonth
    stosd

    mov AX, '20'
    stosw

    mov EAX, EDX        ;    wYear
    stosw
;------------------------------------------------
;           * * *  Set Time = hh:mm:ss
;------------------------------------------------
    mov EAX, ECX
    stosb

    lodsw
    mov AX, [EBX+EAX*4] ;    wHour
    stosw

    mov CL, ':'
    mov EAX, ECX
    stosb

    lodsw
    mov AX, [EBX+EAX*4] ;    wMinute
    stosw

    mov EAX, ECX
    stosb

    lodsw
    mov AX, [EBX+EAX*4] ;    wSecond
    stosw
    xor RCX, RCX
    ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------
