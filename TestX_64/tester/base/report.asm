;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   BASE: Report (Admin)
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Report Group  * * *
;------------------------------------------------
proc ReportGroup
;------------------------------------------------
;       * * *  Get Group
;------------------------------------------------
    mov RSI, [AskOption+8]
    call StrToWord
    mov   AL, ERR_GET_GROUP
    test EBX, EBX 
         jz jmpEnd@ReportGroup
;------------------------------------------------
;       * * *  Set GroupPath
;------------------------------------------------
    call OpenUserBase
    test EAX, EAX
         jnz jmpEnd@ReportGroup
;------------------------------------------------
;       * * *  Type Items
;------------------------------------------------
    InitHtmlReport  CSS_LIST
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection REPORT_GROUP1

    mov RSI, [GroupBasePath.name]
    movsd
    movsb 

    TypeHtmlSection REPORT_GROUP2

    mov RSI, [UserDataBase.user]
    mov R12, RSI
    CopyString

    TypeHtmlSection REPORT_GROUP3

    mov ECX, [UserDataBase.date] 
    mov R10d, ECX
    call StrDate

    TypeHtmlSection REPORT_GROUP4

    mov ECX, R10d
    call StrTime

    TypeHtmlSection REPORT_GROUP5

    mov R15d,[UserDataBase.count]
    mov EAX, R15d
    call ByteToStr

    TypeHtmlSection REPORT_GROUP6
;------------------------------------------------
;       * * *  Item Empty
;------------------------------------------------
    test R15d, R15d
         jnz jmpTypeItem@ReportGroup

         TypeHtmlSection TABLE_GET_EMPTY
         jmp jmpTypeEnd@ReportGroup

jmpTypeItem@ReportGroup:
;   mov R15d,[UserDataBase.count]
;   mov R12, [UserDataBase.user]
    mov R14, [UserDataBase.index]
    xor RCX, RCX
    mov R10, RCX
;------------------------------------------------
;       * * *  TypeUser
;------------------------------------------------
jmpTabScan@ReportGroup:
    TypeHtmlSection REPORT_GROUP_ITEM1

    inc R10d
    mov EAX, R10d
;   call WordToStr
    call ByteToStr

    TypeHtmlSection REPORT_GROUP_ITEM2

    mov RSI, R14
    mov RAX, RCX
    lodsd
    mov R14, RSI
    mov RSI, R12
    add RSI, RAX
    CopyString

    TypeHtmlSection REPORT_GROUP_ITEM3

;   mov [pTypeBuffer], RDI
;   dec [UserDataBase.count]
    dec R15d
        jnz jmpTabScan@ReportGroup
;------------------------------------------------
;       * * *  TypeEnd
;------------------------------------------------
jmpTypeEnd@ReportGroup:
;   xor RCX, RCX
    TypeHtmlSection REPORT_GROUP_END

;   mov [pTypeBuffer], RDI
    mov EAX, ECX
    inc EAX    ;  TEST_TYPE
;------------------------------------------------
jmpEnd@ReportGroup:
    ret
endp
;------------------------------------------------
;       * * *  Report Test  * * *
;------------------------------------------------
proc ReportTest
;------------------------------------------------
;       * * *  Get TestName
;------------------------------------------------
    mov   AL, ERR_GET_TEST
    mov  RBX, [AskOption+8]
    test RBX, RBX 
         jz jmpEnd@ReportTest
;------------------------------------------------
;       * * *  TestBase
;------------------------------------------------
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@ReportTest
;------------------------------------------------
;
;       * * *  Type Items
;
;------------------------------------------------
    InitHtmlReport  CSS_LIST
    TypeHtmlSection FORM_TITLE 
    TypeHtmlSection REPORT_VIEW_HEAD1

    mov RSI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb

    TypeHtmlSection REPORT_VIEW_HEAD2

    mov ECX, [TestDataBase.date] 
    mov R12d, ECX
    call StrDate

    TypeHtmlSection REPORT_VIEW_HEAD3

    mov ECX, R12d
    call StrTime

    TypeHtmlSection REPORT_VIEW_HEAD4

    mov RSI, [TestDataBase.text]
    CopyString

    TypeHtmlSection REPORT_VIEW_HEAD5

    mov EBX, [TestDataBase.questions]
    call WordToStr
    mov AX, ' ('
    stosw
    mov EBX, [TestDataBase.answers]
    call WordToStr

    TypeHtmlSection REPORT_VIEW_HEAD6
;   mov [pTypeBuffer], RDI
;------------------------------------------------
;       * * *  Items Question
;------------------------------------------------
;   xor RCX, RCX 
;   mov [Ind], ECX
    mov R15, RCX
    mov R13, [AskOption+16]
;------------------------------------------------
;       * * *  Type Question
;------------------------------------------------
jmpTestScan@ReportTest:

    TypeHtmlSection REPORT_VIEW_QUEST1

    inc R15d    ;  Ind  
    mov EBX, R15d
    call WordToStr

    TypeHtmlSection REPORT_VIEW_QUEST2

    mov RSI, [TestDataBase.index]     ;      pTabTest
    xor RAX, RAX
    lodsw
    mov RBX, RAX
    lodsd
    mov R11, RSI
    mov RSI, [TestDataBase.text]
    add RSI, RAX
    CopyString

    TypeHtmlSection REPORT_VIEW_QUEST3
;------------------------------------------------
;       * * *   Key AnswerOff
;------------------------------------------------
;   mov  RAX, [AskOption+16]
    test R13d, R13d
         jnz jmpNext@ReportTest
;------------------------------------------------
;       * * *  Type Answer
;------------------------------------------------
    mov R14d, [TestDataBase.answers] 

jmpAnsScan@ReportTest:
    mov RSI, R11
    xor RAX, RAX
    lodsd
    add RAX, [TestDataBase.text]
    mov RDX, RAX 
    mov R11, RSI 
    mov  CX, 1
    mov EAX, EBX
    shr EBX, CL
    test AX, CX
         jz jmpItem@ReportTest

         TypeHtmlSection REPORT_VIEW_ANS_TRUE1

         mov RSI, RDX
         CopyString

         TypeHtmlSection REPORT_VIEW_ANS_TRUE2
         jmp jmpAnswer@ReportTest
;------------------------------------------------
;       * * *  Type Items
;------------------------------------------------
jmpItem@ReportTest:
         TypeHtmlSection REPORT_VIEW_ANS_FALSE1

         mov RSI, RDX
         CopyString

         TypeHtmlSection REPORT_VIEW_ANS_FALSE2

jmpAnswer@ReportTest:

    mov  RSI, R11
    mov  EAX, [RSI] 
    test EAX, EAX
         jz jmpNext@ReportTest

    dec R14d
        jnz jmpAnsScan@ReportTest
;------------------------------------------------
;       * * *  Loop Questions
;------------------------------------------------
jmpNext@ReportTest:
    xor RAX, RAX
    mov EAX, [TestDataBase.fieldsize]
    add [TestDataBase.index], RAX
    cmp R15d, [TestDataBase.questions]
        jb jmpTestScan@ReportTest
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
;   mov RDI, [pTypeBuffer] 
    TypeHtmlSection REPORT_VIEW_END

;   mov pTypeBuffer, RDI
;   xor EAX, EAX
    mov EAX, ECX
    inc EAX    ;  TEST_TYPE

jmpEnd@ReportTest:
    ret
endp
;------------------------------------------------
;       * * *  Report Store  * * *
;------------------------------------------------
proc ReportStore
;------------------------------------------------
;       * * *  Get Part
;------------------------------------------------
    mov RSI, [AskOption+8]
    call StrToWord

    mov   AL, ERR_GET_PART
    test EBX, EBX 
         jz jmpEnd@ReportStore
;------------------------------------------------
;       * * *  Get IndexBase
;------------------------------------------------
;   mov [IndexDataBase.session], EBX
    call OpenIndexBase

    test EAX, EAX
         jnz jmpEnd@ReportStore
;------------------------------------------------
;       * * *  Open OpenStoreBase
;------------------------------------------------
    mov EBX, [IndexDataBase.session]
    xor EDX, EDX   ;    table = 1
    inc EDX
    call OpenStoreBase

    test EAX, EAX 
         jnz jmpEnd@ReportStore
;------------------------------------------------
;       * * *  Set TestBase
;------------------------------------------------
    mov RBX, [IndexDataBase.testname]
;   mov RBX, [TableDataBase.testname]
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@ReportStore
;------------------------------------------------
;       * * *  Set GroupPath
;------------------------------------------------
    mov EBX, [TableDataBase.group]
    call OpenUserBase

    test EAX, EAX
         jnz jmpEnd@ReportStore
;------------------------------------------------
;       * * *  Get FilesBuffer
;------------------------------------------------
    mov RDI, [lpMemBuffer]
;   mov [pTableFile], RAX
;   add EAX, MAX_GROUP * 8 + 8
;   mov [lpMemBuffer], RAX
;------------------------------------------------
;       * * *  Get TableList
;------------------------------------------------
    xor RAX,  RAX
    mov RCX,  RAX
    mov RDX,  RAX
    mov RSI,  [TableDataBase.table]
    mov EDX,  [TableDataBase.tablesize]
    mov ECX,  [TableDataBase.count]
;------------------------------------------------
;       * * *  Set IndexName
;------------------------------------------------
jmpScanStore@ReportStore:
;   xor RAX, RAX
    mov  AL, [RSI]
;   mov RDI,  [pTableFile]
    mov [RDI+RAX*8], RSI
;   movsq     ;    STORE_HEADER_DATA
;   movsd

    add RSI, RDX
    loop jmpScanStore@ReportStore
;------------------------------------------------
;
;       * * *  FormHeader
;
;------------------------------------------------
    InitHtmlReport  CSS_LIST
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection REPORT_GET_HEAD1

    mov RSI, [StoreBasePath.name]
    movsd
    movsb

    TypeHtmlSection REPORT_GET_HEAD2

    mov RSI, [UserDataBase.user]
    CopyString

    TypeHtmlSection REPORT_GET_HEAD3

    mov ECX, [IndexDataBase.date] 
    mov R12d, ECX
    call StrDate

    TypeHtmlSection REPORT_GET_HEAD4

    mov ECX, R12d
    call StrTime

    TypeHtmlSection REPORT_GET_HEAD5

    mov RSI, [StoreBasePath.name]
    movsd
    movsb

    TypeHtmlSection REPORT_GET_HEAD6

    mov RSI, [TestDataBase.text]
    CopyString

    TypeHtmlSection REPORT_GET_HEAD7

    mov RSI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb 

    CopyHtmlSection REPORT_GET_HEAD8@, REPORT_GET_HEAD8 + REPORT_GET_TABLE1 + REPORT_GET_TABLE2
;------------------------------------------------
;       * * *  Init Scan
;------------------------------------------------
    mov [pTypeBuffer], RDI
;   mov RSI, [pTableFile]
    mov RSI, [lpMemBuffer]
    xor R13, R13   ;   Count
    mov R15, R13
    mov R15d, [UserDataBase.count]
    inc R15d
;------------------------------------------------
;       * * *  Type FinishUserList
;------------------------------------------------
jmpScanTable@ReportStore:
    lodsq 
    test RAX, RAX
         jz jmpNextTable@ReportStore

         mov R14, RSI
         mov RSI, RAX    ;    pTableBase
;        mov RDI, TableDataBase.user
         mov RDI, TableDataBase.start
         xor RAX, RAX
         mov RCX, RAX
;        mov EAX, ECX
         lodsb
;        stosd
         mov R12, RAX
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
;------------------------------------------------
;       * * *  Type Item
;------------------------------------------------
         mov RDI, [pTypeBuffer] 
;        xor RCX, RCX
         TypeHtmlSection REPORT_GET_ITEM1

         inc R13d
         mov EAX, R13d
;        call WordToStr
         call ByteToStr

         TypeHtmlSection REPORT_GET_ITEM2

;        mov R12, [TableDataBase.user]
         dec R12
         mov RSI, [UserDataBase.index]
         mov RAX, RCX
         mov EAX, [RSI+R12*4]
         mov RSI, [UserDataBase.user]
         add RSI, RAX
         CopyString

         TypeHtmlSection REPORT_GET_ITEM3

         mov RSI, [TableDataBase.testname]
         CopyString

         TypeHtmlSection REPORT_GET_ITEM4

         mov EBX, [TableDataBase.tests]
         call WordToStr

;        TypeHtmlSection REPORT_GET_ITEM5

         mov EAX, '/<b>'
         stosd

         mov EBX, [TableDataBase.total]
         call WordToStr

         TypeHtmlSection REPORT_GET_ITEM6

         mov ECX, [TableDataBase.close]
         call StrDate

         TypeHtmlSection REPORT_GET_ITEM7

         mov ECX, [TableDataBase.close]
         call StrTime

         TypeHtmlSection REPORT_GET_ITEM8

         mov ECX, [TableDataBase.tests]
         mov EAX, [TableDataBase.total]
         call StrPercent

         TypeHtmlSection REPORT_GET_ITEM9

         mov EAX, [TableDataBase.score]
;        call WordToStr
         call ByteToStr

         TypeHtmlSection REPORT_GET_ITEMA
;------------------------------------------------
;       * * *  End Item
;------------------------------------------------
         mov [pTypeBuffer], RDI
         mov RSI, R14

jmpNextTable@ReportStore:
         dec R15d
             jnz jmpScanTable@ReportStore
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
;   xor RCX, RCX
    TypeHtmlSection REPORT_GET_END

;   mov [pTypeBuffer], RDI
;   xor EAX, EAX
    mov EAX, ECX
    inc EAX    ;  TEST_TYPE

jmpEnd@ReportStore:
    ret 
endp
;------------------------------------------------
;       * * *  Report Table  * * *
;------------------------------------------------
proc ReportTable
;------------------------------------------------
;   mov [ClientAccess.Process], R9d
;------------------------------------------------
;       * * *  Get Part
;------------------------------------------------
    mov RSI, [AskOption+8]
    call StrToWord

    mov   AL, ERR_GET_PART
    test EBX, EBX 
         jz jmpEnd@ReportTable
;------------------------------------------------
;       * * *  Get IndexBase
;------------------------------------------------
;   mov [IndexDataBase.session], EBX
    call OpenIndexBase

    test EAX, EAX
         jnz jmpEnd@ReportTable
;------------------------------------------------
;       * * *  Set TestBase
;------------------------------------------------
;   mov RBX, [IndexDataBase.name]
;   mov RBX, RSI
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@ReportTable
;------------------------------------------------
;       * * *  Set GroupPath
;------------------------------------------------
    mov EBX, [IndexDataBase.group]
    call OpenUserBase

    test EAX, EAX
         jnz jmpEnd@ReportTable
;------------------------------------------------
;       * * *  Scan Table
;------------------------------------------------
;   mov EBX, [IndexDataBase.session]
;   mov EAX, [IndexDataBase.group]
    call GetTableList

    mov R15d, ECX
;------------------------------------------------
;
;       * * *  FormHeader
;
;------------------------------------------------
    InitHtmlReport  CSS_LIST
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection REPORT_GET_HEAD1

    mov RSI, [GroupBasePath.name]
    movsd
    movsb

    TypeHtmlSection REPORT_GET_HEAD2

    mov RSI, [UserDataBase.user]
    CopyString

    TypeHtmlSection REPORT_GET_HEAD3

    mov ECX, [IndexDataBase.date] 
    mov R12d, ECX
    call StrDate

    TypeHtmlSection REPORT_GET_HEAD4

    mov ECX, R12d
    call StrTime

    TypeHtmlSection REPORT_GET_HEAD5

    mov RSI, [TableBasePath.session]
    movsd
    movsb

    TypeHtmlSection REPORT_GET_HEAD6

    mov RSI, [TestDataBase.text]
    CopyString

    TypeHtmlSection REPORT_GET_HEAD7

    mov RSI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb 

    mov EDX, ECX  ;  False
    SetHtmlSection REPORT_GET_HEAD8

    mov EAX, [ClientAccess.Process]
    cmp EAX, REPORT_TABLE_LIST
        je jmpAddType@ReportTable
        mov CL, REPORT_GET_HEAD8 + REPORT_GET_TABLE1
        inc EDX 

jmpAddType@ReportTable:
    rep movsb 

    TypeHtmlSection REPORT_GET_TABLE2
;------------------------------------------------
;       * * *  Empty Item
;------------------------------------------------
    cmp ECX, R15d
        jne jmpInitScan@ReportTable
        cmp ECX, EDX     ;    IndexProcess
            je   jmpTableEmpty@ReportTable
            jmp jmpNumberEmpty@ReportTable
;------------------------------------------------
;       * * *  Init Scan
;------------------------------------------------
jmpInitScan@ReportTable:
    mov [pTypeBuffer], RDI
    mov RSI, [pTableFile]
    mov R13, RCX   ;   Count
    mov R15, R13
    mov R15d, [UserDataBase.count]
    inc R15d
;------------------------------------------------
;       * * *  Mode Select
;------------------------------------------------
    test EDX, EDX    ;    Module
         jnz jmpScanTable@ReportTable
;------------------------------------------------
;       * * *  Type NumberUserList
;------------------------------------------------
jmpScanNumber@ReportTable:
    lodsq
    test RAX, RAX
         jz jmpNextNumber@ReportTable
         mov R14, RSI
         mov RSI, RAX
         xor RAX, RAX
         mov R12, RAX
         mov  AL, TABLE_HEADER.user
         mov R12b, [RSI+RAX]
;        mov [TableDataBase.user], R12b
         mov  AL, TABLE_HEADER.start
         lea RSI, [RSI+RAX]
         lodsd
           or EAX, [RSI]
         test EAX, EAX
              jnz jmpSkipNumber@ReportTable
              add RSI, TABLE_HEADER_SIZE - TABLE_HEADER.close
              mov R10, RSI
;             mov RDI, [pTypeBuffer]
;------------------------------------------------
;       * * *  Head Item
;------------------------------------------------
              TypeHtmlSection REPORT_GET_USER1

              inc R13d
              mov EAX, R13d
;             call WordToStr
              call ByteToStr

              TypeHtmlSection REPORT_GET_USER2

;             mov R12, [TableDataBase.user]
              dec R12
              mov RSI, [UserDataBase.index]
              mov RAX, RCX
              mov EAX, [RSI+R12*4]
              mov RSI, [UserDataBase.user]
              add RSI, RAX
;------------------------------------------------
              CopyString
;------------------------------------------------
              TypeHtmlSection REPORT_GET_USER3

              mov RSI, R10
              movsd
              movsd
              movsw

              TypeHtmlSection REPORT_GET_USER4

;             mov [pTypeBuffer], RDI
;------------------------------------------------
;       * * *  End Item
;------------------------------------------------
jmpSkipNumber@ReportTable:
         mov RSI, R14

jmpNextNumber@ReportTable:
         dec R15d
             jnz jmpScanNumber@ReportTable
;------------------------------------------------
;       * * *  Item Empty
;------------------------------------------------
    test R13d, R13d
         jnz jmpFormEnd@ReportTable

jmpNumberEmpty@ReportTable:
;        xor RCX, RCX
         TypeHtmlSection REPORT_GET_EMPTY1
         jmp jmpFormEnd@ReportTable
;------------------------------------------------
;       * * *  Type FinishUserList
;------------------------------------------------
jmpScanTable@ReportTable:
    lodsq
    test RAX, RAX
         jz jmpNextTable@ReportTable

         mov R14, RSI
         mov RSI, RAX
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
;        mov [TableDataBase.user], EAX

         movsd
;        mov [TableDataBase.start], EAX

         lodsd
         stosd
         mov EDX, EAX
;        mov [TableDataBase.close], EAX

         mov EAX, ECX
         lodsw
         stosd
;        mov [TableDataBase.total], EAX

         mov EAX, ECX
         lodsb
         mov [RDI], EAX
;        mov [TableDataBase.score], EAX
;------------------------------------------------
;       * * *  Type Item
;------------------------------------------------
         mov  RDI, [pTypeBuffer]
         test EDX, EDX
              jz jmpSkipTable@ReportTable
              add RSI, TABLE_NAME_LENGTH   ;   TEST_HEADER_SIZE
              mov R12, RSI

              TypeHtmlSection REPORT_GET_ITEM1

              inc R13d
              mov EAX, R13d
;             call WordToStr
              call ByteToStr

              TypeHtmlSection REPORT_GET_ITEM2

              xor RBX, RBX
              mov EBX, [TableDataBase.user]
              dec EBX
              mov RSI, [UserDataBase.index]
              mov RAX, RCX
              mov EAX, [RSI+RBX*4]
              mov RSI, [UserDataBase.user]
              add RSI, RAX
              CopyString

              TypeHtmlSection REPORT_GET_ITEM3

              mov RSI, R12
              CopyString

              TypeHtmlSection REPORT_GET_ITEM4

              mov EBX, [TableDataBase.tests]
              call WordToStr

;             TypeHtmlSection REPORT_GET_ITEM5

              mov EAX, '/<b>'
              stosd

              mov EBX, [TableDataBase.total]
              call WordToStr

              TypeHtmlSection REPORT_GET_ITEM6

              mov ECX, [TableDataBase.close]
              call StrDate

              TypeHtmlSection REPORT_GET_ITEM7

              mov ECX, [TableDataBase.close]
              call StrTime

              TypeHtmlSection REPORT_GET_ITEM8

              mov ECX, [TableDataBase.tests]
              mov EAX, [TableDataBase.total]
              call StrPercent

              TypeHtmlSection REPORT_GET_ITEM9

              mov EAX, [TableDataBase.score]
;             call WordToStr
              call ByteToStr

              TypeHtmlSection REPORT_GET_ITEMA
              mov [pTypeBuffer], RDI
;------------------------------------------------
;       * * *  Type Item
;------------------------------------------------
jmpSkipTable@ReportTable:
         mov RSI, R14

jmpNextTable@ReportTable:
               dec R15d
                   jnz jmpScanTable@ReportTable
;------------------------------------------------
;       * * *  Item Empty
;------------------------------------------------
    test R13d, R13d 
         jnz jmpFormEnd@ReportTable

jmpTableEmpty@ReportTable:
         xor RCX, RCX
         TypeHtmlSection REPORT_GET_EMPTY2
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpFormEnd@ReportTable:
    TypeHtmlSection REPORT_GET_END

;   mov [pTypeBuffer], RDI
;   xor EAX, EAX
    mov EAX, ECX
    inc EAX    ;  TEST_TYPE

jmpEnd@ReportTable:
    ret 
endp
;------------------------------------------------
;       * * *   END
;------------------------------------------------
