;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   SYSTEM: Config + StatusFile
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
proc SetConfigParameters

    xor RAX, RAX
    mov R14, RAX
    mov AL,  64
    sub RSP, RAX

    mov RDI,  ServerConfig.MaxReportStack
    mov R14b, SERVER_CONFIG_DWORD

jmpSetParam@SetConfigParameters:
    mov  RAX, [RDI]
    test RAX, RAX
         jz jmpNextServer@SetConfigParameters

         mov R15, RDI
         inc RAX
         mov RSI, RAX
         call StrToWord

jmpNextServer@SetConfigParameters:
    mov [SystemReport.ExitCode], R14d
    mov   DL, CFG_ERR_SystemParam
    test RAX, RAX
         jz jmpEnd@SetConfigParameters

    mov RDI, R15
    stosq
    dec R14d
        jnz jmpSetParam@SetConfigParameters
;------------------------------------------------
;       * * *  Valid Host
;------------------------------------------------
;   mov RDI, ServerConfig.lpTempFolder
    xor RAX, RAX
    mov RCX, RAX
    mov  CL, SERVER_CONFIG_PARAM - SERVER_CONFIG_DWORD
    mov  DL, CFG_ERR_HostValue
    repnz scasq
       jz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  Set Client Access
;------------------------------------------------
    mov RDI, TabUsrAccess
;   xor RAX, RAX
    mov R8,  RAX
    mov  CL, MAX_USR_ACCESS
    mov R8b, 16
    sub RCX, [TotalAccess]

jmpLoopAccess@SetConfigParameters:
    mov  DL, CFG_ERR_AccessParam
    xor RAX, RAX
    scasq
       jz jmpEnd@SetConfigParameters
    scasq
       jz jmpEnd@SetConfigParameters

    mov  RSI, [RDI]
    inc  RSI
    mov [RDI], RAX

    mov EDX, [RSI]
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
    mov [RDI], EAX

jmpNextAccess@SetConfigParameters:
    add RDI, R8
    loop jmpLoopAccess@SetConfigParameters
;------------------------------------------------
;       * * *  Delta RecvBuffer
;------------------------------------------------
    mov CX, PORT_DATA_SIZE
    mov RAX, [ServerConfig.BufferSize]
    shr RAX, 12
    inc RAX
    shl RAX, 12
    add RCX, RAX
    sub RAX, [ServerConfig.RecvSize]

    mov [ServerConfig.MaxRecvSize], RAX
    mov [SocketDataSize], RCX
;------------------------------------------------
;       * * *  Set Seconds TimeOut
;------------------------------------------------
    mov RBX, [ServerConfig.MaxTimeOut]
    xor RAX, RAX
    mov AX, 1000   ;   msec
    mul EBX
    mov [ServerConfig.MaxTimeOut], RAX
;------------------------------------------------
;       * * *  Set ListenSocket
;------------------------------------------------
    mov RDX, [ServerConfig.lpHostAddress]
    mov RDI, SystemReport.Address
    mov RSI, RDX
    inc RDX
    xor RCX, RCX
    mov CL, [RSI]
    inc ECX
    rep movsb
;------------------------------------------------
;       * * *  Get Address (inet_addr)
;------------------------------------------------
    mov RSI, RDX
    xor RCX, RCX
    mov RDI, RCX
    mov RBX, RCX
    mov  BL, 10
    mov R8b, '0'
    mov R9b, '9'

jmpFindAddr@SetConfigParameters:
    xor RDX, RDX

jmpScanAddr@SetConfigParameters:
    lodsb
    cmp AL, R8b
        jb jmpGetAddr@SetConfigParameters

    cmp AL, R9b 
        ja jmpGetAddr@SetConfigParameters

        sub AL, R8b
        mov CL, AL

        mov EAX, EDX
        mul RBX 
        add EAX, ECX
        mov EDX, EAX
        jmp jmpScanAddr@SetConfigParameters

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
        xor RDX, RDX

jmpScanPort@SetConfigParameters:
        lodsb
        cmp AL, R8b
            jb jmpGetPort@SetConfigParameters

        cmp AL, R9b 
            ja jmpGetPort@SetConfigParameters

            sub AL, R8b
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
    xor RAX, RAX
    param 4, RAX
    param 5, RAX
    inc RAX
    param 6, RAX
    param 3, IPPROTO_TCP
    param 2, SOCK_STREAM
    param 1, AF_INET
    call [WSASocket]
    mov  DL, SYS_ERR_Socket
    cmp EAX, INVALID_SOCKET
        je jmpEnd@SetConfigParameters

    mov [ListenSocket], RAX
    mov [SystemReport.Socket],  RAX
;------------------------------------------------
;       * * *  Option SocketPort
;------------------------------------------------
    param 1, RAX
    param 5, 8
    param 4, SetOptionPort
    param 3, SO_REUSEADDR
    param 2, SOL_SOCKET
    call [setsockopt]
    mov   DL, SYS_ERR_Option
    test EAX, EAX
         jnz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  Binding
;------------------------------------------------
    param 3, 0
    mov R8b, SOCKADDR_IN_SIZE
    param 2, Address
    param 1, [ListenSocket]
    call [bind]
    mov   DL, SYS_ERR_Binding
    test EAX, EAX
         jnz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  Listen
;------------------------------------------------
    param 2, [ServerConfig.MaxConnections]
    param 1, [ListenSocket]
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
    mov [NetworkEvent], RAX
    param 2, RAX
    param 3, FD_ACCEPT + FD_CLOSE
    param 1, [ListenSocket]
    call [WSAEventSelect]
    mov   DL, SYS_ERR_SetEvent
    test EAX, EAX
         jnz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  ListenReport
;------------------------------------------------
    mov AL, SYS_MSG_Start
    mov [SystemReport.Index], EAX

    param 0, SystemReport
    call WriteReport
;------------------------------------------------
;       * * *  Socket Port
;------------------------------------------------
    param 1, 0
    param 2, RCX  ;  0
    param 3, RCX  ;  0
    param 4, RCX  ;  0
    dec RCX
    call [CreateIoCompletionPort]
    mov   DL, SYS_ERR_SocketPort
    test EAX, EAX
         jz jmpEnd@SetConfigParameters
         mov [hPortIOSocket], RAX
;------------------------------------------------
;       * * *  Set Max RunProcess
;------------------------------------------------
    mov RCX, [ServerConfig.MaxRunning]
    shl ECX, 3
    mov [MaxQueuedProcess], RCX
;------------------------------------------------
;       * * *  Set Report Buffers
;------------------------------------------------
    mov RBX, [ServerConfig.MaxReportStack]
    xor RAX, RAX
    mov  AL, REPORT_INFO_SIZE
    mul EBX
    mov [TabRouteReport], RAX

    add ECX, EAX    ;     RCX = ALL_MEMORY_SIZE
    shl EBX, 10     ;     MAX_PATH_SIZE = 1024
    add EAX, EBX    ;     REPORT_INFO_PATH_SIZE = REPORT_INFO_SIZE + MAX_PATH_SIZE
    mov [TabQueuedProcess], RAX

    add ECX, EAX
    add ECX, TABLE_PATH_SIZE + MAX_BUFFER_SIZE + MAX_SOCKET * 8
;------------------------------------------------
;       * * *  Get ReportBuffers
;------------------------------------------------
    param 4, PAGE_READWRITE
    param 3, MEM_COMMIT
    param 2, RCX
    param 1, 0
    call [VirtualAlloc]
    mov   DL, SYS_ERR_TableBuffer
    test RAX, RAX
         jz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  Init TableSockets
;------------------------------------------------
    mov RDI, TabSocketIoData
    stosq
    add RAX, MAX_SOCKET * 8
    stosq
    stosq
    stosq
    add RAX, [RDI]
    stosq
    stosq
    stosq
    add RAX, [RDI]
    stosq
    stosq
    stosq
    add [RDI], RAX
;------------------------------------------------
;       * * *  ProcessEvent
;------------------------------------------------
    param 1, 0
    param 2, RCX
    param 3, RCX
    param 4, RCX
    call [CreateEvent]
    mov   DL, SYS_ERR_NetEvent
    test EAX, EAX
         jz jmpEnd@SetConfigParameters
         mov [RunProcessEvent], RAX
;------------------------------------------------
;       * * *  Thread Tester
;------------------------------------------------
    param 1, 0
    param 6, RCX
    param 5, RCX
    param 4, RCX
    param 3, ThreadProcessor
    param 2, RCX
    call [CreateThread]
    mov   DL, SYS_ERR_ThreadProcess
    test EAX, EAX
         jz jmpEnd@SetConfigParameters
         param 1, RAX
         call [CloseHandle]
;------------------------------------------------
;       * * *  Thread Socket
;------------------------------------------------
    param 1, 0
    param 6, RCX
    param 5, RCX
    param 4, RCX
    param 3, ThreadRouter
    param 2, RCX
    call [CreateThread]
    mov   DL, SYS_ERR_ThreadRouter
    test EAX, EAX
         jz jmpEnd@SetConfigParameters
         param 1, RAX
         call [CloseHandle]
;------------------------------------------------
;       * * *  Thread Listen
;------------------------------------------------
    param 1, 0
    param 6, RCX
    param 5, RCX
    param 4, RCX
    param 3, ThreadListener
    param 2, RCX
    call [CreateThread]
    mov   DL, SYS_ERR_ThreadListen
    test EAX, EAX
         jz jmpEnd@SetConfigParameters
         param 1, RAX
         call [CloseHandle]

         xor RDX, RDX

jmpEnd@SetConfigParameters:
    xor RAX, RAX
    mov AL,  64
    add RSP, RAX
    ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------