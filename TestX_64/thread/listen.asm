;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   THREAD: Listener + Accepter
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;   Set the socket I/O mode: In this case FIONBIO
;   enables or disables the blocking mode for the 
;   socket based on the numerical value of iMode.
;   iMode == 0 ? blocking is enabled
;   iMode != 0 ? non-blocking mode is enabled
;   ioctlsocket(m_socket, FIONBIO, (u_long FAR*) &iMode);
;------------------------------------------------
proc ThreadListener   ;   RCX = ThrControl

local TotalSocket    QWORD ?
local ppTablePort    LPVOID ?
local lpListenIoData LPPORT_IO_DATA ?
;------------------------------------------------
    xor RAX, RAX
    inc EAX
    mov [ThreadListenCtrl], EAX
    mov AL,  64
    sub RSP, RAX
;------------------------------------------------
;       * * *  Wait Connection
;------------------------------------------------
jmpWaitConnect@Listener:

    mov RDI, ListenReport.Socket
    xor RAX, RAX
    stosq
    stosq

    mov AL, NET_ERR_SetConnect
    mov [ListenReport.Index], EAX

jmpTimeOut@Listener:
    xor RDX, RDX
    mov DX,  WAIT_LIST_TIMEOUT
    param 1, [NetworkEvent]
    call [WaitForSingleObject]

    cmp EAX, WAIT_FAILED
        je jmpListenError@Listener

    mov  ECX, [ThreadServerCtrl]
    test ECX, ECX 
         jz jmpEnd@Listener

    cmp EAX, WAIT_TIMEOUT
        je jmpTimeOut@Listener
;------------------------------------------------
;       * * *  Get NetEvent
;------------------------------------------------
    param 1, [ListenSocket]
    mov [ListenReport.Socket], RCX
    param 2, [NetworkEvent]
    param 3, ListenEvent
    call [WSAEnumNetworkEvents]
    mov   DL, NET_ERR_GetConnect
    test EAX, EAX
         jnz jmpPost@Listener
;------------------------------------------------
;       * * *  Ask Socket
;------------------------------------------------
    xor RAX, RAX
    mov AL,  FD_ACCEPT
    test [ListenEvent.lNetworkEvents], EAX
         jz jmpWaitConnect@Listener

         mov  EAX, [ListenEvent.iErrorCode + FD_ACCEPT_ERROR]
         test EAX, EAX
             jnz jmpPostError@Listener
;------------------------------------------------
;       * * *  Accept Connect
;------------------------------------------------
    param 5, RAX
    param 4, RAX
    param 3, SizeOfAddrIn
    param 2, Address
    param 1, [ListenSocket]
    call [WSAAccept]
    mov  DL, NET_ERR_Accept
    cmp RAX, INVALID_SOCKET
        je jmpPost@Listener
;------------------------------------------------
;       * * *  Set Address (inet_ntoa)
;------------------------------------------------
        mov [ListenReport.Socket], RAX
        mov RSI, sStrByteScale + 1
        mov RDI, ListenReport.Address + 1
        mov EDX, [Address.sin_addr]
        xor RAX, RAX
        mov RBX, RAX
        mov RCX, RAX
        mov CL,  4

jmpScanAddres@Listener:
        mov BL, DL 
        mov EAX, [RSI+RBX*4]

        mov DL, AH
        cmp AL, '0'
            je jmpSet10Addr@Listener

            mov AH, AL 
            stosb

jmpSet10Addr@Listener:
        cmp AH, '0'
            je jmpSetAddres@Listener
            mov AL, DL
            stosb

jmpSetAddres@Listener:
        shr EAX, 16
        mov AH, '.'
        stosw

        ror EDX, 8
        loop jmpScanAddres@Listener

        mov RAX, RDI
        dec EAX
        sub RAX, ListenReport.Address + 1
        mov [ListenReport.Address], AL
;------------------------------------------------
;       * * *  Set Timeout
;------------------------------------------------
    call [GetTickCount]
    add RAX, [ServerConfig.MaxTimeOut]
    mov [ListenReport.TimeLimit], RAX
;------------------------------------------------
;       * * *  Memory Port Buffer
;------------------------------------------------
    param 4, PAGE_READWRITE
    param 3, MEM_COMMIT
    param 2, [SocketDataSize]
    param 1, 0
    call [VirtualAlloc]
    mov   DL, NET_ERR_SocketMemory
    test RAX, RAX
         jz jmpPost@Listener
;------------------------------------------------
;       * * *  Find Free Socket
;------------------------------------------------
         mov [lpListenIoData], RAX
         mov RDI, [TabSocketIoData]
         mov ECX, MAX_SOCKET
         xor RAX, RAX
         mov  DL, NET_ERR_FindSocket
         repnz scasq
           jnz jmpPost@Listener
;------------------------------------------------
               mov [TotalSocket], RCX
               lea RBX, [RDI-8]
               mov [ppTablePort], RBX
               mov qword[ListenReport.Index], RBX
;------------------------------------------------
;       * * *  Create Port
;------------------------------------------------
               param 4, RAX
               param 3, RAX
               param 2, [hPortIOSocket]
               param 1, [ListenReport.Socket]
               call [CreateIoCompletionPort]
               mov   DL, NET_ERR_PortSocket
               test EAX, EAX
                    jz jmpPost@Listener
;------------------------------------------------
;       * * *  Set SocketPort + Buffer
;------------------------------------------------
                    mov RBX, [lpListenIoData]
                    lea RDI, [RBX+PORT_IO_DATA.TimeLimit]
                    mov Rsi, ListenReport
                    xor RCX, RCX
                    mov CL,  ACCEPT_HEADER_COUNT
                    rep movsq

                    mov RDI, qword[ListenReport.Index]
                    mov [RDI], RBX
                    mov RSI, RBX
;------------------------------------------------
;       * * *  Post To Router
;------------------------------------------------
                    mov RAX, [TotalSocket]
                    cmp RAX, [ServerConfig.MaxConnections]
                        jb jmpSendLimit@Listener
;------------------------------------------------
;       * * *  Accept To Buffer
;------------------------------------------------
                        lea RAX, [RSI+PORT_IO_DATA.Buffer]
                        mov [RSI+PORT_IO_DATA.WSABuffer.buf], RAX

                        mov RAX, [ServerConfig.HeadSize]
                        mov [RSI+PORT_IO_DATA.WSABuffer.len], RAX

                        param 7, RCX
                        param 6, RSI
                        param 5, TransFlag
                        param 4, TransBytes
                        inc RCX
                        param 3, RCX
                        lea RDX, [RSI+PORT_IO_DATA.WSABuffer]
                        param 1, [ListenReport.Socket]
                        call [WSARecv]
                        mov   DL, SRV_MSG_Connected
                        test EAX, EAX
                             jz jmpPost@Listener
                             call [WSAGetLastError]

                             mov  DL, SRV_MSG_Connected
                             cmp EAX, ERROR_IO_PENDING
                                 je jmpPost@Listener

                                 mov DL, NET_ERR_RecvHeader
                                 jmp jmpPost@Listener
;------------------------------------------------
;       * * *  MaxSocket Limit
;------------------------------------------------
jmpSendLimit@Listener:
                    mov [RSI+PORT_IO_DATA.ExtRunProc], DefAskFile
                    xor RCX, RCX
                    mov  BL, HTTP_503_BUSY
                    call CreateHttpHeader

                    mov [RSI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER

;                   mov RDX, [ServerConfig.SendSize]
                    mov RAX, [RSI+PORT_IO_DATA.CountBytes]
;                   cmp RAX, RDX
;                       jb jmpSending@Listener
;                       mov RAX, RDX
;------------------------------------------------
;       * * *  Sending (close)
;------------------------------------------------
jmpSending@Listener:
                    mov [RSI+PORT_IO_DATA.WSABuffer.len], RAX
                    param 3, 0
                    param 7, R8
                    param 6, RSI
                    param 5, R8
                    inc R8
                    param 4, TransBytes
                    lea RDX, [RSI+PORT_IO_DATA.WSABuffer]
                    param 1, [ListenReport.Socket]
                    call [WSASend]
                    test EAX, EAX
                         jz jmpConnectLimit@Listener

                         call [WSAGetLastError]
                         mov  DL, NET_ERR_SendListen
                         cmp EAX, ERROR_IO_PENDING
                             jne jmpPost@Listener

jmpConnectLimit@Listener:
                    mov DL, NET_MSG_ConnectLimit
;------------------------------------------------
;       * * *  Post ListReport
;------------------------------------------------
jmpPost@Listener:
    mov [ListenReport.Index], EDX
    call [WSAGetLastError]
;------------------------------------------------
;       * * *  Post ListenError
;------------------------------------------------
jmpPostError@Listener:
    mov [ListenReport.Error], EAX
;------------------------------------------------
;       * * *  Post Report
;------------------------------------------------
    mov RDI, [SetListenReport]
    lea RDX, [RDI+REPORT_INFO_SIZE]
    cmp RDX, [MaxListenReport]
        jb jmpSetReport@Listener
        mov RDX, [TabListenReport]
;------------------------------------------------
;       * * *  Create Report
;------------------------------------------------
jmpSetReport@Listener:
    cmp RDX, [GetListenReport]
        je jmpError@Listener

        mov RSI, ListenReport.Index
        xor RCX, RCX
        mov  CL, ACCEPT_HEADER_REPORT
        rep movsq

        mov [SetListenReport], RDX
;------------------------------------------------
;       * * *  Error ListReport
;------------------------------------------------
jmpError@Listener:
    mov EAX, [ListenReport.Index]
    cmp AL, NET_ERR_WaitConnect
        jae jmpWaitConnect@Listener

    cmp AL, NET_ERR_SocketMemory
        jbe jmpSocketClose@Listener

    cmp AL, NET_ERR_PortSocket
        jbe jmpMeroryFree@Listener
;------------------------------------------------
;       * * *  Port Free
;------------------------------------------------
    mov RDI, [ppTablePort]
    xor RAX, RAX
    mov [RDI], RAX
;------------------------------------------------
;       * * *  Merory Free
;------------------------------------------------
jmpMeroryFree@Listener:
    param 1, [lpListenIoData]
    param 2, 0
    param 3, MEM_RELEASE
    call [VirtualFree]
;------------------------------------------------
;       * * *  Close Socket
;------------------------------------------------
jmpSocketClose@Listener:
    param 1, [ListenSocket]
    call [closesocket]
    jmp jmpWaitConnect@Listener
;------------------------------------------------
;       * * *  ListenEvent Error
;------------------------------------------------
jmpListenError@Listener:
	call [WSAGetLastError]
	mov  [SystemReport.Error], EAX
	mov  [SystemReport.Index], NET_ERR_WaitConnect
;------------------------------------------------
;       * * *  Close ListenEvent + ListenSocket
;------------------------------------------------
jmpEnd@Listener:
    param 1, [NetworkEvent]
    call [WSACloseEvent]

    param 1, [ListenSocket]
    call [closesocket]
;------------------------------------------------
;       * * *  End Thread  * * *
;------------------------------------------------
    xor RAX, RAX
    param 1, RAX
    mov [ThreadListenCtrl], EAX
    mov AL,  64
    add RSP, RAX
    call [ExitThread]
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------