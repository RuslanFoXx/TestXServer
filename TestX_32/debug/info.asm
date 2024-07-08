;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   MAIN: Print ConfigParameters
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
ddInfoRun               equ 095D2B5Bh
ddInfoSet               equ 095D2D5Bh
ddInfoEnd               equ 09090A0Dh
ddInfoError             equ 3F3F3F09h
;ddInfoEmpty            equ 0A0D2D2Dh
ddStrEnd                equ 0A0D0A0Dh
dwInfoEnd               equ 0A0Dh
dwInfoNum               equ 202Eh
dwInfoSep               equ 093Ah
dwInfoEmpty             equ 2D09h
;------------------------------------------------
;
;       * * *  Macros StdOut
;
;------------------------------------------------
macro MacroStdOut
{
;   pushad
    push EDX
    push EAX
;------------------------------------------------
    mov EDI, szTemp
    mov EAX, ddStrEnd
    stosd       
;------------------------------------------------
    call IntToStr
;------------------------------------------------
    mov AX, ': '
    stosw
;------------------------------------------------
    pop ECX
    call IntToStr
;------------------------------------------------
    mov AL, '.'
    stosb
;------------------------------------------------
    pop ECX
    call IntToStr
;------------------------------------------------
    mov AX, 0A0Dh
    stosw
;------------------------------------------------
    push EAX
    push PostBytes
;------------------------------------------------
    mov  EDX, szTemp
    sub  EDI, EDX
    dec  EDI
    push EDI
    push EDX
;------------------------------------------------
    push STD_OUTPUT_HANDLE
    call [GetStdHandle]
;------------------------------------------------
    push EAX
    call [WriteFile]
;------------------------------------------------
;   popad
}
;------------------------------------------------
;
;       * * *  Print StdOut  * * *
;
;------------------------------------------------
;section '.info' code readable executable   ;   default
;------------------------------------------------
proc StdOut __StdOutBuffer__
;------------------------------------------------
;   pushad
    mov EDI, [__StdOutBuffer__]
    mov EDX, EDI
    mov ECX, 1024
    xor EAX, EAX
;------------------------------------------------
    repne scasb
      jne jmpEnd@StdOut
;------------------------------------------------
          push EAX
          push PostBytes
;------------------------------------------------
          sub  EDI, EDX
          dec  EDI
          push EDI
          push EDX
;------------------------------------------------
          push STD_OUTPUT_HANDLE
          call [GetStdHandle]
;------------------------------------------------
          push EAX
          call [WriteFile]
;------------------------------------------------
;         invoke GetStdHandle, STD_OUTPUT_HANDLE
;         invoke WriteFile, EAX,\
;                [__StdOutBuffer__],\
;                EDI,\
;                PostBytes,\
;                NULL
;------------------------------------------------
jmpEnd@StdOut:
;   popad
;------------------------------------------------
    ret
endp
;------------------------------------------------
;
;       * * *  Print Params  * * *
;
;------------------------------------------------
proc PrintParamInfo
;------------------------------------------------
    mov EDI, szTextReport + 32
;------------------------------------------------
;jmp jmpEndParam@PrintParamInfo
;------------------------------------------------
;       * * *  Server version
;------------------------------------------------
    xor ECX, ECX
    mov CL,  szInfoTimeOut - szInfoVersion
    mov ESI, szInfoVersion
    rep movsb
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szVersionServer - szHeaderServer - 10
    mov ESI, szHeaderServer  + 10
    rep movsb
;------------------------------------------------
;       * * *  MaxTimeOut
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoProcess - szInfoTimeOut
    mov ESI, szInfoTimeOut
    rep movsb
;------------------------------------------------
    mov EBX, 1000
    xor EDX, EDX
    mov EAX, [ServerConfig.MaxTimeOut]
    div EBX
;------------------------------------------------
    mov ECX, EAX
    call IntToStr
;------------------------------------------------
;       * * *  MaxConnections
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoAccess - szInfoConnects
    mov ESI, szInfoConnects
    rep movsb
;------------------------------------------------
    mov ECX, [ServerConfig.MaxConnections]
    call IntToStr
;------------------------------------------------
;       * * *  MaxProcesses
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoConnects - szInfoProcess
    mov ESI, szInfoProcess
    rep movsb
;------------------------------------------------
    mov ECX, [ServerConfig.MaxRunning]
    call IntToStr
;------------------------------------------------
;       * * *  BufferSize
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoSendSize - szInfoBufferSize
    mov ESI, szInfoBufferSize
    rep movsb
;------------------------------------------------
    mov ECX, [ServerConfig.BufferSize]
    call IntToStr
;------------------------------------------------
    mov AX, ' ('
    stosw
;------------------------------------------------
    mov ECX, [ServerConfig.MaxRecvSize]
;   mov ECX, [SocketDataSize]
    call IntToStr
;------------------------------------------------
    mov AL, ')'
    stosb
;------------------------------------------------
;       * * *  SendSize
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoRecvSize - szInfoSendSize
    mov ESI, szInfoSendSize
    rep movsb
;------------------------------------------------
    mov ECX, [ServerConfig.SendSize]
    call IntToStr
;------------------------------------------------
;       * * *  RecvSize
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoPipeSize - szInfoRecvSize
    mov ESI, szInfoRecvSize
    rep movsb
;------------------------------------------------
    mov ECX, [ServerConfig.RecvSize]
    call IntToStr
;------------------------------------------------
;       * * *  MaxRecvFileSize
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoReportStack - szInfoFileSize
    mov ESI, szInfoFileSize
    rep movsb
;------------------------------------------------
    mov ECX, [ServerConfig.MaxRecvFileSize]
    call IntToStr
;------------------------------------------------
;       * * *  MaxStackBuffer
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoPath - szInfoReportStack
    mov ESI, szInfoReportStack
    rep movsb
;------------------------------------------------
    mov ECX, [ServerConfig.MaxReportStack]
    call IntToStr
;------------------------------------------------
;       * * *  HostAddres
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoHost - szInfoPath
    mov ESI, szInfoPath
    rep movsb
;------------------------------------------------
    mov ESI, [ServerConfig.lpHostAddress]
    lodsb
    mov CL, AL
;------------------------------------------------
    rep movsb
;------------------------------------------------
;       * * *  HostFolder
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoBase - szInfoHost
    mov ESI, szInfoHost
    rep movsb
;------------------------------------------------
    mov ESI, [ServerConfig.lpHostFolder]
    lodsb
    mov CL, AL
;------------------------------------------------
    rep movsb
;------------------------------------------------
;       * * * PageFolder
;------------------------------------------------
    mov ESI, [ServerConfig.lpDefPage]
    lodsb
    mov CL, AL
;------------------------------------------------
    mov AL, '\'
    stosb
;------------------------------------------------
    rep movsb
;------------------------------------------------
;       * * *  BaseFolder
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoTemp - szInfoBase
    mov ESI, szInfoBase
    rep movsb
;------------------------------------------------
    mov ESI, [ServerConfig.lpBaseFolder]
    lodsb
    mov CL, AL
;------------------------------------------------
    rep movsb
;------------------------------------------------
;       * * *  CodeFolder
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoReport - szInfoCode
    mov ESI, szInfoCode
    rep movsb
;------------------------------------------------
    mov ESI, [ServerConfig.lpCodeFolder]
    lodsb
    mov CL, AL
;------------------------------------------------
    rep movsb
;------------------------------------------------
;       * * *  TempFolder
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoCode - szInfoTemp
    mov ESI, szInfoTemp
    rep movsb
;------------------------------------------------
    mov ESI, [ServerConfig.lpTempFolder]
    lodsb
    mov CL, AL
;------------------------------------------------
    rep movsb
;------------------------------------------------
;       * * *  ReportLogPath
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoMessage - szInfoReport
    mov ESI, szInfoReport
    rep movsb
;------------------------------------------------
    mov ESI, szReportName
;------------------------------------------------
jmpCopyPath@PrintParamInfo:
    lodsb
    stosb
    test AL, AL
         jnz jmpCopyPath@PrintParamInfo
;------------------------------------------------
    dec EDI    
;------------------------------------------------
    mov AX, dwInfoEnd
    stosw
;------------------------------------------------
jmpEndParam@PrintParamInfo:
;------------------------------------------------
;
;       * * *  Headers
;
;------------------------------------------------
jmp jmpEndHeader@PrintParamInfo
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  RESPONT_HEADER_COUNT
    mov EDX, sGetHttpMethod
    mov EBX, lppTagRespont
;------------------------------------------------
jmpLoopHeader@PrintParamInfo:
    push ECX
;------------------------------------------------
    mov AX, dwInfoEnd
    stosw
;------------------------------------------------
    mov EAX, [EDX]
    stosd
;------------------------------------------------
    mov AL, 9
    stosb
;------------------------------------------------
    mov ESI, [EBX]
    xor EAX, EAX
    lodsb
    mov ECX, EAX
;------------------------------------------------
    rep movsb
;------------------------------------------------
    mov CL, 4
    add EDX, ECX
    add EBX, ECX
    pop ECX
;------------------------------------------------
    loop jmpLoopHeader@PrintParamInfo
;------------------------------------------------
    mov AX, dwInfoEnd
    stosw
;------------------------------------------------
jmpEndHeader@PrintParamInfo:
;------------------------------------------------
;
;       * * *  Access Client
;
;------------------------------------------------
jmp jmpEndAccess@PrintParamInfo
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoBufferSize - szInfoAccess
    mov ESI, szInfoAccess
    rep movsb
;------------------------------------------------
    mov  CX, MAX_USR_ACCESS
    sub ECX, [TotalAccess]
    push ECX
;------------------------------------------------
    call IntToStr
;------------------------------------------------
    mov EBX, TabUsrAccess
    pop ECX
;------------------------------------------------
jmpLoopAccess@PrintParamInfo:
    mov AX, dwInfoEnd
    stosw
;------------------------------------------------
    push ECX
    mov  ECX, ASK_ACCESS_PARAM
;------------------------------------------------
jmpLoopUsr@PrintParamInfo:
    mov EDX, [EBX]
    mov EAX, 'ADM '
    cmp EDX, ACCESS_ADMIN
        ja jmpParamUsr@PrintParamInfo
        je jmpSetAccess@PrintParamInfo
;------------------------------------------------
        mov EAX, 'EDIT'
        cmp DL, ACCESS_READ_WRITE
            je jmpSetAccess@PrintParamInfo
;------------------------------------------------
        mov EAX, '??? '
        cmp DL, ACCESS_READ_ONLY
            jne jmpSetAccess@PrintParamInfo
            mov EAX, 'VIEW'
;------------------------------------------------
jmpSetAccess@PrintParamInfo:
        stosd
        jmp jmpNextUsr@PrintParamInfo
;------------------------------------------------
jmpParamUsr@PrintParamInfo:
    mov ESI, EDX
    mov EDX, ECX
    xor EAX, EAX
    lodsb
    mov ECX, EAX
    rep movsb
;------------------------------------------------
    mov ECX, EDX
;------------------------------------------------
jmpNextUsr@PrintParamInfo:
    mov EAX, ddInfoEnd
    stosd
    dec EDI
;------------------------------------------------
    add EBX, 4
    loop jmpLoopUsr@PrintParamInfo
;------------------------------------------------
    pop ECX
    loop jmpLoopAccess@PrintParamInfo
;------------------------------------------------
    mov AX, dwInfoEnd
    stosw
;------------------------------------------------
jmpEndAccess@PrintParamInfo:
;------------------------------------------------
;
;       * * *  RunExt Processes
;
;------------------------------------------------
jmp jmpEndProc@PrintParamInfo
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoConnects - szInfoProcess
    mov ESI, szInfoProcess
    rep movsb
;------------------------------------------------
    mov CX, MAX_RUN_PROC + 1
    sub ECX, [TotalProcess]
    push ECX
;------------------------------------------------
    call IntToStr
;------------------------------------------------
    mov EBX, ErrAskFile
    pop ECX
;------------------------------------------------
jmpLoopProc@PrintParamInfo:
    mov AX, dwInfoEnd
    stosw
;------------------------------------------------
    push ECX
    mov ECX, ASK_EXT_PARAM
;------------------------------------------------
jmpLoopRun@PrintParamInfo:
;   mov EAX, [EBX+ASK_EXT.AskExt]
    mov ESI, [EBX]
;------------------------------------------------
    test ESI, ESI
         jnz jmpParamProc@PrintParamInfo
;------------------------------------------------
         mov AX, dwInfoEmpty
         stosw
         jmp jmpNextProc@PrintParamInfo
;------------------------------------------------
jmpParamProc@PrintParamInfo:
    mov EDX, ECX
    xor EAX, EAX
    lodsb
    mov ECX, EAX
    rep movsb
;------------------------------------------------
    mov ECX, EDX
;------------------------------------------------
jmpNextProc@PrintParamInfo:
    mov EAX, ddInfoEnd
    stosd
    dec EDI
;------------------------------------------------
    add EBX, 4
    loop jmpLoopRun@PrintParamInfo
;------------------------------------------------
    add EBX, 4
    pop ECX
    loop jmpLoopProc@PrintParamInfo
;------------------------------------------------
    mov AX, dwInfoEnd
    stosw
;------------------------------------------------
jmpEndProc@PrintParamInfo:
;------------------------------------------------
;
;       * * *  Messages
;
;------------------------------------------------
jmp jmpEndMessage@PrintParamInfo
;------------------------------------------------
;   xor ECX, ECX
    mov CL,  szInfoEnd - szInfoMessage
    mov ESI, szInfoMessage
    rep movsb
;------------------------------------------------
    mov EBX, lppReportMessages
    mov CL,  REPORT_MESSAGE_COUNT
;------------------------------------------------
jmpLoopMessage@PrintParamInfo:
    mov AX, dwInfoEnd
    stosw
;------------------------------------------------
    mov EAX, [EBX]
    test EAX, EAX
         jnz jmpParamtMessage@PrintParamInfo
;------------------------------------------------
         mov AX, dwInfoEmpty
         stosw
         jmp jmpNextMessage@PrintParamInfo
;------------------------------------------------
jmpParamtMessage@PrintParamInfo:
    push ECX
    push EBX
    push EAX
;------------------------------------------------
    mov EAX, REPORT_MESSAGE_COUNT
    sub EAX, ECX
    mov ECX, EAX
;------------------------------------------------
    call IntToStr
    pop ESI
;------------------------------------------------
    mov AX, dwInfoNum
    stosw
;------------------------------------------------
    xor EAX, EAX
    lodsb
    mov ECX, EAX
    rep movsb
;------------------------------------------------
    pop EBX
    pop ECX
;------------------------------------------------
jmpNextMessage@PrintParamInfo:
    add EBX, 4
    loop jmpLoopMessage@PrintParamInfo
;------------------------------------------------
    mov AX, dwInfoEnd
    stosw
;------------------------------------------------
jmpEndMessage@PrintParamInfo:
;------------------------------------------------
;
;       * * *  Type to STDOUT
;
;------------------------------------------------
jmpType@PrintParamInfo:
;------------------------------------------------
    mov AX, dwInfoEnd
    stosw
    stosw
;------------------------------------------------
    xor EAX, EAX
    push EAX
    push PostBytes
;------------------------------------------------
    mov  EDX, szTextReport + 32
    sub  EDI, EDX
    dec  EDI
    push EDI
    push EDX
;------------------------------------------------
    push STD_OUTPUT_HANDLE
    call [GetStdHandle]
;------------------------------------------------
    push EAX
    call [WriteFile]
;------------------------------------------------
;   mov DL, SRV_ERR_WriteFile
;   test EAX, EAX
;        jz jmpPost@PrintParamInfo
;------------------------------------------------
    ret
endp
;------------------------------------------------
;
;       * * *  Process Strings  * * *
;
;------------------------------------------------
;section '.text' data readable writeable   ;   not set !!!
;------------------------------------------------
szInfoVersion           DB 13,10, "Version: ",9
szInfoTimeOut           DB 13,10, "TimeOut: ",9
szInfoProcess           DB 13,10, "Process: ",9
szInfoConnects          DB 13,10, "Connects: ",9
szInfoAccess            DB 13,10, "Access: ",9
;------------------------------------------------
szInfoBufferSize        DB 13,10, "BufferSize:",9
szInfoSendSize          DB 13,10, "SendSize:",9
szInfoRecvSize          DB 13,10, "RecvSize:",9
szInfoPipeSize          DB 13,10, "PipeSize:",9
szInfoFileSize          DB 13,10, "FileSize:",9
szInfoReportStack       DB 13,10, "ReportStack:",9
;------------------------------------------------
szInfoPath              DB 13,10
                        DB 13,10, "Host:",9,9
szInfoHost              DB 13,10, "HostFolder:",9
szInfoBase              DB 13,10, "BaseFolder:",9
szInfoTemp              DB 13,10, "TempFolder:",9
szInfoCode              DB 13,10, "CodeFolder:",9
szInfoReport            DB 13,10, "Report:",9,9
;------------------------------------------------
szInfoMessage           DB 13,10, "Message:",13,10
szInfoEnd               DB 13,10
;------------------------------------------------
;
;       * * *   END  * * *
;
;------------------------------------------------
               