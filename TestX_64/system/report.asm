;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   SYSTEM: Post & Write Report
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Set FileReport  * * *
;------------------------------------------------
proc FileReport

    xor RAX, RAX
    mov AL,  32
    sub RSP, RAX

    mov [SystemReport.Index], EDX
    call [WSAGetLastError]
    mov [SystemReport.Error], EAX

    param 0, SystemReport
    call WriteReport

    param 1, [hFileReport]
    call [CloseHandle]

    xor RAX, RAX
    mov [hFileReport], RAX

    xor RCX, RCX
    mov CL,  32
    add RSP, RCX
    ret
endp
;------------------------------------------------
;       * * *  Add SocketReport  * * *
;------------------------------------------------
proc PostReport 

    xor RAX, RAX
    mov AL,  32
    sub RSP, RAX

    mov [RouterHeader.Index], EDX
    call [WSAGetLastError]
    mov [RouterHeader.Error], EAX

    mov RDI, [SetRouteReport]
    lea RDX, [RDI+REPORT_INFO_PATH_SIZE]
    cmp RDX, [MaxRouteReport]
        jb jmpSetReport@PostReport

        mov RDX, [TabRouteReport]
;------------------------------------------------
;       * * *  Create Report
;------------------------------------------------
jmpSetReport@PostReport:
    cmp RDX, [GetRouteReport]
        je jmpEnd@PostReport

        mov RSI, RouterHeader
		movsq

        mov RSI, [lpSocketIoData]
        lea RSI, [RSI+PORT_IO_DATA.Socket]
        xor RCX, RCX
        mov  CL, REPORT_INFO_PORT
        rep movsq
            movsd

        lea RSI, [RSI+36]
        mov CX,  [RSI]
            movsw
        rep movsb
        mov [SetRouteReport], RDX
;------------------------------------------------
;       * * *  End  * * *
;------------------------------------------------
jmpEnd@PostReport:
    xor RCX, RCX
    mov CL,  32
    add RSP, RCX
    ret
endp
;------------------------------------------------
;       * * *  Report Dispatcher  * * *
;------------------------------------------------
proc WriteReport

local PostLength QWORD ?
;------------------------------------------------
    mov [lpFileReport], RAX
    xor RAX, RAX
    mov AL,  64    ;   for 7 + 8
    sub RSP, RAX
;------------------------------------------------
;       * * *  Get Local Time
;------------------------------------------------
    param 1, LocalTime
    call [GetLocalTime]

	xor RAX, RAX
	mov RDI, RAX
	mov RSI, RAX
	mov RBX, RAX
	mov RCX, RAX
	mov ESI, LocalTime
	mov EDI, szTextReport
	mov EBX, sStrByteScale + 2
;------------------------------------------------
;           * * *  Set Date = YYYY-MM-DD
;------------------------------------------------
    mov  CL, '-'
    mov  AX, '20'
    stosw

    lodsw
    sub AX, DELTA_ZERO_YEAR
    mov AX, [RBX+RAX*4]
    stosw

    mov EAX, ECX
    stosb

    lodsw
    mov AX, [RBX+RAX*4]
    stosw

    mov EAX, ECX
    stosb

    lodsw
    lodsw
    mov AX, [RBX+RAX*4]
    stosw
;------------------------------------------------
;           * * *  Set Time = hh:mm:ss
;------------------------------------------------
    mov CL, ':'
    mov AL, ' '
    stosb

    lodsw
    mov AX, [RBX+RAX*4]
    stosw

    mov EAX, ECX
    stosb

    lodsw
    mov AX, [RBX+RAX*4]
    stosw

    mov EAX, ECX
    stosb

    lodsw
    mov AX, [RBX+RAX*4]
    stosw
;------------------------------------------------
;       * * *  Set Address (IP)
;------------------------------------------------
    mov R15, [lpFileReport]
    mov RCX, [R15+REPORT_INFO.Socket]
       jECXz jmpHostUrl@WriteReport
        mov AL, ' '
        stosb
        call IntToStr
;------------------------------------------------
;       * * *  Set Address (IP)
;------------------------------------------------
        lea RSI, [R15+REPORT_INFO.Address]
        lodsb
        mov CL, AL
        mov AL, ' '
        stosb
        rep movsb
;------------------------------------------------
;       * * *  Set Url
;------------------------------------------------
    mov  RSI, [R15+REPORT_INFO.Client]
    test RSI, RSI
         jz jmpHostUrl@WriteReport
         mov AL, ' '
         stosb

         mov RSI, [RSI+ASK_ACCESS.User]
         xor EAX, EAX
         lodsb
         mov ECX, EAX
         rep movsb
;------------------------------------------------
;       * * *  Set Url
;------------------------------------------------
jmpHostUrl@WriteReport:
    lea RSI, [R15+REPORT_INFO.UrlSize]
;   xor RAX, RAX
    lodsw
;------------------------------------------------
    mov CX, AX
       jECXz jmpMessage@WriteReport

        mov AX, " '"
        stosw
        mov EAX, 'Host'
        stosd

        mov RBX, [ServerConfig.lpHostFolder]
        xor RAX, RAX
        mov AL, [RBX]
        add RSI, RAX
        sub RCX, RAX
        rep movsb

        mov AL, "'"
        stosb
;------------------------------------------------
;       * * *  Copy Message
;------------------------------------------------
jmpMessage@WriteReport:
    mov AL, ' '
    stosb

    xor R12, R12
    mov EAX, [R15+REPORT_INFO.Index]
    mov R12b, AL

    mov  RSI, [lppReportMessages+R12*8]
    test RSI, RSI
         jnz jmpText@WriteReport
;------------------------------------------------
;       * * *  Set Index
;------------------------------------------------
         mov AX, '[0'
         stosw
         mov AX, word[sStrByteScale+2+R12*4]
         stosw
         mov AL, ']'
         stosb
         jmp jmpInformation@WriteReport
;------------------------------------------------
;       * * *  Copy Message
;------------------------------------------------
jmpText@WriteReport:
    xor RAX, RAX
    lodsb
    mov RCX, RAX
    rep movsb
;------------------------------------------------
;       * * *  Type InformationPort
;------------------------------------------------
jmpInformation@WriteReport:
    cmp R12b, MSG_NO_INFORMATION
        jae jmpReportEnd@WriteReport
;------------------------------------------------
;       * * *  SaveNumberName
;------------------------------------------------
        mov  RDX, [R15+REPORT_INFO.ResurseId]
        test RDX, RDX
             jz jmpCountBytes@WriteReport

              mov EAX, ' id='
              stosd
              call HexToStr

jmpCountBytes@WriteReport:
        mov RCX, [R15+REPORT_INFO.TransferredBytes]
           jRCXz jmpSysError@WriteReport
            mov AL, ' '
            stosb
            call IntToStr
            mov EAX, ' byt'
            stosd
            mov AX, 'es'
            stosw
;------------------------------------------------
;       * * *  System Error
;------------------------------------------------
jmpSysError@WriteReport:
    cmp R12b, MSG_NO_ERROR
        jae jmpReportEnd@WriteReport
;------------------------------------------------
;       * * *  GetRunReurn
;------------------------------------------------
         mov ECX, [R15+REPORT_INFO.Error]
            jECXz jmpExitCode@WriteReport

         cmp RCX, ERROR_IO_PENDING
             je jmpExitCode@WriteReport
             mov AX, ' ('
             stosw
             call IntToStr
             mov AL, ')'
             stosb

jmpExitCode@WriteReport:
         mov ECX, [R15+REPORT_INFO.ExitCode]
            jECXz jmpReportEnd@WriteReport
             mov EAX, ' AX='
             stosd
             call IntToStr
;------------------------------------------------
;       * * *  Get ReportSize
;------------------------------------------------
jmpReportEnd@WriteReport:
	mov AX, CHR_CRLF
	stosw

	sub RDI, szTextReport
	mov [PostLength], RDI
;------------------------------------------------
;       * * *  Write Report
;------------------------------------------------
	mov RCX, [hFileReport]
	jRCXz jmpOpen@WriteReport

;       param 1, RCX
		call [CloseHandle]

		xor RCX, RCX
		mov [hFileReport], RCX
;------------------------------------------------
;       * * *  Create ReportFile
;------------------------------------------------
jmpOpen@WriteReport:
;   mov  RCX, [hFileReport]
	test RCX, RCX
	jnz jmpWrite@WriteReport

		param 7, RCX
		param 6, FILE_ATTRIBUTE_NORMAL
		param 5, OPEN_ALWAYS
		param 4, RCX
		param 3, FILE_SHARE_READ 
		param 2, FILE_APPEND_DATA
		param 1, szReportName
		call [CreateFile]
		cmp RAX, INVALID_HANDLE_VALUE
		je jmpEnd@WriteReport

			mov RCX, RAX
			mov [hFileReport], RAX
;------------------------------------------------
;       * * *  Write ReportFile
;------------------------------------------------
jmpWrite@WriteReport:
	xor RAX, RAX
	param 5, RAX
	param 4, PostBytes
	param 3, [PostLength] 
	param 2, szTextReport 
	call [WriteFile]
;------------------------------------------------
;       * * *  End Proc  * * *
;------------------------------------------------
jmpEnd@WriteReport:
	mov RSI, [lpFileReport]
	xor RCX, RCX
	mov CL,  64
	add RSP, RCX
	ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------
