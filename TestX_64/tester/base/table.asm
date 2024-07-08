;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   BASE: Test Get + Add + List + View + Edit (Admin)
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Get Table Test
;------------------------------------------------
proc GetTableTest
;------------------------------------------------
;       * * *  Get Group
;------------------------------------------------
    mov RSI, [AskOption+8]
    call StrToWord
    mov   AL, ERR_GET_GROUP
    test EBX, EBX 
         jz jmpEnd@GetTableTest
;------------------------------------------------
;       * * *  Set GroupPath
;------------------------------------------------
    call OpenUserBase
    test EAX, EAX
         jnz jmpEnd@GetTableTest
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
    InitHtmlSection CSS_VIEW

    mov AL, '.'
    stosb

    mov RSI, [AskOption+8]
    CopyString

    TypeHtmlSection TABLE_GET1

    mov EBX, [UserDataBase.count]
    call WordToStr

    TypeHtmlSection TABLE_GET2
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TABLE_GET_HEAD1

    mov RSI, [GroupBasePath.name]
    movsd
    movsb 

    TypeHtmlSection TABLE_GET_HEAD2

    mov RSI, [UserDataBase.user]
    CopyString

    TypeHtmlSection TABLE_GET_HEAD3
    mov [pTypeBuffer], RDI 
;------------------------------------------------
;       * * *  Get List TestBase
;------------------------------------------------
    param 1, [TestBasePath.dir]
    call GetFileList

;   mov   AL, BASE_TEST + ERR_GET_TEST
    test ECX, ECX
;        jz jmpEnd@GetTableTest
         jz jmpUser@GetTableTest
         mov RAX, [lpMemBuffer]
         mov [lpSaveBuffer], RAX
         mov [Count], ECX
;------------------------------------------------
;       * * *  Selector Tests
;------------------------------------------------
jmpSelScan@GetTableTest:
         mov RSI, [pTableFile]
         lodsq
         mov [pTableFile], RSI

         mov RSI, RAX
         lodsd
         mov RDI, [TestBasePath.name]
         xor RAX, RAX
         lodsb
         mov RCX, RAX
         sub AL,  FILE_EXT_LENGTH + 1
         mov [TestDataBase.pathsize], EAX
;        mov [NameSize], EAX
         rep movsb

;        mov AL, '.'
;        stosb
;        mov EAX, EXT_TEST
;        stosd
;------------------------------------------------
;       * * *  Get Base
;------------------------------------------------
         mov RAX, [lpSaveBuffer]
         mov [lpMemBuffer], RAX
;------------------------------------------------
;       * * *  Read Test
;------------------------------------------------
         param 1, [TestBasePath.path]
         call ReadToBuffer

         mov RDI, [pTypeBuffer]
         test ECX, ECX
              jz jmpNext@GetTableTest
;------------------------------------------------
;       * * *  TestHeader
;------------------------------------------------
              mov RSI, [pReadBuffer]
              lodsd
;             mov [TestDataBase.date], EAX
              xor RAX, RAX
              lodsw
              mov EBX, EAX 
              xor EAX, EAX
              lodsb
              inc EAX
              shl EAX, 2
              add EAX, 2
              mul EBX

              add RSI, TEST_HEADER_SIZE - TEST_HEADER.tests
              add RSI, RAX 
              mov RDX, RSI
              cmp RSI, [lpMemBuffer]
                  jae jmpNext@GetTableTest
;------------------------------------------------
;       * * *  TypeTest
;------------------------------------------------
                  mov RDI, [pTypeBuffer] 
                  xor RCX, RCX
                  mov RSI, RCX

                  TypeHtmlSection TABLE_GET_SEL1

                  mov RSI, [TestBasePath.name]
                  mov ECX, [TestDataBase.pathsize]
;                 mov ECX, [NameSize]
                  mov R9, RSI
                  mov R8, RCX
                  rep movsb 

                  TypeHtmlSection TABLE_GET_SEL2

                  mov AL, '['
                  stosb

                  mov RSI, R9 
                  mov RCX, R8
                  rep movsb 

                  mov AX, '] '
                  stosw

                  mov RSI, RDX
                  CopyString

                  TypeHtmlSection TABLE_GET_SEL3

jmpNext@GetTableTest:
    mov [pTypeBuffer], RDI
    dec [Count]
        jnz jmpSelScan@GetTableTest
;------------------------------------------------
;       * * *  TypeForm
;------------------------------------------------
jmpUser@GetTableTest:
    mov R14,  [UserDataBase.index]
    mov R15d, [UserDataBase.count]
    xor RCX, RCX
    mov RSI, RCX
    mov R13, RCX

    TypeHtmlSection TABLE_GET_FIND
;   mov [pTypeBuffer], RDI 

    mov  EAX, [UserDataBase.count]
    test EAX, EAX
         jnz jmpTabScan@GetTableTest

         TypeHtmlSection TABLE_GET_EMPTY
         jmp jmpTypeEnd@GetTableTest
;------------------------------------------------
;       * * *  TypeUser
;------------------------------------------------
jmpTabScan@GetTableTest:
;   mov RDI, [pTypeBuffer]
    TypeHtmlSection TABLE_GET_ITEM1

    mov R11, RDI
    inc R13d
    mov EAX, R13d
;   call WordToStr
    call ByteToStr

    mov R12,  RDI
    sub R12d, R11d

    TypeHtmlSection TABLE_GET_ITEM2

    mov RSI, R14
    mov RAX, RCX
    lodsd
    mov R14, RSI
    mov RSI, [UserDataBase.user]
    add RSI, RAX
    CopyString

    TypeHtmlSection TABLE_GET_ITEM3

    mov RSI, R11
    mov ECX, R12d
    rep movsb

    TypeHtmlSection TABLE_GET_ITEM4

;   mov [pTypeBuffer], RDI
;   dec [UserDataBase.count]
    dec R15d
        jnz jmpTabScan@GetTableTest
;------------------------------------------------
;       * * *  TypeEnd
;------------------------------------------------
jmpTypeEnd@GetTableTest:
;   xor RCX, RCX
    TypeHtmlSection TABLE_GET_END

;   mov [pTypeBuffer], RDI
;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX

jmpEnd@GetTableTest:
    ret
endp
;------------------------------------------------
;       * * *  Create Group Base  * * *
;------------------------------------------------
proc CreateGroupBase
;------------------------------------------------
;       * * *  Selected User
;------------------------------------------------
    mov  RAX, [AskOption+24]
    test RAX, RAX
         jz jmpListTable@ListGroupBase    ;       TEST_POST
;------------------------------------------------
;       * * *  Get Random Buffers
;------------------------------------------------
    mov RAX, [lpMemBuffer]
    mov [pRandGroup], RAX
    xor RDX, RDX
    mov  DX, MAX_GROUP * 4
    add RAX, RDX
    mov [pRandQuest], RAX
    mov  DX, MAX_QUESTION * 4
    add RAX, RDX
    mov [pRandAnswer], RAX
    mov  DX, MAX_ANSWER * 4
    add RAX, RDX
    mov [lpMemBuffer], RAX
;------------------------------------------------
;       * * *  Get BaseTest
;------------------------------------------------
    mov RBX, [AskOption+16]
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@CreateGroupBase
;------------------------------------------------
;       * * *  Get Group
;------------------------------------------------
    mov RSI, [AskOption+8]
    call StrToWord

    mov   AL, ERR_GET_GROUP
    test EBX, EBX 
         jz jmpEnd@CreateGroupBase
;------------------------------------------------
;       * * *  Set GroupPath
;------------------------------------------------
    mov RDI, IndexDataBase
    xor RAX, RAX
    stosd

    inc EAX
    stosd

    mov EAX, EBX
    stosd
;   mov [IndexDataBase.group], EBX

    xor RAX, RAX
;   stosq
    mov [RDI], RAX
;   mov [IndexDataBase.attribute], EAX

;   mov EBX, [IndexDataBase.group]
    call OpenUserBase

    test EAX, EAX
         jnz jmpEnd@CreateGroupBase
;------------------------------------------------
;       * * *  Create IndexField
;------------------------------------------------
    mov RDI, [lpMemBuffer]
    mov [pTextBuffer], RDI
    xor RAX, RAX
    stosq    ;    INDEX_HEADER_SIZE
    stosw

    mov [lpMemBuffer], RDI
    param 1, [IndexBasePath]
    call ReadToBuffer

    mov RBX, RCX
    xor RCX, RCX
    mov ECX, [TestDataBase.pathsize]
    mov R9,  RCX
;   mov RSI, [TestBasePath.name]
    mov R10, [AskOption+16]
    mov RSI, R10
;------------------------------------------------
;   * * *  Add BaseName
;------------------------------------------------
    test EBX, EBX
         jnz jmpCopyTest@CreateGroupBase
         mov R12, [pTextBuffer]
         lea RDI, [R12+INDEX_HEADER_SIZE+2]
         rep movsb
         rep stosb

;        mov [lpMemBuffer], RDI
         mov R12, RDI
         jmp jmpBaseName@CreateGroupBase
;------------------------------------------------
;   * * *  Add BaseName
;------------------------------------------------
jmpCopyTest@CreateGroupBase:
    mov R12, [lpMemBuffer]
    rep movsb

;   mov [lpMemBuffer], RDI
    mov R12, RDI
;------------------------------------------------
;   * * *  Set BaseName
;------------------------------------------------
    mov R15, [pReadBuffer]
    mov RSI, R15
;   mov RDI, RSI
    xor RAX, RAX
    lodsw

    mov EDX, EAX
    inc EDX
    mov [IndexDataBase.session], EDX
    mov CL,  INDEX_HEADER_SIZE
    mul ECX
    mov RDX, RSI
    add RDX, RAX
    sub EBX, EAX
    dec EBX
    mov [R15], BX
;   mov [RDI], BX
;   mov [IndexDataBase.testname], EBX
    inc R9d  ;  Ind
;------------------------------------------------
;   * * *  Find BaseName
;------------------------------------------------
jmpFindTest@CreateGroupBase:
;   mov RDX, [TestBasePath.name]
    mov RSI, R10
    mov ECX, R9d
    cmp ECX, EBX
        ja jmpBaseName@CreateGroupBase
        mov RDI, RDX  
        inc RDX
        dec EBX
        repe cmpsb
         jne jmpFindTest@CreateGroupBase
;            mov RSI, [pReadBuffer]
             inc EBX
             sub [R15], BX
             sub R12, R9

jmpBaseName@CreateGroupBase:
    mov [lpMemBuffer], R12
    sub R12, [pTextBuffer]
    mov [BaseSize], R12
;------------------------------------------------
;       * * *  Create DirTable
;------------------------------------------------
    mov RDI, [TableBasePath.session]
    mov EBX, [IndexDataBase.session]
    call IndexToStr

    mov RDI, [TableBaseScan.dir]
    mov RSI, [TableBasePath.session]
    movsd
    movsb

    xor RAX, RAX
    param 2, RAX
    mov [RDI], AL
;   mov [IndexDataBase.count], EAX
;   xor RAX, RAX
    mov  AL, 32   ;   for 4 + 0
    sub RSP, RAX
;   param 2, 0
    param 1, [TableBaseScan.path]
    call [CreateDirectory]

    mov RDX, RAX
    xor RAX, RAX
    mov  AL, 32
    add RSP, RAX
    mov  AL, BASE_TABLE + ERR_DIRECTORY
    test EDX, EDX
         jz jmpEnd@CreateGroupBase
;------------------------------------------------
;       * * *  Create TableHeader
;------------------------------------------------
    mov RDI, [lpMemBuffer]
    mov [lpSaveBuffer], RDI     ;   pTableBase

    xor RAX, RAX
    mov EAX, [IndexDataBase.session]
    stosw

    mov EAX, [IndexDataBase.group]
    stosw

    mov EAX, [TestDataBase.time]
    stosw

    mov EAX, [TestDataBase.tests]
    stosw                       ;   questions
    mov RBX, RAX
;   mov [TableDataBase.tests], EAX

    mov EAX, [TestDataBase.answers]
    stosb

    add EAX, 2
    mov [TableDataBase.fieldsize], EAX
    mul EBX

    shl EBX, 1
    add EBX, EAX
    mov [TableDataBase.tablesize], EBX
;------------------------------------------------
;       * * *  Clear TableHeader
;------------------------------------------------
    mov [pTableUser], RDI
;   mov RCX, TABLE_HEADER_CLEAR
    xor RAX, RAX
    mov RCX, RAX
    inc RDI    ;       user
    stosq      ;       start
;   stosd      ;       close
    stosw      ;       total
    stosb      ;       score

    mov [TableDataBase.index], RDI
;------------------------------------------------
;       * * *  Clear TestData
;------------------------------------------------
    mov RCX, RBX
    xor EAX, EAX
    rep stosb

    mov RSI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb
;------------------------------------------------
;       * * *  Clear RandTablePath
;------------------------------------------------
;   mov [lpMemBuffer], RDI
    sub RDI, [lpMemBuffer]
    mov [FileSize], RDI
    mov RDI, [pRandGroup]
;   xor EAX, EAX
    mov EAX, ECX
    mov  CX, MAX_GROUP
    rep stosd
;------------------------------------------------
;       * * *  DateRandom
;------------------------------------------------
    call [GetTickCount]
    add [DateRandom], EAX

    mov RAX, [AskOption+24]
    mov [pFind], RAX
;------------------------------------------------
;       * * *  Scan TableBase
;------------------------------------------------
;   R9w  = Check
;   R10d = IndexQuest
;   R11  = pRandAnswer
;   R12  = pRandQuest
;   R13  = pTable
;   R14d = TestDataBase.answers
;   R15d = TestDataBase.tests
;------------------------------------------------
jmpTabScan@CreateGroupBase:
    mov RSI, [pFind]
    call StrToWord

    test EAX, EAX
         jz jmpRegister@CreateGroupBase
         mov [pFind], RSI

         test EAX, EAX
              jz jmpTabError@CreateGroupBase

         cmp EAX, [UserDataBase.count]
             ja jmpTabError@CreateGroupBase
;------------------------------------------------
;       * * *  Create Table 
;------------------------------------------------
             inc [IndexDataBase.count]
             mov RDI, [pTableUser]
             mov [RDI], AL
             mov RSI, [pRandQuest]
;            mov R12, RSI
             mov R13, RSI
             xor RCX, RCX
             mov ECX, [TestDataBase.tests]
             mov EBX, [TestDataBase.questions]
             mov R15, RCX
             call GetRandValue

             mov RDI, [TableDataBase.index]
             mov ECX, [TableDataBase.tablesize]
             mov R14, RDI
             xor RAX, RAX
             rep stosb

;            mov R15d, [TestDataBase.tests]
;            mov R13,  [pRandQuest]
;------------------------------------------------
;       * * *  Random Item
;------------------------------------------------
jmpTabItem@CreateGroupBase:
             mov RSI, R13
             lodsd
             mov R13, RSI
             dec EAX
             mov R10d, EAX
             mov RDI, [TestDataBase.index]
             mov ECX, [TestDataBase.fieldsize]
             mul ECX
             add RDI, RAX
             xor RAX, RAX
             mov RCX, RAX
             mov R9,  RAX
             mov R9w,[RDI]        ;     Check
             mov CL,  6 
             add RDI, RCX
             mov ECX, [TestDataBase.answers]
             mov R8d, ECX
             inc ECX
;            xor EAX, EAX
             repnz scasd
             sub R8d, ECX
                 jz jmpTabSkip@CreateGroupBase

                 mov RSI, [pRandAnswer]
;                mov R12, RSI
                 mov ECX, R8d
                 mov EBX, R8d
                 call GetRandValue
;------------------------------------------------
;       * * *  Copy Itme
;------------------------------------------------
;                mov RSI, [pRandAnswer]
                 mov RSI, R12
                 mov RDI, R14    ;       pTable
;                add RDI, 2      ;       NumQuest
                 inc RDI
                 inc RDI
                 mov R8d, EBX

jmpCopyItem@CreateGroupBase:
                 lodsd
                 mov ECX, EAX 
                 xor EBX, EBX
                 inc EBX
                 dec ECX
                 shl EBX, CL 
                 test R9w, BX    ;       Check
                      jz jmpTrue@CreateGroupBase
                      or AL, SET_ITEM_TRUE 

jmpTrue@CreateGroupBase:
                 stosb
                 dec R8d
                     jnz jmpCopyItem@CreateGroupBase
;------------------------------------------------
;       * * *  ItemLoop 
;------------------------------------------------
jmpTabSkip@CreateGroupBase:
;            mov RSI,   R14     ;       pTable
             mov [R14], R10w    ;       IndexQuest
             xor RAX, RAX
             mov EAX, [TableDataBase.fieldsize]
             add R14, RAX       ;       pTable
;            loop jmpTabItem@CreateGroupBase
             dec R15d
                 jnz jmpTabItem@CreateGroupBase
;------------------------------------------------
;       * * *  Set Random TablePath
;------------------------------------------------
             mov EBX, MAX_TABLE_CODE
             mov EAX, [DateRandom]
             xor RDX, RDX
             div EBX
             dec EAX
             add [DateRandom], EAX
             mov EAX, MIN_TABLE_CODE
             cmp EAX, EDX
                 jbe jmpFindRand@CreateGroupBase
                 add EDX, EAX

jmpFindRand@CreateGroupBase:
             mov RBX, [pRandGroup]
             mov RSI, RBX

jmpRandPath@CreateGroupBase:
             lodsd
             test EAX, EAX
                  jz jmpTabPath@CreateGroupBase

                  cmp EAX, EDX
                      jne jmpRandPath@CreateGroupBase

                      inc EDX
                      mov RSI, RBX
                      jmp jmpRandPath@CreateGroupBase
;------------------------------------------------
;       * * *  Path TableDataBase 
;------------------------------------------------
jmpTabPath@CreateGroupBase:
             mov [RSI-4], EDX 
             mov R15d, EDX
             mov EBX, [IndexDataBase.session]
             mov EAX, EDX
             call DataToHash

             mov RDI, [TableBasePath.index]  ;  hash = session % number
             mov EBX, EDX 
             xor EBX, R15d
             call IndexToStr

             mov RDI, [TableBasePath.table]  ;  number
             mov EBX, R15d
             call WordToStr
;------------------------------------------------
;       * * *  Write TableData 
;------------------------------------------------
             param 3, [FileSize]
             param 2, [lpSaveBuffer]   ;    pTableBase
             param 1, [TableBasePath.path]
             call WriteFromBuffer
             cmp RCX, [FileSize]
                 je jmpTabScan@CreateGroupBase
;------------------------------------------------
;       * * *  Type Error 
;------------------------------------------------
jmpTabError@CreateGroupBase:
         mov RDI, [pTypeBuffer]
         mov AX,  CHR_CRLF
         stosw

         mov RSI, [TableBasePath.path]
         mov CL,  szIndexDirPath - szTablePath
         rep movsb

         mov EAX, '<br>'
         stosd
;------------------------------------------------
;       * * *  QuestLoop 
;------------------------------------------------
         mov [pTypeBuffer], RDI 
         jmp jmpTabScan@CreateGroupBase
;------------------------------------------------
;       * * *  WriteRegister

;------------------------------------------------
jmpRegister@CreateGroupBase:
    call GetBaseTime
    mov  ECX, [IndexDataBase.count]
    test ECX, ECX
;        jz jmpEnd@CreateGroupBase    ;       TEST_POST
         jz jmpListTable@ListGroupBase
;------------------------------------------------
;       * * *  WriteRegister
;------------------------------------------------
         mov R10, [pTextBuffer]
         mov RDI, R10
         mov RSI, IndexDataBase.session
;        mov EAX, [IndexDataBase.session]
         lodsd
         stosw
;        mov [IndexDataBase.fields], AX

         lodsd
         stosw
;        mov [IndexDataBase.group], AX

         mov EAX, EDX
         stosd
;        mov [IndexDataBase.date], EAX

         mov EAX, ECX
         stosb
;        mov [IndexDataBase.count], AL

         xor EAX, EAX
;        stosb
         mov [RDI], AL
;        mov [IndexDataBase.attribute], AL
;------------------------------------------------
;       * * *  Write Register
;------------------------------------------------
         param 3, [BaseSize]
         param 2, R10
         param 1, [IndexBasePath]
         call WriteFromBuffer

         mov EBX, [IndexDataBase.group]
         cmp RCX, [BaseSize]
             je jmpGroupTable@ListGroupBase
             mov AL, BASE_INDEX + ERR_WRITE
;------------------------------------------------
;   * * *  End 
;------------------------------------------------
jmpEnd@CreateGroupBase:
    ret
endp
;------------------------------------------------
;       * * *  List Group Tables  * * *
;------------------------------------------------
proc ListGroupBase
;------------------------------------------------
;       * * *  Get Group
;------------------------------------------------
jmpListTable@ListGroupBase:
    mov RSI, [AskOption+8]
    call StrToWord

    mov   AL, ERR_GET_GROUP
    test EBX, EBX 
         jz jmpEnd@ListGroupBase
;------------------------------------------------
;       * * *  Set GroupPath
;------------------------------------------------
    mov [IndexDataBase.group], EBX

jmpGroupTable@ListGroupBase:
    call OpenUserBase

    test EAX, EAX
         jnz jmpEnd@ListGroupBase
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
    InitHtmlSection CSS_VIEW
    SetHtmlSection TABLE_LIST_HEAD1

    mov EAX, [ClientAccess.Mode]
    cmp  AL, ACCESS_READ_ONLY
        jb jmpAdd@ListGroupBase

        mov CX, TABLE_LIST_HEAD1 + TABLE_LIST_HEAD2
        rep movsb 

        mov RSI, [AskOption+8]
        CopyString

        TypeHtmlSection TABLE_LIST_HEAD3

jmpAdd@ListGroupBase:
    rep movsb 

    TypeHtmlSection TABLE_LIST_HEAD4

    mov RSI, [AskOption+8]
    CopyString

    TypeHtmlSection TABLE_LIST_HEAD5
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TABLE_LIST_HEAD6

    mov RSI, [GroupBasePath.name]
    movsd
    movsb

    TypeHtmlSection TABLE_LIST_HEAD7

    mov RSI, [UserDataBase.user]
    CopyString

    TypeHtmlSection TABLE_LIST_HEAD8

    mov EAX, [UserDataBase.count]
;   call WordToStr
    call ByteToStr

    TypeHtmlSection TABLE_LIST_DATE

    mov ECX, [UserDataBase.date] 
    mov R11d, ECX  
    call StrDate

    TypeHtmlSection TABLE_LIST_TIME

    mov ECX, R11d 
    call StrTime

    TypeHtmlSection TABLE_LIST_HEAD9
    mov [pTypeBuffer], RDI
;------------------------------------------------
;       * * *  Get BaseTest
;------------------------------------------------
    param 1, [IndexBasePath]
    call ReadToBuffer
    test ECX, ECX
         jz jmpEmpty@ListGroupBase
;------------------------------------------------
;       * * *  FormItems
;------------------------------------------------
         mov RSI, [pReadBuffer]
         xor RAX, RAX
         mov RBX, RAX
         mov [Count], EAX
         lodsw
;        mov [IndexDataBase.fields], EAX
         mov [IndexDataBase.session], EAX
         mov [pFind], RSI
         mov BL, INDEX_HEADER_SIZE
         mul EBX
         add RAX, RSI
         mov [pTextBuffer], RAX

         mov RAX, [lpMemBuffer]
         mov [lpSaveBuffer], RAX
;------------------------------------------------
;       * * *  Scan Folder
;------------------------------------------------
jmpTabScan@ListGroupBase:
         mov RSI, [pFind]
         mov RDI, IndexDataBase.group
         xor EAX, EAX
         lodsw
;        cmp EAX, [IndexDataBase.group]
         cmp EAX, [RDI]  ; IF == USER
             jne jmpNext@ListGroupBase

             stosd
;            mov [IndexDataBase.group], EAX

             movsd
;            mov [IndexDataBase.date], EAX

             xor RAX, RAX
             lodsb
             stosd
;            mov [IndexDataBase.count], EAX

             lodsb
             stosd
;            mov [IndexDataBase.attribute], EAX
             test AL, TABLE_STATUS_DELETE
                  jnz jmpNext@ListGroupBase

             lodsw
             add RAX, [pTextBuffer]
             mov RSI, RAX
             mov [RDI], RAX
;            mov [IndexDataBase.name], RAX
;------------------------------------------------
;       * * *  Get TestName
;------------------------------------------------
             mov RDI, [TestBasePath.name]
             CopyString

             mov AL, '.'
             stosb

             mov EAX, EXT_TEST
             stosd
;------------------------------------------------
;       * * *  Get Base
;------------------------------------------------
         mov RAX, [lpSaveBuffer]
         mov [lpMemBuffer], RAX
         inc [Count]
;------------------------------------------------
;       * * *  Read Test
;------------------------------------------------
         param 1, [TestBasePath.path]
         call ReadToBuffer

         mov  RDI, [pTypeBuffer]
         test ECX, ECX
              jz jmpError@ListGroupBase
;------------------------------------------------
;       * * *  TestHeader
;------------------------------------------------
              mov RSI, [pReadBuffer]
              lodsd
;             mov [TestDataBase.date], EAX
              xor RAX, RAX
              lodsw
              mov EBX, EAX 
              xor EAX, EAX
              lodsb
              inc EAX
              shl EAX, 2
              add EAX, 2
              mul BX
              add EAX, TEST_HEADER_SIZE - TEST_HEADER.tests
              cmp EAX, ECX
                  ja jmpError@ListGroupBase
;------------------------------------------------
;       * * *  Type Items
;------------------------------------------------
              add RSI, RAX 
              mov [IndexDataBase.testname], RSI
              xor RCX, RCX
              mov RSI, RCX

              TypeHtmlSection TABLE_LIST_ITEM1

              mov EAX, 'Get('
              mov EDX, [IndexDataBase.attribute]
              test DL, TABLE_STATUS_ARHIVE
                   jz jmpSkip@ListGroupBase
                   mov EAX, 'Set('

jmpSkip@ListGroupBase:
              stosd

              mov EBX, [IndexDataBase.session]
              call WordToStr

              SetHtmlSection TABLE_LIST_ITEM2
              jmp jmpType@ListGroupBase
;------------------------------------------------
;       * * *  ErrorItem Only
;------------------------------------------------
jmpError@ListGroupBase:
         xor RCX, RCX
         SetHtmlSection TEST_GET_ERROR

jmpType@ListGroupBase:
         rep movsb 

         mov EBX, [IndexDataBase.session]
         call IndexToStr

         TypeHtmlSection TABLE_LIST_ITEM3

         mov RSI, [IndexDataBase.testname]
         CopyString

         TypeHtmlSection TABLE_LIST_ITEM4

         mov EAX, [IndexDataBase.count]
;        call WordToStr
         call ByteToStr

         TypeHtmlSection TABLE_LIST_ITEM5

         mov ECX, [IndexDataBase.date]
         call StrDate

         TypeHtmlSection TABLE_LIST_ITEM5

         mov  EDX, [IndexDataBase.attribute]
         test EDX, EDX ; TABLE_STATUS_CREATE
              jz jmpSkipStatus@ListGroupBase
              mov  AL, '+'
              test DL, TABLE_STATUS_ARHIVE
                   jnz jmpTypeStatus@ListGroupBase

;             mov  AL, '-'
;             test DL, TABLE_STATUS_DELETE
;                  jnz jmpTypeStatus@ListGroupBase
                   mov  AL, '?'

jmpTypeStatus@ListGroupBase:
              stosb

jmpSkipStatus@ListGroupBase:
         TypeHtmlSection TABLE_LIST_ITEM6
         mov [pTypeBuffer], RDI

jmpNext@ListGroupBase:
         add [pFind], INDEX_HEADER_SIZE
         dec [IndexDataBase.session]
             jnz jmpTabScan@ListGroupBase
;------------------------------------------------
;       * * *  TableEmpty
;------------------------------------------------
         mov RDI, [pTypeBuffer]
         mov EAX, [Count]
         test EAX, EAX
              jnz jmpAddForm@ListGroupBase
;------------------------------------------------
;       * * *  EmptyForm
;------------------------------------------------
jmpEmpty@ListGroupBase:
    mov RDI, [pTypeBuffer] 
    xor RCX, RCX
    TypeHtmlSection TABLE_LIST_EMPTY
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpAddForm@ListGroupBase:
    mov  CL, TABLE_LIST_END1 + TABLE_LIST_ADD
    mov EAX, [ClientAccess.Mode]
    cmp  AL, ACCESS_READ_WRITE
        jge jmpEndForm@ListGroupBase
        mov CL, TABLE_LIST_END1
;------------------------------------------------
jmpEndForm@ListGroupBase:
    mov RSI, gettext TABLE_LIST_END1@
    rep movsb

    TypeHtmlSection TABLE_LIST_END2
;   mov [pTypeBuffer], RDI
;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX

jmpEnd@ListGroupBase:
    ret 
endp
;------------------------------------------------
;       * * *  Viewer Base Clients  * * *
;------------------------------------------------
proc ViewBaseClients
;------------------------------------------------
;       * * *  Get Session
;------------------------------------------------
    mov RSI, [AskOption+8]
    call StrToWord
    mov   AL, ERR_GET_PART
    test EBX, EBX 
         jz jmpEnd@ViewBaseClients
;------------------------------------------------
;       * * *  Get IndexBase
;------------------------------------------------
;   mov [IndexDataBase.session], EBX
    call OpenIndexBase

    test EAX, EAX
         jnz jmpEnd@ViewBaseClients
;------------------------------------------------
;       * * *  Set TestBase
;------------------------------------------------
;   mov RBX, [IndexDataBase.name]
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@ViewBaseClients
;------------------------------------------------
;       * * *  Set GroupPath
;------------------------------------------------
    mov EBX, [IndexDataBase.group]
    call OpenUserBase

    test EAX, EAX
         jnz jmpEnd@ViewBaseClients
;------------------------------------------------
;       * * *  Get Time
;------------------------------------------------
    call GetBaseTime
    mov RSI, RDX

    call TimeToTick
    mov [Date], ECX
;------------------------------------------------
;       * * *  Scan Table
;------------------------------------------------
;   mov EBX, [IndexDataBase.session]
;   mov EAX, [IndexDataBase.group]
    call GetTableList

    mov R15d, ECX
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
    InitHtmlSection CSS_VIEW
    TypeHtmlSection TABLE_VIEW1

    mov RSI, [TableBasePath.session]
    movsd
    movsb

    TypeHtmlSection TABLE_VIEW2

    mov EBX, [IndexDataBase.group]
    call WordToStr

    TypeHtmlSection TABLE_VIEW3
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TABLE_VIEW_HEAD1

    mov RSI, [GroupBasePath.name]
    movsd
    movsb

    TypeHtmlSection TABLE_VIEW_HEAD2

    mov RSI, [UserDataBase.user]
    CopyString

    TypeHtmlSection TABLE_VIEW_HEAD3

    mov RSI, [TableBasePath.session]
    movsd
    movsb 

    TypeHtmlSection TABLE_VIEW_HEAD4

;   mov RSI, [TestBasePath.name]
;   mov ECX, [TestDataBase.pathsize] 
;   rep movsb 

;   mov AX, ' ]'
;   stosw

    mov RSI, [TestDataBase.text]
    CopyString

    TypeHtmlSection TABLE_VIEW_HEAD5

    mov ECX, [IndexDataBase.date]
    mov R12d, ECX
    call StrDate

    TypeHtmlSection TABLE_VIEW_HEAD6

    mov ECX, R12d
    call StrTime

    TypeHtmlSection TABLE_VIEW_HEAD7
;   mov [pTypeBuffer], RDI
;------------------------------------------------
;       * * *  Empty Item
;------------------------------------------------
    test R15d, R15d
         jnz jmpItems@ViewBaseClients

         TypeHtmlSection TABLE_VIEW_EMPTY
         jmp jmpTableEnd@ViewBaseClients
;------------------------------------------------
;       * * *  Type Items
;------------------------------------------------
jmpItems@ViewBaseClients:
    mov [pTypeBuffer], RDI
    mov RSI,  [pTableFile]
    mov R15d, [UserDataBase.count]
    inc R15d

jmpScanTable@ViewBaseClients:
    lodsq 
    test RAX, RAX
         jz jmpNextTable@ViewBaseClients

         mov R14, RSI
         mov RSI, RAX    ;    pTableBase
         mov RDI, TableDataBase.session

         xor RAX, RAX
         mov RCX, RAX
         lodsw
         stosd
;        mov [TableDataBase.session], EAX

;        mov EAX, ECX
         lodsw
         stosd
;        mov [TableDataBase.group], EAX

;        mov EAX, ECX
         lodsw
         stosd
;        mov [TableDataBase.time], EAX

;        mov EAX, ECX
         lodsw
         stosd
;        mov [TableDataBase.tests], EAX

         mov EAX, ECX
         lodsb
         stosd
;        mov [TableDataBase.items], EAX

;        mov EAX, ECX
         lodsb
         stosd
         mov R12d, EAX
;        mov [TableDataBase.user], EAX

         movsq
;        mov [TableDataBase.close], EAX
;        mov [TableDataBase.start], EAX

         mov EAX, ECX
         lodsw
         stosd
;        mov [TableDataBase.total], EAX

         mov EAX, ECX
         lodsb
;        stosd
         mov [RDI], EAX
;        mov [TableDataBase.score], EAX
         mov RDX, RSI   ;   TABLE_HEAD_SIZE
;------------------------------------------------
;       * * *  Head Item
;------------------------------------------------
         mov RDI, [pTypeBuffer] 
;        xor RCX, RCX
         mov RSI, RCX

         TypeHtmlSection TABLE_VIEW_ITEM1

         mov RSI, RDX
         movsq    ;   TABLE_NAME_LENGTH
         movsw

         mov R11, RSI
         TypeHtmlSection TABLE_VIEW_ITEM2

;        mov EBX, [StoreDataBase.user]
         mov EBX, R12d
         call WordToStr

         TypeHtmlSection TABLE_VIEW_ITEM3

         mov RBX, RCX
;        mov EBX, [StoreDataBase.user]
         mov EBX, R12d
         dec EBX
         mov RSI, [UserDataBase.index]
         mov RAX, RCX
         mov EAX, [RSI+RBX*4]
         mov RSI, [UserDataBase.user]
         add RSI, RAX
         CopyString

         TypeHtmlSection TABLE_VIEW_ITEM4

         mov RSI, R11
         CopyString

         TypeHtmlSection TABLE_VIEW_ITEM5

         mov EBX, [TableDataBase.tests]
         call WordToStr

;        TypeHtmlSection TABLE_VIEW_ITEM6

         mov EAX, '.<b>'
         stosd

         mov EBX, [TableDataBase.total]
         call WordToStr

         TypeHtmlSection TABLE_VIEW_ITEM7

         mov EAX, [TableDataBase.time]
         call StrSecond

         TypeHtmlSection TABLE_VIEW_ITEM8
;------------------------------------------------
;       * * *  Close Item
;------------------------------------------------
         mov EDX, [TableDataBase.close]
         test EDX, EDX
              jz jmpStart@ViewBaseClients

              TypeHtmlSection TABLE_VIEW_CLOSE1

              mov ECX, EDX
              call StrDate

              mov EAX, '<br>'
              stosd

              mov ECX, [TableDataBase.close]
              call StrTime

              TypeHtmlSection TABLE_VIEW_CLOSE2

              mov ECX, [TableDataBase.tests]
              mov EAX, [TableDataBase.total]
              call StrPercent

              TypeHtmlSection TABLE_VIEW_CLOSE3

              mov EBX, [TableDataBase.score]
              call WordToStr

              TypeHtmlSection TABLE_VIEW_CLOSE4
              jmp jmpEndItem@ViewBaseClients
;------------------------------------------------
;       * * *  Start Item
;------------------------------------------------
jmpStart@ViewBaseClients:
         mov ESI, [TableDataBase.start]
         test ESI, ESI
              jz jmpList@ViewBaseClients

              call TimeToTick

              mov EDX, [Date] 
              sub EDX, ECX
              xor RCX, RCX
              mov RSI, RCX

              TypeHtmlSection TABLE_VIEW_START1

              mov EAX, [TableDataBase.time]
              cmp EAX, EDX
                  jb jmpSkipTimer@ViewBaseClients

                  sub EAX, EDX
                  call StrSecond

jmpSkipTimer@ViewBaseClients:
              TypeHtmlSection TABLE_VIEW_START2

              mov EBX, [TableDataBase.session]
              mov R10d, EBX
              call WordToStr

              mov EBX,  [TableDataBase.group]
              sub EBX,  R10d
                  jz jmpSkipTotal@ViewBaseClients

                  mov EAX, '.<b>'
                  stosd
                  call WordToStr
                  mov EAX, '</b>'
                  stosd

jmpSkipTotal@ViewBaseClients:
              TypeHtmlSection TABLE_VIEW_LIST2
              jmp jmpEndItem@ViewBaseClients
;------------------------------------------------
;       * * *  List Item
;------------------------------------------------
jmpList@ViewBaseClients:
         CopyHtmlSection TABLE_VIEW_LIST1@, TABLE_VIEW_LIST1 + TABLE_VIEW_LIST2
;------------------------------------------------
;       * * *  List Item
;------------------------------------------------
jmpEndItem@ViewBaseClients:
    mov [pTypeBuffer], RDI
    mov RSI, R14

jmpNextTable@ViewBaseClients:
    dec R15d
        jnz jmpScanTable@ViewBaseClients
;------------------------------------------------
;       * * *  End Item
;------------------------------------------------
;   xor RCX, RCX
    mov  CL, TABLE_VIEW_END1 + TABLE_VIEW_ARCH

    mov EAX, [ClientAccess.Mode]
    cmp AL,  ACCESS_ADMIN
        je jmpStore@ViewBaseClients

jmpTableEnd@ViewBaseClients:
        mov CL, TABLE_VIEW_END1

jmpStore@ViewBaseClients:
    mov RSI, gettext TABLE_VIEW_END1@
    rep movsb 

    TypeHtmlSection TABLE_VIEW_END2
;   mov [pTypeBuffer], RDI
;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX

jmpEnd@ViewBaseClients:
    ret 
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
