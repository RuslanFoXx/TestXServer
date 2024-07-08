;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   SYSTEM: Headers
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Get Status SocketPort  * * *
;------------------------------------------------
proc CreateHttpHeader

local lpHeaderIoData dq ?
local HeaderMethod   dq ?
;------------------------------------------------
;   mov RSI, lpIoSocketPort
;   mov RCX, hFile
;   mov BL,  index
    mov [lpHeaderIoData], RSI
    xor RAX, RAX
    mov [RSI+PORT_IO_DATA.CountBytes], RAX
    mov [RSI+PORT_IO_DATA.TotalBytes], RAX
    mov [RSI+PORT_IO_DATA.TransferredBytes], RAX

    mov AL, BL
    mov [HeaderMethod], RAX
    mov AL,  32
    sub RSP, RAX

    lea RAX, [RSI+PORT_IO_DATA.Buffer]
    mov [RSI+PORT_IO_DATA.WSABuffer.buf], RAX
;------------------------------------------------
;       * * *  Get FileSize  * * *
;------------------------------------------------
    jRCXz jmpSetExt@Header
          lea RDX, [RSI+PORT_IO_DATA.TotalBytes]
          call [GetFileSizeEx]

jmpSetExt@Header:
    mov RSI, [lpHeaderIoData]
    mov RBX, [RSI+PORT_IO_DATA.ExtRunProc]
    mov RAX, [RBX+ASK_EXT.Type]
    test RAX, RAX
         jz jmpEnd@Header
;------------------------------------------------
;           * * *  Get Date + Time
;------------------------------------------------
         param 1, ServerTime
         call [GetSystemTime]
;------------------------------------------------
;       * * *  Index Method
;------------------------------------------------
         mov R10, [lpHeaderIoData]
         lea RDI, [R10+PORT_IO_DATA.Buffer]
         mov R15, RDI

         mov RAX, HEADER_HTTP_VER64
         stosq
         mov AL, ' '
         stosb

         mov RBX, [HeaderMethod]
         mov EAX, dword[sGetHttpMethod+1+RBX]
         and EAX, 20FFFFFFh
          or EAX, 20000000h
         stosd

         mov RSI, [lppTagRespont+RBX*2]
         xor RAX, RAX
         lodsb
         mov RCX, RAX
         rep movsb
;------------------------------------------------
;       * * *  Set Server Information
;------------------------------------------------
         mov CL,  szHeaderType - szHeaderServer
         mov ESI, szHeaderServer
         rep movsb
;------------------------------------------------
;           * * *  Set Date = Www, DD Mmm YYYY
;------------------------------------------------
         mov ESI, ServerTime
         mov EBX, sStrByteScale + 2
;        xor RAX, RAX
         mov RAX, RCX

         lodsw
         sub AX, DELTA_ZERO_YEAR
         mov AX, [RBX+RAX*4]
         mov EDX, EAX

         mov EAX, ECX
         lodsw
         dec EAX
         mov EAX, dword[sMonthDateHeader+EAX*4]
         mov R8d, EAX

         mov EAX, ECX
         lodsw
         mov EAX, dword[sWeekDateHeader+EAX*4]
         stosd

         mov CL, ' '
         mov EAX, ECX
         stosb

         lodsw
         mov AX, [EBX+EAX*4]
         stosw

         mov EAX, ECX
         stosb

         mov EAX, R8d
         stosd

         mov AX, '20'
         stosw

         mov EAX, EDX
         stosw
;------------------------------------------------
;           * * *  Set Time = hh:mm:ss
;------------------------------------------------
         mov EAX, ECX
         stosb

         lodsw
         mov AX, [EBX+EAX*4]
         stosw

         mov CL, ':'
         mov EAX, ECX
         stosb

         lodsw
         mov AX, [EBX+EAX*4]
         stosw

         mov EAX, ECX
         stosb

         lodsw
         mov AX, [EBX+EAX*4]
         stosw
;------------------------------------------------
;       * * *  Set Server Information
;------------------------------------------------
         mov CL,  szHeaderDisposition - szHeaderType
         mov ESI, szHeaderType
         rep movsb
;------------------------------------------------
;       * * *  Set Content Type
;------------------------------------------------
         mov RBX, [R10+PORT_IO_DATA.ExtRunProc]
         mov RSI, [RBX+ASK_EXT.Type]

         lodsb
         mov CL, AL
         rep movsb
;------------------------------------------------
;       * * *  Set Content Disposition
;------------------------------------------------
         mov  RDX, [RBX+ASK_EXT.Disposition]
         test RDX, RDX
              jz jmpContentLength@Header

              mov CL,  szHeaderLength - szHeaderDisposition
              mov ESI, szHeaderDisposition
              rep movsb

              mov RSI, RDX 
              lodsb
              mov CL, AL
              rep movsb
;------------------------------------------------
;       * * *  Set Content Length
;------------------------------------------------
jmpContentLength@Header:
         mov CL,  szHeaderConnection - szHeaderLength
         mov ESI, szHeaderLength
         rep movsb

         mov RCX, [R10+PORT_IO_DATA.TotalBytes]
;           jECXz jmpHeaderConnect@Header
;                 dec RDI
                  call IntToStr
;------------------------------------------------
;       * * *  Set Connect
;------------------------------------------------
jmpHeaderConnect@Header:
         mov CL,  szClose - szHeaderConnection
         mov ESI, szHeaderConnection
         rep movsb

         mov  CL, szKeepAlive - szClose 
         mov  AX, [R10+PORT_IO_DATA.Connection]
         test AX, AX
              jz jmpEndHeader@Header

              mov CL,  szKeepAliveEnd - szKeepAlive
              mov ESI, szKeepAlive

jmpEndHeader@Header:
        rep movsb
;------------------------------------------------
;       * * *  End Header
;------------------------------------------------
         mov EAX, END_CRLF
         stosd

         mov RAX, RDI
         sub RAX, R15
         mov RSI, R10
         mov [RSI+PORT_IO_DATA.CountBytes], RAX

jmpEnd@Header:
    xor RAX, RAX
    mov AL,  32
    add RSP, RAX
    ret
endp
;------------------------------------------------
;       * * *  Set StatusFile  * * *
;------------------------------------------------
proc GetStatusFile

	xor RAX, RAX
	mov [RSI+PORT_IO_DATA.Connection], AX
	mov [RSI+PORT_IO_DATA.ExtRunProc], DefAskFile
	mov  AL,  BL
	mov RBX, RAX

	mov RSI, [ServerConfig.lpCodeFolder]
	mov RDX, RDI
	lodsb
	mov RCX, RAX
	rep movsb

	mov AL, '\'
	stosb
	mov EAX, dword[sGetHttpMethod+1+RBX]
	and EAX, 20FFFFFFh
	or  EAX, 2E000000h
	stosd
	mov EAX, EXT_HTML
	stosd
;------------------------------------------------
;       * * *  Open StatFile
;------------------------------------------------
    param 4, RCX
    mov CL,  64
    sub RSP, RCX

    param 7, R9
    param 6, FILE_ATTRIBUTE_READONLY
    param 5, OPEN_EXISTING
    param 3, FILE_SHARE_READ 
    param 1, RDX
    param 2, GENERIC_READ 
    call [CreateFile]

    xor RCX, RCX
    cmp RAX, INVALID_HANDLE_VALUE
        je jmpEnd@GetStatusFile
        mov RCX, RAX

jmpEnd@GetStatusFile:
    xor RDX, RDX
    mov DL,  64
    add RSP, RDX
    ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------