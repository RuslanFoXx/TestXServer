;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   THREAD:  RunProcessor
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
proc ThreadProcessor ThrControl

local lpProcessIoData LPPORT_IO_DATA ?
;------------------------------------------------
;       * * *  Set IndexPath
;------------------------------------------------
    mov EDI, [IndexBasePath]
    mov ESI, [ServerConfig.lpBaseFolder]
    xor EAX, EAX
    lodsb
    mov EDX, EAX
    mov EBX, ESI

    mov AL, '\'
    mov [ESI+EDX], AL
    inc EDX
    mov ECX, EDX
    rep movsb

    mov ESI, szIndexDirPath
    mov CL,  BASE_DIR_LENGTH + 10
    rep movsb
;------------------------------------------------
;       * * *  Set TablePath
;------------------------------------------------
	mov [TableBasePath.path], EDI
    mov ESI, EBX   ;   lpBaseFolder
    mov ECX, EDX
    rep movsb

    mov ESI, szTablePath
    mov CL,  BASE_DIR_LENGTH
    rep movsb

    mov [TableBasePath.session], EDI
    mov CL, BASE_NAME_LENGTH + 1
    rep movsb

    mov [TableBasePath.table], EDI
    add CL, MAX_TABLE_COUNT
    rep movsb

    mov [TableBasePath.index], EDI
    mov CL, MAX_INDEX_COUNT + FILE_EXT_LENGTH + 1
    rep movsb
;------------------------------------------------
;       * * *  Set TableScan
;------------------------------------------------
    mov [TableBaseScan.path], EDI
    mov ESI, [TableBasePath.path]
    mov ECX, EDX
    add CL,  BASE_DIR_LENGTH
    rep movsb

    mov [TableBaseScan.dir], EDI
    add CL, BASE_NAME_LENGTH
    rep movsb

    mov [TableBaseScan.name], EDI
    movsb
    mov AX, '*.'
    stosw
    mov EAX, EXT_TAB
    stosd
;------------------------------------------------
;       * * *  Set StorePath
;------------------------------------------------
    mov [StoreBasePath.path], EDI
    mov ESI, EBX   ;   lpBaseFolder
    mov ECX, EDX
    rep movsb

    mov ESI, szStoreDirPath
    mov CL,  STORE_DIR_LENGTH
    rep movsb

    mov [StoreBasePath.name], EDI
    mov CL, STORE_DIR_LENGTH + FILE_EXT_LENGTH + 1
    rep movsb
;------------------------------------------------
;       * * *  Set StoreScan
;------------------------------------------------
    mov [StoreBasePath.dir], EDI
    mov ESI, [StoreBasePath.path]
    mov ECX, EDX
    add CL,  STORE_DIR_LENGTH
    rep movsb

    mov AX, '*.'
    stosw

    mov EAX, EXT_ARCH
    stosd
;------------------------------------------------
;       * * *  Set GroupPath
;------------------------------------------------
    mov [GroupBasePath.path], EDI
    mov ESI, EBX   ;   lpBaseFolder
    mov ECX, EDX
    rep movsb

    mov ESI, szGroupDirPath
    mov CL,  GROUP_DIR_LENGTH
    rep movsb

    mov [GroupBasePath.name], EDI
    mov CL, GROUP_NAME_LENGTH + FILE_EXT_LENGTH + 1
    rep movsb
;------------------------------------------------
;       * * *  Set GroupScan
;------------------------------------------------
    mov [GroupBasePath.dir], EDI
    mov ESI, [GroupBasePath.path]
    mov ECX, EDX
    add CL,  GROUP_DIR_LENGTH
    rep movsb

    mov AX, '*.'
    stosw

    mov EAX, EXT_USR
    stosd
;------------------------------------------------
;       * * *  Set UserPath
;------------------------------------------------
    mov [UserBasePath.path], EDI
    mov ESI, EBX   ;   lpBaseFolder
    mov ECX, EDX
    rep movsb

    mov ESI, szUserDirPath
    mov CL,  USER_DIR_LENGTH
    rep movsb

    mov [UserBasePath.name], EDI
    add EDI, TEXT_NAME_LENGTH
;------------------------------------------------
;       * * *  Set UserScan
;------------------------------------------------
    mov [UserBasePath.dir], EDI
    mov ESI, [UserBasePath.path]
    mov ECX, EDX
    add CL,  USER_DIR_LENGTH
    rep movsb

    mov AX, '*.'
    stosw

    mov EAX, EXT_TXT
    stosd
;------------------------------------------------
;       * * *  Set TestPath
;------------------------------------------------
    mov [TestBasePath.path], EDI
    mov ESI, EBX   ;   lpBaseFolder
    mov ECX, EDX
    rep movsb

    mov ESI, szTestDirPath
    mov CL,  TEST_DIR_LENGTH
    rep movsb

    mov [TestBasePath.name], EDI
    add EDI, TEXT_NAME_LENGTH
;------------------------------------------------
;       * * *  Set TestScan
;------------------------------------------------
    mov [TestBasePath.dir], EDI
    mov ESI, [TestBasePath.path]
    mov ECX, EDX
    add CL,  TEST_DIR_LENGTH
    rep movsb

    mov AX, '*.'
    stosw

    mov EAX, EXT_TEST
    stosd
;------------------------------------------------
;       * * *  Set TextPath
;------------------------------------------------
    mov [TextBasePath.path], EDI
    mov ESI, EBX   ;   lpBaseFolder
    mov ECX, EDX
    rep movsb

    mov ESI, szTextDirPath
    mov CL,  TEXT_DIR_LENGTH
    rep movsb

    mov [TextBasePath.name], EDI
    add EDI, TEXT_NAME_LENGTH
;------------------------------------------------
;       * * *  Set TextScan
;------------------------------------------------
    mov [TextBasePath.dir], EDI
    mov ESI, [TextBasePath.path]
    mov ECX, EDX
    add CL,  TEST_DIR_LENGTH
    rep movsb

    mov AX, '*.'
    stosw

    mov EAX, EXT_TXT
    stosd
    mov [lpSystemBuffer], EDI
    mov EAX, ECX
    inc EAX
    mov [ThreadProcessCtrl], EAX
;------------------------------------------------
;   * * *  Wait Process
;------------------------------------------------
jmpWaitProcess@Processor:

    push WAIT_PROC_TIMEOUT
    push [RunProcessEvent]
    call [WaitForSingleObject]

    cmp EAX, WAIT_FAILED
        je jmpWaitError@Processor

    mov  ECX, [ThreadServerCtrl]
    test ECX, ECX 
         jz jmpEnd@Processor

    cmp EAX, WAIT_TIMEOUT
        je jmpWaitProcess@Processor
;------------------------------------------------
;   * * *  Get Process
;------------------------------------------------
jmpTabProcess@Processor:
    mov ESI, [GetQueuedProcess]
    cmp ESI, [SetQueuedProcess]
        je jmpWaitProcess@Processor

        lodsd

        cmp ESI, [MaxQueuedProcess]
            jb jmpGetProcess@Processor
            mov ESI, [TabQueuedProcess]
;------------------------------------------------
jmpGetProcess@Processor:
    mov [lpProcessIoData],  EAX
    mov [GetQueuedProcess], ESI
;------------------------------------------------
;   * * *  Local Year
;------------------------------------------------
    push LocalTime
    call [GetLocalTime]
;------------------------------------------------
;   * * *  Get Date + Random
;------------------------------------------------
    mov AX, [LocalTime.wSecond]
    mov [DateRandom], EAX
;------------------------------------------------
;   * * *  Get Date + Random
;------------------------------------------------
    mov DL,  PRC_ERR_Date
    xor EAX, EAX
    mov ECX, EAX
    mov AX, [LocalTime.wYear]
    cmp AX, ZERO_YEAR
        jb jmpWaitError@Processor

        sub AX, DELTA_YEAR   ;   delta year
        mov [LocalYear], EAX

        mov CL,  10
        div CL
        add AX, '00'
        mov word[gettext FORM_END@], AX
;------------------------------------------------
;   * * *  Get Tester-client
;------------------------------------------------
    mov EDI, ClientAccess
    xor EAX, EAX
    stosd
    stosd
    mov EDI, [TableBaseScan.name]
    mov byte[EDI], '\'
;------------------------------------------------
;   * * *  Set TypeBuffer
;------------------------------------------------
    mov EAX, [lpSystemBuffer]
    mov [lpMemBuffer], EAX
    mov [lpSaveBuffer],EAX
;------------------------------------------------
;   * * *  Type HTML-Top
;------------------------------------------------
    mov EBX, [lpProcessIoData]
    lea EDX, [EBX+PORT_IO_DATA.Buffer]
    mov EDI, EDX
    add EDI, HTTP_HEADER_SIZE
    mov [lpTypeMemory], EDI

    CopyHtmlSection FORM_STYLE@, FORM_STYLE + FORM_HTML + FORM_HEADER
    mov [lpTypeBuffer], EDI
;------------------------------------------------
;   * * *  Ask POST
;------------------------------------------------
    mov AL,  TEST_NUMBER
;   mov EBX, [lpProcessIoData]
    mov EDI, EDX
;------------------------------------------------
    mov ECX, [EBX+PORT_IO_DATA.TotalBytes]
;      jECXz jmpClient@Processor

    cmp ECX, MAX_POST_SIZE
        ja  jmpSysError@Processor

        mov EDI, EDX
        mov EBX, [EDI]
        and EBX, METHOD_CASE_UP
        cmp EBX, 'POST'
            jne jmpSysError@Processor
;------------------------------------------------
;   * * *  Get Param 
;------------------------------------------------
        mov EBX, END_CRLF
;       mov AL,  CHR_LF
        mov AL,  BL

jmpScanAsk@Processor:
        repne scasb   ;   ECX = 0
          jne jmpAskError@Processor

              mov ESI, EDI
              dec ESI
              cmp EBX, [ESI]
                  jne jmpScanAsk@Processor
;------------------------------------------------
;   * * *  Copy Option
;------------------------------------------------
jmpAskError@Processor:
    mov  AL,  ERR_GET_POST
    test ECX, ECX
         jz jmpSysError@Processor

         mov EDX, AskBuffer
         mov EDI, EDX
         xor EAX, EAX
         lodsd
         lodsw
         mov EBX, EAX
         sub CX, 3 + 3
         inc ESI
         rep movsb

         mov [EDI], CL
         mov ECX, EBX    ;   KeyProcess
;------------------------------------------------
;   * * *  Get Options
;------------------------------------------------
    mov EDI, AskOption
;   mov ESI, AskBuffer
    mov ESI, EDX
    mov EAX, EDX
    stosd

jmpScan@Processor:
    mov EBX, ESI
    lodsb
    cmp AL, ' '
        jb jmpEndOption@Processor

    cmp AL, '.'
        jne jmpScan@Processor

        mov EAX, ESI
        stosd

        xor EAX, EAX
        mov [EBX], AL
        jmp jmpScan@Processor

jmpEndOption@Processor:
    xor EAX, EAX
    stosD
    mov [EBX], AL
;------------------------------------------------
;       * * *  Find Ask Process
;------------------------------------------------
    mov EBX, TableClient
    mov EAX, ECX   ;   KeyProcess
    cmp AX, ASK_TableClient
        je jmpRunProcess@Processor
;------------------------------------------------
;       * * *  Get IndexProcess
;------------------------------------------------
    mov EDI, KeyRunProccess
    mov  CL, TOTAL_PROCESS_COUNT
    mov EBX, ECX
    repne scasw
      jne jmpAskError@Processor
;------------------------------------------------
;       * * *  Get IndexProcess
;------------------------------------------------
    sub EBX, ECX
    mov [ClientAccess.Process], EBX
;------------------------------------------------
;       * * *  Set Access Mode
;------------------------------------------------
;   mov EDX, AskBuffer
    xor EAX, EAX
;   mov ECX, EAX
    mov CL,  MAX_STRING_LENGTH
    mov EDI, EDX
    repnz scasb
;     jnz jmpAskError@Processor

    sub EDI, EDX
    mov EDX, EDI
    dec EDX
    inc EAX
    mov [ClientAccess.Mode], EAX
;------------------------------------------------
;       * * *  Find Access Client
;------------------------------------------------
    mov EBX, TabUsrAccess - ASK_ACCESS_SIZE

jmpFindMode@Processor:
    add EBX, ASK_ACCESS_SIZE
    mov ESI, [EBX]
    mov  AL, ACCESS_DENIED
    test ESI, ESI
         jz jmpSysError@Processor

         lodsb
         cmp EAX, EDX 
             jne jmpFindMode@Processor

             mov EDI, AskBuffer
             mov ECX, EDX    ;   Len
             repe cmpsb
              jne jmpFindMode@Processor
;------------------------------------------------
;       * * *  Access Address
;------------------------------------------------
    mov ESI, [lpProcessIoData]
    mov [ESI+PORT_IO_DATA.Client], EBX

    lea  EDI, [ESI+PORT_IO_DATA.Address]
    mov  ESI, [EBX+ASK_ACCESS.Address]
    test ESI, ESI
         jz jmpAccessMode@Processor

         xor EAX, EAX
         mov  AL, [ESI]
         inc EAX
         mov ECX, EAX
         mov  AL, ACCESS_DENIED
         repe cmpsb
          jne jmpSysError@Processor
;------------------------------------------------
;       * * *  Access Mode
;------------------------------------------------
jmpAccessMode@Processor:
    mov EDI, EDX
    mov ECX, [EBX+ASK_ACCESS.Mode]
    mov [ClientAccess.Mode], ECX

    mov EBX, [ClientAccess.Process]
    mov AL,  ACCESS_DENIED
    cmp ECX, EBX
        jb jmpSetSession@Processor
        cmp CL, ACCESS_READ_ONLY
            jb jmpRunIndProc@Processor
;------------------------------------------------
;       * * *  Set Header Session
;------------------------------------------------
jmpSetSession@Processor:
    mov EDX, EDI
    mov EDI, [lpTypeBuffer]
    xor ECX, ECX

    TypeHtmlSection FORM_SCRIPT

    mov ESI, AskBuffer
    mov ECX, EDX
    rep movsb

    mov [lpTypeBuffer], EDI 
;------------------------------------------------
;   * * *  Call Process
;------------------------------------------------
jmpRunIndProc@Processor:
;   mov EBX, [IndexProcess]
    mov EBX, [RunProcModule-4+EBX*4]

jmpRunProcess@Processor:
    call EBX
;------------------------------------------------
;   * * *  Process Return
;------------------------------------------------
    mov ESI, gettext FORM_POST@
    mov ECX, FORM_POST + FORM_YEAR + FORM_END
    test AL, AL
         jz jmpFooter@Processor

    test AL, TEST_END    ;    finish + not found
         jnz jmpSysError@Processor

         cmp AL, TEST_TYPE
             jz jmpType@Processor

jmpSysError@Processor:
             call TestBegin
;------------------------------------------------
;   * * *  Form End
;------------------------------------------------
jmpFooter@Processor:
    rep movsb
;------------------------------------------------
;   * * *  Type HTML-Header
;------------------------------------------------
jmpType@Processor:
    sub EDI, [lpTypeMemory]
    mov [Count], EDI
;------------------------------------------------
;   * * *  Local Year
;------------------------------------------------
    push LocalTime
    call [GetLocalTime]
;------------------------------------------------
;   * * *  Type HTML-Body
;------------------------------------------------
    mov EDI, szBuffer
    mov ESI, szTypeForm
    xor ECX, ECX
    mov CL,  HEADER_DATE@
    rep movsb

    call HeaderDateToStr

    TypeHtmlSection HEADER_DATE

    mov ECX, [Count]
    call IntToStr

    CopyHtmlSection HEADER_LENGTH@, HEADER_LENGTH + HEADER_CONNECT
;------------------------------------------------
;       * * *  Create Header
;------------------------------------------------
    mov EDX, szBuffer
    mov ECX, EDI
    sub ECX, EDX
    mov ESI, [lpProcessIoData]
    mov EDI, [lpTypeMemory]
    sub EDI, ECX
    mov EAX, [Count]
    add EAX, ECX
    mov EBX, EAX
    mov [ESI+PORT_IO_DATA.CountBytes], EAX
    mov [ESI+PORT_IO_DATA.WSABuffer.buf], EDI
    mov ESI, EDX   ;   szBuffer
    rep movsb 

    mov ECX, EBX
    mov ESI, [lpProcessIoData]
    jmp jmpSending@Processor
;------------------------------------------------
;   * * *  Type HTML-Header
;------------------------------------------------
    mov ESI, [lpProcessIoData]
    xor ECX, ECX   ;    hFile = NULL
    mov EBX, ECX   ;    HTTP_200_OK
;   mov BL, HTTP_201_CREATE
;------------------------------------------------
jmpCreateHeader@Processor:

    call CreateHttpHeader

;   mov ESI, [lpProcessIoData]
    mov ECX, [ESI+PORT_IO_DATA.TotalBytes]

jmpSending@Processor:
    mov EAX, [ServerConfig.SendSize]
    cmp EAX, ECX
        ja jmpSizeRecv@Processor
        mov ECX, EAX
;------------------------------------------------
;       * * *  Sending Form
;------------------------------------------------
jmpSizeRecv@Processor:
    mov [ESI+PORT_IO_DATA.WSABuffer.len], ECX
    mov [ESI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER

    xor EAX, EAX
    mov [ESI+PORT_IO_DATA.TransferredBytes], EAX
    mov [ESI+PORT_IO_DATA.TotalBytes], EAX

    push EAX
    push ESI
    push EAX
    push TransBytes
    inc EAX
    push EAX 
    lea EAX, [ESI+PORT_IO_DATA.WSABuffer]
    push EAX
    push [ESI+PORT_IO_DATA.Socket]
    call [WSASend]
    test EAX, EAX
         jz jmpTabProcess@Processor

         call [WSAGetLastError]
         cmp EAX, ERROR_IO_PENDING
             je jmpTabProcess@Processor
;------------------------------------------------
;       * * *  CloseSocket
;------------------------------------------------
             mov ESI, [lpProcessIoData]
             mov EDI, [ESI+PORT_IO_DATA.TablePort]
             xor EAX, EAX
             mov [EDI], EAX

             push MEM_RELEASE
;            xor EAX, EAX
             push EAX
             push ESI
             push [ESI+PORT_IO_DATA.Socket]
             call [closesocket]
             call [VirtualFree]
             jmp jmpTabProcess@Processor
;------------------------------------------------
;       * * *  Process Error
;------------------------------------------------
jmpWaitError@Processor:
	call [GetLastError]
	mov  [SystemReport.Error], EAX
	mov  [SystemReport.Index], PRC_ERR_WaitProc
;------------------------------------------------
;       * * *  End Thread  * * *
;------------------------------------------------
jmpEnd@Processor:
    xor EAX, EAX
    mov [ThreadProcessCtrl], EAX
    push EAX
    call [ExitThread]
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------
