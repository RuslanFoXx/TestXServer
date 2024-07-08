;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   BASE: Client Work + View (Admin)
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Client Processor  * * *
;------------------------------------------------
proc TableClient
;------------------------------------------------
;       * * *  Get CheckBuffer
;------------------------------------------------
    mov EAX, [lpMemBuffer]
    mov [pTabCheck], EAX
    add EAX, MAX_ANSWER * 2 + 16
    mov [lpMemBuffer],  EAX
    mov [lpSaveBuffer], EAX
;------------------------------------------------
;       * * *  Get TableNumber
;------------------------------------------------
    mov  ESI, [AskOption]
    push ESI
    xor EBX, EBX
    mov ECX, EBX
    mov EDX, EBX
    mov CL,  MAX_TABLE_COUNT
    mov BL,  10
;------------------------------------------------
;       * * *  Get Code Base
;------------------------------------------------
jmpScanNum@TableClient:
    xor EAX, EAX
    lodsb

    sub  AL, '0'
    mov EDI, EAX
    mov EAX, EDX
    mul EBX 
    add EAX, EDI
    mov EDX, EAX
    loop jmpScanNum@TableClient

    push EAX
;------------------------------------------------
;       * * *  Get  Base
;------------------------------------------------
    mov EDX, ECX
    mov  CL, MAX_INDEX_COUNT

jmpScanDir@TableClient:
    xor EAX, EAX
    lodsb

    sub  AL, '0'
    mov EDI, EAX
    mov EAX, EDX
    mul EBX 
    add EAX, EDI
    mov EDX, EAX
    loop jmpScanDir@TableClient

    mov EBX, EAX
    pop EAX
    xor EBX, EAX
    call HashToData
;------------------------------------------------
;       * * *  Table Not Found!
;------------------------------------------------
;   mov [TableDataBase.session], EDX
    mov EBX, EDX    ;   Dir
    pop ESI         ;   AskOption
    call OpenTableBase

    mov ECX, EAX
    mov AL,  TEST_NOT_FOUND
    test ECX, ECX
         jnz jmpEnd@TableClient
;------------------------------------------------
;       * * *  Table Closed!
;------------------------------------------------
    mov   AL, TEST_CLOSE
    mov  ECX, [TableDataBase.close]
    test ECX, ECX
         jnz jmpEnd@TableClient
;------------------------------------------------
;       * * *  TestBase
;------------------------------------------------
    mov EBX, [TableDataBase.testname]
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@TableClient
;------------------------------------------------
;       * * *  Get UserName
;------------------------------------------------
;   mov [pTestName], EAX
    mov EBX, [TableDataBase.group]
    call OpenUserBase

    test EAX, EAX
         jnz jmpEnd@TableClient
;------------------------------------------------
;       * * *  Get UserName
;------------------------------------------------
    mov EBX, [TableDataBase.user]
    dec EBX
    mov EDI, [UserDataBase.index]
    mov EAX, [EDI+EBX*4]
    add EAX, [UserDataBase.user]
    mov [pUserName], EAX 
;------------------------------------------------
;       * * *  Get Question
;------------------------------------------------
    mov  ESI, [AskOption+4]
    test ESI, ESI 
         jnz jmpWork@TableClient
;------------------------------------------------
;       * * *  Begin Testing
;------------------------------------------------
         xor EAX, EAX
         inc EAX
         mov [Quest], EAX
         inc EAX
         mov [Next], EAX
         mov EAX, [TableDataBase.tests]
         mov [Prev], EAX
;------------------------------------------------
;       * * *  Set Date
;------------------------------------------------
         mov  EAX, [TableDataBase.start]
         test EAX, EAX
              jnz jmpTime@TableClient

              call GetBaseTime

              mov  EDI, TableDataBase.start
              mov [EDI], EDX
              push TABLE_HEADER.start
              push 4
              push EDI
              mov  EDX, [TableBasePath.path]
              call WriteToPosition 

              test ECX, ECX
                   jnz jmpTime@TableClient

                   mov AL, BASE_TABLE + ERR_WRITE
                   jmp jmpEnd@TableClient
;------------------------------------------------
;       * * *  Begin Testing
;------------------------------------------------
jmpWork@TableClient:
    call StrToWord

    mov EDX, [TableDataBase.tests]
    cmp EAX, EDX 
        jbe jmpQuest@TableClient
        xor EAX, EAX
        inc EAX

jmpQuest@TableClient:
    mov EBX, EAX
    mov [Quest], EAX
    inc EAX
    cmp EAX, EDX 
        jbe jmpNext@TableClient
        xor EAX, EAX
        inc EAX

jmpNext@TableClient:
    mov [Next], EAX
    dec EBX
    test EBX, EBX 
         jnz jmpPrev@TableClient
         mov EBX, EDX

jmpPrev@TableClient:
    mov [Prev], EBX
;------------------------------------------------
;       * * *  Checked
;------------------------------------------------
    mov ESI, [AskOption+8]
    call StrToWord

    test EAX, EAX 
         jz jmpTime@TableClient

         dec EAX
         shl EAX, 1
         add EAX, [TableDataBase.data]
         push EAX
         mov ESI, [AskOption+12]
         call StrToWord
         pop EDI
         cmp EAX, [EDI]
             je jmpTime@TableClient

             mov [EDI], AX
             mov ECX, EDI              ;    position
             sub ECX, [lpSaveBuffer]   ;    pTableBase
             push ECX
             push 2
             push EDI
             mov  EDX, [TableBasePath.path]
             call WriteToPosition 

             mov AL, BASE_TABLE + ERR_WRITE
             test ECX, ECX
                  jz jmpEnd@TableClient
;------------------------------------------------
;       * * *  TimeOut >> call FinishClient
;------------------------------------------------
jmpTime@TableClient:
    mov  EAX, [Quest]
    test EAX, EAX
         jz CallFinishClient

         call GetBaseTime
         mov ESI, EDX

         call TimeToTick
         push ECX

         mov ESI, [TableDataBase.start]
         call TimeToTick

         pop EDX
         sub EDX, ECX
         mov EBX, [TableDataBase.time]
         cmp EBX, EDX
             jbe CallFinishClient
;------------------------------------------------
;       * * *  Set Tester Time
;------------------------------------------------
    sub EBX, EDX
    mov [Time], EBX
;------------------------------------------------
;       * * *  Set  TableChecked
;------------------------------------------------
    mov EAX, [Quest]
    dec EAX
    mov EBX, EAX
    shl EBX, 1
    add EBX, [TableDataBase.data]
    xor EDX, EDX
    mov DX, [EBX]
    mov [Param], EDX
;------------------------------------------------
;       * * *  Set  TableField
;------------------------------------------------
    mov ESI, [TableDataBase.index]
    mov EBX, [TableDataBase.fieldsize]
    mul EBX
    add ESI, EAX 
;------------------------------------------------
;       * * *  Set TestField
;------------------------------------------------
    mov EBX, [TestDataBase.fieldsize]
    xor EAX, EAX
    lodsw

    mul EBX
    add EAX, 2
    add EAX, [TestDataBase.index]
    mov [pTabTest], EAX
    mov [pTabData], ESI
;------------------------------------------------
;       * * *  Count Items
;------------------------------------------------
    mov ECX, [TableDataBase.items]
    xor EBX, EBX
    mov EDX, EBX

jmpScan@TableClient:
    lodsb
    test AL, AL
         jz jmpCount@TableClient

    test AL, SET_ITEM_TRUE
         jz jmpStep@TableClient
         inc EBX

jmpStep@TableClient:
    inc EDX
    loop jmpScan@TableClient
;------------------------------------------------
;       * * *  Set Items
;------------------------------------------------
jmpCount@TableClient:
    mov [Items], EDX
    mov [ItemCount], EBX
;------------------------------------------------
;       * * *  Type FormHeader
;------------------------------------------------
    InitHtmlSection CSS_TEST
    TypeHtmlSection CLIENT_GET1

    mov EBX, [Time]
    call WordToStr

    TypeHtmlSection CLIENT_GET2

    mov EBX, [Param]
    call WordToStr

    TypeHtmlSection CLIENT_GET3

    mov ESI, [TableBasePath.table]
    movsd
    movsd
    movsw

    TypeHtmlSection CLIENT_GET4

    mov EBX, [Quest]
    call WordToStr

    TypeHtmlSection CLIENT_GET5

    mov EBX, [Items]
    call WordToStr

    TypeHtmlSection CLIENT_GET6
     SetHtmlSection CLIENT_GET8

    cmp [ItemCount], 1
        ja jmpGetPart@TableClient
        SetHtmlSection CLIENT_GET7

jmpGetPart@TableClient:
    rep movsb 

    TypeHtmlSection CLIENT_GET_ORG
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection CLIENT_GET_HEAD1 

    mov ESI, [TableBasePath.table]
    movsd
    movsd
    movsw

    TypeHtmlSection CLIENT_GET_HEAD2

    mov ESI, [pUserName]
    CopyString

    TypeHtmlSection CLIENT_GET_HEAD3
;   mov [pTypeBuffer], EDI
;------------------------------------------------
;       * * *  Set SelectScale
;------------------------------------------------
    mov EBX, [TableDataBase.tests]
    mov EAX, [Quest]
;   xor EDX, EDX
    mov EDX, ECX
    mov ESI, ECX
    mov  DL, MAX_VIEW_ITEMS
    mov ECX, EBX
    sub ECX, ESI
    cmp ECX, EDX
        jle jmpSetScan@TableClient
;------------------------------------------------
        mov ECX, EDX
        sub EAX, MAX_VIEW_CENTER
        cmp EAX, ESI
            jl jmpSetScale@TableClient
            mov ESI, EAX

jmpSetScale@TableClient:
        mov EAX, ESI
        add EAX, EDX
        cmp EAX, EBX
            jl jmpSetScan@TableClient
            sub EBX, EDX
            mov ESI, EBX

jmpSetScan@TableClient:
    mov [Ind], ESI

    shl ESI, 1
    add ESI, [TableDataBase.data]
    mov [pFind], ESI
;   mov EDI, [pTypeBuffer]
;------------------------------------------------
;       * * *  Scan Selector
;------------------------------------------------
jmpSelScan@TableClient:
    push ECX
    inc [Ind]
    mov ESI, [pFind]
    lodsw
    mov [pFind], ESI 
    mov DL, 'D'

    mov ECX, [Ind]
    cmp ECX, [Quest]
        je jmpSelect@TableClient
        mov   DL, 'A'
        test EAX, EAX 
             jnz jmpSelect@TableClient
             mov DL, 'C'
;------------------------------------------------
;       * * *  TypeScale
;------------------------------------------------
jmpSelect@TableClient:
    xor ECX, ECX
    TypeHtmlSection CLIENT_GET_SEL1

    mov EAX, EDX 
    stosb

;   mov ESI, gettext CLIENT_GET_SEL2@
    mov  CL, CLIENT_GET_SEL2
    rep movsb 

    push EDI
    mov EBX, [Ind]
    call WordToStr

    push EDI
    TypeHtmlSection CLIENT_GET_SEL3

    pop ECX
    pop ESI
    sub ECX, ESI
    rep movsb 

    TypeHtmlSection CLIENT_GET_SEL4

    pop ECX
    loop jmpSelScan@TableClient
;------------------------------------------------
;       * * *  Type Question
;------------------------------------------------
;   mov EDI, [pTypeBuffer]  
    TypeHtmlSection CLIENT_GET_QUEST1

    mov ESI, [TestDataBase.text]
    CopyString

    TypeHtmlSection CLIENT_GET_QUEST2

    push EDI
    mov EBX, [Quest]
    call WordToStr

    push EDI
    TypeHtmlSection CLIENT_GET_QUEST3

    mov EBX, [TableDataBase.tests]
    call WordToStr

    TypeHtmlSection CLIENT_GET_QUEST4

    pop ECX 
    pop ESI 
    sub ECX, ESI
    rep movsb 

    TypeHtmlSection CLIENT_GET_QUEST5

    mov EDX, [pTabTest]
    mov ESI, [TestDataBase.text]
    add ESI, [EDX]

    CopyString

    TypeHtmlSection CLIENT_GET_QUEST6

    mov EAX, [ItemCount]
    call ByteToStr

    TypeHtmlSection CLIENT_GET_QUEST7
;   mov [pTypeBuffer], EDI
;------------------------------------------------
;       * * *  Type Answer Form
;------------------------------------------------
;   xor ECX, ECX
    inc ECX 
    mov EBX, ECX
    mov ECX, [Items]

jmpAnsScan@TableClient:
    mov ESI, [pTabData]
    xor EAX, EAX
    lodsb
    test AL, AL 
         jz jmpEndForm@TableClient
;------------------------------------------------
;       * * *  Select Items
;------------------------------------------------
         push ECX
         push EBX
         push EAX
         mov [pTabData], ESI
         xor ECX, ECX

         TypeHtmlSection CLIENT_GET_ITEM1

         push EDI
;        mov  EBX, Items
         call WordToStr

         mov EDX, EDI
         TypeHtmlSection CLIENT_GET_ITEM2

         pop ESI
         mov ECX, EDX
         sub ECX, ESI
         rep movsb 

         TypeHtmlSection CLIENT_GET_ITEM3

         pop EBX
         and BL,  GET_ITEM
         shl EBX, 2
         add EBX, [pTabTest]
         mov ESI, [TestDataBase.text]
         add ESI, [EBX]
         CopyString

         TypeHtmlSection CLIENT_GET_ITEM4 

         pop EBX
         shl EBX, 1
         pop ECX
         loop jmpAnsScan@TableClient
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpEndForm@TableClient:
;   mov EDI, pTypeBuffer 
    TypeHtmlSection CLIENT_GET_END1 

    mov EBX, [Prev]
    call WordToStr

    TypeHtmlSection CLIENT_GET_END2

    mov EBX, [Next]
    call WordToStr

    TypeHtmlSection CLIENT_GET_END3

;   mov [pTypeBuffer], EDI
    mov EAX, ECX        ;       TEST_POST
;   xor EAX, EAX        ;       TEST_POST

jmpEnd@TableClient:
    ret 
;endp
;------------------------------------------------
;       * * *  Clent Finish  * * *
;------------------------------------------------
;proc FinishClient
CallFinishClient:

    InitHtmlSection CSS_TEST
    TypeHtmlSection CLIENT_GET_FIN1
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection CLIENT_GET_FIN2

    mov ESI, [TableBasePath.table]
    movsd
    movsd
    movsw

    TypeHtmlSection CLIENT_GET_FIN3

    mov ESI, [pUserName]
    CopyString

    TypeHtmlSection CLIENT_GET_FIN4
;------------------------------------------------
;       * * *  Set SelectScale
;------------------------------------------------
;   xor ECX, ECX
    mov [TableDataBase.total], ECX
    mov [Ind], ECX 

    push EDI
    mov EDI, [pTabCheck]
    call GetTabCheck

    pop EDI
    mov EAX, [TableDataBase.data]   ;   pTabCheck
    mov [pFind], EAX
    mov ECX, [TableDataBase.tests]
;------------------------------------------------
;       * * *  Scan Selector
;------------------------------------------------
jmpFinScan@FinishClient:
    push ECX
    mov ESI, [pTabCheck]
    lodsw

    mov EBX, EAX
    mov [pTabCheck], ESI 

    mov ESI, [pFind]
    lodsw
    mov [pFind], ESI 

    mov  DL, 'C'
    test AX, AX
         jz jmpFinType@FinishClient
;------------------------------------------------
         mov DL, 'B'
;------------------------------------------------
         cmp AX, BX
             jne jmpFinType@FinishClient
;------------------------------------------------
             inc [TableDataBase.total]
             mov DL, 'A'
;------------------------------------------------
;       * * *  TypeScale
;------------------------------------------------
jmpFinType@FinishClient:
    xor ECX, ECX
    TypeHtmlSection CLIENT_GET_INFO1

    mov EAX, EDX 
    stosb

    TypeHtmlSection CLIENT_GET_INFO2

    mov EBX, [Ind]
    inc EBX
    mov [Ind], EBX
    call WordToStr

    TypeHtmlSection CLIENT_GET_INFO3

    pop ECX
    loop jmpFinScan@FinishClient
;------------------------------------------------
;       * * *  End TotalForm
;------------------------------------------------
    TypeHtmlSection CLIENT_GET_TOTAL1

    mov ECX, [TableDataBase.tests]
    mov EAX, [TableDataBase.total]
    call StrPercent

    TypeHtmlSection CLIENT_GET_TOTAL2

    mov ESI, [TestDataBase.text]
    CopyString

    TypeHtmlSection CLIENT_GET_TOTAL3

    mov EBX, [TableDataBase.total]
    call WordToStr

    TypeHtmlSection CLIENT_GET_TOTAL4

    mov EBX, [TableDataBase.tests]
    call WordToStr

    TypeHtmlSection CLIENT_GET_TOTAL5
;------------------------------------------------
;       * * *  Score
;------------------------------------------------
    mov EDX, EDI
    mov EDI, [TestDataBase.scale]
;   xor ECX, ECX
    mov CL,  TEST_SCALE_COUNT
    mov EBX, ECX
    mov EAX, [TableDataBase.total]

jmpScoreScan@FinishClient:
    scasw
      jb jmpEndScan@FinishClient
    loop jmpScoreScan@FinishClient

jmpEndScan@FinishClient:
    sub EBX, ECX
    mov EDI, EDX
;------------------------------------------------
;       * * *  Level
;------------------------------------------------
    mov EDX, [TestDataBase.level]
    mov ECX, EDX
    and CL, 0Fh
    mov AL, 'C'
    cmp BL, CL
        jb jmpSetLevel@FinishClient
        shr DL, 4
;       and DL, 0Fh
        mov AL,'B'
        cmp BL, DL
            jb jmpSetLevel@FinishClient
            mov AL,'A'

jmpSetLevel@FinishClient:
    stosb
    mov AX, '">'
    stosw

    push EBX
    call WordToStr

    TypeHtmlSection CLIENT_GET_TOTAL6
    mov [pTypeBuffer], EDI
;------------------------------------------------
;       * * *  CloseCount
;------------------------------------------------
    call GetBaseTime

    mov ECX, szBuffer
    mov EDI, ECX
    mov EAX, EDX
    stosd

    mov EAX, [TableDataBase.total]
    stosw

    pop EAX
;   mov EAX, [Score]
;   stosb
    mov [EDI], AL

    push TABLE_HEADER.close
    push TABLE_HEADER_SIZE - TABLE_HEADER.close 
    push ECX 
    mov  EDX, [TableBasePath.path]
    call WriteToPosition

    mov AL, BASE_TABLE + ERR_WRITE
    jECXz jmpEnd@FinishClient
          xor EAX, EAX     ;     TEST_POST

jmpEnd@FinishClient:
    mov EDI, [pTypeBuffer]
    ret 
endp
;------------------------------------------------
;       * * *  Client Viewer  * * *
;------------------------------------------------
proc ViewStoreClient
;------------------------------------------------
;       * * *  Get CheckBuffer
;------------------------------------------------
    mov EAX, [lpMemBuffer]
    mov [pTabCheck], EAX
    add EAX, MAX_ANSWER * 2 + 16
    mov [lpMemBuffer], EAX
    mov [lpSaveBuffer], EAX
;------------------------------------------------
;       * * *  Get Table
;------------------------------------------------
    mov ESI, [AskOption+8]
    call StrToWord

    mov  AL,  ERR_GET_TABLE
    test EBX, EBX 
         jz jmpEnd@ViewStoreClient
         mov [Ind], EBX
;------------------------------------------------
;       * * *  Set TableName
;------------------------------------------------
    mov EDI,[TableBasePath.index]
;   mov EAX, [Ind]
    mov EAX, EBX
    call IndexToStr
;------------------------------------------------
;       * * *  Get Session
;------------------------------------------------
    mov ESI, [AskOption+4]
    call StrToWord

    mov   AL, ERR_GET_PART
    test EBX, EBX 
         jz jmpEnd@ViewStoreClient
         mov [IndexDataBase.session], EBX
         mov EDX, [Ind]
         call OpenStoreBase

         test EAX, EAX 
              jnz jmpEnd@ViewStoreClient
;------------------------------------------------
;       * * *  Open TestBase
;------------------------------------------------
;   mov EBX, [TableDataBase.testname]
    call OpenTestBase

    test EAX, EAX 
         jnz jmpEnd@ViewStoreClient
;------------------------------------------------
;       * * *  Open UserBase
;------------------------------------------------
    mov EBX, [TableDataBase.group]
    call OpenUserBase

    test EAX, EAX 
         jnz jmpEnd@ViewStoreClient
;------------------------------------------------
;       * * *  Get UserName
;------------------------------------------------
    mov EBX, [TableDataBase.user]
    dec EBX
    mov EDI, [UserDataBase.index]
    mov EAX, [EDI+EBX*4]
    add EAX, [UserDataBase.user]
    mov [pUserName], EAX
;------------------------------------------------
;       * * *  Get Question
;------------------------------------------------
    mov  ESI, [AskOption+12]
    test ESI, ESI 
         jnz jmpWork@ViewStoreClient
;------------------------------------------------
;       * * *  Begin Testing
;------------------------------------------------
         xor EAX, EAX
         inc EAX
         mov [Quest], EAX
         inc EAX
         mov [Next], EAX
         mov EAX, [TableDataBase.tests]
         mov [Prev], EAX
         jmp jmpTime@ViewStoreClient
;------------------------------------------------
;       * * *  Begin Testing
;------------------------------------------------
jmpWork@ViewStoreClient:
    call StrToWord

    mov EDX, [TableDataBase.tests]
    cmp EAX, EDX 
        jbe jmpQuest@ViewStoreClient
        xor EAX, EAX
        inc EAX

jmpQuest@ViewStoreClient:
    mov EBX, EAX
    mov [Quest], EAX
    inc EAX
    cmp EAX, EDX 
        jbe jmpNext@ViewStoreClient
        xor EAX, EAX
        inc EAX

jmpNext@ViewStoreClient:
    mov [Next], EAX
    dec EBX
    test EBX, EBX 
         jnz jmpPrev@ViewStoreClient
         mov EBX, EDX

jmpPrev@ViewStoreClient:
    mov [Prev], EBX
;------------------------------------------------
;       * * *  Set TimeOut
;------------------------------------------------
jmpTime@ViewStoreClient:
;   xor EAX, EAX
;   mov [Time], EAX
;------------------------------------------------
;       * * *  Set TableChecked
;------------------------------------------------
    mov EAX, [Quest]
    dec EAX
    mov EBX, EAX
    shl EBX, 1
    add EBX, [TableDataBase.data]       ;       pTabCheck
    mov DX, [EBX]
    mov [Param], EDX    ;    Check
;------------------------------------------------
;       * * *  Set TableField
;------------------------------------------------
    mov ESI, [TableDataBase.index]      ;       pTabData
    mov EBX, [TableDataBase.fieldsize]
    mul EBX
    add ESI, EAX 
;------------------------------------------------
;       * * *  Set TestField
;------------------------------------------------
    mov EBX, [TestDataBase.fieldsize]
    xor EAX, EAX
    mov [Time], EAX
    lodsw
    mov [Question], EAX
    mul EBX
    add EAX, 2
    add EAX, [TestDataBase.index]
    mov [pTabTest], EAX
    mov [pTabData], ESI 
;------------------------------------------------
;       * * *  Count Items
;------------------------------------------------
    xor EBX, EBX
    mov EDX, EBX
    mov ECX, [TableDataBase.items]

jmpScan@ViewStoreClient:
    lodsb
    test AL, AL
         jz jmpCount@ViewStoreClient

    test AL, SET_ITEM_TRUE
         jz jmpStep@ViewStoreClient
         inc EBX

jmpStep@ViewStoreClient:
    inc EDX
    loop jmpScan@ViewStoreClient
;------------------------------------------------
;       * * *  Set Items
;------------------------------------------------
jmpCount@ViewStoreClient:
    mov [Items], EDX
    mov [ItemCount], EBX
;------------------------------------------------
;       * * *  Type FormHeader
;------------------------------------------------
    InitHtmlSection CSS_TEST

    mov AL, '.'
    stosb

    mov ESI, [TableBasePath.session]
;   mov ESI, [StoreBasePath.name]
    movsd
    movsb
;   mov EBX, [IndexDataBase.session]
;   call WordToStr

    mov Ax, "';"
    stosw

    mov AL, 's'
;   mov AX, ASK_StoreClient
    mov [gettext CLIENT_VIEW4@], AL

;   mov AX, ASK_ViewStoreItems
    mov [gettext CLIENT_VIEW6@], AL

    CopyHtmlSection CLIENT_VIEW3@, CLIENT_VIEW3 + CLIENT_VIEW4

    mov EAX, [Ind]
    call ByteToStr
    jmp jmpOrgHeader@ViewTableClient

jmpEnd@ViewStoreClient:
    ret
endp
;------------------------------------------------
;       * * *  Clent Viewer  * * *
;------------------------------------------------
proc ViewTableClient
;------------------------------------------------
;       * * *  Get CheckBuffer
;------------------------------------------------
    mov EAX, [lpMemBuffer]
    mov [pTabCheck], EAX
    add EAX, MAX_ANSWER * 2 + 16
    mov [lpMemBuffer], EAX
    mov [lpSaveBuffer], EAX
;------------------------------------------------
;       * * *  Get Part
;------------------------------------------------
    mov ESI, [AskOption+4]
    call StrToWord

    mov   AL, ERR_GET_PART
    test EBX, EBX 
         jz jmpEnd@ViewTableClient

         mov AL,  ERR_GET_TABLE
         mov ESI, [AskOption+8]
         test ESI, ESI 
              jz jmpEnd@ViewTableClient
;------------------------------------------------
;       * * *  Open Table
;------------------------------------------------
    mov [IndexDataBase.session], EBX
;   mov [Table], ESI
    call OpenTableBase

    test EAX, EAX
         jnz jmpEnd@ViewTableClient
;------------------------------------------------
;       * * *  TestBase
;------------------------------------------------
;   mov EBX, [TableDataBase.testname]
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@ViewTableClient
;------------------------------------------------
;       * * *  Get UserName
;------------------------------------------------
;   mov [pTestName], EAX
    mov EBX, [TableDataBase.group]
    call OpenUserBase

    test EAX, EAX
         jnz jmpEnd@ViewTableClient
;------------------------------------------------
;       * * *  Get UserName
;------------------------------------------------
    mov EBX, [TableDataBase.user]
    dec EBX

    mov EDI, [UserDataBase.index]
    mov EAX, [EDI+EBX*4]
    add EAX, [UserDataBase.user]
    mov [pUserName], EAX
;------------------------------------------------
;       * * *  Get Question
;------------------------------------------------
    mov ESI, [AskOption+12]
    test ESI, ESI 
         jnz jmpWork@ViewTableClient
;------------------------------------------------
;       * * *  Begin Testing
;------------------------------------------------
         xor EAX, EAX
         inc EAX
         mov [Quest], EAX
         inc EAX
         mov [Next], EAX
         mov EAX, [TableDataBase.tests]
         mov [Prev], EAX
         jmp jmpTime@ViewTableClient
;------------------------------------------------
;       * * *  Begin Testing
;------------------------------------------------
jmpWork@ViewTableClient:
    call StrToWord

    mov EDX, [TableDataBase.tests]
    cmp EAX, EDX 
        jbe jmpQuest@ViewTableClient
        xor EAX, EAX
        inc EAX

jmpQuest@ViewTableClient:
    mov EBX, EAX
    mov [Quest], EAX
    inc EAX
    cmp EAX, EDX 
        jbe jmpNext@ViewTableClient
        xor EAX, EAX
        inc EAX

jmpNext@ViewTableClient:
    mov [Next], EAX
    dec  EBX
    test EBX, EBX 
         jnz jmpPrev@ViewTableClient
         mov EBX, EDX

jmpPrev@ViewTableClient:
    mov [Prev], EBX
;------------------------------------------------
;       * * *  Set TimeOut
;------------------------------------------------
jmpTime@ViewTableClient:
    xor  EBX, EBX
    mov  EAX, [TableDataBase.close]
    test EAX, EAX 
         jnz jmpSetTime@ViewTableClient
         call GetBaseTime
         mov ESI, EDX

         call TimeToTick
         push ECX

         mov ESI, [TableDataBase.start]
         call TimeToTick

         pop EDX
         sub EDX, ECX
         mov EBX, [TableDataBase.time]
         cmp EBX, EDX
             ja jmpTimeOut@ViewTableClient
             mov EDX, EBX

jmpTimeOut@ViewTableClient:
         sub EBX, EDX
;------------------------------------------------
;       * * *  Set TimeOut
;------------------------------------------------
jmpSetTime@ViewTableClient:
    mov [Time], EBX
;------------------------------------------------
;       * * *  Set TableChecked
;------------------------------------------------
    mov EAX, [Quest]
    dec EAX
    mov EBX, EAX
    shl EBX, 1
    add EBX, [TableDataBase.data]       ;       pTabCheck
    mov DX, [EBX]
    mov [Param], EDX    ;    Check
;------------------------------------------------
;       * * *  Set TableField
;------------------------------------------------
    mov ESI, [TableDataBase.index]      ;       pTabData
    mov EBX, [TableDataBase.fieldsize]
    mul EBX
    add ESI, EAX 
;------------------------------------------------
;       * * *  Set TestField
;------------------------------------------------
    mov EBX, [TestDataBase.fieldsize]
    xor EAX, EAX
    lodsw
    mov [Question], EAX
    mul EBX
    add EAX, 2
    add EAX, [TestDataBase.index]
;------------------------------------------------
    mov [pTabTest], EAX
    mov [pTabData], ESI 
;------------------------------------------------
;       * * *  Count Items
;------------------------------------------------
    xor EBX, EBX
    mov EDX, EBX
    mov ECX, [TableDataBase.items]

jmpScan@ViewTableClient:
    lodsb
    test AL, AL
         jz jmpCount@ViewTableClient

    test AL, SET_ITEM_TRUE
         jz jmpStep@ViewTableClient
         inc EBX

jmpStep@ViewTableClient:
    inc EDX
    loop jmpScan@ViewTableClient
;------------------------------------------------
;       * * *  Set Items
;------------------------------------------------
jmpCount@ViewTableClient:
    mov [Items], EDX
    mov [ItemCount], EBX
;------------------------------------------------
;       * * *  Type FormHeader
;------------------------------------------------
    mov AL, 'b'
;   mov AX, ASK_StoreClient
    mov [gettext CLIENT_VIEW4@], AL
;   mov AX, ASK_ViewStoreItems
    mov [gettext CLIENT_VIEW6@], AL

    InitHtmlSection CSS_TEST

    mov AL, '.'
    stosb
    mov ESI, [TableBasePath.session]
    movsd
    movsb
    mov AX, "';"
    stosw

    mov EBX, [Time]
    test EBX, EBX
         jz jmpSkipTime@ViewTableClient

         TypeHtmlSection CLIENT_VIEW1

;        mov EBX, [Time]
         call WordToStr

         TypeHtmlSection CLIENT_VIEW2

jmpSkipTime@ViewTableClient:
    CopyHtmlSection CLIENT_VIEW3@, CLIENT_VIEW3 + CLIENT_VIEW4

    mov ESI, [TableBasePath.table]
    movsd
    movsd
    movsw
;------------------------------------------------
;       * * *  Client FormHeader
;------------------------------------------------
jmpOrgHeader@ViewTableClient:

    CopyHtmlSection CLIENT_VIEW5@, CLIENT_VIEW5 + CLIENT_VIEW6
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection CLIENT_VIEW_HEAD1 

    mov ESI, [TableBasePath.table]
    movsd
    movsd    ;    TABLE_NAME_LENGTH
    movsw

    TypeHtmlSection CLIENT_VIEW_HEAD2

    mov ESI, [pUserName]
    CopyString

    TypeHtmlSection CLIENT_VIEW_HEAD3
;   mov [pTypeBuffer], EDI
;------------------------------------------------
;       * * *  Scan Selector
;------------------------------------------------
    mov [Count], ECX
    mov [TableDataBase.total], ECX
    push EDI
    mov  EDI, [pTabCheck]
    call GetTabCheck

    mov EBX, [TableDataBase.tests]
    mov EAX, [Quest]
    pop EDI
;   xor EDX, EDX
    mov EDX, ECX
    mov ESI, ECX
    mov  DL, MAX_VIEW_ITEMS
    mov ECX, EBX
    sub ECX, ESI
    cmp ECX, EDX
        jle jmpSetScan@ViewTableClient
        mov ECX, EDX
        sub EAX, MAX_VIEW_CENTER
        cmp EAX, ESI
            jl jmpSetScale@ViewTableClient
            mov ESI, EAX

jmpSetScale@ViewTableClient:
        mov EAX, ESI
        add EAX, EDX
        cmp EAX, EBX
            jl jmpSetScan@ViewTableClient
            sub EBX, EDX
            mov ESI, EBX

jmpSetScan@ViewTableClient:
    mov [Ind], ESI
    shl ESI, 1
    add [pTabCheck], ESI
    add ESI, [TableDataBase.data]       ;       pTabCheck
    mov [pFind], ESI
;   mov EDI, [pTypeBuffer]
;------------------------------------------------
;       * * *  Scan Selector
;------------------------------------------------
jmpSelScan@ViewTableClient:
    push ECX
    inc [Ind]
    mov ESI, [pTabCheck]
    lodsw
    mov EBX, EAX
    mov [pTabCheck], ESI 
    mov ESI, [pFind]
    lodsw
    mov [pFind], ESI 

    mov  DL, 'C'
    test AX, AX
         jz jmpFocus@ViewTableClient
         inc [Count]
         mov DL, 'B'
         cmp AX, BX
             jne jmpFocus@ViewTableClient
             inc [TableDataBase.total]
             mov DL, 'A'
;------------------------------------------------
;       * * *  TypeScale
;------------------------------------------------
jmpFocus@ViewTableClient:
    mov ECX, [Quest]
    cmp ECX, [Ind]
        jne jmpSelect@ViewTableClient
        mov DL, 'D'

jmpSelect@ViewTableClient:
    xor ECX, ECX
    TypeHtmlSection CLIENT_VIEW_SEL1 

    mov EAX, EDX 
    stosb

;   mov ESI, getform CLIENT_VIEW_SEL2@
    mov CL,  CLIENT_VIEW_SEL2
    rep movsb 

    push EDI
    mov EBX, [Ind]
    call WordToStr

;   push EDI
    mov ECX, EDI
;   TypeHtmlSection CLIENT_VIEW_SEL3

    mov EAX, ');">'
    stosd

;   pop ECX
    pop ESI
    sub ECX, ESI
    rep movsb 

    TypeHtmlSection CLIENT_VIEW_SEL4
;   mov [pTypeBuffer], EDI

    pop ECX
;   loop jmpSelScan@ViewTableClient
    dec ECX
        jnz jmpSelScan@ViewTableClient
;------------------------------------------------
;       * * *  Type Question
;------------------------------------------------
;   mov EDI, [pTypeBuffer]  
;   xor ECX, ECX
    TypeHtmlSection CLIENT_VIEW_LEVEL1

    mov EAX, [TableDataBase.total]
    mov ECX, [TableDataBase.tests]

    call StrPercent

    TypeHtmlSection CLIENT_VIEW_LEVEL2

    mov EBX, [TableDataBase.total]
    call WordToStr

    TypeHtmlSection CLIENT_VIEW_LEVEL3

    mov EBX, [Count]
    sub EBX, [TableDataBase.total]
    call WordToStr

    TypeHtmlSection CLIENT_VIEW_LEVEL4
;------------------------------------------------
;       * * *  Score
;------------------------------------------------
    mov EDX, EDI
    mov EDI, [TestDataBase.scale]
;   xor ECX, ECX
    mov CL,  TEST_SCALE_COUNT
    mov EBX, ECX
    mov EAX, [TableDataBase.total]

jmpScoreScan@ViewTableClient:
    scasw
      jb jmpEndScan@ViewTableClient
    loop jmpScoreScan@ViewTableClient

jmpEndScan@ViewTableClient:
    mov EDI, EDX
    sub EBX, ECX
    call WordToStr

    TypeHtmlSection CLIENT_VIEW_QUEST1

    mov ESI, [TestDataBase.text]
    CopyString

    TypeHtmlSection CLIENT_VIEW_QUEST2

    mov EBX, [Question]
    inc EBX
    call WordToStr

    mov AX, '] '
    stosw

    mov EBX, [Quest]
    push EDI
    call WordToStr
    push EDI

    TypeHtmlSection CLIENT_VIEW_QUEST3

    mov EBX, [TableDataBase.tests]
    call WordToStr

    TypeHtmlSection CLIENT_VIEW_QUEST4

    pop ECX
    pop ESI
    sub ECX, ESI
    rep movsb 

    TypeHtmlSection CLIENT_VIEW_QUEST5

    mov ESI, [pTabTest]
    mov ESI, [ESI]
    add ESI, [TestDataBase.text]
    CopyString

    TypeHtmlSection CLIENT_VIEW_QUEST6 

    mov EAX, [ItemCount]
    call ByteToStr

    TypeHtmlSection CLIENT_VIEW_QUEST7
;   mov [pTypeBuffer], EDI
;------------------------------------------------
;       * * *  Type Answer Form
;------------------------------------------------
    mov ECX, [Items]
    mov EDX, [Param]   ;    Check

jmpAnsScan@ViewTableClient:
    mov ESI, [pTabData]
    xor EAX, EAX
    lodsb
    test AL, AL 
         jz jmpEndForm@ViewTableClient
;------------------------------------------------
;       * * *  Select Items
;------------------------------------------------
         push ECX
         push EDX
         push EAX
         mov EBX, EAX
         mov [pTabData], ESI
         xor ECX, ECX

         TypeHtmlSection CLIENT_VIEW_ITEM1

;        mov EDX, [Check]
         inc ECX
         test BL, SET_ITEM_TRUE
              jnz jmpSelItem@ViewTableClient
              mov AL, 'B'
              test DX, CX 
                   jnz jmpSetValid@ViewTableClient
                   mov AL, 'C'
                   jmp jmpSetValid@ViewTableClient

jmpSelItem@ViewTableClient:
          mov  AL, 'A'
          test DX, CX 
               jnz jmpSetValid@ViewTableClient
               mov AL, 'D'

jmpSetValid@ViewTableClient:
         stosb

;        TypeHtmlSection CLIENT_VIEW_ITEM2 
         mov AX, '">' 
         stosw

         pop EBX
         and BL,  GET_ITEM
         shl EBX, 2

         add EBX, [pTabTest]
         mov ESI, [TestDataBase.text]
         add ESI, [EBX]
         CopyString

         TypeHtmlSection CLIENT_VIEW_ITEM3 

         pop EDX
         shr EDX, 1

jmpItemNext@ViewTableClient:
         pop ECX
         loop jmpAnsScan@ViewTableClient
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpEndForm@ViewTableClient:
;   mov EDI, [pTypeBuffer] 
;   xor ECX, ECX
    SetHtmlSection CLIENT_VIEW_END1

    mov EAX, [Time]
    test EAX, EAX
         jz jmpPanel@ViewTableClient
         mov CL, CLIENT_VIEW_END1 + CLIENT_VIEW_TIME1

jmpPanel@ViewTableClient:
    rep movsb 

    TypeHtmlSection CLIENT_VIEW_TIME2

    mov EBX, [Prev]
    call WordToStr

    TypeHtmlSection CLIENT_VIEW_END2

    mov EBX, [Next]
    call WordToStr

    TypeHtmlSection CLIENT_VIEW_END3

;   mov [pTypeBuffer], EDI
;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX

jmpEnd@ViewTableClient:
    ret
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
