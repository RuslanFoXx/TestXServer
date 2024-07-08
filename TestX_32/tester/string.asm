;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   SYSTEM: Type To String
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Copy String  * * *
;------------------------------------------------
proc CopyString1

;   mov EBX, String
    mov EDX, EDI
    mov EDI, EBX
    mov EAX, EAX
    mov ECX, MAX_STRING_LENGTH
    repnz scasb

    mov ESI, EBX     ;     string
    mov ECX, EDI
    inc EBX
    sub ECX, EBX
    mov EDI, EDX
    mov EDX, ECX     ;     length
    rep movsb
    ret
endp
;------------------------------------------------
;       * * *  Trim Of String  * * *
;------------------------------------------------
proc StrTrim

;   mov ESI, pNew
    mov BL,  32

jmpFind@StrTrim:
    lodsb
    test AL, AL
         jz jmpZero@StrTrim

    cmp AL, BL
        jbe jmpFind@StrTrim

    dec ESI
    mov EDI, ESI
    mov ECX, FILEPATH_SIZE
    xor EAX, EAX
    repne scasb

jmpZero@StrTrim:
    dec EDI
    cmp [EDI], BL
        ja jmpEnd@StrTrim

    cmp EDI, ESI
        jae jmpZero@StrTrim

jmpEnd@StrTrim:
    inc EDI
    xor EAX, EAX
    mov [EDI], AL
;   stosb
    ret
endp
;------------------------------------------------
;       * * *  Index To String  * * *
;------------------------------------------------
proc IndexToStr

;   mov EDI, String
;   mov EBX, Index
    xor EAX, EAX
    mov ECX, EAX
    mov EDX, EAX
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

    xor ECX, ECX    ;   for form rep movs
    ret
endp
;------------------------------------------------
;       * * *  HEX To String  * * *
;------------------------------------------------
proc HexToStr

;   mov EDI, pBuffer
    mov ESI, sHexScaleChar
;   mov EDX, Value
    xor ECX, ECX
    mov EBX, ECX
    mov CL,  8

jmpScan@HexToStr:
    rol EDX, 4
    mov BL,  DL
    and BL,  0Fh
    mov AL, [ESI+EBX]
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
proc DecToStr1

;   mov EDI, pBuffer
;   mov EBX, Value
;   mov ECX, Zero [15]
    mov ESI, EDI
;   xor ECX, ECX
;   mov CL,  AL
    and ECX, 0Fh 

    mov AL, '0'
    rep stosb 

    mov CL, 10
    mov EAX, EBX

jmpScan@DecToStr:
    inc ESI
    xor EDX, EDX
    div ECX

    test EAX, EAX
         jnz jmpScan@DecToStr

    cmp EDI, ESI
        ja jmpEnd@DecToStr
        mov EDI, ESI  

jmpEnd@DecToStr:
    mov ESI, EDI 

    mov [EDI], AL
    mov EAX, EBX

jmpDiv@DecToStr:
    dec EDI
    xor EDX, EDX
    div ECX

    add DL, '0'
    mov [EDI], DL

    test EAX, EAX
         jnz jmpDiv@DecToStr

    mov EDI, ESI 
    xor ECX, ECX    ;   for form rep movs
    ret
endp
;------------------------------------------------
;       * * *  INT To String  * * *
;------------------------------------------------
proc WordToStr

;   mov EDI, pBuffer
;   mov EBX, Value
    xor ECX, ECX
    mov CL,  10
    mov EAX, EBX

jmpScan@WordToStr:
    inc EDI
    xor EDX, EDX
    div ECX

    test EAX, EAX
         jnz jmpScan@WordToStr

    mov ESI, EDI
;   mov [EDI], AL
    mov EAX, EBX

jmpDiv@WordToStr:
    dec EDI
    xor EDX, EDX
    div ECX

    add DL, '0'
    mov [EDI],DL

    test EAX, EAX
         jnz jmpDiv@WordToStr

    mov EDI, ESI 
    xor ECX, ECX    ;   for form rep movs
    ret
endp
;------------------------------------------------
;       * * *  INT To String  * * *
;------------------------------------------------
proc IntToStr

;   mov  EDI, pBuffer
;   mov  ECX, Value
;   test ECX, ECX
;        jns jmpSign@IntToStr
;        neg ECX
;        mov AL, '-'
;        stosb

jmpSign@IntToStr:
    xor EBX, EBX
    mov BL,  10
    mov EAX, ECX

jmpScan@IntToStr:
    inc EDI
    xor EDX, EDX
    div EBX

    test EAX, EAX
         jnz jmpScan@IntToStr

    mov ESI, EDI
;   mov [EDI], AL
    mov EAX, ECX

jmpDiv@IntToStr:
    dec EDI
    xor EDX, EDX
    div EBX

    add DL, '0'
    mov [EDI], DL

    test EAX, EAX
         jnz jmpDiv@IntToStr

    mov EDI, ESI 
    xor ECX, ECX
    ret
endp
;------------------------------------------------
;       * * *  Percent To String  * * *
;------------------------------------------------
proc StrPercent

;   mov EDI, Buffer
;   mov ECX, total
;   mov EAX, part

    jECXz jmpErr@StrPercent

    cmp EAX, ECX
        ja jmpErr@StrPercent
        jb jmpSet@StrPercent

        mov EAX, '100.'
        stosd
        mov AX, '00'
        stosw
        ret

jmpErr@StrPercent:
        mov EAX, ERROR_PARAM
        stosd
        ret

jmpSet@StrPercent:
    xor EBX, EBX
    mov BX,  10000
    mul EBX

    xor EDX, EDX
    div ECX

    mov BX,  100
    xor EDX, EDX
    div EBX

    mov ESI, EDX    ;    100.xx%
;   mov BL,  100
    xor EDX, EDX
    div EBX
    test AL, AL
         jz jmpDec2@StrPercent

         add AL, '0'
         stosb

jmpDec2@StrPercent:
    mov EBX, ESI
    mov ESI, sStrByteScale + 2

    mov AX, [ESI+EDX*4] ;    000.xx%
    cmp AL, '0'
        je jmpDec3@StrPercent
        stosb

jmpDec3@StrPercent:
    mov AL, AH
    mov AH,'.'
    stosw

    mov AX, [ESI+EBX*4] ;    xxx.00% 
    stosw

jmpEnd@StrPercent:
    xor ECX, ECX    ;   for form rep movs
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

    push EDX
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
    mov AX, [ESI+EDX*4] ;    wMinute
    stosw

    mov AL,  ':' 
    stosb

    pop EBX
    mov AX, [ESI+EBX*4] ;    wSecond
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
;   xor EBX, EBX

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

    xor ECX, ECX    ;   for form rep movs
    ret
endp
;------------------------------------------------
;       * * *  Time Of String  * * *
;------------------------------------------------
proc StrTime

;   mov ECX, Date
    mov ESI, sStrByteScale + 2
    xor EBX, EBX

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

    xor ECX, ECX    ;   for form rep movs
    ret
endp
;------------------------------------------------
;       * * *  DATE To String  * * *
;------------------------------------------------
proc HeaderDateToStr
;------------------------------------------------
;           * * *  Set Date = Www, DD Mmm YYYY
;------------------------------------------------
    mov ESI, LocalTime
    mov EBX, sStrByteScale + 2
    xor EAX, EAX
    mov ECX, EAX

    lodsw
    sub AX, DELTA_ZERO_YEAR
    mov AX, [EBX+EAX*4]
    mov EDX, EAX

    mov EAX, ECX
    lodsw
    dec  EAX
    mov  EAX, dword[sMonthDateHeader+EAX*4]
    push EAX

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

    pop EAX             ;    wMonth
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
    xor ECX, ECX
    ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------
