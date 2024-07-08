;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   THREAD:  RunProcessor
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
proc ThreadProcessor   ;   RCX = ThrControl

local lpProcessIoData LPPORT_IO_DATA ?
;------------------------------------------------
    mov RDI, [IndexBasePath]
    mov RSI, [ServerConfig.lpBaseFolder]
    xor RAX, RAX
    lodsb
    mov RDX, RAX
    mov RBX, RSI

    mov AL, '\'
    mov [RSI+RDX], AL
    inc EDX
    mov ECX, EDX
    rep movsb

    mov ESI, szIndexDirPath
    mov CL,  BASE_DIR_LENGTH + 10
    rep movsb
;------------------------------------------------
;       * * *  Set TablePath
;------------------------------------------------
    mov [TableBasePath.path], RDI
    mov RSI, RBX
    mov ECX, EDX
    rep movsb

    mov ESI, szTablePath
    mov CL,  BASE_DIR_LENGTH
    rep movsb

    mov [TableBasePath.session], RDI
    mov CL, BASE_NAME_LENGTH + 1
    rep movsb

    mov [TableBasePath.table], RDI
    add CL, MAX_TABLE_COUNT
    rep movsb

    mov [TableBasePath.index], RDI
    mov CL, MAX_INDEX_COUNT + FILE_EXT_LENGTH + 1
    rep movsb
;------------------------------------------------
;       * * *  Set TableScan
;------------------------------------------------
    mov [TableBaseScan.path], RDI
    mov RSI, [TableBasePath.path]
    mov ECX, EDX
    add CL,  BASE_DIR_LENGTH
    rep movsb

    mov [TableBaseScan.dir], RDI
    add CL, BASE_NAME_LENGTH
    rep movsb

    mov [TableBaseScan.name], RDI
    movsb

    mov AX, '*.'
    stosw
    mov EAX, EXT_TAB
    stosd
;------------------------------------------------
;       * * *  Set StorePath
;------------------------------------------------
    mov [StoreBasePath.path], RDI
    mov RSI, RBX
    mov ECX, EDX
    rep movsb

    mov ESI, szStoreDirPath
    mov CL,  STORE_DIR_LENGTH
    rep movsb

    mov [StoreBasePath.name], RDI
    mov CL, STORE_DIR_LENGTH + FILE_EXT_LENGTH + 1
    rep movsb
;------------------------------------------------
;       * * *  Set StoreScan
;------------------------------------------------
    mov [StoreBasePath.dir], RDI
    mov RSI, [StoreBasePath.path]
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
    mov [GroupBasePath.path], RDI
    mov RSI, RBX
    mov ECX, EDX
    rep movsb

    mov ESI, szGroupDirPath
    mov CL,  GROUP_DIR_LENGTH
    rep movsb

    mov [GroupBasePath.name], RDI
    mov CL, GROUP_NAME_LENGTH + FILE_EXT_LENGTH + 1
    rep movsb
;------------------------------------------------
;       * * *  Set GroupScan
;------------------------------------------------
    mov [GroupBasePath.dir], RDI
    mov RSI, [GroupBasePath.path]
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
    mov [UserBasePath.path], RDI
    mov RSI, RBX
    mov ECX, EDX
    rep movsb

    mov RSI, szUserDirPath
    mov CL,  USER_DIR_LENGTH
    rep movsb

    mov [UserBasePath.name], RDI
    add RDI, TEXT_NAME_LENGTH
;------------------------------------------------
;       * * *  Set UserScan
;------------------------------------------------
    mov [UserBasePath.dir], RDI
    mov RSI, [UserBasePath.path]
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
    mov [TestBasePath.path], RDI
;------------------------------------------------
    mov RSI, RBX
    mov ECX, EDX
    rep movsb

    mov ESI, szTestDirPath
    mov CL,  TEST_DIR_LENGTH
    rep movsb

    mov [TestBasePath.name], RDI
    add RDI, TEXT_NAME_LENGTH
;------------------------------------------------
;       * * *  Set TestScan
;------------------------------------------------
    mov [TestBasePath.dir], RDI
    mov RSI, [TestBasePath.path]
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
    mov [TextBasePath.path], RDI
    mov RSI, RBX
    mov ECX, EDX
    rep movsb

    mov ESI, szTextDirPath
    mov CL,  TEXT_DIR_LENGTH
    rep movsb

    mov [TextBasePath.name], RDI
    add RDI, TEXT_NAME_LENGTH
;------------------------------------------------
;       * * *  Set TextScan
;------------------------------------------------
    mov [TextBasePath.dir], RDI
    mov RSI, [TextBasePath.path]
    mov ECX, EDX
    add CL,  TEST_DIR_LENGTH
    rep movsb

    mov AX, '*.'
    stosw
    mov EAX, EXT_TXT
    stosd
    mov [lpSystemBuffer], RDI

    mov RAX, RCX
    inc EAX
    mov [ThreadProcessCtrl], EAX
    mov AL,  48
    sub RSP, RAX
;------------------------------------------------
;
;   * * *  Wait Process
;
;------------------------------------------------
jmpWaitProcess@Processor:
    xor RDX, RDX
    mov DX,  WAIT_PROC_TIMEOUT
    param 1, [RunProcessEvent]
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
    mov RSI, [GetQueuedProcess]
    cmp RSI, [SetQueuedProcess]
        je jmpWaitProcess@Processor

        lodsq

        cmp RSI, [MaxQueuedProcess]
            jb jmpGetProcess@Processor
            mov RSI, [TabQueuedProcess]

jmpGetProcess@Processor:
    mov [lpProcessIoData],  RAX
    mov [GetQueuedProcess], RSI
;------------------------------------------------
;   * * *  Local Year
;------------------------------------------------
    param 1, LocalTime
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
    xor RAX, RAX
    mov AX, [LocalTime.wYear]
    cmp AX, ZERO_YEAR
        jb jmpWaitError@Processor

        sub AX, DELTA_YEAR
        mov [LocalYear], EAX
        mov CL,  10
        div CL
        add AX, '00'
        mov word[gettext FORM_END@], AX
;------------------------------------------------
;   * * *  Get Tester-client
;------------------------------------------------
    xor RAX, RAX
    mov qword[ClientAccess], RAX

    mov RDI, [TableBaseScan.name]
    mov byte[RDI], '\'
;------------------------------------------------
;   * * *  Set TypeBuffer
;------------------------------------------------
    mov RAX, [lpSystemBuffer]
    mov [lpMemBuffer], RAX
    mov [lpSaveBuffer], RAX
;------------------------------------------------
;   * * *  Type HTML-Top
;------------------------------------------------
    mov RBX, [lpProcessIoData]
    lea RDI, [RBX+PORT_IO_DATA.Buffer]
    mov R12, RDI
    xor RCX, RCX
    mov RSI, RCX
    mov CX,  HTTP_HEADER_SIZE
    add RDI, RCX
    mov [lpTypeMemory], RDI

    CopyHtmlSection FORM_STYLE@, FORM_STYLE + FORM_HTML + FORM_HEADER
    mov [lpTypeBuffer], RDI
;------------------------------------------------
;   * * *  Ask POST
;------------------------------------------------
    mov  AL, TEST_NUMBER
    mov RCX, [RBX+PORT_IO_DATA.TotalBytes]
;      jECXz jmpClient@Processor

    cmp ECX, MAX_POST_SIZE
        ja  jmpSysError@Processor

        mov RDI, R12
        mov EBX, [EDI]
        and EBX, METHOD_CASE_UP
        cmp EBX, 'POST'
            jne jmpSysError@Processor
;------------------------------------------------
;   * * *  Get Param 
;------------------------------------------------
jmpGetParam@Processor:
        mov EBX, END_CRLF
        mov  AL, BL

jmpScanAsk@Processor:
        repne scasb
          jne jmpAskError@Processor

              mov RSI, RDI
              dec RSI
              cmp EBX, [RSI]
                  jne jmpScanAsk@Processor
;------------------------------------------------
;   * * *  Copy Option
;------------------------------------------------
jmpAskError@Processor:
    mov   AL, ERR_GET_POST
    test ECX, ECX
         jz jmpSysError@Processor

         mov R12, AskBuffer
         mov RDI, R12
         xor EAX, EAX
         lodsd
         lodsw
         mov R8d, EAX
         sub CX, 3 + 3
         inc RSI
         rep movsb
         mov [RDI], CL
;------------------------------------------------
;   * * *  Get Options
;------------------------------------------------
    mov RDI, AskOption
    mov RSI, R12
    mov RAX, R12
    stosq

jmpScan@Processor:
    mov RBX, RSI
    lodsb
    cmp AL, ' '
        jb jmpEndOption@Processor

    cmp AL, '.'
        jne jmpScan@Processor

        mov RAX, RSI
        stosq

        xor RAX, RAX
        mov [RBX], AL
        jmp jmpScan@Processor

jmpEndOption@Processor:
    xor RAX, RAX
    stosq
    mov [RBX], AL
;------------------------------------------------
;       * * *  Find Ask Process
;------------------------------------------------
    mov RBX, TableClient
    mov EAX, R8d
    cmp  AX, ASK_TableClient
        je jmpRunProcess@Processor
;------------------------------------------------
;       * * *  Get IndexProcess
;------------------------------------------------
    mov RDI, KeyRunProccess
    mov CL,  TOTAL_PROCESS_COUNT
    mov R10, RCX
;------------------------------------------------
    repne scasw
      jne jmpAskError@Processor
;------------------------------------------------
;       * * *  Get IndexProcess
;------------------------------------------------
    sub R10d, ECX
    mov [ClientAccess.Process], R10d
;------------------------------------------------
;       * * *  Find Access Mode
;------------------------------------------------
    xor RAX, RAX
    mov R8,  RAX
    mov CL,  MAX_STRING_LENGTH
    mov RDI, R12

    repnz scasb
;     jnz jmpAskError@Processor

    mov R9, RDI
    sub R9, R12
    dec R9d
    inc EAX
    mov [ClientAccess.Mode], EAX
;------------------------------------------------
;       * * *  Find Access Client
;------------------------------------------------
    mov EBX, TabUsrAccess - ASK_ACCESS_SIZE
    mov R8b, ASK_ACCESS_SIZE

jmpFindMode@Processor:
    add  RBX, R8
    mov  RSI, [RBX]
    mov  AL, ACCESS_DENIED
    test RSI, RSI
         jz jmpSysError@Processor

         lodsb
         cmp EAX, R9d 
             jne jmpFindMode@Processor

             mov RDI, R12
             mov ECX, R9d
             repe cmpsb
              jne jmpFindMode@Processor
;------------------------------------------------
;       * * *  Access Address
;------------------------------------------------
    mov RSI, [lpProcessIoData]
    mov [RSI+PORT_IO_DATA.Client], RBX

    lea  RDI, [RSI+PORT_IO_DATA.Address]
    mov  RSI, [RBX+ASK_ACCESS.Address]
    test RSI, RSI
         jz jmpAccessMode@Processor

         xor RAX, RAX
         mov  AL,[RSI]
         inc EAX
         mov RCX, RAX
         mov  AL, ACCESS_DENIED
         repe cmpsb
          jne jmpSysError@Processor
;------------------------------------------------
;       * * *  Access Mode
;------------------------------------------------
jmpAccessMode@Processor:
    mov RAX, [RBX+ASK_ACCESS.Mode]
    mov [ClientAccess.Mode], EAX

    cmp EAX, R10d
        jb jmpSetSession@Processor
        cmp AL, ACCESS_READ_ONLY
            jb jmpRunIndProc@Processor
;------------------------------------------------
;       * * *  Set Header Session
;------------------------------------------------
jmpSetSession@Processor:
    mov RDI, [lpTypeBuffer]
    xor RCX, RCX
    mov RSI, RCX
    TypeHtmlSection FORM_SCRIPT

    mov RSI, R12
    mov ECX, R9d
    rep movsb
    mov [lpTypeBuffer], RDI 
;------------------------------------------------
;   * * *  Call Process
;------------------------------------------------
jmpRunIndProc@Processor:
    mov RBX, [RunProcModule-8+R10*8]

jmpRunProcess@Processor:
    call RBX
;------------------------------------------------
;   * * *  Process Return
;------------------------------------------------
    xor RCX, RCX
    mov RSI, RCX
    mov ESI, gettext FORM_POST@
    mov  CX, FORM_POST + FORM_YEAR + FORM_END
    test AL, AL
         jz jmpFooter@Processor

    test AL, TEST_END
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
;   * * *  Type to StdOut
;------------------------------------------------
jmpType@Processor:
    sub RDI, [lpTypeMemory]
    mov [Count], EDI
;------------------------------------------------
;   * * *  Local Year
;------------------------------------------------
    param 1, LocalTime
    call [GetLocalTime]
;------------------------------------------------
;   * * *  Type HTML-Header
;------------------------------------------------
    mov RDI, szBuffer
    mov RSI, szTypeForm
    xor RCX, RCX
    mov CL,  HEADER_DATE@
    rep movsb
    call HeaderDateToStr

    TypeHtmlSection HEADER_DATE

    mov ECX, [Count]
    call IntToStr

    CopyHtmlSection HEADER_LENGTH@, HEADER_LENGTH + HEADER_CONNECT

    mov RDX, szBuffer
    mov RCX, RDI
    sub RCX, RDX
;------------------------------------------------
;       * * *  Create Header
;------------------------------------------------
    mov RSI, [lpProcessIoData]
    mov RDI, [lpTypeMemory]
    sub RDI, RCX
    mov RAX, RCX
    add EAX, [Count]
    mov EBX, EAX
    mov [RSI+PORT_IO_DATA.CountBytes], RAX
    mov [RSI+PORT_IO_DATA.WSABuffer.buf], RDI

    mov RSI, RDX
    rep movsb 

    mov ECX, EBX
    mov RSI, [lpProcessIoData]
    jmp jmpSending@Processor
;------------------------------------------------
;       * * *  Create Header
;------------------------------------------------
    mov RSI, [lpProcessIoData]
    xor RCX, RCX   ;    hFile = NULL
    mov RBX, RCX   ;    HTTP_200_OK

jmpCreateHeader@Processor:
    call CreateHttpHeader

    mov RCX, [RSI+PORT_IO_DATA.TotalBytes]

jmpSending@Processor:
    mov RAX, [ServerConfig.SendSize]
    cmp RAX, RCX
        ja jmpSizeRecv@Processor
        mov RCX, RAX
;------------------------------------------------
;       * * *  Sending Form
;------------------------------------------------
jmpSizeRecv@Processor:
    mov [RSI+PORT_IO_DATA.WSABuffer.len], RCX
    mov [RSI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER
    param 3, 0
    mov [RSI+PORT_IO_DATA.TransferredBytes], R8
    mov [RSI+PORT_IO_DATA.TotalBytes], R8
    param 7, R8
    param 6, RSI
    param 5, R8
    inc R8
    param 4, TransBytes
    lea RDX, [RSI+PORT_IO_DATA.WSABuffer]
    param 1, [RSI+PORT_IO_DATA.Socket]
    call [WSASend]
    test EAX, EAX
         jz jmpTabProcess@Processor

         call [WSAGetLastError]
         cmp EAX, ERROR_IO_PENDING
             je jmpTabProcess@Processor
;------------------------------------------------
;       * * *  CloseSocket
;------------------------------------------------
            mov RSI, [lpProcessIoData]
            mov RDI, [RSI+PORT_IO_DATA.TablePort]
            xor RAX, RAX
            mov [RDI], RAX
            param 1, [RSI+PORT_IO_DATA.Socket]
            call [closesocket]

            param 3, MEM_RELEASE
            param 2, 0
            param 1, [lpProcessIoData]
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
    xor RAX, RAX
    param 1, RAX
    mov [ThreadProcessCtrl], EAX
    mov  AL, 48
    add RSP, RAX
    call [ExitThread]
endp
;------------------------------------------------
;   * * *  END  * * *
;------------------------------------------------
