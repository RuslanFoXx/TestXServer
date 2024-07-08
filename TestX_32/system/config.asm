;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   SYSTEM: Config + StatusFile
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
proc SetConfigParameters
;------------------------------------------------
;       * * *  Init Params
;------------------------------------------------
    mov EDI, ServerConfig.MaxReportStack
    mov ECX, SERVER_CONFIG_DWORD

jmpSetParam@SetConfigParameters:
    mov EAX, [EDI]
    test EAX, EAX
         jz jmpNextServer@SetConfigParameters

         push ECX
         push ESI

         inc EAX
         mov ESI, EAX
         call StrToWord

         pop ESI
         pop ECX

jmpNextServer@SetConfigParameters:
    mov [SystemReport.ExitCode], ECX

    mov   DL, CFG_ERR_SystemParam
    test EAX, EAX
         jz jmpEnd@SetConfigParameters
    stosd
    loop jmpSetParam@SetConfigParameters
;------------------------------------------------
;       * * *  Valid Host
;------------------------------------------------
;   mov EDI, ServerConfig.lpTempFolder
    mov EAX, ECX
    mov  CL, SERVER_CONFIG_PARAM - SERVER_CONFIG_DWORD
    mov  DL, CFG_ERR_HostValue
    repnz scasd
       jz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  Set Client Access
;------------------------------------------------
    mov EDI, TabUsrAccess
    mov EBX, ECX
    mov  CL, MAX_USR_ACCESS
    mov  BL, 8
    sub ECX, [TotalAccess]

jmpLoopAccess@SetConfigParameters:
    mov  DL, CFG_ERR_AccessParam
    xor EAX, EAX
    scasd
       jz jmpEnd@SetConfigParameters
    scasd
       jz jmpEnd@SetConfigParameters

    mov  ESI, [EDI]
    inc  ESI
    mov [EDI], EAX

    mov EDX, [ESI]
     or EDX, SET_CASE_DOWN

    mov  AL, ACCESS_ADMIN
    cmp EDX, 'admi'
        je jmpSetAccess@SetConfigParameters

    mov  AL, ACCESS_READ_WRITE
    cmp EDX, 'edit'
        je jmpSetAccess@SetConfigParameters

    mov  AL, ACCESS_READ_ONLY
    cmp EDX, 'read'
        je jmpSetAccess@SetConfigParameters

        mov [SystemReport.ExitCode], ECX
        mov DL, CFG_ERR_SystemParam
        jmp jmpEnd@SetConfigParameters

jmpSetAccess@SetConfigParameters:
    mov [EDI], EAX

jmpNextAccess@SetConfigParameters:
    add EDI, EBX
    loop jmpLoopAccess@SetConfigParameters
;------------------------------------------------
;       * * *  Delta RecvBuffer
;------------------------------------------------
	mov CX,  PORT_DATA_SIZE
    mov EAX, [ServerConfig.BufferSize]
    shr EAX, 12
    inc EAX
    shl EAX, 12
    add ECX, EAX
    sub EAX, [ServerConfig.RecvSize]

    mov [ServerConfig.MaxRecvSize], EAX
    mov [SocketDataSize], ECX
;------------------------------------------------
;       * * *  Set Seconds TimeOut
;------------------------------------------------
    mov EBX, [ServerConfig.MaxTimeOut]
    mov EAX, 1000   ;   msec
    mul EBX
    mov [ServerConfig.MaxTimeOut], EAX
;------------------------------------------------
;       * * *  Set ListenSocket
;------------------------------------------------
    mov EDX, [ServerConfig.lpHostAddress]
    mov EDI, SystemReport.Address
    mov ESI, EDX
    inc EDX
    xor ECX, ECX
    mov CL, [ESI]
    inc ECX
    rep movsb
;------------------------------------------------
;       * * *  Get Address (inet_addr)
;------------------------------------------------
    mov ESI, EDX
    xor ECX, ECX
    mov EDI, ECX
    mov EBX, ECX
    mov  BL, 10

jmpFindAddr@SetConfigParameters:
    xor EDX, EDX

jmpScanAddr@SetConfigParameters:
    lodsb
    cmp AL, '0'
        jb jmpGetAddr@SetConfigParameters

    cmp AL, '9' 
        ja jmpGetAddr@SetConfigParameters

        sub AL, '0'
        mov CL, AL

        mov EAX, EDX
        mul EBX 
        add EAX, ECX
        mov EDX, EAX
        jmp jmpScanAddr@SetConfigParameters
;------------------------------------------------
jmpGetAddr@SetConfigParameters:
    or EDI, EDX
    ror EDI, 8 
    cmp AL, '.'
        je jmpFindAddr@SetConfigParameters

;   mov [Address.sin_addr.S_un.S_addr], EDI
    mov [Address.sin_addr], EDI
;------------------------------------------------
;       * * *  Get Port : 20480 = htons( 80 )
;------------------------------------------------
    mov DX, INTERNET_PORT
    cmp AL, ':'
        jne jmpAddrEnd@SetConfigParameters
        xor EDX, EDX

jmpScanPort@SetConfigParameters:
        lodsb
        cmp AL, '0'
            jb jmpGetPort@SetConfigParameters

        cmp AL, '9' 
            ja jmpGetPort@SetConfigParameters

            sub AL, '0'
            mov CL, AL

            mov EAX, EDX
            mul EBX 
            add EAX, ECX
            mov EDX, EAX
            jmp jmpScanPort@SetConfigParameters

jmpGetPort@SetConfigParameters:
        xchg DH, DL    ;   htons

jmpAddrEnd@SetConfigParameters:
    mov [Address.sin_port], DX
    mov [Address.sin_family], AF_INET
;------------------------------------------------
;       * * *  Socket
;------------------------------------------------
    xor EAX, EAX
    inc EAX
    push EAX
    xor EAX, EAX
    push EAX
    push EAX
    push IPPROTO_TCP
    push SOCK_STREAM
    push AF_INET
    call [WSASocket]
    mov  DL, SYS_ERR_Socket
    cmp EAX, INVALID_SOCKET
        je jmpEnd@SetConfigParameters

    mov [ListenSocket], EAX
    mov [SystemReport.Socket],  EAX
;------------------------------------------------
;       * * *  Option SocketPort
;------------------------------------------------
    push 4
    push SetOptionPort
    push SO_REUSEADDR
    push SOL_SOCKET
    push EAX
    call [setsockopt]
    mov   DL, SYS_ERR_Option
    test EAX, EAX
         jnz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  Binding
;------------------------------------------------
    push SOCKADDR_IN_SIZE
    push Address
    push [ListenSocket]
    call [bind]
    mov   DL, SYS_ERR_Binding
    test EAX, EAX
         jnz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  Listen
;------------------------------------------------
    push [ServerConfig.MaxConnections]
    push [ListenSocket]
    call [listen]
    mov   DL, SYS_ERR_Listen
    test EAX, EAX
         jnz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  SocketEvent
;------------------------------------------------
    call [WSACreateEvent]
    mov   DL, SYS_ERR_NetEvent
    test EAX, EAX
         jz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  ListenEvent
;------------------------------------------------
    mov [NetworkEvent], EAX

    push FD_ACCEPT + FD_CLOSE
    push EAX
    push [ListenSocket]
    call [WSAEventSelect]
    mov   DL, SYS_ERR_SetEvent
    test EAX, EAX
         jnz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  ListenReport
;------------------------------------------------
    mov [SystemReport.Index], SYS_MSG_Start
    mov EAX, SystemReport
    call WriteReport
;------------------------------------------------
;       * * *  Socket Port
;------------------------------------------------
    xor EAX, EAX
    push EAX
    push EAX
    push EAX
    dec EAX
    push EAX
    call [CreateIoCompletionPort]
    mov   DL, SYS_ERR_SocketPort
    test EAX, EAX
         jz jmpEnd@SetConfigParameters
         mov [hPortIOSocket], EAX
;------------------------------------------------
;       * * *  Set Max RunProcess
;------------------------------------------------
    mov ECX, [ServerConfig.MaxRunning]
    shl ECX, 2
    mov [MaxQueuedProcess], ECX
;------------------------------------------------
;       * * *  Set Report Buffers
;------------------------------------------------
    mov EBX, [ServerConfig.MaxReportStack]
    xor EAX, EAX
    mov  AL, REPORT_INFO_SIZE
    mul EBX
    mov [TabRouteReport], EAX
;------------------------------------------------
    add ECX, EAX    ;     RCX = ALL_MEMORY_SIZE
    shl EBX, 10     ;     MAX_PATH_SIZE = 1024
    add EAX, EBX    ;     REPORT_INFO_PATH_SIZE = REPORT_INFO_SIZE + MAX_PATH_SIZE
    mov [TabQueuedProcess], EAX

    add ECX, EAX
    add ECX, TABLE_PATH_SIZE + MAX_BUFFER_SIZE + MAX_SOCKET * 4
;------------------------------------------------
;       * * *  Get ReportBuffers
;------------------------------------------------
    push PAGE_READWRITE
    push MEM_COMMIT
    push ECX
    xor EAX, EAX
    push EAX
    call [VirtualAlloc]
    mov  DL, SYS_ERR_TableBuffer
    test EAX, EAX
         jz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  Init TableSockets
;------------------------------------------------
    mov EDI, TabSocketIoData
    stosd
    add EAX, MAX_SOCKET * 4
    stosd
    stosd
    stosd
    add EAX, [EDI]
    stosd
    stosd
    stosd
    add EAX, [EDI]
    stosd
    stosd
    stosd
    add [EDI], EAX
;------------------------------------------------
;       * * *  ProcessEvent
;------------------------------------------------
    xor EAX, EAX
    push EAX
    push EAX
    push EAX
    push EAX
    call [CreateEvent]
    mov   DL, SYS_ERR_NetEvent
    test EAX, EAX
         jz jmpEnd@SetConfigParameters
         mov [RunProcessEvent], EAX
;------------------------------------------------
;       * * *  Thread Tester
;------------------------------------------------
    xor EAX, EAX
    push EAX
    push EAX
    push EAX
    push ThreadProcessor
    push EAX
    push EAX
    call [CreateThread]
    mov   DL, SYS_ERR_ThreadProcess
    test EAX, EAX
         jz jmpEnd@SetConfigParameters
         push EAX
         call [CloseHandle]
;------------------------------------------------
;       * * *  Thread Socket
;------------------------------------------------
    xor EAX, EAX
    push EAX
    push EAX
    push EAX
    push ThreadRouter
    push EAX
    push EAX
    call [CreateThread]
    mov   DL, SYS_ERR_ThreadRouter
    test EAX, EAX
         jz jmpEnd@SetConfigParameters
         push EAX
         call [CloseHandle]
;------------------------------------------------
;       * * *  Thread Listen
;------------------------------------------------
    xor EAX, EAX
    push EAX
    push EAX
    push EAX
    push ThreadListener
    push EAX
    push EAX
    call [CreateThread]
    mov   DL, SYS_ERR_ThreadListen
    test EAX, EAX
         push EAX
         call [CloseHandle]

         xor EDX, EDX

jmpEnd@SetConfigParameters:
    ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------