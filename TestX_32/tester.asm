;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   MAIN: Main + Config + Start
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
format PE CONSOLE   ;   4.0
include 'tester.inc'

    mov EDI, ThreadServerCtrl
    xor EAX, EAX
    mov ECX, EAX
    mov CX,  STACK_FRAME_CLEAR
    rep stosd
    inc EAX
    mov [SetOptionPort], EAX
;------------------------------------------------
;   * * *  Set Digital Scale
;------------------------------------------------
    mov EDI, sStrByteScale
    mov ECX, MAX_INT_SCALE
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
    test EAX, EAX
         jz jmpError@Main

         mov ESI, EAX
         xor EDX, EDX
         mov EBX, EDX
         mov AL, [ESI]
         cmp AL, '"'
             je jmpSetEnd@Main

         cmp AL, "'"
             jne jmpGetPath@Main

     jmpSetEnd@Main:
             mov DL, AL
             inc ESI

jmpGetPath@Main:
         mov EDI, szReportName
         mov [pFind], ESI
         mov [lppReportMessages], EDI

jmpCopyPath@Main:
         lodsb
         stosb
         cmp AL, '.'
             jne jmpNextPath@Main
             mov EBX, ESI
             mov ECX, EDI

jmpNextPath@Main:
         cmp AL, DL
             jne jmpCopyPath@Main

jmpPathEnd@Main:
         mov   DL, SYS_ERR_CommandLine
         test EBX, EBX
         jz jmpError@Main

    mov dword[ECX], EXT_LOG
    mov dword[EBX], EXT_INI
;------------------------------------------------
;   * * *  OpenConfig
;------------------------------------------------
    mov [lpMemBuffer], _DataBuffer_
    mov EDX, [pFind]
    call ReadToBuffer

    xor  EDX, EDX
;   mov  ECX,[ReadBytes]
    test ECX, ECX
         jz jmpError@Main
;------------------------------------------------
;   * * *  Get Config Strings
;------------------------------------------------
    mov EDI, _DataBuffer_   ;  Buffer
    mov ESI, TabConfig      ;  pTable
;   mov ECX, [ReadBytes]
    mov [lpSocketIoData], ESI

    xor EBX, EBX
    mov [TabSocketIoData], EBX

    mov EDX, MAX_CONFIG_COUNT
    mov BL,   4

jmpTextScan@Main:
    mov [ESI], EDI
    add ESI, EBX

jmpTextSkip@Main:
    mov AL, CHR_LF
    repne scasb
      jne jmpTextEnd@Main
          xor EAX, EAX
          mov [EDI-1], AL

             jECXz jmpTextEnd@Main
          dec EDX
              jnz jmpTextScan@Main

jmpTextEnd@Main:
    xor EAX, EAX
    mov [ESI], EAX
;------------------------------------------------
;   * * *  Init Table HTTP Tags
;------------------------------------------------
    mov  CL, RESPONT_HEADER_COUNT
    mov EDI, lppTagRespont
    mov EAX, szTagOk
    rep stosd
;------------------------------------------------
;   * * *  Find KeyWord + Param
;------------------------------------------------
    mov EDI, TotalAccess
    mov EAX, ECX
    mov  AL, MAX_USR_ACCESS
    stosd
    mov  AL, MAX_RUN_PROC
    stosd
    mov EAX, TabUsrAccess
    stosd
    mov EAX, DefAskFile
    stosd
    stosd
    mov EAX, TabConfig
    stosd
    mov [DefAskFile.Type], szHeaderTextHtml
;------------------------------------------------
;   * * *  Get ConfigTable
;------------------------------------------------
jmpFindConfig@Main:
    mov ESI, [pBuffer]
    lodsd
    test EAX, EAX
         jz jmpScanEnd@Main

         mov [pBuffer], ESI
         mov EBX, EAX
         mov EAX, [EBX]
         cmp  AL, '#'
              je jmpFindConfig@Main
;------------------------------------------------
;   * * *  Get ConfigParam
;------------------------------------------------

    mov EDI, EBX
    xor ECX, ECX
    mov  CL, MAX_PARAM_LENGTH
    mov  AL, '='
    repne scasb
      jne jmpErrorParam@Main

      mov [pFind], EBX
      inc EBX
      mov EDX, EDI
      sub EDX, EBX
      mov ESI, EDI
      mov AL,  ' '

jmpFindParam@Main:
      scasb
        jbe jmpFindParam@Main

        mov EAX, EDI
        dec EAX
        sub EAX, ESI
            jz jmpSetParam@Main
            dec ESI
            mov [ESI],AL

            dec EDI
            xor EAX, EAX
            mov [EDI],AL

            mov EAX, ESI

jmpSetParam@Main:
    mov [Param], EAX
;------------------------------------------------
;   * * *  Find KeyParam
;------------------------------------------------
    mov ESI, sServerConfigParam
    xor ECX, ECX
    mov EBX, ECX

jmpFindKey@Main:
    inc EBX
    add ESI, ECX
    xor EAX, EAX
    lodsb
    mov ECX, EAX
       jECXz jmpReport@Main
        cmp EAX, EDX
            jne jmpFindKey@Main
            mov EDI, [pFind]
            repe cmpsb
             jne jmpFindKey@Main
;------------------------------------------------
;   * * *  Select Table
;------------------------------------------------
             mov ESI, [Param]
             shl EBX, 2
             cmp BL, CFG_INDEX_ACCESS
                 je jmpAccess@Main
                 ja jmpSetAccess@Main

             cmp BL, CFG_INDEX_PROCESS
                 je jmpAsk@Main
                 ja jmpSetAsk@Main

             mov [ServerConfig+EBX], ESI
             jmp jmpFindConfig@Main
;------------------------------------------------
;   * * *  Set Report
;------------------------------------------------
jmpReport@Main:
    mov ESI,[pFind]
    mov AX, [ESI]
    mov EBX, ECX
    sub AX,'00'
    mov BL, AH
    mov CL, 10
    mul CL
    add BL, AL
    mov ESI,[Param]
    cmp BL, REPORT_MESSAGE_COUNT-1
        ja jmpErrorParam@Main

        mov [lppReportMessages+EBX*4], ESI
        jmp jmpFindConfig@Main
;------------------------------------------------
;   * * *  Set ExtAsk
;------------------------------------------------
jmpAsk@Main:
    mov  EDX, DefAskFile
    test ESI, ESI
         jz jmpGetAsk@Main

    dec [TotalProcess]
        jz jmpErrorParam@Main

        mov EDI, [GetRunProc]
        mov [SetRunProc], EDI

        xchg EDX, ESI
        mov   CL, ASK_EXT_COUNT
        rep movsd

        mov ESI, EDX
        mov [GetRunProc], EDI

jmpSetAsk@Main:
        mov EDI, [SetRunProc]
        mov [EDI+EBX-CFG_OFFSET_PROCESS], ESI
        jmp jmpFindConfig@Main

jmpGetAsk@Main:
        mov [SetRunProc], EDX
        jmp jmpFindConfig@Main
;------------------------------------------------
;   * * *  Set Access
;------------------------------------------------
jmpAccess@Main:
    dec [TotalAccess]
        jz jmpErrorParam@Main

        mov CL, ASK_ACCESS_SIZE
        add [GetUsrAccess], ECX

jmpSetAccess@Main:
        mov EDI, [GetUsrAccess]
        mov [EDI+EBX-CFG_OFFSET_ACCESS], ESI
        jmp jmpFindConfig@Main
;------------------------------------------------
;   * * *  Config Error
;------------------------------------------------
jmpErrorParam@Main:
    mov [lppReportMessages], ESI
    mov EAX, [pBuffer]
    sub EAX, TabConfig
    shr EAX, 2
    mov [SystemReport.ExitCode], EAX

    xor EDX, EDX
    jmp jmpError@Main
;------------------------------------------------
;       * * *  Set Report FileName
;------------------------------------------------
jmpScanEnd@Main:
    mov   DL, CFG_ERR_SystemParam
    mov  ESI, [ServerConfig.lpReportPath]
    test ESI, ESI
         jz jmpError@Main

         mov EDI, szReportName
         xor EAX, EAX
         lodsb
         inc EAX
         mov ECX, EAX
         rep movsb
;------------------------------------------------
;       * * *  StartUp WSAver.2.2
;------------------------------------------------
    push WSockVer
    push SET_WSA_VER
    call [WSAStartup]
    mov   DL, SYS_ERR_WSAversion
    test EAX, EAX
         jnz jmpError@Main
;------------------------------------------------
;   * * *  Start Server
;------------------------------------------------
	push ServiceTable
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
;   * * *  Stop Server
;------------------------------------------------
jmpEnd@Main:
	mov  DL, SYS_MSG_Stop
	call FileReport

	xor EAX, EAX
	push EAX
	call [ExitProcess]
;------------------------------------------------
include 'resource.asm'
;------------------------------------------------
;   * * *   END  * * *
;------------------------------------------------
