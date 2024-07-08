;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
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
;       * * *  Macros StdOut
;------------------------------------------------
macro Print pLable, LableSize
{
    param 5, 0
    param 4, PostBytes
    param 3, LableSize
    param 2, pLable
    param 1, [LetStdOutHandle]
;------------------------------------------------
    call [WriteFile]
}
;------------------------------------------------
macro MacroStdOut
{
;   pushad
    push RDX
    push RAX

    mov RDI, szTemp
    mov EAX, ddStrEnd
    stosd       

    call IntToStr

    mov AX, ': '
    stosw

    pop RCX
    call IntToStr

    mov AL, '.'
    stosb

    pop RCX
    call IntToStr
    mov AX, 0A0Dh
    stosw

    push RAX
    push PostBytes

    mov  RDX, szTemp
    sub  RDI, RDX
    dec  RDI
    push RDI
    push RDX

    push STD_OUTPUT_HANDLE
    call [GetStdHandle]

    push RAX
    call [WriteFile]
;------------------------------------------------
;   popad
}
;------------------------------------------------
;       * * *  Print StdOut  * * *
;------------------------------------------------
;section '.info' code readable executable   ;   default

proc StdOut   ;   

;   pushad
;   mov RDX, [__StdOutBuffer__]
;   mov RDX, [RSP]
    sub RSP, 40  ;  8*5 (+8)

    mov RDI, RDX 
    xor RAX, RAX
    mov RCX, RAX
    mov CX, 1024
    repne scasb
      jne jmpEnd@StdOut
          xor RAX, RAX
          mov qword[RSP+32], RAX

          push RDI
          push RDX

          mov RCX, STD_OUTPUT_HANDLE
          call [GetStdHandle]

          mov RCX, RAX
          pop RDX
          pop R8
          sub R8, RDX
          mov R9, PostBytes
          call [WriteFile]

jmpEnd@StdOut:
    add RSP, 40  ;  8*5 (+8)
;   popad
    ret
endp
;------------------------------------------------
;       * * *  Print StdOut  * * *
;------------------------------------------------
proc StdIn   ;   

;   pushad
;   mov RDX, [__StdInBuffer__]
;   mov RDX, [RSP]
;   mov RCX, [Count]
    sub RSP, 40  ;  8*5 (+8)

    xor RAX, RAX
    mov qword[RSP+32], RAX

    push RDX
    push RCX

    mov RCX, STD_INPUT_HANDLE
    call [GetStdHandle]

    mov RCX, RAX
    mov R9, PostBytes
    pop R8
    pop RDX
    call [ReadFile]

    add RSP, 40  ;  8*5 (+8)
;   popad
    ret
endp
;------------------------------------------------
;       * * *  Print Params  * * *
;------------------------------------------------
proc PrintParamInfo
;------------------------------------------------
local Len QWORD ?
;------------------------------------------------
    mov RDI, szTextReport + 32

;jmp jmpEndParam@PrintParamInfo
;------------------------------------------------
;       * * *  Server version
;------------------------------------------------
    xor RCX, RCX
    mov RSI, RCX
    mov CL,  szInfoTimeOut - szInfoVersion
    mov ESI, szInfoVersion
    rep movsb

;   xor RCX, RCX
    mov CL,  szVersionServer - szHeaderServer - 10
    mov ESI, szHeaderServer  + 10
    rep movsb
;------------------------------------------------
;       * * *  MaxTimeOut
;------------------------------------------------
;   xor RCX, RCX
    mov CL,  szInfoProcess - szInfoTimeOut
    mov ESI, szInfoTimeOut
    rep movsb

    xor RDX, RDX
    mov RBX, RDX
    mov BX, 1000
    mov RAX, [ServerConfig.MaxTimeOut]
    div RBX

    mov RCX, RAX
    call IntToStr
;------------------------------------------------
;       * * *  MaxConnections
;------------------------------------------------
;   xor RCX, RCX
    mov CL,  szInfoAccess - szInfoConnects
    mov ESI, szInfoConnects
    rep movsb

    mov RCX, [ServerConfig.MaxConnections]
    call IntToStr
;------------------------------------------------
;       * * *  MaxProcesses
;------------------------------------------------
;   xor RCX, RCX
    mov CL,  szInfoConnects - szInfoProcess
    mov ESI, szInfoProcess
    rep movsb

    mov RCX, [ServerConfig.MaxRunning]
    call IntToStr
;------------------------------------------------
;       * * *  BufferSize
;------------------------------------------------
;   xor RCX, RCX
    mov CL,  szInfoSendSize - szInfoBufferSize
    mov ESI, szInfoBufferSize
    rep movsb

    mov RCX, [ServerConfig.BufferSize]
    call IntToStr

    mov AX, ' ('
    stosw

;   mov RCX, [SocketDataSize]
    mov RCX, [ServerConfig.MaxRecvSize]
    call IntToStr

    mov AL, ')'
    stosb
;------------------------------------------------
;       * * *  SendSize
;------------------------------------------------
;   xor RCX, RCX
    mov CL,  szInfoRecvSize - szInfoSendSize
    mov ESI, szInfoSendSize
    rep movsb

    mov RCX, [ServerConfig.SendSize]
    call IntToStr
;------------------------------------------------
;       * * *  RecvSize
;------------------------------------------------
;   xor RCX, RCX
    mov CL,  szInfoPipeSize - szInfoRecvSize
    mov ESI, szInfoRecvSize
    rep movsb

    mov RCX, [ServerConfig.RecvSize]
    call IntToStr
;------------------------------------------------
;       * * *  MaxStackBuffer
;------------------------------------------------
;   xor RCX, RCX
    mov CL,  szInfoPath - szInfoReportStack
    mov ESI, szInfoReportStack
    rep movsb
    mov RCX, [ServerConfig.MaxReportStack]
    call IntToStr
;------------------------------------------------
;       * * *  HostAddres
;------------------------------------------------
;   xor RCX, RCX
    mov CL,  szInfoHost - szInfoPath
    mov ESI, szInfoPath
    rep movsb
    mov RSI, [ServerConfig.lpHostAddress]
    lodsb
    mov CL, AL
    rep movsb
;------------------------------------------------
;       * * *  HostFolder
;------------------------------------------------
;   xor RCX, RCX
    mov CL,  szInfoBase - szInfoHost
    mov ESI, szInfoHost
    rep movsb
    mov RSI, [ServerConfig.lpHostFolder]
    lodsb
    mov CL, AL
    rep movsb
;------------------------------------------------
;       * * * PageFolder
;------------------------------------------------
    mov RSI, [ServerConfig.lpDefPage]
    lodsb
    mov CL, AL
    mov AL, '\'
    stosb
    rep movsb
;------------------------------------------------
;       * * *  BaseFolder
;------------------------------------------------
;   xor RCX, RCX
    mov CL,  szInfoTemp - szInfoBase
    mov ESI, szInfoBase
    rep movsb

    mov RSI, [ServerConfig.lpBaseFolder]
    lodsb
    mov CL, AL
    rep movsb
;------------------------------------------------
;       * * *  CodeFolder
;------------------------------------------------
;   xor RCX, RCX
    mov CL,  szInfoReport - szInfoCode
    mov ESI, szInfoCode
    rep movsb

    mov RSI, [ServerConfig.lpCodeFolder]
    lodsb
    mov CL, AL
    rep movsb
;------------------------------------------------
;       * * *  TempFolder
;------------------------------------------------
;   xor RCX, RCX
    mov CL,  szInfoCode - szInfoTemp
    mov ESI, szInfoTemp
    rep movsb

    mov RSI, [ServerConfig.lpTempFolder]
    lodsb
    mov CL, AL
    rep movsb
;------------------------------------------------
;       * * *  ReportLogPath
;------------------------------------------------
;   xor RCX, RCX
    mov CL,  szInfoMessage - szInfoReport
    mov ESI, szInfoReport
    rep movsb
;------------------------------------------------
    mov RSI, szReportName
;------------------------------------------------
jmpCopyPath@PrintParamInfo:
    lodsb
    stosb
    test AL, AL
         jnz jmpCopyPath@PrintParamInfo

    dec RDI    
    mov AX, dwInfoEnd
    stosw

jmpEndParam@PrintParamInfo:
    xor R10, R10
    mov R11, R10
    mov R12, R10
    mov R12b, 4
    mov R10b, 8
;------------------------------------------------
;       * * *  Headers
;------------------------------------------------
jmp jmpEndHeader@PrintParamInfo

    mov RDX,  sGetHttpMethod
    mov RBX,  lppTagRespont
    mov R11b, RESPONT_HEADER_COUNT

jmpLoopHeader@PrintParamInfo:
    mov AX, dwInfoEnd
    stosw

    mov EAX, [RDX]
    stosd

    mov AL, 9
    stosb

    mov RSI, [RBX]
    xor RAX, RAX
    lodsb
    mov RCX, RAX
    rep movsb

    add RBX, R10
    add RDX, R12

    dec R11
        jnz jmpLoopHeader@PrintParamInfo

    mov AX, dwInfoEnd
    stosw

jmpEndHeader@PrintParamInfo:
;------------------------------------------------
;       * * *  Access Client
;------------------------------------------------
jmp jmpEndAccess@PrintParamInfo

;   xor RCX, RCX
    mov CL,  szInfoBufferSize - szInfoAccess
    mov RSI, szInfoAccess
    rep movsb

    mov CX,  MAX_USR_ACCESS
    sub RCX, [TotalAccess]
    mov R13, RCX
    call IntToStr

    mov RBX, TabUsrAccess

jmpLoopAccess@PrintParamInfo:
    mov AX, dwInfoEnd
    stosw

    mov RCX, ASK_ACCESS_PARAM

jmpLoopUsr@PrintParamInfo:
    mov RDX, [RBX]
    mov EAX, 'ADM '
    cmp EDX, ACCESS_ADMIN
        ja jmpParamUsr@PrintParamInfo
        je jmpSetAccess@PrintParamInfo

        mov EAX, 'EDIT'
        cmp DL, ACCESS_READ_WRITE
            je jmpSetAccess@PrintParamInfo

        mov EAX, '??? '
        cmp DL, ACCESS_READ_ONLY
            jne jmpSetAccess@PrintParamInfo
            mov EAX, 'VIEW'

jmpSetAccess@PrintParamInfo:
        stosd
        jmp jmpNextUsr@PrintParamInfo

jmpParamUsr@PrintParamInfo:
    mov RSI, RDX
    mov RDX, RCX
    xor RAX, RAX
    lodsb
    mov RCX, RAX
    rep movsb

    mov RCX, RDX

jmpNextUsr@PrintParamInfo:
    mov EAX, ddInfoEnd
    stosd
    dec RDI
    add RBX, R10
    loop jmpLoopUsr@PrintParamInfo

    dec R13d
        jnz jmpLoopAccess@PrintParamInfo

    mov AX, dwInfoEnd
    stosw

jmpEndAccess@PrintParamInfo:
;------------------------------------------------
;       * * *  RunExt Processes
;------------------------------------------------
jmp jmpEndProc@PrintParamInfo

;   xor RCX, RCX
    mov CL,  szInfoConnects - szInfoProcess
    mov RSI, szInfoProcess
    rep movsb

    mov CX,   MAX_RUN_PROC + 1
    sub RCX, [TotalProcess]
    mov R13, RCX
    call IntToStr

    mov RBX, ErrAskFile

jmpLoopProc@PrintParamInfo:
    mov AX, dwInfoEnd
    stosw

    mov RCX, ASK_EXT_PARAM

jmpLoopRun@PrintParamInfo:
    mov  RSI, [RBX]
    test RSI, RSI
         jnz jmpParamProc@PrintParamInfo
         mov AX, dwInfoEmpty
         stosw
         jmp jmpNextProc@PrintParamInfo

jmpParamProc@PrintParamInfo:
    mov RDX, RCX
    xor RAX, RAX
    lodsb
    mov RCX, RAX
    rep movsb

    mov RCX, RDX

jmpNextProc@PrintParamInfo:
    mov EAX, ddInfoEnd
    stosd
    dec RDI
    add RBX, R10
    loop jmpLoopRun@PrintParamInfo

    add RBX, R10
    dec R13d
        jnz jmpLoopProc@PrintParamInfo

    mov AX, dwInfoEnd
    stosw

jmpEndProc@PrintParamInfo:
;------------------------------------------------
;       * * *  Messages
;------------------------------------------------
jmp jmpEndMessage@PrintParamInfo

jmpMessage@PrintParamInfo:
;   xor RCX, RCX
    mov CL,  szInfoEnd - szInfoMessage
    mov RSI, szInfoMessage
    rep movsb

    mov RBX, RCX
    mov EBX, lppReportMessages
    mov CL,  REPORT_MESSAGE_COUNT

jmpLoopMessage@PrintParamInfo:
    mov AX, dwInfoEnd
    stosw

    mov  RAX, [RBX]
    test RAX, RAX
         jnz jmpParamtMessage@PrintParamInfo
         mov AX, dwInfoEmpty
         stosw
         jmp jmpNextMessage@PrintParamInfo

jmpParamtMessage@PrintParamInfo:
    push RCX
    push RBX
    push RAX

    mov RAX, REPORT_MESSAGE_COUNT
    sub RAX, RCX
    mov RCX, RAX
    call IntToStr
    pop RSI

    mov AX, dwInfoNum
    stosw

    xor RAX, RAX
    lodsb
    mov RCX, RAX
    rep movsb

    pop RBX
    pop RCX

jmpNextMessage@PrintParamInfo:
    add RBX, R10
    loop jmpLoopMessage@PrintParamInfo

;   mov AX, dwInfoEnd
;   stosw

jmpEndMessage@PrintParamInfo:
;------------------------------------------------
;       * * *  Type to STDOUT
;------------------------------------------------
jmpType@PrintParamInfo:

    mov AX, dwInfoEnd
    stosw
    stosw

    mov [Len], RDI

    xor RAX, RAX
    mov AL,  48    ;   for 5 + 8
    sub RSP, RAX

    xor RAX, RAX
    param 5, RAX
    param 1, STD_OUTPUT_HANDLE
    call [GetStdHandle]

    param 1, RAX
    param 2, szTextReport + 32  ;  RDX
    param 4, PostBytes
    mov R8,  [Len]
    sub R8,  RDX
    call [WriteFile]
;   mov DL, SRV_ERR_WriteFile
;   test EAX, EAX
;        jz jmpPost@PrintParamInfo

    xor RAX, RAX
    mov AL,  48    ;   for 5 + 8
    add RSP, RAX
    ret
endp
;------------------------------------------------
;       * * *  Process Strings  * * *
;------------------------------------------------
;section '.text' data readable writeable   ;   not set !!!

szInfoVersion           DB 13,10, "Version: ",9
szInfoTimeOut           DB 13,10, "TimeOut: ",9
szInfoProcess           DB 13,10, "Process: ",9
szInfoConnects          DB 13,10, "Connects: ",9
szInfoAccess            DB 13,10, "Access: ",9

szInfoBufferSize        DB 13,10, "BufferSize:",9
szInfoSendSize          DB 13,10, "SendSize:",9
szInfoRecvSize          DB 13,10, "RecvSize:",9
szInfoPipeSize          DB 13,10, "PipeSize:",9
szInfoFileSize          DB 13,10, "FileSize:",9
szInfoReportStack       DB 13,10, "ReportStack:",9

szInfoPath              DB 13,10
                        DB 13,10, "Host:",9,9
szInfoHost              DB 13,10, "HostFolder:",9
szInfoBase              DB 13,10, "BaseFolder:",9
szInfoTemp              DB 13,10, "TempFolder:",9
szInfoCode              DB 13,10, "CodeFolder:",9
szInfoReport            DB 13,10, "Report:",9,9

szInfoMessage           DB 13,10, "Message:",13,10
szInfoEnd               DB 13,10
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
               