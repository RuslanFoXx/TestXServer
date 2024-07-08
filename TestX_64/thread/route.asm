;------------------------------------------------
;   Web Server (slim) AntXs + Web Tester x64: ver. 2.73
;   THREAD: Router
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
proc ThreadRouter   ;   RCX = ThrControl

local Method DWORD ?
;------------------------------------------------
    mov RDI, [TabSocketIoData]
    mov RCX, [ServerConfig.MaxConnections]
    xor RAX, RAX
    rep stosq
    inc RAX
    mov [ThreadSocketCtrl], EAX
    mov AL,  64
    sub RSP, RAX
;------------------------------------------------
;       * * *  Wait Completion
;------------------------------------------------
jmpWaitCompletionPort@Router:

    param 5, WAIT_PORT_TIMEOUT
    param 4, lpSocketIoData
    param 3, lpPortIoCompletion
    param 2, TransferredBytes
    param 1, [hPortIOSocket]
    call [GetQueuedCompletionStatus]
    mov  ECX, [ThreadServerCtrl]
    test ECX, ECX 
         jz jmpEnd@Router
;------------------------------------------------
;       * * *  ReportError
;------------------------------------------------
    test EAX, EAX
         jnz jmpSetSocket@Router
         mov [TransferredBytes], RAX

         call [WSAGetLastError]
         cmp EAX, WAIT_TIMEOUT
             je jmpWaitCompletionPort@Router

         mov  DL, SRV_MSG_BreakConnect
         cmp EAX, ERROR_NETNAME_DELETED
             je jmpPost@Router

             mov [SystemReport.Error], EAX
             mov [SystemReport.Index], EDX
;------------------------------------------------
;       * * *  ServerRouter
;------------------------------------------------
jmpSetSocket@Router:
    mov  RSI, [lpSocketIoData]
    test RSI, RSI
         jz jmpWaitCompletionPort@Router

jmpGetRoute@Router:
    mov  RCX, [TransferredBytes]
    mov   DL, SRV_MSG_Disconnected
    test ECX, ECX
         jz jmpPost@Router
;------------------------------------------------
;       * * *  ServerRouter
;------------------------------------------------
    add [ESI+PORT_IO_DATA.TransferredBytes], RCX
    add [ESI+PORT_IO_DATA.WSABuffer.buf], RCX

    mov AX, [ESI+PORT_IO_DATA.Route]
    cmp AL, ROUTE_SEND_FILE
        je jmpRespondFromFile@Router

    cmp AL, ROUTE_SEND_BUFFER
        je jmpRespondFromBuffer@Router

    cmp AL, ROUTE_RECV_BUFFER
        je jmpRequestToBuffer@Router

    cmp AL, ROUTE_RECV_FILE
        je jmpRequestToFile@Router

    test AL, AL
         jnz jmpPost@Router
;------------------------------------------------
;       * * *  ASK
;------------------------------------------------
	mov [RSI+PORT_IO_DATA.CountBytes], RCX
 	mov R15, RSI
 	mov R14, RCX
	xor R13, R13
	sub  CX, 4

    lea RSI,[RSI+PORT_IO_DATA.Buffer]
    lodsd
    and EAX, KEY_CASE_UP
    cmp EAX, 'GET'
        je jmpMethod@Router

		inc R13d
		inc RSI
		dec ECX

        mov  BL, HTTP_501_NOT_IMPLEMENT
        mov  DL, SRV_ERR_Method
        cmp EAX, 'POST'
            jne jmpSelected@Router

jmpMethod@Router:
    call HTTPRequest
    test EDX, EDX
         jnz jmpSelected@Router
;------------------------------------------------
;       * * *  SELECT0 METHOD GET/POST
;------------------------------------------------
jmpGetAskExt@Router:
	mov  RSI, R15
	test R13, R13
         jnz jmpRecvMethod@Router
;------------------------------------------------
;       * * *  GET CGI-PROCESSOR
;------------------------------------------------
    mov EAX, [R12]
    cmp EAX, ASK_MODE
        je jmpRunProcess@Router
;------------------------------------------------
;       * * *  Find TableExt
;------------------------------------------------
        mov RBX, DefAskFile
        mov R8,  RCX
        mov R8b, ASK_EXT_SIZE

jmpFindExt@Router:
        add  RBX, R8
        mov  RSI, [RBX]
        test RSI, RSI
             jz jmpAccessDenied@Router
             xor RAX, RAX
             lodsb
             cmp EAX, R9d 
                 jne jmpFindExt@Router
                 mov RDI, R12
                 mov ECX, R9d
                 repe cmpsb
                  jne jmpFindExt@Router
;------------------------------------------------
;       * * *  OpenSendFile
;------------------------------------------------
                  mov RSI, R15
                  xor RAX, RAX
                  mov [RSI+PORT_IO_DATA.ResurseId], RAX
                  mov [RSI+PORT_IO_DATA.ExtRunProc], RBX
                  param 7, RAX  ;  0
                  param 6, FILE_ATTRIBUTE_READONLY
                  param 5, OPEN_EXISTING
                  param 4, RAX  ;  0
                  param 3, FILE_SHARE_READ 
                  param 2, GENERIC_READ 
                  lea RCX, [RSI+PORT_IO_DATA.Path]
                  call [CreateFile]
                  mov  DL, SRV_ERR_OpenFile
                  cmp RAX, INVALID_HANDLE_VALUE
                      je jmpNotFound@Router
;------------------------------------------------
;       * * *  FileSize
;------------------------------------------------
                      mov [hFile], RAX

                      param 1, RAX
                      call [GetFileType]

                      mov RCX, [hFile]
                      xor EBX, EBX
                      cmp EAX, FILE_TYPE_DISK
                          je jmpHeaderMethod1@Router
;------------------------------------------------
;       * * *  Http Code Selected
;       * * *  Access Denied
;------------------------------------------------
jmpAccessDenied@Router:
    mov BL, HTTP_403_FORBIDDEN
    mov DL, SRV_MSG_OpenAccess
    jmp jmpSelected@Router
;------------------------------------------------
;       * * *  File Not Found
;------------------------------------------------
jmpNotFound@Router:
    mov BL, HTTP_404_NOT_FOUND
    jmp jmpSelected@Router
;------------------------------------------------
;       * * *  Internal Error
;------------------------------------------------
jmpInternalError@Router:
    mov BL, HTTP_500_INTERNAL
;------------------------------------------------
;       * * *  CodeSelector
;------------------------------------------------
jmpSelected@Router:
    mov [Method], EBX
    call PostReport
;------------------------------------------------
;       * * *  Get StatFile
;------------------------------------------------
    mov RSI, [lpSocketIoData]
    mov EBX, [Method]
    mov RDI, szFileName
    call GetStatusFile

    mov RSI, [lpSocketIoData]
    mov EBX, [Method]
;------------------------------------------------
;       * * *  Create Headers
;------------------------------------------------
jmpHeaderMethod1@Router:
    mov RSI, [lpSocketIoData]
    mov [RSI+PORT_IO_DATA.hFile], RCX
    call CreateHttpHeader

 ;mov RDI, szFileName
 ;mov RCX, [RSI+PORT_IO_DATA.TotalBytes]
 ;call IntToStr
 ;invoke MessageBox, HWND_DESKTOP, szFileName, szWSACleanup+2, MB_OK

    mov [RSI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER

    mov RCX, [RSI+PORT_IO_DATA.TotalBytes]
       jRCXz jmpSendFromBuffer@Router

        mov [RSI+PORT_IO_DATA.Route], ROUTE_SEND_FILE
        jmp jmpSendFromFile@Router
;------------------------------------------------
;       * * *  Send From Buffer
;------------------------------------------------
jmpRespondFromBuffer@Router:
    mov RSI, [lpSocketIoData] 
    sub [RSI+PORT_IO_DATA.CountBytes], RCX
;------------------------------------------------
;       * * *  SendToBuffer
;------------------------------------------------
jmpSendFromBuffer@Router:
    mov  DL, SRV_MSG_Send
    mov RCX, [RSI+PORT_IO_DATA.CountBytes]
    xor RAX, RAX
    cmp RCX, RAX 
        jg jmpSizeSend@Router
;------------------------------------------------
;       * * *  Post To Buffer
;------------------------------------------------
        cmp AX, [RSI+PORT_IO_DATA.Connection]
            je jmpPost@Router

            call PostReport

            mov RSI, [lpSocketIoData] 
            lea RDI, [RSI+PORT_IO_DATA.ResurseId]
            mov RCX, PORT_CLEAR_COUNT
            xor RAX, RAX
            rep stosq

            lea RDX, [RSI+PORT_IO_DATA.Buffer]
            mov [RSI+PORT_IO_DATA.WSABuffer.buf], RDX

            mov AX, HTTP_HEADER_SIZE
            jmp jmpReceiving@Router
;------------------------------------------------
;       * * *  Send From File
;------------------------------------------------
jmpRespondFromFile@Router:
    mov RSI, [lpSocketIoData]
    sub [RSI+PORT_IO_DATA.CountBytes], RCX
;------------------------------------------------
;       * * *  SendToFile
;------------------------------------------------
jmpSendFromFile@Router:
    mov RCX, [RSI+PORT_IO_DATA.CountBytes]
    cmp RCX, [ServerConfig.SendSize] 
        jg jmpSizeSend@Router
;------------------------------------------------
;       * * *  Copy Buffer
;------------------------------------------------
        mov [CountBytes], RCX
        mov R10, [ServerConfig.BufferSize]
        sub R10, RCX

        mov RBX, [RSI+PORT_IO_DATA.WSABuffer.buf]
        lea RDX, [RSI+PORT_IO_DATA.Buffer]
        mov [RSI+PORT_IO_DATA.WSABuffer.buf], RDX

        xchg RSI, RBX
        mov  RDI, RDX
        add  RDX, RCX
        rep movsb
;------------------------------------------------
;       * * *  Read Buffer
;------------------------------------------------
        mov R8, [RBX+PORT_IO_DATA.TotalBytes]
        cmp R8, R10
            jb jmpReadSend@Router
            mov R8, R10
;------------------------------------------------
;       * * *  Read SendFile
;------------------------------------------------
jmpReadSend@Router:
        param 5, RCX
        param 4, TotalBytes
;       param 3, ReadBytes
;       param 2, Buffer
        param 1, [RBX+PORT_IO_DATA.hFile]
        call [ReadFile]
        mov   DL, SRV_ERR_ReadFile
        test EAX, EAX
             jz jmpPost@Router
;------------------------------------------------
;       * * *  SendBuffer
;------------------------------------------------
             mov RSI, [lpSocketIoData] 
             mov RBX, [RSI+PORT_IO_DATA.TotalBytes]
             mov RCX, [CountBytes]
             mov RAX, [TotalBytes]
             add RCX, RAX
             sub RBX, RAX
             mov [CountBytes], RCX
             mov [RSI+PORT_IO_DATA.CountBytes], RCX
             mov [RSI+PORT_IO_DATA.TotalBytes], RBX
             test RBX, RBX
                  jnz jmpSetSend@Router
;------------------------------------------------
;       * * *  Close File
;------------------------------------------------
jmpCloseSend@Router:
                  param 1, [RSI+PORT_IO_DATA.hFile]
                  xor RAX, RAX
                  mov [RSI+PORT_IO_DATA.hFile], RAX
                  call [CloseHandle]
                  mov   DL, SRV_ERR_ReadClose
                  test EAX, EAX
                       jz jmpPost@Router
                       mov RSI, [lpSocketIoData] 
                       xor RAX, RAX
                       mov [RSI+PORT_IO_DATA.hFile], RAX
                       mov [RSI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER
jmpSetSend@Router:
             mov RCX, [CountBytes]
;------------------------------------------------
;       * * *  Sendinge
;------------------------------------------------
jmpSizeSend@Router:
    mov RCX, [RSI+PORT_IO_DATA.CountBytes]
;    mov RCX, [RSI+PORT_IO_DATA.WSABuffer.len]
     ;   lea RDI, [RSI+PORT_IO_DATA.Buffer]
     ;   mov RDI, [RSI+PORT_IO_DATA.WSABuffer.buf]
	;  xor EAX, EAX
	;  mov [RDI+RCX], AX
 ;invoke MessageBox, HWND_DESKTOP, RDI, szWSAWaitForMultipleEvents+2, MB_OK

    mov RAX, [ServerConfig.SendSize]
    cmp RCX, RAX
        jb jmpSending@Router
        mov RCX, RAX

jmpSending@Router:
    mov [RSI+PORT_IO_DATA.WSABuffer.len], RCX
    param 3, 0
    param 7, R8
    param 6, RSI
    param 5, R8
    inc R8
;   param 3, 1
    param 4, TransBytes
    lea RDX, [RSI+PORT_IO_DATA.WSABuffer]
    param 1, [RSI+PORT_IO_DATA.Socket]
    call [WSASend]
    test EAX, EAX
         jz jmpWaitCompletionPort@Router

         call [WSAGetLastError]
         cmp EAX, ERROR_IO_PENDING
             je jmpWaitCompletionPort@Router
             mov DL, SRV_ERR_SendRouter
             jmp jmpPost@Router
;------------------------------------------------
;       * * *  RECV METHOD
;------------------------------------------------     
jmpRecvMethod@Router:
    mov   BL, HTTP_400_BAD_REQUEST
    mov   DL, SRV_MSG_RecvDataSize
    mov  RAX, [RSI+PORT_IO_DATA.TotalBytes]
    test RAX, RAX
         jz jmpSelected@Router
         cmp RAX, [ServerConfig.MaxRecvFileSize]
             ja jmpSelected@Router
;------------------------------------------------
;       * * *  RECV Resurse
;------------------------------------------------
    mov  DL, SRV_MSG_Recv
    mov RCX, [RSI+PORT_IO_DATA.CountBytes]
    cmp RAX, RCX
        ja jmpRecvToResurse@Router
        jb jmpSendFileResurse@Router
;------------------------------------------------
;       * * *  SEND Resurse
;------------------------------------------------
jmpSendFromResurse@Router:
    mov DL, SRV_MSG_Recv

jmpSendFileResurse@Router:
    call PostReport
;------------------------------------------------
;       * * *  GET CGI-PROCESSOR
;------------------------------------------------
jmpRunProcess@Router:
        mov RDI, [SetQueuedProcess]
        lea RAX, [RDI+8]
        cmp RAX, [MaxQueuedProcess]
            jb jmpSetProcess@Router
            mov RAX, [TabQueuedProcess]

jmpSetProcess@Router:
        mov  BL, HTTP_503_BUSY
        mov  DL, SRV_MSG_ProcessLimit
        cmp RAX, [GetQueuedProcess]

            je jmpSelected@Router
            mov [SetQueuedProcess], RAX

            mov  RAX, [lpSocketIoData]
            mov [RDI], RAX

            mov RAX, [CountProcess]
            cmp AL, MAXIMUM_WAIT_OBJECTS
                jae jmpWaitCompletionPort@Router

                param 1, [RunProcessEvent]
                call [SetEvent]
                jmp jmpWaitCompletionPort@Router
;------------------------------------------------
;       * * *  Set FileResurse
;------------------------------------------------
jmpRecvToResurse@Router:
    mov [RSI+PORT_IO_DATA.Route], ROUTE_RECV_BUFFER

    cmp RAX, [ServerConfig.BufferSize]
        jbe jmpReceiving@Router

        mov RSI, [ServerConfig.lpTempFolder]
        mov R14, szFileName
        xor RAX, RAX
        lodsb
        mov RCX, RAX
        mov RDI, R14
        rep movsb

        mov AL, '\'
        stosb

        mov RDX, [ServerResurseId]
        inc RDX
        call HexToStr

        mov EAX, INS_TMP
        stosd
        mov [RDI], CL
;;------------------------------------------------
;       * * *  Create TempFile
;------------------------------------------------
        param 7, RCX
        param 6, FILE_ATTRIBUTE_NORMAL
        param 5, CREATE_ALWAYS
        param 4, RCX
        param 3, RCX
        param 2, GENERIC_WRITE 
        param 1, R14
;------------------------------------------------
        call [CreateFile]
;------------------------------------------------
        mov  DL, SRV_ERR_SaveFile
        cmp RAX, INVALID_HANDLE_VALUE
            je jmpInternalError@Router

            mov RSI, [lpSocketIoData] 
            mov [RSI+PORT_IO_DATA.hFile], RAX

            mov RAX, [ServerResurseId]
            inc RAX
            mov [ServerResurseId], RAX

            mov [RSI+PORT_IO_DATA.ResurseId], RAX
            mov [RSI+PORT_IO_DATA.Route], ROUTE_RECV_FILE
            jmp jmpRecvToFile@Router
;------------------------------------------------
;       * * *  RECV To File
;------------------------------------------------
jmpRequestToFile@Router:
    add [RSI+PORT_IO_DATA.CountBytes], RCX
;------------------------------------------------
;       * * *  RecvToFile
;------------------------------------------------
jmpRecvToFile@Router:
    mov RAX, [RSI+PORT_IO_DATA.TotalBytes]
    mov R8,  [RSI+PORT_IO_DATA.CountBytes]
    cmp R8,  [ServerConfig.MaxRecvSize]
        ja jmpWriteFile@Router
        cmp R8, RAX
            jb jmpReceiving@Router
;------------------------------------------------
;       * * *  Write File
;------------------------------------------------
jmpWriteFile@Router:
    xor RAX, RAX
    mov [RSI+PORT_IO_DATA.CountBytes], RAX

    param 5, RAX
    param 4, TotalBytes
    lea RDX, [RSI+PORT_IO_DATA.Buffer]
    param 1, [RSI+PORT_IO_DATA.hFile]
    mov [RSI+PORT_IO_DATA.WSABuffer.buf], RDX
    call [WriteFile]

    mov   DL, SRV_ERR_WriteFile
    test EAX, EAX
         jz jmpPost@Router
;------------------------------------------------
;       * * *  Reset Buffer
;------------------------------------------------
        mov RSI, [lpSocketIoData] 
        mov RAX, [RSI+PORT_IO_DATA.TotalBytes]
        sub RAX, [TotalBytes]
            js jmpSaveSize@Router
;------------------------------------------------
;       * * *  Close File
;------------------------------------------------
            mov [RSI+PORT_IO_DATA.TotalBytes], RAX
            test RAX, RAX
                 jnz jmpReceiving@Router

jmpRecvClose@Router:
                 param 1, [RSI+PORT_IO_DATA.hFile]
                 call [CloseHandle]

                 mov   DL, SRV_ERR_SaveClose
                 test EAX, EAX
                      jz jmpPost@Router

                      mov RSI, [lpSocketIoData]
                      xor RAX, RAX
                      mov [RSI+PORT_IO_DATA.hFile], RAX

                      mov DL, SRV_MSG_Save
                      jmp jmpSendFileResurse@Router
jmpSaveSize@Router:
        mov  DL, SRV_ERR_SaveSize
        call PostReport
        jmp jmpRecvClose@Router
;------------------------------------------------
;       * * *  RECV To Buffer
;------------------------------------------------
jmpRequestToBuffer@Router:
    add [RSI+PORT_IO_DATA.CountBytes], RCX
;------------------------------------------------
;       * * *  RecvToBuffer
;------------------------------------------------
    mov RAX, [RSI+PORT_IO_DATA.TotalBytes]
    mov RCX, [RSI+PORT_IO_DATA.CountBytes]
    mov  DL, SRV_ERR_RecvSize
    cmp RCX, RAX
        je jmpSendFromResurse@Router
        ja jmpSendFileResurse@Router
;------------------------------------------------
;       * * *  Receiving
;------------------------------------------------
jmpReceiving@Router:
    mov RSI, [lpSocketIoData] 
    mov RCX, [ServerConfig.RecvSize]
    cmp RAX, RCX
        jb jmpSizeRecv@Router
        mov RAX, RCX

jmpSizeRecv@Router:
    mov [RSI+PORT_IO_DATA.WSABuffer.len], RAX
    param 3, 0
    param 7, R8
    param 6, RSI
    param 5, TransFlag
    param 4, TransBytes
    inc R8
    lea RDX, [RSI+PORT_IO_DATA.WSABuffer]
    param 1, [RSI+PORT_IO_DATA.Socket]
    call [WSARecv] 

    test EAX, EAX
         jz jmpWaitCompletionPort@Router

         call [WSAGetLastError]
         cmp EAX, ERROR_IO_PENDING
             je jmpWaitCompletionPort@Router

             mov DL, SRV_ERR_RecvRouter
;------------------------------------------------
;       * * *  PostError
;------------------------------------------------
jmpPost@Router:
    call PostReport

jmpClose@Router:
    mov RSI, [lpSocketIoData]
    mov RDI, [RSI+PORT_IO_DATA.TablePort]
    xor RAX, RAX
    mov [RDI], RAX

    mov AL,  SD_BOTH
    param 2, RAX
    param 1, [RSI+PORT_IO_DATA.Socket]
    mov [hFile], RCX
    call [shutdown]
    test EAX, EAX
         jz jmpSocket@Router
         mov  DL, SRV_ERR_ShutDown
         call PostReport

jmpSocket@Router:
    param 1, [hFile]
    call [closesocket]
    test EAX, EAX
         jz jmpCloseFile@Router
         mov  DL, SRV_ERR_SocketClose
         call PostReport
;------------------------------------------------
;       * * *  Close ReadFile / WriteFile
;------------------------------------------------
jmpCloseFile@Router:
    mov RSI, [lpSocketIoData]
    mov RCX, [RSI+PORT_IO_DATA.hFile]
       jRCXz jmpSocketFree@Router
        call [CloseHandle]

jmpSocketFree@Router:
    mov  DL, SRV_MSG_Close
    call PostReport

    param 1, [lpSocketIoData]
    param 2, 0
    param 3, MEM_RELEASE
    call [VirtualFree]
    jmp jmpWaitCompletionPort@Router
;------------------------------------------------
;       * * *  End Thread  * * *
;------------------------------------------------
jmpEnd@Router:
    xor RAX, RAX
    param 1, RAX
    mov [ThreadSocketCtrl], EAX
    mov AL,  64
    add RSP, RAX
    call [ExitThread]
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------