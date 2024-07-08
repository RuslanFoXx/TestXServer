;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   SYSTEM: Post & Write Report
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Set FileReport  * * *
;------------------------------------------------
proc FileReport

    mov [SystemReport.Index], EDX
    call [WSAGetLastError]
    mov [SystemReport.Error], EAX

    mov EAX, SystemReport
    call WriteReport

    push [hFileReport]
    call [CloseHandle]

    xor EAX, EAX
    mov [hFileReport], EAX
    ret
endp
;------------------------------------------------
;
;       * * *  Add SocketReport  * * *
;
;------------------------------------------------
proc PostReport 

    mov [RouterHeader.Index], EDX
    call [WSAGetLastError]
    mov [RouterHeader.Error], EAX

    mov EDI, [SetRouteReport]
    lea EDX, [EDI+REPORT_INFO_PATH_SIZE]

    cmp EDX, [MaxRouteReport]
        jb jmpSetReport@PostReport
        mov EDX, [TabRouteReport]
;------------------------------------------------
;       * * *  Create Report
;------------------------------------------------
jmpSetReport@PostReport:
    cmp EDX, [GetRouteReport]
        je jmpEnd@PostReport

        mov ESI, RouterHeader
		movsd
		movsd

        mov ESI, [lpSocketIoData]
        lea ESI, [ESI+PORT_IO_DATA.Socket]
        xor ECX, ECX
        mov  CL, REPORT_INFO_PORT
        rep movsd

        lea ESI, [ESI+20]
        mov  CX, [ESI]
            movsw
        rep movsb
        mov [SetRouteReport], EDX

jmpEnd@PostReport:
    ret
endp
;------------------------------------------------
;       * * *  Report Dispatcher  * * *
;------------------------------------------------
proc WriteReport

local PostLength DWORD ?

    mov [lpFileReport], EAX
;------------------------------------------------
;       * * *  Get Local Time
;------------------------------------------------
    push LocalTime
    call [GetLocalTime]

    mov ESI, LocalTime
    mov EDI, szTextReport
    mov EBX, sStrByteScale + 2
;------------------------------------------------
;           * * *  Set Date = YYYY-MM-DD
;------------------------------------------------
    xor EAX, EAX
    mov ECX, EAX
    mov  CL, '-'
    mov  AX, '20'
    stosw

    lodsw
    sub AX, DELTA_ZERO_YEAR
    mov AX, [EBX+EAX*4]
    stosw

    mov EAX, ECX
    stosb

    lodsw
    mov AX, [EBX+EAX*4]
    stosw

    mov EAX, ECX
    stosb

    lodsw
    lodsw
    mov AX, [EBX+EAX*4]
    stosw
;------------------------------------------------
;           * * *  Set Time = hh:mm:ss
;------------------------------------------------
    mov CL, ':'
    mov AL, ' '
    stosb

    lodsw
    mov AX, [EBX+EAX*4]
    stosw

    mov EAX, ECX
    stosb

    lodsw
    mov AX, [EBX+EAX*4]
    stosw

    mov EAX, ECX
    stosb

    lodsw
    mov AX, [EBX+EAX*4]
    stosw
;------------------------------------------------
;       * * *  Set Address (IP)
;------------------------------------------------
    mov EBX, [lpFileReport]
    mov ECX, [EBX+REPORT_INFO.Socket]
       jECXz jmpHostUrl@WriteReport
        mov AL, ' '
        stosb
        call IntToStr
;------------------------------------------------
;       * * *  Set Address (IP)
;------------------------------------------------
        mov EBX, [lpFileReport]
        lea ESI, [EBX+REPORT_INFO.Address]
        lodsb
        mov CL, AL
        mov AL, ' '
        stosb
        rep movsb
;------------------------------------------------
;       * * *  Set Url
;------------------------------------------------
    mov  EBX, [lpFileReport]
    mov  ESI, [EBX+REPORT_INFO.Client]
    test ESI, ESI
         jz jmpHostUrl@WriteReport
         mov AL, ' '
         stosb
         mov ESI, [ESI+ASK_ACCESS.User]
         xor EAX, EAX
         lodsb
         mov ECX, EAX
         rep movsb
;------------------------------------------------
;       * * *  Set Url
;------------------------------------------------
jmpHostUrl@WriteReport:
    lea ESI, [EBX+REPORT_INFO.UrlSize]
    lodsw
    mov CX, AX
       jCXz jmpMessage@WriteReport
        mov AX, " '"
        stosw
        mov EAX, 'Host'
        stosd

        mov EDX, [ServerConfig.lpHostFolder]
        xor EAX, EAX
        mov  AL, [EDX]
        add ESI, EAX
        sub ECX, EAX
        rep movsb

        mov AL, "'"
        stosb
;------------------------------------------------
;       * * *  Set Index
;------------------------------------------------
jmpMessage@WriteReport:
    mov AL, ' '
    stosb

    xor EDX, EDX
    mov EAX, [EBX+REPORT_INFO.Index]
    mov  DL, AL

    push EDX
    push EDX

    mov  ESI, [lppReportMessages+EDX*4]
    test ESI, ESI
         jnz jmpText@WriteReport
;------------------------------------------------
;       * * *  Set Index
;------------------------------------------------
         mov AX, '[0'
         stosw
         mov AX, word[sStrByteScale+2+EDX*4]
         stosw
         mov AL, ']'
         stosb
         jmp jmpInformation@WriteReport
;------------------------------------------------
;       * * *  Copy Message
;------------------------------------------------
jmpText@WriteReport:
    xor EAX, EAX
    lodsb
    mov ECX, EAX
    rep movsb
;------------------------------------------------
;       * * *  Type InformationPort
;------------------------------------------------
jmpInformation@WriteReport:
    pop EAX
    cmp AL, MSG_NO_INFORMATION
        jae jmpReportEnd@WriteReport
;------------------------------------------------
;       * * *  SaveNumberName
;------------------------------------------------
        mov EDX, [EBX+REPORT_INFO.ResurseId]
        test EDX, EDX
             jz jmpCountBytes@WriteReport
             mov EAX, ' id='
             stosd
             call HexToStr

             mov EBX, [lpFileReport]
;------------------------------------------------
;       * * *  Transceiver CountBytes
;------------------------------------------------
jmpCountBytes@WriteReport:
        mov ECX, [EBX+REPORT_INFO.TransferredBytes]
           jECXz jmpSysError@WriteReport
            mov AL, ' '
            stosb
            call IntToStr
            mov EAX, ' byt'
            stosd
            mov AX, 'es'
            stosw

            mov EBX, [lpFileReport]
;------------------------------------------------
;       * * *  System Error
;------------------------------------------------
jmpSysError@WriteReport:
    pop EAX
    cmp AL, MSG_NO_ERROR
        jae jmpReportEnd@WriteReport
;------------------------------------------------
;       * * *  GetRunReurn
;------------------------------------------------
        mov ECX, [EBX+REPORT_INFO.Error]
           jECXz jmpRunReurn@WriteReport

        cmp ECX, ERROR_IO_PENDING
            je jmpRunReurn@WriteReport
            mov AX, ' ('
            stosw
            call IntToStr
            mov AL, ')'
            stosb

            mov EBX, [lpFileReport]
;------------------------------------------------
jmpRunReurn@WriteReport:
        mov ECX, [EBX+REPORT_INFO.ExitCode]
           jECXz jmpReportEnd@WriteReport
            mov EAX, ' AX='
            stosd
            call IntToStr
;------------------------------------------------
;       * * *  Get LogSize
;------------------------------------------------
jmpReportEnd@WriteReport:
	mov AX, CHR_CRLF
	stosw

	sub EDI, szTextReport
	mov [PostLength], EDI
;------------------------------------------------
;       * * *  Write Report
;------------------------------------------------
	mov ECX, [hFileReport]
	jECXz jmpOpen@WriteReport

		push ECX
		call [CloseHandle]
		xor ECX, ECX
		mov [hFileReport], ECX
;------------------------------------------------
;       * * *  Create ReportFile
;------------------------------------------------
jmpOpen@WriteReport:
	test ECX, ECX
	jnz jmpWrite@WriteReport

		push ECX
		push FILE_ATTRIBUTE_NORMAL
		push OPEN_ALWAYS
		push ECX
		push FILE_SHARE_READ
		push FILE_APPEND_DATA
		push szReportName
		call [CreateFile]
		cmp EAX, INVALID_HANDLE_VALUE
		je jmpEnd@WriteReport

			mov ECX, EAX
			mov [hFileReport], EAX
;------------------------------------------------
;       * * *  Write ReportFile
;------------------------------------------------
jmpWrite@WriteReport:
	xor EAX, EAX
	push EAX
	push PostBytes
	push [PostLength]
	push szTextReport
	push ECX
	call [WriteFile]
;------------------------------------------------
;       * * *  End Proc  * * *
;------------------------------------------------
jmpEnd@WriteReport:
	mov ESI, [lpFileReport]
	ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------

