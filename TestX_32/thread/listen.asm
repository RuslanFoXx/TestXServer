;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   THREAD: Listener + Accepter
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
proc ThreadListener ThrControl

local lpListenIoData LPPORT_IO_DATA ?
local ppTablePort    LPVOID ?
local TotalSocket    DWORD ?
;------------------------------------------------
    xor EAX, EAX
    inc EAX
    mov [ThreadListenCtrl], EAX
;------------------------------------------------
;       * * *  Wait Connection
;------------------------------------------------
jmpWaitConnect@Listener:
    mov EDI, ListenReport.Socket
    xor EAX, EAX
    stosd
    stosd

    mov AL, NET_ERR_SetConnect
    mov [ListenReport.TimeLimit], EAX

jmpTimeOut@Listener:
    push WAIT_LIST_TIMEOUT
    push [NetworkEvent]
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
    push ListenEvent
    push [NetworkEvent]
    mov EAX, [ListenSocket]
    mov [ListenReport.Socket], EAX
    push EAX
    call [WSAEnumNetworkEvents]
    mov   DL, NET_ERR_GetConnect
    test EAX, EAX
         jnz jmpPost@Listener
;------------------------------------------------
;       * * *  Ask Socket
;------------------------------------------------
    mov AL, FD_ACCEPT
    test [ListenEvent.lNetworkEvents], EAX
         jz jmpWaitConnect@Listener

         mov  EAX, [ListenEvent.iErrorCode + FD_ACCEPT_ERROR]
         test EAX, EAX
              jnz jmpPostError@Listener
;------------------------------------------------
;       * * *  Accept Connect
;------------------------------------------------
    push EAX
    push EAX
    push SizeOfAddrIn
    push Address
    push [ListenSocket]
    call [WSAAccept]
    mov  DL, NET_ERR_Accept
    cmp EAX, INVALID_SOCKET
        je jmpPost@Listener
;------------------------------------------------
;       * * *  Set Address (inet_ntoa)
;------------------------------------------------
        mov [ListenReport.Socket], EAX
        mov ESI, sStrByteScale + 1
        mov EDI, ListenReport.Address + 1
        mov EDX, [Address.sin_addr]
        xor EAX, EAX
        mov EBX, EAX
        mov ECX, EAX
        mov CL,  4

jmpScanAddres@Listener:
        mov BL, DL 
        mov EAX, [ESI+EBX*4]

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

        mov EAX, EDI
        dec EAX
        sub EAX, ListenReport.Address + 1
        mov [ListenReport.Address], AL
;------------------------------------------------
;       * * *  Set Timeout
;------------------------------------------------
    call [GetTickCount]
    add EAX, [ServerConfig.MaxTimeOut]
    mov [ListenReport.TimeLimit], EAX
;------------------------------------------------
;       * * *  Memory Port Buffer
;------------------------------------------------
    push PAGE_READWRITE
    push MEM_COMMIT
    push [SocketDataSize]
    xor EAX, EAX
    push EAX
    call [VirtualAlloc]
    mov   DL, NET_ERR_SocketMemory
    test EAX, EAX
         jz jmpPost@Listener
;------------------------------------------------
;       * * *  Find Free Socket
;------------------------------------------------
         mov [lpListenIoData], EAX
         mov EDI, [TabSocketIoData]
         mov ECX, MAX_SOCKET
         xor EAX, EAX

         mov DL, NET_ERR_FindSocket
         repnz scasd
           jnz jmpPost@Listener

               mov [TotalSocket], ECX
               lea EBX, [EDI-4]
               mov [ppTablePort], EBX
               mov [ListenReport.TablePort], EBX
;------------------------------------------------
;       * * *  Create Port
;------------------------------------------------
               push EAX
               push EAX
               push [hPortIOSocket]
               push [ListenReport.Socket]
               call [CreateIoCompletionPort]
               mov   DL, NET_ERR_PortSocket
               test EAX, EAX
                    jz jmpPost@Listener
;------------------------------------------------
;       * * *  Set SocketPort + Buffer
;------------------------------------------------
                    mov EBX, [lpListenIoData]
                    lea EDI, [EBX+PORT_IO_DATA.TimeLimit]
                    mov ESI, ListenReport.TimeLimit
                    xor ECX, ECX
                    mov CL,  ACCEPT_HEADER_COUNT
                    rep movsd

                    mov EDI, [ListenReport.TablePort]
                    mov [EDI], EBX
                    mov ESI, EBX
;------------------------------------------------
;       * * *  Post to Router
;------------------------------------------------
                    mov EAX, [TotalSocket]
                    cmp EAX, [ServerConfig.MaxConnections]
                        jb jmpSendLimit@Listener
;------------------------------------------------
;       * * *  Accept to Buffer
;------------------------------------------------
                        lea EAX, [ESI+PORT_IO_DATA.Buffer]
                        mov [ESI+PORT_IO_DATA.WSABuffer.buf], EAX

                        mov EAX, [ServerConfig.HeadSize]
                        mov [ESI+PORT_IO_DATA.WSABuffer.len], EAX

                        push ECX
                        push ESI
                        push TransFlag
                        push TransBytes
                        inc ECX
                        push ECX
                        lea EAX, [ESI+PORT_IO_DATA.WSABuffer]
                        push EAX
                        push [ListenReport.Socket]
                        call [WSARecv]

                        mov   DL, SRV_MSG_Connected
                        test EAX, EAX
                             jz jmpPost@Listener
                             call [WSAGetLastError]

                             mov  DL,  SRV_MSG_Connected
                             cmp EAX, ERROR_IO_PENDING
                                 je jmpPost@Listener

                                 mov DL, NET_ERR_RecvHeader
                                 jmp jmpPost@Listener
;------------------------------------------------
;       * * *  MaxSocket Limit
;------------------------------------------------
jmpSendLimit@Listener:
                    mov [ESI+PORT_IO_DATA.ExtRunProc], DefAskFile
                    mov ESI, EBX
                    xor ECX, ECX
                    mov BL,  HTTP_503_BUSY
                    call CreateHttpHeader

                    mov [ESI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER

;                   mov EDX, [ServerConfig.SendSize]
                    mov EAX, [ESI+PORT_IO_DATA.CountBytes]
;                   cmp EAX, EDX
;                       jb jmpSending@Listener
;                       mov EAX, EDX
;------------------------------------------------
;       * * *  Sending (close)
;------------------------------------------------
jmpSending@Listener:
                    mov [ESI+PORT_IO_DATA.WSABuffer.len], EAX
                    xor EAX, EAX
                    push EAX
                    push ESI
                    push EAX
                    push TransBytes
                    inc EAX
                    push EAX 
                    lea EAX, [ESI+PORT_IO_DATA.WSABuffer]
                    push EAX
                    push [ListenReport.Socket]
                    call [WSASend]
                    test EAX, EAX
                         jz jmpConnectLimit@Listener

                         call [WSAGetLastError]
                         mov DL, NET_ERR_SendListen
                         cmp EAX, ERROR_IO_PENDING
                             jne jmpPost@Listener
jmpConnectLimit@Listener:
                    mov DL, NET_MSG_ConnectLimit
;------------------------------------------------
;       * * *  Post ListReport
;------------------------------------------------
jmpPost@Listener:
    mov [ListenReport.TimeLimit], EDX
    call [WSAGetLastError]

jmpPostError@Listener:
    mov [ListenReport.TablePort], EAX
;------------------------------------------------
;       * * *  Post Report
;------------------------------------------------
    mov EDI, [SetListenReport]
    lea EDX, [EDI+REPORT_INFO_SIZE]
    cmp EDX, [MaxListenReport]
        jb jmpSetReport@Listener
        mov EDX, [TabListenReport]

jmpSetReport@Listener:
    cmp EDX, [GetListenReport]
        je jmpError@Listener

        mov ESI, ListenReport
        xor ECX, ECX
        mov  CL, ACCEPT_HEADER_REPORT
        rep movsd

        mov [SetListenReport], EDX
;------------------------------------------------
;       * * *  Error ListReport
;------------------------------------------------
jmpError@Listener:
    mov EAX, [ListenReport.TimeLimit]
    cmp  AL, NET_ERR_WaitConnect
        jae jmpWaitConnect@Listener

    cmp  AL, NET_ERR_SocketMemory
        jbe jmpSocketClose@Listener

    cmp  AL, NET_ERR_PortSocket
        jbe jmpMeroryFree@Listener
;------------------------------------------------
;       * * *  Port Free
;------------------------------------------------
    mov EDI, [ppTablePort]
    xor EAX, EAX
    mov [EDI], EAX
;------------------------------------------------
;       * * *  Merory Free
;------------------------------------------------
jmpMeroryFree@Listener:
    push MEM_RELEASE
    xor EAX, EAX
    push EAX
    push [lpListenIoData]
    call [VirtualFree]
;------------------------------------------------
;       * * *  Close Socket
;------------------------------------------------
jmpSocketClose@Listener:
    push [ListenReport.Socket]
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
    push [NetworkEvent]
    call [WSACloseEvent]
;------------------------------------------------
;       * * *  End Thread  * * *
;------------------------------------------------
    xor EAX, EAX
    mov [ThreadListenCtrl], EAX
    push EAX
    call [ExitThread]
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------