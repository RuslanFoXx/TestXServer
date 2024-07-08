;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
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
    mov ESI, [AskOption+4]
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

    mov ESI, [AskOption+4]
    CopyString

    TypeHtmlSection TABLE_GET1

    mov EBX, [UserDataBase.count]
    call WordToStr

    TypeHtmlSection TABLE_GET2
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TABLE_GET_HEAD1

    mov ESI, [GroupBasePath.name]
    movsd
    movsb

    TypeHtmlSection TABLE_GET_HEAD2

    mov ESI, [UserDataBase.user]
    CopyString

    TypeHtmlSection TABLE_GET_HEAD3
    mov [pTypeBuffer], EDI 
;------------------------------------------------
;       * * *  Get List TestBase
;------------------------------------------------
    mov EDX, [TestBasePath.dir]
    call GetFileList

;   mov   AL, BASE_TEST + ERR_GET_TEST
    test ECX, ECX
;        jz jmpEnd@GetTableTest
         jz jmpUser@GetTableTest
         mov EAX, [lpMemBuffer]
         mov [lpSaveBuffer], EAX
         mov ESI, [pTableFile]
;        mov [pFind], ESI
;------------------------------------------------
;       * * *  Selector Tests
;------------------------------------------------
jmpSelScan@GetTableTest:
         lodsd
         push ECX
         push ESI
;        mov ESI, [pFind]
         mov ESI, EAX
         lodsd
         mov EDI, [TestBasePath.name]
         xor EAX, EAX
         lodsb
         mov ECX, EAX
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
         mov EAX, [lpSaveBuffer]
         mov [lpMemBuffer], EAX
;------------------------------------------------
;       * * *  Read Test
;------------------------------------------------
         mov EDX, [TestBasePath.path]
         call ReadToBuffer

         mov  EDI, [pTypeBuffer]
         test ECX, ECX
              jz jmpNext@GetTableTest
;------------------------------------------------
;       * * *  TestHeader
;------------------------------------------------
              mov ESI, [pReadBuffer]
              lodsd
;             mov [TestDataBase.date], EAX
              xor EAX, EAX
              lodsw
              mov EBX, EAX 
              xor EAX, EAX
              lodsb
              inc EAX
              shl EAX, 2
              add EAX, 2
              mul EBX
              add ESI, TEST_HEADER_SIZE - TEST_HEADER.tests
              add ESI, EAX 
              mov EDX, ESI
              cmp ESI, [lpMemBuffer]
                  jae jmpNext@GetTableTest
;------------------------------------------------
;       * * *  TypeTest
;------------------------------------------------
                  mov EDI, [pTypeBuffer] 
                  xor ECX, ECX

                  TypeHtmlSection TABLE_GET_SEL1

                  mov ESI, [TestBasePath.name]
                  mov ECX, [TestDataBase.pathsize]
;                 mov ECX, [NameSize]
                  mov EBX, ECX
                  rep movsb 

                  TypeHtmlSection TABLE_GET_SEL2 

                  mov AL, '['
                  stosb

                  mov ESI, [TestBasePath.name]
                  mov ECX, EBX
                  rep movsb 

                  mov AX, '] '
                  stosw

                  mov ESI, EDX
                  CopyString

                  TypeHtmlSection TABLE_GET_SEL3
;------------------------------------------------
jmpNext@GetTableTest:
    mov [pTypeBuffer], EDI
    pop ESI
    pop ECX
    dec ECX
        jnz jmpSelScan@GetTableTest
;------------------------------------------------
;       * * *  TypeForm
;------------------------------------------------
jmpUser@GetTableTest:
    xor ECX, ECX
    mov [Ind], ECX

    TypeHtmlSection TABLE_GET_FIND
;   mov [pTypeBuffer], EDI 

    mov  EAX, [UserDataBase.count]
    test EAX, EAX
         jnz jmpTabScan@GetTableTest

         TypeHtmlSection TABLE_GET_EMPTY
         jmp jmpTypeEnd@GetTableTest
;------------------------------------------------
;       * * *  TypeUser
;------------------------------------------------
jmpTabScan@GetTableTest:
;   mov EDI, [pTypeBuffer]
    TypeHtmlSection TABLE_GET_ITEM1

    push EDI
    mov EAX, [Ind]
    inc EAX
    mov [Ind], EAX
;   call WordToStr
    call ByteToStr

    mov EDX, EDI
    pop EBX
    sub EDX, EBX

    TypeHtmlSection TABLE_GET_ITEM2

    mov ESI, [UserDataBase.index]
    lodsd
    mov [UserDataBase.index], ESI  

    mov ESI, [UserDataBase.user]
    add ESI, EAX
    CopyString
;------------------------------------------------
    TypeHtmlSection TABLE_GET_ITEM3
;------------------------------------------------
    mov ESI, EBX
    mov ECX, EDX
    rep movsb

    TypeHtmlSection TABLE_GET_ITEM4

;   mov [pTypeBuffer], EDI
    dec [UserDataBase.count]
        jnz jmpTabScan@GetTableTest
;------------------------------------------------
;       * * *  TypeEnd
;------------------------------------------------
jmpTypeEnd@GetTableTest:
;   xor ECX, ECX
    TypeHtmlSection TABLE_GET_END

;   mov [pTypeBuffer], EDI
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
    mov  EAX, [AskOption+12]
    test EAX, EAX
         jz  jmpListTable@ListGroupBase
;------------------------------------------------
;       * * *  Get Random Buffers
;------------------------------------------------
    mov EAX, [lpMemBuffer]
    mov [pRandGroup], EAX
    add EAX, MAX_GROUP * 4
    mov [pRandQuest], EAX 
    add EAX, MAX_QUESTION * 2
    mov [pRandAnswer], EAX
    add EAX, MAX_ANSWER * 2
    mov [lpMemBuffer], EAX
;------------------------------------------------
;       * * *  Get BaseTest
;------------------------------------------------
    mov EBX, [AskOption+8]
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@CreateGroupBase
;------------------------------------------------
;       * * *  Get Group
;------------------------------------------------
    mov ESI, [AskOption+4]
    call StrToWord

    mov   AL, ERR_GET_GROUP
    test EBX, EBX 
         jz jmpEnd@CreateGroupBase
;------------------------------------------------
;       * * *  Set GroupPath
;------------------------------------------------
    mov EDI, IndexDataBase
    xor EAX, EAX
    stosd

    inc EAX
    stosd
    mov EAX, EBX
    stosd
;   mov [IndexDataBase.group], EBX

    xor EAX, EAX
    stosd
    stosd
;   stosd
    mov [EDI], EAX
;   mov [IndexDataBase.attribute], EAX
;   mov EBX, [IndexDataBase.group]
    call OpenUserBase

    test EAX, EAX
         jnz jmpEnd@CreateGroupBase
;------------------------------------------------
;       * * *  Create IndexField
;------------------------------------------------
    mov EDI, [lpMemBuffer]
    mov [pTextBuffer], EDI
    xor EAX, EAX
    stosd    ;    INDEX_HEADER_SIZE
    stosd
    stosw

    mov [lpMemBuffer], EDI

    mov EDX, [IndexBasePath]
    call ReadToBuffer

    mov EBX, ECX
;   mov ESI, [TestBasePath.name]
    mov ESI, [AskOption+8]
    mov EAX, [TestDataBase.pathsize]
    mov ECX, EAX
    inc EAX
    mov [Ind], EAX
    test EBX, EBX
         jnz jmpCopyTest@CreateGroupBase
         mov EDI, [pTextBuffer]
         add EDI, INDEX_HEADER_SIZE + 2
         rep movsb

         mov [lpMemBuffer], EDI
         jmp jmpBaseName@CreateGroupBase
;------------------------------------------------
;   * * *  Add BaseName
;------------------------------------------------
jmpCopyTest@CreateGroupBase:
    mov EDI, [lpMemBuffer]
    rep movsb
    mov [lpMemBuffer], EDI
;------------------------------------------------
;   * * *  Set BaseName
;------------------------------------------------
    mov ESI, [pReadBuffer]
    mov EDI, ESI
    xor EAX, EAX
    lodsw

    mov EDX, EAX
    inc EDX
    mov [IndexDataBase.session], EDX

    mov CL,  INDEX_HEADER_SIZE
    mul ECX
    mov EDX, ESI
    add EDX, EAX
    sub EBX, EAX
    dec EBX
    mov [EDI], BX
;   mov [IndexDataBase.testname], EBX
;------------------------------------------------
;   * * *  Find BaseName
;------------------------------------------------
jmpFindTest@CreateGroupBase:
;   mov EDX, [TestBasePath.name]
    mov ESI, [AskOption+8]
    mov ECX, [Ind]
    cmp ECX, EBX
        ja jmpBaseName@CreateGroupBase
        mov EDI, EDX  
        inc EDX
        dec EBX
        repe cmpsb
         jne jmpFindTest@CreateGroupBase
             mov ESI, [pReadBuffer]
             inc EBX
             sub [ESI], BX
             mov EAX, [Ind]
             sub [lpMemBuffer], EAX
;------------------------------------------------
jmpBaseName@CreateGroupBase:
    mov EAX, [lpMemBuffer]
    sub EAX, [pTextBuffer]
    mov [BaseSize], EAX
;------------------------------------------------
;       * * *  Create DirTable
;------------------------------------------------
    mov EDI, [TableBasePath.session]
    mov EBX, [IndexDataBase.session]
    call IndexToStr

    mov EDI, [TableBaseScan.dir]
    mov ESI, [TableBasePath.session]
    movsd
    movsb

    xor EAX, EAX
    mov [EDI], AL
;   xor EAX, EAX
    push EAX
    push [TableBaseScan.path]
    call [CreateDirectory]

    mov  EDX, EAX
    mov   AL, BASE_TABLE + ERR_DIRECTORY
    test EDX, EDX
         jz jmpEnd@CreateGroupBase
;------------------------------------------------
;       * * *  Create TableHeader
;------------------------------------------------
    mov EDI, [lpMemBuffer]
    mov [lpSaveBuffer], EDI     ;   pTableBase
    mov EAX, [IndexDataBase.session]
    stosw

    mov EAX, [IndexDataBase.group]
    stosw

    mov EAX, [TestDataBase.time]
    stosw

    mov EAX, [TestDataBase.tests]
    stosw                       ;   questions
    mov EBX, EAX
;   mov [TableDataBase.tests], EAX

    mov EAX, [TestDataBase.answers]
    stosb

    add EAX, 2
    mov [TableDataBase.fieldsize], EAX
    mul EBX  ;   FieldSize

    shl EBX, 1
    add EBX, EAX
    mov [TableDataBase.tablesize], EBX
;------------------------------------------------
;       * * *  Clear TableHeader
;------------------------------------------------
    mov [pTableUser], EDI
;   mov ECX, TABLE_HEADER_CLEAR
    xor EAX, EAX
    inc EDI    ;       user
    stosd      ;       start
    stosd      ;       close
    stosw      ;       total
    stosb      ;       score

    mov [TableDataBase.index], EDI
;------------------------------------------------
;       * * *  Clear TestData
;------------------------------------------------
    mov ECX, EBX
    xor EAX, EAX
    rep stosb

    mov ESI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb
;------------------------------------------------
;
;       * * *  Clear RandTablePath
;
;------------------------------------------------
;   mov [lpMemBuffer], EDI
    sub EDI, [lpMemBuffer]
    mov [FileSize], EDI

    mov EDI, [pRandGroup]
;   xor EAX, EAX
    mov EAX, ECX
    mov  CX, MAX_GROUP
    rep stosd
;------------------------------------------------
;       * * *  DateRandom
;------------------------------------------------
;   mov [mrTablePath + BASE_DIR_LENGTH + BASE_NAME_LENGTH], '\'

    call [GetTickCount]
 
    add [DateRandom], EAX
    mov ESI, [AskOption+12]
;------------------------------------------------
;       * * *  Scan TableBase
;------------------------------------------------
jmpTabScan@CreateGroupBase:
    call StrToWord
;------------------------------------------------
    test EAX, EAX
         jz jmpRegister@CreateGroupBase

         push ESI
         test EAX, EAX
              jz jmpTabError@CreateGroupBase

         cmp EAX, [UserDataBase.count]
             ja jmpTabError@CreateGroupBase
;------------------------------------------------
;       * * *  Create Table 
;------------------------------------------------
             inc [IndexDataBase.count]
             mov EDI, [pTableUser]
             mov [EDI], AL

             mov ESI, [pRandQuest]
             mov EBX, [TestDataBase.questions]
             mov ECX, [TestDataBase.tests]
             call GetRandValue

             mov EDI, [TableDataBase.index]
             mov ECX, [TableDataBase.tablesize]
             mov [pFind], EDI
             xor EAX, EAX
             rep stosb

             mov ECX, [TestDataBase.tests]
             mov ESI, [pRandQuest]
;------------------------------------------------
;       * * *  Random Item
;------------------------------------------------
jmpTabItem@CreateGroupBase:
;            xor EAX, EAX
             lodsd
             dec EAX
             push ECX
             push ESI
             push EAX        ;       IndexQuest
             mov EDI, [TestDataBase.index]
             mov ECX, [TestDataBase.fieldsize]
             mul ECX
             add EDI, EAX
             xor EAX, EAX
             mov AX, [EDI] 
             mov [Ind], EAX  ;       Check

             mov EDX, [TestDataBase.answers]
             mov ECX, EDX 
             add EDI, 6

             inc ECX
             xor EAX, EAX
             repnz scasd
             sub EDX, ECX
                 jz jmpTabSkip@CreateGroupBase
                 mov ESI, [pRandAnswer]
                 mov ECX, EDX
                 mov EBX, EDX
                 call GetRandValue
;------------------------------------------------
;       * * *  Copy Itme
;------------------------------------------------
                 mov ESI, [pRandAnswer]
                 mov EDI, [pFind]
                 mov EDX, [Ind]
;                add EDI, 2      ;       NumQuest
                 inc EDI
                 inc EDI
                 mov ECX, EBX

jmpCopyItem@CreateGroupBase:
;                xor EAX, EAX
                 lodsd

                 push ECX
                 mov ECX, EAX 
                 xor EBX, EBX
                 inc EBX
                 dec ECX
                 shl EBX, CL 

                 test DX, BX
                      jz jmpTrue@CreateGroupBase
                      or AL, SET_ITEM_TRUE 

jmpTrue@CreateGroupBase:
                 stosb

                 pop ECX
                 loop jmpCopyItem@CreateGroupBase
;------------------------------------------------
;       * * *  ItemLoop 
;------------------------------------------------
jmpTabSkip@CreateGroupBase:
             mov ESI, [pFind]
             pop EAX            ;       IndexQuest
             mov [ESI], AX
             add ESI, [TableDataBase.fieldsize]
             mov [pFind], ESI

             pop ESI
             pop ECX
;            loop jmpTabItem@CreateGroupBase
             dec ECX
                 jnz jmpTabItem@CreateGroupBase
;------------------------------------------------
;       * * *  Set Random TablePath
;------------------------------------------------
             mov EBX, MAX_TABLE_CODE
             mov EAX, [DateRandom]
             xor EDX, EDX
             div EBX
             dec EAX
             add [DateRandom], EAX
             mov EAX, MIN_TABLE_CODE
             cmp EAX, EDX
                 jbe jmpFindRand@CreateGroupBase
                 add EDX, EAX

jmpFindRand@CreateGroupBase:
             mov EBX, [pRandGroup]
             mov ESI, EBX

jmpRandPath@CreateGroupBase:
             lodsd
             test EAX, EAX
                  jz jmpTabPath@CreateGroupBase

                  cmp EAX, EDX
                      jne jmpRandPath@CreateGroupBase
                      inc EDX
                      mov ESI, EBX
                      jmp jmpRandPath@CreateGroupBase
;------------------------------------------------
;       * * *  Path TableDataBase 
;------------------------------------------------
jmpTabPath@CreateGroupBase:
             mov [ESI-4], EDX 
             push EDX
             push EDX
             mov EBX, [IndexDataBase.session]
             mov EAX, EDX
             call DataToHash

             mov EDI, [TableBasePath.index]  ;  hash = part % number
             pop EAX
             mov EBX, EDX
             xor EBX, EAX
             call IndexToStr

             mov EDI, [TableBasePath.table]  ;  number
             pop EBX
             call WordToStr
;------------------------------------------------
;       * * *  Write TableData 
;------------------------------------------------
             push [FileSize]
             push [lpSaveBuffer]    ;    pTableBase 
             mov  EDX, [TableBasePath.path]
             call WriteFromBuffer

             cmp ECX, [FileSize]
                 je jmpTabNext@CreateGroupBase
;------------------------------------------------
;       * * *  Type Error 
;------------------------------------------------
jmpTabError@CreateGroupBase:
         mov EDI, [pTypeBuffer]
         mov AX,  CHR_CRLF
         stosw

         mov ESI, [TableBasePath.path]
         mov CL,  szIndexDirPath - szTablePath
         rep movsb

         mov EAX, '<br>'
         stosd

         mov [pTypeBuffer], EDI 
;------------------------------------------------
;       * * *  QuestLoop 
;------------------------------------------------
jmpTabNext@CreateGroupBase:
    pop ESI
    jmp jmpTabScan@CreateGroupBase
;------------------------------------------------
;       * * *  Register TableBase
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
         mov ESI, IndexDataBase.session
         mov EDI, [pTextBuffer]
         push [BaseSize]
         push EDI

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
         mov [EDI], AL
;        mov [IndexDataBase.attribute], AL
;------------------------------------------------
;       * * *  Write Register
;------------------------------------------------
;        push [BaseSize]
;        push [pTextBuffer]
         mov  EDX, [IndexBasePath]
         call WriteFromBuffer

         mov EBX, [IndexDataBase.group]
         cmp ECX, [BaseSize]
             je jmpGroupTable@ListGroupBase
             mov AL, BASE_INDEX + ERR_WRITE

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

    mov ESI, [AskOption+4]
    call StrToWord

    mov   AL, ERR_GET_GROUP
    test EBX, EBX 
         jz jmpEnd@ListGroupBase
;------------------------------------------------
;       * * *  Set GroupPath
;------------------------------------------------
    mov [IndexDataBase.group], EBX
;------------------------------------------------
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
    cmp AL,  ACCESS_READ_ONLY
        jb jmpAdd@ListGroupBase

        mov CX, TABLE_LIST_HEAD1 + TABLE_LIST_HEAD2
        rep movsb 

        mov ESI, [AskOption+4]
        CopyString

        TypeHtmlSection TABLE_LIST_HEAD3
;------------------------------------------------
jmpAdd@ListGroupBase:
    rep movsb 

    TypeHtmlSection TABLE_LIST_HEAD4

    mov ESI, [AskOption+4]
    CopyString

    TypeHtmlSection TABLE_LIST_HEAD5
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TABLE_LIST_HEAD6

    mov ESI, [GroupBasePath.name]
    movsd
    movsb

    TypeHtmlSection TABLE_LIST_HEAD7

    mov ESI, [UserDataBase.user]
    CopyString

    TypeHtmlSection TABLE_LIST_HEAD8

    mov EAX, [UserDataBase.count]
;   call WordToStr
    call ByteToStr

    TypeHtmlSection TABLE_LIST_DATE

    mov ECX, [UserDataBase.date] 
    push ECX
    call StrDate

    TypeHtmlSection TABLE_LIST_TIME

    pop ECX
    call StrTime

    TypeHtmlSection TABLE_LIST_HEAD9
    mov [pTypeBuffer], EDI
;------------------------------------------------
;       * * *  Get BaseTest
;------------------------------------------------
    mov EDX, [IndexBasePath]
    call ReadToBuffer

    test ECX, ECX
         jz jmpEmpty@ListGroupBase
;------------------------------------------------
;       * * *  FormItems
;------------------------------------------------
         mov ESI, [pReadBuffer]
         xor EAX, EAX
         mov [Count], EAX

         lodsw
;        mov [IndexDataBase.fields], EAX
         mov [IndexDataBase.session], EAX
         mov [pFind], ESI

         mov EBX, INDEX_HEADER_SIZE
         mul EBX
         add EAX, ESI
         mov [pTextBuffer], EAX

         mov EAX, [lpMemBuffer]
         mov [lpSaveBuffer], EAX
;------------------------------------------------
;       * * *  Scan Folder
;------------------------------------------------
jmpTabScan@ListGroupBase:
         mov ESI, [pFind]
         mov EDI, IndexDataBase.group
         xor EAX, EAX
         lodsw
;        cmp EAX, [IndexDataBase.group]
         cmp EAX, [EDI]  ; IF == USER
             jne jmpNext@ListGroupBase
             stosd
;            mov [IndexDataBase.group], EAX
             movsd
;            mov [IndexDataBase.date], EAX
             xor EAX, EAX
             lodsb
             stosd
;            mov [IndexDataBase.count], EAX
             lodsb
             stosd
;            mov [IndexDataBase.attribute], EAX
             test AL, TABLE_STATUS_DELETE
                  jnz jmpNext@ListGroupBase

             lodsw
             add EAX, [pTextBuffer]
             mov ESI, EAX
             mov [EDI], EAX
;            mov [IndexDataBase.name], EAX
;------------------------------------------------
;       * * *  Get TestName
;------------------------------------------------
             mov EDI, [TestBasePath.name]
             CopyString

             mov AL, '.'
             stosb

             mov EAX, EXT_TEST
             stosd
;------------------------------------------------
;       * * *  Get Base
;------------------------------------------------
         mov EAX, [lpSaveBuffer]
         mov [lpMemBuffer], EAX
         inc [Count]
;------------------------------------------------
;       * * *  Read Test
;------------------------------------------------
         mov EDX, [TestBasePath.path]
         call ReadToBuffer

         mov  EDI, [pTypeBuffer]
         test ECX, ECX
              jz jmpError@ListGroupBase
;------------------------------------------------
;       * * *  TestHeader
;------------------------------------------------
              mov ESI, [pReadBuffer]
              lodsd
;             mov [TestDataBase.date], EAX
              xor EAX, EAX
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
              add ESI, EAX 
              mov [IndexDataBase.testname], ESI

              xor ECX, ECX
              TypeHtmlSection TABLE_LIST_ITEM1

              mov EAX, 'Get('
              mov EDX, [IndexDataBase.attribute]
              test DL, TABLE_STATUS_ARHIVE
                   jz jmpSkip@ListGroupBase
                   mov EAx, 'Set('
;------------------------------------------------
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
         xor ECX, ECX
         SetHtmlSection TEST_GET_ERROR

jmpType@ListGroupBase:
         rep movsb 

         mov EBX, [IndexDataBase.session]
         call IndexToStr

         TypeHtmlSection TABLE_LIST_ITEM3

         mov ESI, [IndexDataBase.testname]
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
         mov [pTypeBuffer], EDI

jmpNext@ListGroupBase:
         add [pFind], INDEX_HEADER_SIZE
         dec [IndexDataBase.session]
             jnz jmpTabScan@ListGroupBase
;------------------------------------------------
;       * * *  TableEmpty
;------------------------------------------------
         mov EDI, [pTypeBuffer]
         mov EAX, [Count]
         test EAX, EAX
              jnz jmpAddForm@ListGroupBase
;------------------------------------------------
;       * * *  EmptyForm
;------------------------------------------------
jmpEmpty@ListGroupBase:
    mov EDI, [pTypeBuffer] 
    xor ECX, ECX
    TypeHtmlSection TABLE_LIST_EMPTY
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpAddForm@ListGroupBase:
    mov  CL, TABLE_LIST_END1 + TABLE_LIST_ADD
    mov EAX, [ClientAccess.Mode]
    cmp AL,  ACCESS_READ_WRITE
        jae jmpEndForm@ListGroupBase
        mov CL, TABLE_LIST_END1

jmpEndForm@ListGroupBase:
    mov ESI, gettext TABLE_LIST_END1@
    rep movsb

    TypeHtmlSection TABLE_LIST_END2
;   mov [pTypeBuffer], EDI
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
;       * * *  Get Part
;------------------------------------------------
    mov ESI, [AskOption+4]
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
;   mov EBX, [IndexDataBase.name]
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
    mov ESI, EDX

    call TimeToTick
    mov [Date], ECX
;------------------------------------------------
;       * * *  Scan Table
;------------------------------------------------
;   mov EBX, [IndexDataBase.session]
;   mov EAX, [IndexDataBase.group]
    call GetTableList

    push ECX
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
    InitHtmlSection CSS_VIEW
    TypeHtmlSection TABLE_VIEW1

    mov ESI, [TableBasePath.session]
    movsd
    movsb

    TypeHtmlSection TABLE_VIEW2

    mov EBX, [IndexDataBase.group]
    call WordToStr

    TypeHtmlSection TABLE_VIEW3
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TABLE_VIEW_HEAD1

    mov ESI, [GroupBasePath.name]
    movsd
    movsb

    TypeHtmlSection TABLE_VIEW_HEAD2

    mov ESI, [UserDataBase.user]
    CopyString

    TypeHtmlSection TABLE_VIEW_HEAD3

    mov ESI, [TableBasePath.session]
    movsd
    movsb

    TypeHtmlSection TABLE_VIEW_HEAD4

;   mov ESI, [TestBasePath.name]
;   mov ECX, TestDataBase.pathsize  
;   rep movsb 

;   mov AX, ' ]'
;   stosw

    mov ESI, [TestDataBase.text]
    CopyString

    TypeHtmlSection TABLE_VIEW_HEAD5

    mov ECX, [IndexDataBase.date] 
    push ECX
    call StrDate

    TypeHtmlSection TABLE_VIEW_HEAD6

;   mov ECX, [IndexDataBase.date]
    pop ECX
    call StrTime

    TypeHtmlSection TABLE_VIEW_HEAD7
;   mov [pTypeBuffer], EDI
;------------------------------------------------
;       * * *  Empty Item
;------------------------------------------------
    pop  ECX
    test ECX, ECX
         jnz jmpItems@ViewBaseClients

         TypeHtmlSection TABLE_VIEW_EMPTY
         jmp jmpTableEnd@ViewBaseClients
;------------------------------------------------
;       * * *  Init Scan
;------------------------------------------------
jmpItems@ViewBaseClients:
    mov [pTypeBuffer], EDI
    mov ESI, [pTableFile]
    mov ECX, [UserDataBase.count]
    inc ECX
;------------------------------------------------
;       * * *  Type Items
;------------------------------------------------
jmpScanTable@ViewBaseClients:
    lodsd 
    test EAX, EAX
         jz jmpNextTable@ViewBaseClients
         push ECX
         push ESI

         mov ESI, EAX    ;    pTableBase
         mov EDI, TableDataBase.session

         xor EAX, EAX
         mov ECX, EAX
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
         mov EBX, EAX
;        mov [TableDataBase.user], EAX

         movsd
         movsd
;        mov [TableDataBase.start], EAX
;        mov [TableDataBase.close], EAX

         mov EAX, ECX
         lodsw
         stosd
;        mov [TableDataBase.total], EAX

         mov EAX, ECX
         lodsb
;        stosd
         mov [EDI], EAX
;        mov [TableDataBase.score], EAX

         mov EDX, ESI   ;   TABLE_HEAD_SIZE
;------------------------------------------------
;       * * *  Head Item
;------------------------------------------------
         mov EDI, [pTypeBuffer] 
;        xor ECX, ECX

         TypeHtmlSection TABLE_VIEW_ITEM1

         mov ESI, EDX
         movsd    ;   TABLE_NAME_LENGTH
         movsd
         movsw 

         push ESI

         TypeHtmlSection TABLE_VIEW_ITEM2

;        mov EBX, [TableDataBase.user]
         push EBX
         call WordToStr

         TypeHtmlSection TABLE_VIEW_ITEM3 

;        mov EBX, [TableDataBase.user]
         pop EBX
         dec EBX

         mov ESI, [UserDataBase.index]
         mov ESI, [ESI+EBX*4]                
         add ESI, [UserDataBase.user]
         CopyString

         TypeHtmlSection TABLE_VIEW_ITEM4

         pop ESI
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
         mov  EDX, [TableDataBase.close]
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
              xor ECX, ECX

              TypeHtmlSection TABLE_VIEW_START1

              mov EAX, [TableDataBase.time]
              cmp EAX, EDX
                  jb jmpSkipTimer@ViewBaseClients

                  sub EAX, EDX
                  call StrSecond

jmpSkipTimer@ViewBaseClients:
              TypeHtmlSection TABLE_VIEW_START2

              mov EBX, [TableDataBase.session]
              push EBX
              call WordToStr

              mov EBX, [TableDataBase.group]
              pop EAX
              sub EBX, EAX
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

jmpEndItem@ViewBaseClients:
    mov [pTypeBuffer], EDI
    pop ESI
    pop ECX
;------------------------------------------------
;       * * *  End Item
;------------------------------------------------
jmpNextTable@ViewBaseClients:
    dec ECX
        jnz jmpScanTable@ViewBaseClients
;------------------------------------------------
;       * * *  End Item
;------------------------------------------------
;   xor ECX, ECX
    mov  CL, TABLE_VIEW_END1 + TABLE_VIEW_ARCH

    mov EAX, [ClientAccess.Mode]
    cmp  AL, ACCESS_ADMIN
        je jmpStore@ViewBaseClients

jmpTableEnd@ViewBaseClients:
        mov CL, TABLE_VIEW_END1

jmpStore@ViewBaseClients:
    mov ESI, gettext TABLE_VIEW_END1@
    rep movsb 

    TypeHtmlSection TABLE_VIEW_END2
;   mov [pTypeBuffer], EDI

;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX

jmpEnd@ViewBaseClients:
    ret 
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------

