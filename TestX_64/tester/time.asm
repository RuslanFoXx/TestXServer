;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   SYSTEM: Time
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Time to DWORD  * * *
;------------------------------------------------
proc TimeToTick

;   mov ESI, Time
    xor RCX, RCX
    mov RBX, RCX

    mov EAX, ESI        ;       sec
    and EAX, 63 
    add ECX, EAX

    shr ESI, 6          ;       min 
    mov EAX, ESI
    and EAX, 63 
    mov EBX, 60
    mul EBX
    add ECX, EAX

    shr ESI, 6          ;       hour
    mov EAX, ESI
    and EAX, 31 
    mov EBX, 3600
    mul EBX
    add ECX, EAX

    shr ESI, 5          ;       day
    mov EAX, ESI
    and EAX, 31 
    mov EBX, 86400
    mul EBX
    add ECX, EAX

    shr ESI, 5          ;       month
    mov EAX, ESI
    and EAX, 15 
    mov EBX, 2678400
    mul EBX
    add ECX, EAX

    shr ESI, 4          ;       year
    mov EAX, ESI
    mov EBX, 32140800
    mul EBX
    add ECX, EAX

jmpEnd@TimeToTick:
;   mov EAX, RCX
    ret
endp
;------------------------------------------------
;       * * *  Set DeltaTick Year  * * *
;------------------------------------------------
proc GetDeltaTick

;   mov DX, wTime 
;   mov BX, wOldTime 
    mov AX, DX
    and DX, 63
    shr AX, 6

    mov CL, 60
    mul CL
    add AX, DX 

    cmp AX, BX
        jae jmpDelta@GetDeltaTick
        mov AX, 3600
-
jmpDelta@GetDeltaTick:
    sub BX, AX
    ret
endp
;------------------------------------------------
;       * * *  Get BaseTime  * * *
;------------------------------------------------
proc GetBaseTime

    xor RAX, RAX
    mov AL,  40   ;   for 4 + 8
    sub RSP, RAX

    param 1, LocalTime
    call [GetLocalTime]

    xor RAX, RAX
    mov AL,  40
    add RSP, RAX

    xor RDX, RDX
    mov  DX, [LocalTime.wYear]
    sub EDX, ZERO_YEAR

    shl EDX, 4 
    or DX, [LocalTime.wMonth]

    shl EDX, 5 
    or   DX, [LocalTime.wDay]

    shl EDX, 5 
    or   DX, [LocalTime.wHour]

    shl EDX, 6 
    or   DX, [LocalTime.wMinute]
    shl EDX, 6 
    or DX, [LocalTime.wSecond]
    ret         ;       EDX = Time
endp
;------------------------------------------------
;       * * *  Set BaseTime  * * *
;------------------------------------------------
proc SetBaseTime
;------------------------------------------------
;   mov RSI, SystemTyme 
;   mov EDX, [Time ]
    xor EAX, EAX
    mov AL, DL
    and AL, 63
    mov [RSI+SOCKTIME.Second], AX 

    shr EDX, 6 
    mov AL, DL
    and AL, 63
    mov [RSI+SOCKTIME.Minute], AX 

    shr EDX, 6 
    mov AX, DX 
    and AX, 31 
    mov [RSI+SOCKTIME.Hour], AX

    shr EDX, 5 
    mov AL, DL
    and AL, 31
    mov [RSI+SOCKTIME.Day], AX

    shr EDX, 5 
    mov AL, DL
    and AL, 15
    mov [RSI+SOCKTIME.Month], AX

    shr EDX, 4
    add EDX, ZERO_YEAR
    mov [RSI+SOCKTIME.Year], DX
    ret
endp
;------------------------------------------------
;       * * *  END OF FILE  * * *
;------------------------------------------------