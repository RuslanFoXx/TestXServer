;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   MAIN: Main + Config + Start
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
format PE64 CONSOLE
include 'tester.inc'

    xor RCX, RCX
    mov CL,  56
    sub RSP, RCX
    mov RDI, ThreadServerCtrl
    xor RAX, RAX
    mov CX,  STACK_FRAME_CLEAR
    rep stosq

    inc EAX    
    mov [SetOptionPort], RAX
;------------------------------------------------
;   * * *  Set Digital Scale
;------------------------------------------------
    mov RDI, sStrByteScale
    xor RCX, RCX
    mov CX,  MAX_INT_SCALE
    mov DX, '00'
    mov EBX, EDX

jmpSetScale@Main:

    cmp DH, '9'
        jbe jmpSet10@Main
        mov DH, '0'
        inc DL

jmpSet10@Main:
        cmp DL, '9'
            jbe jmpSet100@Main
            mov DL, '0'
            inc BH

jmpSet100@Main:
    mov EAX, EBX
    stosw
    mov EAX, EDX
    stosw
    inc DH
    loop jmpSetScale@Main
;------------------------------------------------
;   * * *  Get CommandLine
;------------------------------------------------
    call [GetCommandLine]
    test RAX, RAX
         jz jmpError@Main

         mov R10, RAX
         mov RSI, RAX
         xor RDX, RDX
         mov RBX, RDX
;        mov RDI, RDX
         mov AL, [RSI]
         cmp AL, '"'
             je jmpSetEnd@Main

         cmp AL, "'"
             jne jmpGetPath@Main

jmpSetEnd@Main:
             mov DL, AL
             inc RSI

jmpGetPath@Main:
         mov EDI, szReportName
         mov R10, RSI
         mov [lppReportMessages], RDI

jmpCopyPath@Main:
         lodsb
         stosb
         cmp AL, '.'
             jne jmpNextPath@Main
             mov RBX, RSI
             mov RCX, RDI

jmpNextPath@Main:
         cmp AL, DL
             jne jmpCopyPath@Main

jmpPathEnd@Main:
         mov   DL, SYS_ERR_CommandLine
         test RBX, RBX
              jz jmpError@Main

    mov dword[RCX], EXT_LOG
    mov dword[RBX], EXT_INI
;------------------------------------------------
;   * * *  OpenConfig
;------------------------------------------------
    mov [lpMemBuffer], _DataBuffer_
    param 1, R10
    call ReadToBuffer

    xor  RDX, RDX
;   mov  RCX,[ReadBytes]
    test RCX, RCX
         jz jmpError@Main
;------------------------------------------------
;   * * *  Get Config Strings
;------------------------------------------------
    mov RDI, _DataBuffer_   ;   Buffer
    mov R15, TabConfig      ;   Table
;   mov RCX, [CountBytes]
    mov RSI, R15
    xor RDX, RDX
    mov R8,  RDX
    mov [TabSocketIoData], RDX
    mov DX, MAX_CONFIG_COUNT
    mov R8b, 4

jmpTextScan@Main:
    mov [RSI], EDI
    add RSI, R8

jmpTextSkip@Main:
    mov AL, CHR_LF
    repne scasb
      jne jmpTextEnd@Main
          xor EAX, EAX
          mov [RDI-1], AL

             jECXz jmpTextEnd@Main
          dec EDX
              jnz jmpTextScan@Main

jmpTextEnd@Main:
    xor RAX, RAX
    mov [RSI], EAX
;------------------------------------------------
;   * * *  Init Table HTTP Tags
;------------------------------------------------
    mov  CL, RESPONT_HEADER_COUNT
    mov EDI, lppTagRespont
    mov EAX, szTagOk
    rep stosq
;------------------------------------------------
;   * * *  Find KeyWord + "Param"
;------------------------------------------------
;   R10  = TabNetAccess 
;   R11  = TabRunProcess 
;   R12  = GetRunProcess
;   R15  = TabConfig
;   RSI  = Param
;------------------------------------------------
    mov  CL, MAX_RUN_PROC
    mov R13, RCX
    mov  CL, MAX_USR_ACCESS
    mov R14, RCX

    mov [DefAskFile.Type], szHeaderTextHtml

    mov R10, TabUsrAccess   ;   GetUsrAccess
    mov R11, DefAskFile     ;   GetRunProc
;   mov R15, TabConfig      ;   Table
    mov R12, R11
;------------------------------------------------
;   * * *  Get ConfigTable
;------------------------------------------------
jmpFindConfig@Main:
    mov RSI, R15
    xor RAX, RAX
    lodsd
    test EAX, EAX
         jz jmpScanEnd@Main

         mov R15, RSI
         mov RBX, RAX
         cmp byte[RBX], '#'
              je jmpFindConfig@Main
;------------------------------------------------
;   * * *  Get ConfigParam
;------------------------------------------------
    mov RDI, RBX
    xor RCX, RCX
    mov  CL, MAX_PARAM_LENGTH
    mov  AL, '='
    repne scasb
      jne jmpErrorParam@Main

      mov RDX, RBX
      inc RBX
      mov R8,  RDI
      sub R8,  RBX
      mov RSI, RDI
      mov AL,  ' '

jmpFindParam@Main:
      scasb
        jbe jmpFindParam@Main

        mov RAX, RDI
        dec RAX
        sub RAX, RSI
            jz jmpSetParam@Main
            dec RSI
            mov [RSI],AL

            dec RDI
            xor EAX, EAX
            mov [RDI],AL

            mov RAX, RSI

jmpSetParam@Main:
    mov R9, RAX
;------------------------------------------------
;   * * *  Find KeyParam
;------------------------------------------------
    mov ESI, sServerConfigParam
    xor RCX, RCX
    mov RBX, RCX

jmpFindKey@Main:
    inc EBX
    add ESI, ECX
    xor EAX, EAX
    lodsb
    mov ECX, EAX
       jECXz jmpReport@Main
        cmp EAX, R8d
            jne jmpFindKey@Main
            mov EDI, EDX
            repe cmpsb
            jne jmpFindKey@Main
;------------------------------------------------
;   * * *  Select Table
;------------------------------------------------
             shl EBX, 3
             cmp BL, CFG_INDEX_ACCESS
                 je jmpAccess@Main
                 ja jmpSetAccess@Main

             cmp BL, CFG_INDEX_PROCESS
                 je jmpAsk@Main
                 ja jmpSetAsk@Main

             mov [ServerConfig+RBX], R9
             jmp jmpFindConfig@Main
;------------------------------------------------
;   * * *  Set Report
;------------------------------------------------
jmpReport@Main:
    mov AX, [RDX]
    mov RBX, RCX
    sub AX,'00'
    mov BL, AH
    mov CL, 10
    mul CL
    add BL, AL
    cmp BL, REPORT_MESSAGE_COUNT-1
        ja jmpErrorParam@Main

        mov [lppReportMessages+RBX*8], R9
        jmp jmpFindConfig@Main
;------------------------------------------------
;   * * *  Set ExtAsk
;------------------------------------------------
jmpAsk@Main:
    mov R12d, DefAskFile
    test RSI, RSI
         jz jmpFindConfig@Main

    dec R13d
        jz jmpErrorParam@Main

        mov RDX, RSI
        mov RSI, R12
        mov RDI, R11
        mov R12, R11
        mov  CL, ASK_EXT_COUNT
        rep movsq

        mov R11, RDI
        mov RSI, RDX

jmpSetAsk@Main:
        mov [R12+RBX-CFG_OFFSET_PROCESS], R9
        jmp jmpFindConfig@Main
;------------------------------------------------
;   * * *  Set Access
;------------------------------------------------
jmpAccess@Main:
    dec R14d
        jz jmpErrorParam@Main
        mov CL,  ASK_ACCESS_SIZE
        add R10, RCX

jmpSetAccess@Main:
        mov [R10+RBX-CFG_OFFSET_ACCESS], R9
		jmp jmpFindConfig@Main
;------------------------------------------------
;   * * *  Config Error
;------------------------------------------------
jmpErrorParam@Main:
    mov [lppReportMessages], R9
    mov RAX, R15
    sub EAX, TabConfig
    shr EAX, 2
    mov [SystemReport.ExitCode], EAX

    xor EDX, EDX
    jmp jmpError@Main
;------------------------------------------------
;   * * *  Init System Errors
;------------------------------------------------
jmpScanEnd@Main:
    mov [TotalAccess], R14
    mov [TotalProcess], R13
;------------------------------------------------
;       * * *  Set Report FileName
;------------------------------------------------
    mov   DL, CFG_ERR_SystemParam
    mov  RSI, [ServerConfig.lpReportPath]
    test RSI, RSI
         jz jmpError@Main

         mov EDI, szReportName
         xor RAX, RAX
         lodsb
         inc EAX
         mov RCX, RAX
         rep movsb
;------------------------------------------------
;       * * *  Startup WSAver.2.2
;------------------------------------------------
    xor RCX, RCX
    mov  CX, SET_WSA_VER
    param 2, WSockVer
    call [WSAStartup]
    mov   DL, SYS_ERR_WSAversion
    test EAX, EAX
         jnz jmpError@Main
;------------------------------------------------
;   * * *  Start Server
;------------------------------------------------
    param 1, ServiceTable
    call [StartServiceCtrlDispatcher]
    test EAX, EAX
         jnz jmpEnd@Main
         mov DL, SYS_ERR_Dispatcher
;------------------------------------------------
;   * * *  Server Error
;------------------------------------------------
jmpError@Main:
	call FileReport
;------------------------------------------------
;       * * *  End Process  * * *
;------------------------------------------------
jmpEnd@Main:
    param 1, 0
    call [ExitProcess]
;------------------------------------------------
include 'resource.asm'
;------------------------------------------------
;   * * *   END  * * *
;------------------------------------------------
