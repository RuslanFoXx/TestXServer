;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
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
    mov ESI, [AskOption+4]
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

    mov ESI, [GroupBasePath.name]
    movsd
    movsb 
;------------------------------------------------
    TypeHtmlSection REPORT_GROUP2
    mov [Count], ECX

    mov ESI, [UserDataBase.user]
    CopyString

    TypeHtmlSection REPORT_GROUP3

    mov ECX, [UserDataBase.date] 
    push ECX
    call StrDate

    TypeHtmlSection REPORT_GROUP4

    pop ECX
    call StrTime

    TypeHtmlSection REPORT_GROUP5

    mov EAX,[UserDataBase.count]
    push EAX
    call ByteToStr

    TypeHtmlSection REPORT_GROUP6
;------------------------------------------------
;       * * *  Item Empty
;------------------------------------------------
;   mov  ECX, [UserDataBase.count]
    pop  ECX
    test ECX, ECX
         jnz jmpTypeItem@ReportGroup

         TypeHtmlSection TABLE_GET_EMPTY
         jmp jmpTypeEnd@ReportGroup

jmpTypeItem@ReportGroup:
    mov EAX, [UserDataBase.index]
    mov [pFind], EAX
;------------------------------------------------
;       * * *  TypeUser
;------------------------------------------------
jmpTabScan@ReportGroup:
    push ECX
    TypeHtmlSection REPORT_GROUP_ITEM1

    mov EAX, [Count]
    inc EAX
    mov [Count], EAX
;   call WordToStr
    call ByteToStr

    TypeHtmlSection REPORT_GROUP_ITEM2

    mov ESI, [pFind]
    lodsd
    mov [pFind], ESI
    mov ESI, [UserDataBase.user]
    add ESI, EAX
    CopyString

    TypeHtmlSection REPORT_GROUP_ITEM3

;   mov [pTypeBuffer], RDI
    pop ECX
    loop jmpTabScan@ReportGroup
;------------------------------------------------
;       * * *  TypeEnd
;------------------------------------------------
jmpTypeEnd@ReportGroup:
;   xor ECX, ECX
    TypeHtmlSection REPORT_GROUP_END 

;   mov [pTypeBuffer], RDI
    mov EAX, ECX
    inc EAX    ;  TEST_TYPE

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
    mov  EBX, [AskOption+4]

    test EBX, EBX 
         jz jmpEnd@ReportTest
;------------------------------------------------
;       * * *  TestBase
;------------------------------------------------
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@ReportTest
;------------------------------------------------
;       * * *  Type FormHeader
;------------------------------------------------
    InitHtmlReport  CSS_LIST
    TypeHtmlSection FORM_TITLE 
    TypeHtmlSection REPORT_VIEW_HEAD1 

    mov ESI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb 

    TypeHtmlSection REPORT_VIEW_HEAD2

    mov  ECX, [TestDataBase.date] 
    push ECX
    call StrDate

    TypeHtmlSection REPORT_VIEW_HEAD3

;   mov ECX, [TestDataBase.date]
    pop ECX
    call StrTime

    TypeHtmlSection REPORT_VIEW_HEAD4

    mov ESI, [TestDataBase.text]
    CopyString

    TypeHtmlSection REPORT_VIEW_HEAD5

    mov EBX, [TestDataBase.questions]
    call WordToStr

    mov AX, ' ('
    stosw

    mov EBX, [TestDataBase.answers]
    call WordToStr

    TypeHtmlSection REPORT_VIEW_HEAD6 
;   mov [pTypeBuffer], EDI
;------------------------------------------------
;       * * *  Items Question
;------------------------------------------------
;   xor ECX, ECX 
    mov [Ind], ECX
;------------------------------------------------
;       * * *  Type Question
;------------------------------------------------
jmpTestScan@ReportTest:

    TypeHtmlSection REPORT_VIEW_QUEST1

    mov EBX, [Ind]
    inc EBX
    mov [Ind], EBX
    call WordToStr

    TypeHtmlSection REPORT_VIEW_QUEST2

    mov ESI, [TestDataBase.index]       ;       pTabTest
    xor EAX, EAX
    lodsw
    mov EBX, EAX     ;     Check
    lodsd
    mov [pFind], ESI

    mov ESI, [TestDataBase.text]
    add ESI, EAX
    CopyString

    TypeHtmlSection REPORT_VIEW_QUEST3
;------------------------------------------------
;       * * *   Key AnswerOff
;------------------------------------------------
;   mov  EAX, [AskOption+8]
;   test EAX, EAX
;        jnz jmpNext@ReportTest
;------------------------------------------------
;       * * *  Type Answer
;------------------------------------------------
    mov ECX, [TestDataBase.answers] 

jmpAnsScan@ReportTest:
    push ECX
    mov ESI, [pFind]
    lodsd
    add EAX, [TestDataBase.text]
    mov EDX, EAX 
    mov [pFind], ESI 
    mov  CX, 1
    mov EAX, EBX
    shr EBX, CL

    test AX, CX
         jz jmpItem@ReportTest

         TypeHtmlSection REPORT_VIEW_ANS_TRUE1

         mov ESI, EDX
         CopyString

         TypeHtmlSection REPORT_VIEW_ANS_TRUE2
         jmp jmpAnswer@ReportTest
;------------------------------------------------
;       * * *  Type Items
;------------------------------------------------
jmpItem@ReportTest:
         TypeHtmlSection REPORT_VIEW_ANS_FALSE1

         mov ESI, EDX
         CopyString

         TypeHtmlSection REPORT_VIEW_ANS_FALSE2
;------------------------------------------------
jmpAnswer@ReportTest:
    pop ECX
    mov ESI, [pFind]
    mov EAX, [ESI] 
    test EAX, EAX
         jz jmpNext@ReportTest

    loop jmpAnsScan@ReportTest
;------------------------------------------------
;       * * *  Loop Questions
;------------------------------------------------
jmpNext@ReportTest:
    mov EAX, [TestDataBase.fieldsize]
    add [TestDataBase.index], EAX

    mov EAX, [Ind]
    cmp EAX, [TestDataBase.questions]
        jb jmpTestScan@ReportTest
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
;   mov EDI, [pTypeBuffer] 
    TypeHtmlSection REPORT_VIEW_END

;   mov pTypeBuffer, EDI
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
    mov ESI, [AskOption+4]
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
    mov EBX, [IndexDataBase.testname]
;   mov EBX, [TableDataBase.testname]
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
    mov EDI, [lpMemBuffer]
;   mov [pTableFile], EAX
;   add EAX, MAX_GROUP * 4 + 8
;   mov [lpMemBuffer], EAX
;------------------------------------------------
;       * * *  Get TableList
;------------------------------------------------
    mov ESI, [TableDataBase.table]
    mov EDX, [TableDataBase.tablesize]
    mov ECX, [TableDataBase.count]
    xor EAX, EAX
    mov [Count], EAX
;------------------------------------------------
;       * * *  Set IndexName
;------------------------------------------------
jmpScanStore@ReportStore:
;   xor EAX, EAX
    mov  AL, [ESI]
;   mov EDI, [pTableFile]
    mov [EDI+EAX*4], ESI
 
    add ESI, EDX
    loop jmpScanStore@ReportStore
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
    InitHtmlReport  CSS_LIST
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection REPORT_GET_HEAD1 

    mov ESI, [StoreBasePath.name]
    movsd
    movsb

    TypeHtmlSection REPORT_GET_HEAD2

    mov ESI, [UserDataBase.user]
    CopyString

    TypeHtmlSection REPORT_GET_HEAD3 

    mov ECX, [IndexDataBase.date] 
    push ECX
    call StrDate

    TypeHtmlSection REPORT_GET_HEAD4

;   mov ECX, [IndexDataBase.date] 
    pop ECX
    call StrTime

    TypeHtmlSection REPORT_GET_HEAD5

    mov ESI, [StoreBasePath.name]
    movsd
    movsb

    TypeHtmlSection REPORT_GET_HEAD6

    mov ESI, [TestDataBase.text]
    CopyString

    TypeHtmlSection REPORT_GET_HEAD7

    mov ESI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb 

    CopyHtmlSection REPORT_GET_HEAD8@, REPORT_GET_HEAD8 + REPORT_GET_TABLE1 + REPORT_GET_TABLE2
;------------------------------------------------
;       * * *  Init Scan
;------------------------------------------------
    mov [pTypeBuffer], EDI
;   mov ESI, [pTableFile]
    mov ESI, [lpMemBuffer]
    mov ECX, [UserDataBase.count]
    inc ECX
;------------------------------------------------
;       * * *  Type FinishUserList
;------------------------------------------------
jmpScanTable@ReportStore:
    lodsd 
    test EAX, EAX
         jz jmpNextTable@ReportStore
         push ECX
         push ESI

         mov ESI, EAX    ;    pTableBase
;        mov EDI, TableDataBase.user
         mov EDI, TableDataBase.start

         xor EAX, EAX
         mov ECX, EAX

;        mov EAX, ECX
         lodsb
;        stosd
         push EAX
;        mov EBX, EAX
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
;------------------------------------------------
;       * * *  Type Item
;------------------------------------------------
         mov EDI, [pTypeBuffer] 
;        xor ECX, ECX
         TypeHtmlSection REPORT_GET_ITEM1

         mov EAX, [Count]
         inc EAX
         mov [Count], EAX
;        call WordToStr
         call ByteToStr

         TypeHtmlSection REPORT_GET_ITEM2

;        mov EBX, [TableDataBase.user]
         pop EBX
         dec EBX

         mov ESI, [UserDataBase.index]
         mov ESI, [ESI+EBX*4]                
         add ESI, [UserDataBase.user]
         CopyString

         TypeHtmlSection REPORT_GET_ITEM3

         mov ESI, [TableDataBase.testname]
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
         mov [pTypeBuffer], EDI
         pop ESI
         pop ECX

jmpNextTable@ReportStore:
         dec ECX
             jnz jmpScanTable@ReportStore
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
    TypeHtmlSection REPORT_GET_END

;   mov [pTypeBuffer], EDI
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

;   mov [ClientAccess.Process], EAX
;------------------------------------------------
;       * * *  Get Part
;------------------------------------------------
    mov ESI, [AskOption+4]
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

    push ECX
;------------------------------------------------
;
;       * * *  FormHeader
;
;------------------------------------------------
    InitHtmlReport  CSS_LIST
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection REPORT_GET_HEAD1

    mov ESI, [GroupBasePath.name]
    movsd
    movsb 

    TypeHtmlSection REPORT_GET_HEAD2

    mov ESI, [UserDataBase.user]
    CopyString

    TypeHtmlSection REPORT_GET_HEAD3

    mov ECX, [IndexDataBase.date] 
    push ECX
    call StrDate

    TypeHtmlSection REPORT_GET_HEAD4

;   mov ECX, [IndexDataBase.date] 
    pop ECX
    call StrTime

    TypeHtmlSection REPORT_GET_HEAD5

    mov ESI, [TableBasePath.session]
    movsd
    movsb

    TypeHtmlSection REPORT_GET_HEAD6

    mov ESI, [TestDataBase.text]
    CopyString

    TypeHtmlSection REPORT_GET_HEAD7

    mov ESI, [TestBasePath.name]
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
;   xor ECX, ECX
    mov [Count], ECX
;------------------------------------------------
;       * * *  Empty Item
;------------------------------------------------
    pop EAX
    cmp EAX, ECX
        jne jmpInitScan@ReportTable
        cmp ECX, EDX     ;    IndexProcess
            je   jmpTableEmpty@ReportTable
            jmp jmpNumberEmpty@ReportTable
;------------------------------------------------
;       * * *  Init Scan
;------------------------------------------------
jmpInitScan@ReportTable:
    mov [pTypeBuffer], EDI
    mov ESI, [pTableFile]
    mov ECX, [UserDataBase.count]
    inc ECX
;------------------------------------------------
;       * * *  Mode Select
;------------------------------------------------
	test EDX, EDX    ;    Param
      jnz jmpScanTable@ReportTable
;------------------------------------------------
;       * * *  Type NumberUserList
;------------------------------------------------
jmpScanNumber@ReportTable:
    lodsd
    test EAX, EAX
         jz jmpNextNumber@ReportTable
         push ECX
         push ESI

         mov ESI, EAX
         xor ECX, ECX
         mov EBX, ECX
         mov  BL, [ESI+TABLE_HEADER.user]
;        mov [TableDataBase.user], EBX
         lea ESI, [ESI+TABLE_HEADER.start]
         lodsd

           or EAX, [ESI]
         test EAX, EAX
              jnz jmpSkipNumber@ReportTable

              add  ESI, TABLE_HEADER_SIZE - TABLE_HEADER.close
              push ESI
              push EBX
;             mov EDI, [pTypeBuffer]
;------------------------------------------------
;       * * *  Head Item
;------------------------------------------------
              TypeHtmlSection REPORT_GET_USER1

              mov EAX, [Count]
              inc EAX
              mov [Count], EAX
;             call WordToStr
              call ByteToStr

              TypeHtmlSection REPORT_GET_USER2

              pop EBX
;             mov EBX, [TableDataBase.user]
              dec EBX
              mov ESI, [UserDataBase.index]
              mov ESI, [ESI+EBX*4]                
              add ESI, [UserDataBase.user]
              CopyString

              TypeHtmlSection REPORT_GET_USER3

              pop ESI
              movsd
              movsd
              movsw

              TypeHtmlSection REPORT_GET_USER4 
;------------------------------------------------
;             mov [pTypeBuffer], RDI
;------------------------------------------------
jmpSkipNumber@ReportTable:
         pop ESI
         pop ECX
;------------------------------------------------
;       * * *  End Item
;------------------------------------------------
jmpNextNumber@ReportTable:
         dec ECX
             jnz jmpScanNumber@ReportTable
;------------------------------------------------
;       * * *  Items Empty
;------------------------------------------------
    mov EAX, [Count]
    test EAX, EAX 
         jnz jmpFormEnd@ReportTable

jmpNumberEmpty@ReportTable:
;        xor ECX, ECX
         TypeHtmlSection REPORT_GET_EMPTY1
         jmp jmpFormEnd@ReportTable
;------------------------------------------------
;       * * *  Type FinishUserList
;------------------------------------------------
jmpScanTable@ReportTable:
    lodsd 
    test EAX, EAX
         jz jmpNextTable@ReportTable
         push ECX
         push ESI

         mov ESI, EAX
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

         mov EAX, ECX
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
         mov [EDI], EAX
;        mov [TableDataBase.score], EAX
;------------------------------------------------
;       * * *  Type Item
;------------------------------------------------
         mov  EDI, [pTypeBuffer]
         test EDX, EDX
              jz jmpSkipTable@ReportTable
              add ESI, TABLE_NAME_LENGTH   ;   TEST_HEADER_SIZE
              push ESI

              TypeHtmlSection REPORT_GET_ITEM1

              mov EAX, [Count]
              inc EAX
              mov [Count], EAX
;             call WordToStr
              call ByteToStr

              TypeHtmlSection REPORT_GET_ITEM2

              mov EBX, [TableDataBase.user]
              dec EBX
              mov ESI, [UserDataBase.index]
              mov ESI, [ESI+EBX*4]                
              add ESI, [UserDataBase.user]
              CopyString

              TypeHtmlSection REPORT_GET_ITEM3 

              pop ESI
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
              mov [pTypeBuffer], EDI

jmpSkipTable@ReportTable:
         pop ESI
         pop ECX
;------------------------------------------------
;       * * *  End Item
;------------------------------------------------
jmpNextTable@ReportTable:
         dec ECX
             jnz jmpScanTable@ReportTable
;------------------------------------------------
;       * * *  Item Empty
;------------------------------------------------
    mov  EAX, [Count]
    test EAX, EAX 
         jnz jmpFormEnd@ReportTable

jmpTableEmpty@ReportTable:
;        mov EDI, pTypeBuffer 
         TypeHtmlSection REPORT_GET_EMPTY2
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpFormEnd@ReportTable:
    TypeHtmlSection REPORT_GET_END

;   mov [pTypeBuffer], EDI
;   xor EAX, EAX
    mov EAX, ECX
    inc EAX    ;  TEST_TYPE
jmpEnd@ReportTable:
    ret 
endp
;------------------------------------------------
;       * * *   END
;------------------------------------------------

