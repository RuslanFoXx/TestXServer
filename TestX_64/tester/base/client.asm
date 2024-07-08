;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
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
    mov RAX, [lpMemBuffer]
    mov [pTabCheck], RAX
    add RAX, MAX_ANSWER * 2 + 16
    mov [lpMemBuffer],  RAX
    mov [lpSaveBuffer], RAX
;------------------------------------------------
;       * * *  Get Part (GetDirBase)
;------------------------------------------------
    mov R14, [AskOption]
    mov RSI, R14
    xor RBX, RBX
    mov RCX, RBX
    mov RDX, RBX
    mov R9,  RBX
    mov R8b, '0'
    mov  BL, 10
    mov  CL, MAX_TABLE_COUNT
;------------------------------------------------
;       * * *  Get Code Base
;------------------------------------------------
jmpScanNum@TableClient:
    xor RAX, RAX
    lodsb

    sub  AL, R8b
    mov R9b, AL
    mov EAX, EDX
    mul EBX 
    add EAX, R9d
    mov EDX, EAX
    loop jmpScanNum@TableClient
;------------------------------------------------
;       * * *  Get Base
;------------------------------------------------
    mov R12, RAX
    mov RDX, RCX
    mov  CL, MAX_INDEX_COUNT

jmpScanDir@TableClient:
    xor RAX, RAX
    lodsb

    sub AL,  R8b
    mov R9b, AL
    mov EAX, EDX
    mul EBX 
    add EAX, R9d
    mov EDX, EAX
    loop jmpScanDir@TableClient

    mov EBX, EAX
    mov EAX, R12d
    xor EBX, EAX
    call HashToData
;------------------------------------------------
;       * * *  Table Not Found!
;------------------------------------------------
;   mov [TableDataBase.session], EDX
    mov EBX, EDX    ;   Dir
    mov RSI, R14    ;   AskOption
    call OpenTableBase
    mov  ECX, EAX
    mov   AL, TEST_NOT_FOUND
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
    mov RBX, [TableDataBase.testname]
    call OpenTestBase
    test EAX, EAX
         jnz jmpEnd@TableClient
;------------------------------------------------
;       * * *  Get UserName
;------------------------------------------------
;   mov [pTestName], RAX
    mov EBX, [TableDataBase.group]
    call OpenUserBase
    test EAX, EAX
         jnz jmpEnd@TableClient
;------------------------------------------------
;       * * *  Get UserName
;------------------------------------------------
    xor RAX, RAX
    mov RBX, RAX
    mov EBX, [TableDataBase.user]
    dec RBX
    mov RDI, [UserDataBase.index]
    mov EAX, [RDI+RBX*4]
    add RAX, [UserDataBase.user]
    mov [pUserName], RAX 
;------------------------------------------------
;       * * *  Get Question
;------------------------------------------------
    mov  RSI, [AskOption+8]
    test RSI, RSI 
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

              mov EAX, EDX
              param 2, TableDataBase.start
              mov [RDX], EAX

              xor R8, R8
              mov R9, R8
              mov R9b, TABLE_HEADER.start
              mov R8b, 4
;             param 4, TABLE_HEADER.start
;             param 3, 4
;             param 2, TableDataBase.start
              param 1, [TableBasePath.path]
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
    mov [Ind], EAX
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
    mov RSI, [AskOption+16]
    call StrToWord
    test EAX, EAX 
         jz jmpTime@TableClient
         dec EAX
         shl EAX, 1
         add RAX, [TableDataBase.data]
         mov R15, RAX
         mov RSI, [AskOption+24]
         call StrToWord
         cmp EAX, [R15]
             je jmpTime@TableClient
             mov [R15], AX
             param 4, R15
             sub R9, [lpSaveBuffer]   ;   pTableBase
             xor R8, R8
             mov R8b, 2
;            param 3, 2
             param 2, R15
             param 1, [TableBasePath.path]
             call WriteToPosition 
             mov   AL, BASE_TABLE + ERR_WRITE
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
         mov R10d, ECX

         mov ESI, [TableDataBase.start]
         call TimeToTick

         sub R10d, ECX
         mov R15d, [TableDataBase.time]
         cmp R15d, R10d
             jbe CallFinishClient
;------------------------------------------------
;       * * *  Set Tester Time
;------------------------------------------------
    sub R15d, R10d
    mov [Time], R15d
;------------------------------------------------
;       * * *  Set  TableChecked
;------------------------------------------------
    xor RAX, RAX
    mov R13, RAX
    mov EAX, [Quest]
    dec EAX
    mov RBX, RAX
    shl RBX, 1
    add RBX, [TableDataBase.data]       ;       pTabCheck
    mov R13w, [RBX]
;------------------------------------------------
;       * * *  Set  TableField
;------------------------------------------------
    mov RSI, [TableDataBase.index]      ;       pTabData
    mov EBX, [TableDataBase.fieldsize]
;   xor RAX, RAX
    mul EBX
    add RSI, RAX 
;------------------------------------------------
;       * * *  Set TestField
;------------------------------------------------
    mov EBX, [TestDataBase.fieldsize]
    xor RAX, RAX
    lodsw

    mul EBX
    add EAX, 2
    add RAX, [TestDataBase.index]
    mov [pTabTest], RAX
    mov [pTabData], RSI
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
    mov R14d, EDX
    mov R10d, EBX
    mov [Items], EDX
    mov [ItemCount], EBX
;------------------------------------------------
;       * * *  Type FormHeader
;------------------------------------------------
    InitHtmlSection CSS_TEST
    TypeHtmlSection CLIENT_GET1

    mov EBX, R15d   ;   Time
    call WordToStr

    TypeHtmlSection CLIENT_GET2

    mov EBX, R13d   ;  Check
    call WordToStr

    TypeHtmlSection CLIENT_GET3

    mov RSI, [TableBasePath.table]
    mov R11, RSI
    movsq    ;    TABLE_NAME_LENGTH
    movsw

    TypeHtmlSection CLIENT_GET4

    mov EBX, [Quest]
    call WordToStr

    TypeHtmlSection CLIENT_GET5

    mov EBX, R14d  ;  Items
    call WordToStr

    TypeHtmlSection CLIENT_GET6
     SetHtmlSection CLIENT_GET8

    cmp R10b, 1   ;  ItemCount = 1
        ja jmpGetPart@TableClient
        SetHtmlSection CLIENT_GET7

jmpGetPart@TableClient:
    rep movsb 

    TypeHtmlSection CLIENT_GET_ORG
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection CLIENT_GET_HEAD1

    mov RSI, R11
;   mov ESI, [TableBasePath.table]
    movsq    ;    TABLE_NAME_LENGTH
    movsw

    TypeHtmlSection CLIENT_GET_HEAD2

    mov RSI, [pUserName]
    CopyString

    TypeHtmlSection CLIENT_GET_HEAD3
;   mov [pTypeBuffer], RDI
;------------------------------------------------
;       * * *  Set SelectScale
;------------------------------------------------
    mov EBX,  [TableDataBase.tests]
    mov R10d, [Quest]
    mov EAX,  R10d
;   xor EDX,  EDX
    mov RDX,  RCX
    mov R14d, ECX
    mov  DL,  MAX_VIEW_ITEMS
    mov R15d, EBX
    sub R15d, R14d
    cmp R15d, EDX
        jle jmpSetScan@TableClient
        mov R15d, EDX
        sub EAX, MAX_VIEW_CENTER
        cmp EAX, R14d
            jl jmpSetScale@TableClient
            mov R14d, EAX

jmpSetScale@TableClient:
        mov EAX, R14d
        add EAX, EDX
        cmp EAX, EBX
            jl jmpSetScan@TableClient
            sub EBX, EDX
            mov R14d, EBX

jmpSetScan@TableClient:
    mov R13, R14
    shl R13, 1
    add R13, [TableDataBase.data]
;------------------------------------------------
;       * * *  Scan Selector
;------------------------------------------------
jmpSelScan@TableClient:
    mov RSI, R13
    lodsw
    mov R13, RSI 
    mov  DL, 'D'
    inc R14d
    cmp R14d, R10d
        je jmpSelect@TableClient
        mov  DL, 'A'
        test AX, AX 
             jnz jmpSelect@TableClient
             mov DL, 'C'
;------------------------------------------------
;       * * *  TypeScale
;------------------------------------------------
jmpSelect@TableClient:
    xor RCX, RCX
    TypeHtmlSection CLIENT_GET_SEL1

    mov EAX, EDX 
    stosb

;   mov RSI, gettext CLIENT_GET_SEL2@
    mov CL,  CLIENT_GET_SEL2
    rep movsb 

    mov R11, RDI
    mov EBX, R14d
    call WordToStr

    mov R12, RDI
    TypeHtmlSection CLIENT_GET_SEL3

    mov RCX, R12
    mov RSI, R11
    sub RCX, R11
    rep movsb 

    TypeHtmlSection CLIENT_GET_SEL4

    dec R15d
        jnz jmpSelScan@TableClient
;------------------------------------------------
;       * * *  Type Question
;------------------------------------------------
;   mov RDI, [pTypeBuffer]  
    TypeHtmlSection CLIENT_GET_QUEST1

    mov RSI, [TestDataBase.text]
    CopyString

    TypeHtmlSection CLIENT_GET_QUEST2

    mov R11, RDI
    mov EBX, [Quest]
    call WordToStr

    mov R12, RDI
    TypeHtmlSection CLIENT_GET_QUEST3

    mov EBX, [TableDataBase.tests]
    call WordToStr

    TypeHtmlSection CLIENT_GET_QUEST4

    mov RCX, R12
    mov RSI, R11
    sub RCX, R11
    rep movsb 

    TypeHtmlSection CLIENT_GET_QUEST5

    mov RSI, [TestDataBase.text]
    mov RBX, [pTabTest]
    mov RAX, RCX
    mov EAX, [RBX]
    add RSI, RAX
    CopyString

    TypeHtmlSection CLIENT_GET_QUEST6

    mov EAX, [ItemCount]
    call ByteToStr

    TypeHtmlSection CLIENT_GET_QUEST7
;   mov [pTypeBuffer], RDI
;------------------------------------------------
;       * * *  Type Answer Form
;------------------------------------------------
;   xor ECX, ECX
    inc ECX 
    mov R10d, ECX
    mov R15d, [Items]
    mov R12,  [pTabTest]
    mov R14,  [pTabData]

jmpAnsScan@TableClient:
    mov RSI, R14
    xor EAX, EAX
    lodsb
    test AL, AL 
         jz jmpEndForm@TableClient
;------------------------------------------------
;       * * *  Select Items
;------------------------------------------------
         mov R13d, EAX
         mov R14,  RSI
         xor RCX,  RCX

         TypeHtmlSection CLIENT_GET_ITEM1

         mov R11, RDI
         mov EBX, R10d  ;  Items

         call WordToStr
         mov R8, RDI

         TypeHtmlSection CLIENT_GET_ITEM2

         mov RCX, R8
         mov RSI, R11
         sub RCX, R11
         rep movsb 

         TypeHtmlSection CLIENT_GET_ITEM3

         mov RBX, RCX
         mov EBX, R13d
         and BL,  GET_ITEM
         shl EBX, 2
         add RBX, R12
         mov RSI, [TestDataBase.text]
         mov EAX, [RBX]
         add RSI, RAX
         CopyString

         TypeHtmlSection CLIENT_GET_ITEM4

         shl R10d, 1
         dec R15d
             jnz jmpAnsScan@TableClient
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpEndForm@TableClient:
;   mov RDI, pTypeBuffer 
    TypeHtmlSection CLIENT_GET_END1

    mov EBX, [Prev]
    call WordToStr

    TypeHtmlSection CLIENT_GET_END2

    mov EBX, [Next]
    call WordToStr

    TypeHtmlSection CLIENT_GET_END3

;   mov [pTypeBuffer], RDI
    mov EAX, ECX        ;       0
;   xor EAX, EAX        ;       TEST_POST
;------------------------------------------------
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

    mov RSI, [TableBasePath.table]
    movsq    ;    TABLE_NAME_LENGTH
    movsw

    TypeHtmlSection CLIENT_GET_FIN3

    mov RSI, [pUserName]
    CopyString

    TypeHtmlSection CLIENT_GET_FIN4
;------------------------------------------------
;       * * *  Set SelectScale
;------------------------------------------------
;   xor ECX, ECX
    mov R13, RCX    ;    TableDataBase.total
    mov R10, RCX    ;    Ind
    mov R11, RDI
    mov RDI, [pTabCheck]
    call GetTabCheck

    mov R15d, [TableDataBase.tests]
    mov R14,  [TableDataBase.data]    ;   pTabCheck
    mov RDI,  R11
;------------------------------------------------
;       * * *  Scan Selector
;------------------------------------------------
jmpFinScan@FinishClient:
    mov RSI, [pTabCheck]
    lodsw

    mov EBX, EAX
    mov [pTabCheck], RSI 
    mov RSI, R14
    lodsw
    mov R14, RSI 

    mov  DL, 'C'
    test AX, AX
         jz jmpFinType@FinishClient
         mov DL, 'B'
         cmp AX, BX
             jne jmpFinType@FinishClient
;            inc TableDataBase.total
             inc R13d
             mov DL, 'A'
;------------------------------------------------
;       * * *  TypeScale
;------------------------------------------------
jmpFinType@FinishClient:
    mov [TableDataBase.total], R13d
    xor RCX, RCX
    TypeHtmlSection CLIENT_GET_INFO1

    mov EAX, EDX 
    stosb

    TypeHtmlSection CLIENT_GET_INFO2

    inc R10d
    mov EBX, R10d

    call WordToStr

    TypeHtmlSection CLIENT_GET_INFO3
;------------------------------------------------
    dec R15d
        jnz jmpFinScan@FinishClient
;------------------------------------------------
;       * * *  End TotalForm
;------------------------------------------------
    TypeHtmlSection CLIENT_GET_TOTAL1

    mov ECX, [TableDataBase.tests]
;   mov EAX, [TableDataBase.total]
    mov EAX, R13d
    call StrPercent

    TypeHtmlSection CLIENT_GET_TOTAL2

    mov RSI, [TestDataBase.text]
    CopyString

    TypeHtmlSection CLIENT_GET_TOTAL3

;   mov EBX, [TableDataBase.total]
    mov EBX, R13d
    call WordToStr

    TypeHtmlSection CLIENT_GET_TOTAL4

    mov EBX, [TableDataBase.tests]
    call WordToStr

    TypeHtmlSection CLIENT_GET_TOTAL5
;------------------------------------------------
;       * * *  Score
;------------------------------------------------
    mov R15, RDI
    mov RDI, [TestDataBase.scale]
;   xor RCX, RCX
    mov CL,  TEST_SCALE_COUNT
    mov EBX, ECX
    mov EAX, R13d

jmpScoreScan@FinishClient:
    scasw
      jb jmpEndScan@FinishClient
    loop jmpScoreScan@FinishClient

jmpEndScan@FinishClient:
    sub EBX, ECX
    mov RDI, R15
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

    mov R15d, EBX
    call WordToStr

    TypeHtmlSection CLIENT_GET_TOTAL6
    mov [pTypeBuffer], RDI
;------------------------------------------------
;       * * *  CloseCount
;------------------------------------------------
    call GetBaseTime

    mov EAX, EDX
    mov RDX, szBuffer
    mov RDI, RDX
    stosd

    mov EAX, [TableDataBase.total]
    stosw

;   mov EAX, [Score]
;   stosb
    mov [RDI], R15b

    xor R8, R8
    mov R9, R8
    mov R9b, TABLE_HEADER.close
    mov R8b, TABLE_HEADER_SIZE - TABLE_HEADER.close

;   param 4, TABLE_HEADER.close
;   param 3, TABLE_HEADER_SIZE - TABLE_HEADER.close
;   param 2, szBuffer
    param 1, [TableBasePath.path]
    call WriteToPosition

    mov AL, BASE_TABLE + ERR_WRITE
    jECXz jmpEnd@FinishClient
          xor EAX, EAX     ;     TEST_POST

jmpEnd@FinishClient:
    mov RDI, [pTypeBuffer]
    ret
endp
;------------------------------------------------
;       * * *  Client Viewer  * * *
;------------------------------------------------
proc ViewStoreClient
;------------------------------------------------
;       * * *  Get CheckBuffer
;------------------------------------------------
    mov RAX, [lpMemBuffer]
    mov [pTabCheck], RAX
    add RAX, MAX_ANSWER * 2 + 16
    mov [lpMemBuffer],  RAX
    mov [lpSaveBuffer], RAX
;------------------------------------------------
;       * * *  Get Table
;------------------------------------------------
    mov RSI, [AskOption+16]
    call StrToWord

    mov   AL, ERR_GET_TABLE
    test EBX, EBX 
         jz jmpEnd@ViewStoreClient
         mov R12d,  EBX
         mov [Ind], EBX
;------------------------------------------------
;       * * *  Set TableName
;------------------------------------------------
    mov RDI, [TableBasePath.index]
    mov EAX, EBX
    call IndexToStr
;------------------------------------------------
;       * * *  Get Session
;------------------------------------------------
    mov RSI, [AskOption+8]
    call StrToWord

    mov   AL, ERR_GET_PART
    test EBX, EBX 
         jz jmpEnd@ViewStoreClient

         mov [IndexDataBase.session], EBX
;        mov EBX, [IndexDataBase.session]
         mov EDX, R12d   ;   Ind
         call OpenStoreBase

         test EAX, EAX 
              jnz jmpEnd@ViewStoreClient
;------------------------------------------------
;       * * *  Open TestBase
;------------------------------------------------
;   mov RBX, [TableDataBase.testname]
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
    xor RAX, RAX
    mov RBX, RAX
    mov EBX, [TableDataBase.user]
    dec RBX
    mov RDI, [UserDataBase.index]
    mov EAX, [RDI+RBX*4]
    add RAX, [UserDataBase.user]
    mov [pUserName], RAX 
;------------------------------------------------
;       * * *  Get Question
;------------------------------------------------
    mov  RSI, [AskOption+24]
    test RSI, RSI 
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
    xor RBX, RBX
    mov [Time], EBX
;------------------------------------------------
;       * * *  Set TableChecked
;------------------------------------------------
;   xor RBX, RBX
    mov EAX, [Quest]
    dec EAX
    mov EBX, EAX
    shl RBX, 1
    add RBX, [TableDataBase.data]       ;       pTabCheck
    mov DX, [RBX]
;   mov [Check], DX
    mov [Param], EDX
;------------------------------------------------
;       * * *  Set TableField
;------------------------------------------------
    mov RSI, [TableDataBase.index]      ;       pTabData
    mov EBX, [TableDataBase.fieldsize]
    mul EBX
    add RSI, RAX 
;------------------------------------------------
;       * * *  Set TestField
;------------------------------------------------
    mov EBX, [TestDataBase.fieldsize]
    xor RAX, RAX
    lodsw
    mov [Question], EAX
    mul EBX
    add RAX, 2
    add RAX, [TestDataBase.index]
    mov [pTabTest], RAX
    mov [pTabData], RSI 
;------------------------------------------------
;       * * *  Count Items
;------------------------------------------------
    xor RCX, RCX
    mov RBX, RCX
    mov RDX, RCX
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

    mov RSI, [TableBasePath.session]
;   mov RSI, [StoreBasePath.name]
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
    mov RAX, [lpMemBuffer]
    mov [pTabCheck], RAX
    add RAX, MAX_ANSWER * 2 + 16
    mov [lpMemBuffer],  RAX
    mov [lpSaveBuffer], RAX
;------------------------------------------------
;       * * *  Get Part
;------------------------------------------------
    mov RSI, [AskOption+8]
    call StrToWord

    mov   AL, ERR_GET_PART
    test EBX, EBX 
         jz jmpEnd@ViewTableClient
         mov   AL, ERR_GET_TABLE
         mov  RSI, [AskOption+16]
         test RSI, RSI 
              jz jmpEnd@ViewTableClient
;------------------------------------------------
;       * * *  Open Table
;------------------------------------------------
    mov [IndexDataBase.session], EBX
;   mov [Table], RSI
    call OpenTableBase

    test EAX, EAX
         jnz jmpEnd@ViewTableClient
;------------------------------------------------
;       * * *  TestBase
;------------------------------------------------
;   mov RBX, [TableDataBase.testname]
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@ViewTableClient
;------------------------------------------------
;       * * *  Get UserName
;------------------------------------------------
;   mov [pTestName], RAX
    mov EBX, [TableDataBase.group]
    call OpenUserBase

    test EAX, EAX
         jnz jmpEnd@ViewTableClient
;------------------------------------------------
;       * * *  Get UserName
;------------------------------------------------
    xor RAX, RAX
    mov RBX, RAX
    mov EBX, [TableDataBase.user]
    dec RBX
    mov RDI, [UserDataBase.index]
    mov EAX, [RDI+RBX*4]
    add RAX, [UserDataBase.user]
    mov [pUserName], RAX 
;------------------------------------------------
;       * * *  Get Question
;------------------------------------------------
    mov  RSI, [AskOption+24]
    test RSI, RSI 
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
    dec EBX
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

         push RCX
         mov ESI, [TableDataBase.start]
         call TimeToTick

         pop RDX
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
    xor RBX, RBX
    mov EAX, [Quest]
    dec EAX
    mov EBX, EAX
    shl RBX, 1
    add RBX, [TableDataBase.data]       ;       pTabCheck
    mov DX, [RBX]
;   mov [Check], DX
    mov [Param], EDX
;------------------------------------------------
;       * * *  Set TableField
;------------------------------------------------
    mov RSI, [TableDataBase.index]      ;       pTabData
    mov EBX, [TableDataBase.fieldsize]
    mul EBX
    add RSI, RAX 
;------------------------------------------------
;       * * *  Set TestField
;------------------------------------------------
    mov EBX, [TestDataBase.fieldsize]
    xor RAX, RAX
    lodsw
    mov [Question], EAX
    mul EBX
    add RAX, 2
    add RAX, [TestDataBase.index]
    mov [pTabTest], RAX
    mov [pTabData], RSI 
;------------------------------------------------
;       * * *  Count Items
;------------------------------------------------
    xor RCX, RCX
    mov RBX, RCX
    mov RDX, RCX
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

    mov RSI, [TableBasePath.session]
    movsd
    movsb
;   mov EBX, [IndexDataBase.session]
;   call WordToStr

    mov Ax, "';"
    stosw

    mov  EBX, [Time]
    test EBX, EBX
         jz jmpSkipTime@ViewTableClient
         TypeHtmlSection CLIENT_VIEW1

;        mov EBX, [Time]
         call WordToStr

         TypeHtmlSection CLIENT_VIEW2

jmpSkipTime@ViewTableClient:
    CopyHtmlSection CLIENT_VIEW3@, CLIENT_VIEW3 + CLIENT_VIEW4

    mov RSI, [TableBasePath.table]
    movsq    ;    TABLE_NAME_LENGTH
    movsw
;------------------------------------------------
;       * * *  Client FormHeader
;------------------------------------------------
jmpOrgHeader@ViewTableClient:

    CopyHtmlSection CLIENT_VIEW5@, CLIENT_VIEW5 + CLIENT_VIEW6
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection CLIENT_VIEW_HEAD1

    mov RSI, [TableBasePath.table]
    movsq    ;    TABLE_NAME_LENGTH
    movsw

    TypeHtmlSection CLIENT_VIEW_HEAD2

    mov RSI, [pUserName]
    CopyString

    TypeHtmlSection CLIENT_VIEW_HEAD3
;   mov [pTypeBuffer], RDI
;------------------------------------------------
;       * * *  Set SelectScale
;------------------------------------------------
;   mov [Count], ECX
;   mov [Total], ECX
    mov R11, RDI
    mov RDI, [pTabCheck]
    call GetTabCheck

    mov EBX,  [TableDataBase.tests]
    mov R10d, [Quest]
    mov EAX,  R10d
    mov RDI,  R11
    xor EDX,  EDX
    mov R14d, EDX
    mov  DL,  MAX_VIEW_ITEMS
    mov R15d, EBX
    sub R15d, R14d
    cmp R15d, EDX
        jle jmpSetScan@ViewTableClient
        mov R15d, EDX
        sub EAX,  MAX_VIEW_CENTER
        cmp EAX,  R14d
            jl jmpSetScale@ViewTableClient
            mov R14d, EAX

jmpSetScale@ViewTableClient:
        mov EAX, R14d
        add EAX, EDX
        cmp EAX, EBX
            jl jmpSetScan@ViewTableClient
            sub EBX,  EDX
            mov R14d, EBX

jmpSetScan@ViewTableClient:
    mov R13, R14
    shl R13, 1
    mov R12, R13
    add R12, [TableDataBase.data]       ;       pTabCheck
    add R13, [pTabCheck]
;   mov RDI, [pTypeBuffer]
    xor R11, R11    ;   TableDataBase.total
    mov [Count], R11d
;------------------------------------------------
;       * * *  Scan Selector
;------------------------------------------------
jmpSelScan@ViewTableClient:
    mov RSI, R13
    lodsw
    mov BX, AX
    mov R13, RSI 
    mov RSI, R12
    lodsw
    mov R12, RSI 

    mov  DL, 'C'
    test AX, AX
         jz jmpFocus@ViewTableClient
         inc [Count]
         mov DL, 'B'
         cmp AX, BX
             jne jmpFocus@ViewTableClient
             inc R11d   ;   TableDataBase.total
             mov DL, 'A'
;------------------------------------------------
;       * * *  TypeScale
;------------------------------------------------
jmpFocus@ViewTableClient:
    inc R14d
    cmp R14d, R10d
        jne jmpSelect@ViewTableClient
        mov DL, 'D'

jmpSelect@ViewTableClient:
    xor RCX, RCX
    TypeHtmlSection CLIENT_VIEW_SEL1

    mov EAX, EDX 
    stosb

;   mov RSI, gettext CLIENT_VIEW_SEL2@
    mov CL,  CLIENT_VIEW_SEL2
    rep movsb 

    mov R9,  RDI
    mov EBX, R14d
    call WordToStr

    mov RCX, RDI
;   TypeHtmlSection CLIENT_VIEW_SEL3

    mov EAX, ');">'
    stosd

    mov RSI, R9
    sub RCX, R9
    rep movsb 

    TypeHtmlSection CLIENT_VIEW_SEL4
;   mov [pTypeBuffer], RDI
    dec R15d
        jnz jmpSelScan@ViewTableClient
;------------------------------------------------
;       * * *  Type Question
;------------------------------------------------
;   mov RDI, [pTypeBuffer]  
    xor RCX, RCX
    TypeHtmlSection CLIENT_VIEW_LEVEL1

    mov ECX, [TableDataBase.tests]
    mov EAX, R11d   ;   TableDataBase.total
    call StrPercent

    TypeHtmlSection CLIENT_VIEW_LEVEL2

    mov EBX, R11d   ;   TableDataBase.total
    call WordToStr

    TypeHtmlSection CLIENT_VIEW_LEVEL3

    mov EBX, [Count]
    sub EBX, R11d   ;   TableDataBase.total
    call WordToStr

    TypeHtmlSection CLIENT_VIEW_LEVEL4
;------------------------------------------------
;       * * *  Score
;------------------------------------------------
    mov RDX, RDI
    mov RDI, [TestDataBase.scale]
;   xor RCX, RCX
    mov CL,  TEST_SCALE_COUNT
    mov EBX, ECX
    mov EAX, R11d

jmpScoreScan@ViewTableClient:
    scasw
      jb jmpEndScan@ViewTableClient
    loop jmpScoreScan@ViewTableClient

jmpEndScan@ViewTableClient:
    mov RDI, RDX
    sub EBX, ECX
    call WordToStr

    TypeHtmlSection CLIENT_VIEW_QUEST1

    mov RSI, [TestDataBase.text]
    CopyString

    TypeHtmlSection CLIENT_VIEW_QUEST2

    mov EBX, [Question]
    inc EBX
    call WordToStr

    mov AX, '] '
    stosw

    mov EBX, [Quest]
    mov R11, RDI
    call WordToStr

    mov R12, RDI
    TypeHtmlSection CLIENT_VIEW_QUEST3

    mov EBX, [TableDataBase.tests]
    call WordToStr

    TypeHtmlSection CLIENT_VIEW_QUEST4

    mov RCX, R12
    mov RSI, R11
    sub RCX, R11
    rep movsb 

    TypeHtmlSection CLIENT_VIEW_QUEST5

    mov RSI, [TestDataBase.text]
    mov RBX, [pTabTest]
    mov RAX, RCX
    mov EAX, [RBX]
    add RSI, RAX
    CopyString

    TypeHtmlSection CLIENT_VIEW_QUEST6

    mov EAX, [ItemCount]
    call ByteToStr

    TypeHtmlSection CLIENT_VIEW_QUEST7
;   mov [pTypeBuffer], RDI
;------------------------------------------------
;       * * *  Type Answer Form
;------------------------------------------------
    mov R15d, [Items]
;   mov R10w, [Check]
    mov R10d, [Param]
    mov R11,  [pTabTest]
    mov R14,  [pTabData]

jmpAnsScan@ViewTableClient:
    mov RSI, R14   ;  pTabData
    xor RAX, RAX
    lodsb
    test AL, AL 
         jz jmpEndForm@ViewTableClient
;------------------------------------------------
;       * * *  Select Items
;------------------------------------------------
         mov EBX, EAX
         mov R9, RAX
         mov R14, RSI
         xor RCX, RCX
         TypeHtmlSection CLIENT_VIEW_ITEM1

;        mov EDX, R10d   ;   [Check]
         inc ECX
         test BL, SET_ITEM_TRUE
              jnz jmpSelItem@ViewTableClient
              mov AL, 'B'
              test R10w, CX 
                   jnz jmpSetValid@ViewTableClient
                   mov AL, 'C'
                   jmp jmpSetValid@ViewTableClient

jmpSelItem@ViewTableClient:

          mov   AL, 'A'
          test R10w, CX 
               jnz jmpSetValid@ViewTableClient
               mov AL, 'D'

jmpSetValid@ViewTableClient:
         stosb

;        TypeHtmlSection CLIENT_VIEW_ITEM2
         mov RBX, R9
         mov AX, '">' 
         stosw

         and BL,  GET_ITEM
         shl RBX, 2
         add RBX, R11   ;   pTabTest
         mov RSI, [TestDataBase.text]
         mov RAX, RCX
         mov EAX, [RBX]
         add RSI, RAX
         CopyString

         TypeHtmlSection CLIENT_VIEW_ITEM3

         shr R10d, 1

jmpItemNext@ViewTableClient:
         dec R15d
             jnz jmpAnsScan@ViewTableClient
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpEndForm@ViewTableClient:
;   mov RDI, [pTypeBuffer] 
    xor RCX, RCX
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
;   mov [pTypeBuffer], RDI

;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX

jmpEnd@ViewTableClient:
    ret
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
