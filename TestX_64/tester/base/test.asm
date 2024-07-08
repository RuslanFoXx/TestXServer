;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   BASE: Test Editor (Admin)
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Import Text To Test  * * *
;------------------------------------------------
proc GetTextTest
;------------------------------------------------
jmpGetTest@GetTextTest:

    param 1, [TextBasePath.dir]
    call GetFileList
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
    mov RDX, RCX

    InitHtmlSection CSS_VIEW
    TypeHtmlSection TEST_GET
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TEST_GET_HEAD

;   mov [pTypeBuffer], RDI
    test EDX, EDX
         jnz jmpTest@GetTextTest

         TypeHtmlSection TEST_GET_EMPTY
         jmp jmpEnd@GetTextTest
;------------------------------------------------
;       * * *  Init Scan Folder
;------------------------------------------------
jmpTest@GetTextTest:
    mov [pTypeBuffer], RDI
    mov RAX, [pTableFile]
    mov [pFind], RAX
    xor RCX, RCX
    mov [Ind], ECX
;------------------------------------------------
;   * * *  Scan Folder
;------------------------------------------------
jmpTabScan@GetTextTest:

    mov RSI, [pFind]
    lodsq
    mov [pFind], RSI

    test RAX, RAX
         jz jmpEnd@GetTextTest

         mov RSI, RAX
         xor RAX, RAX
         lodsd
         mov [FileSize], RAX
         xor EAX, EAX
         lodsb
         mov RCX, RAX
         sub AL, FILE_EXT_LENGTH + 1
         mov [TestDataBase.pathsize], EAX
         mov RDI, [TextBasePath.name]
         rep movsb

         mov [pName],    gettext TEST_GET_ERR@
         mov [NameSize], TEST_GET_ERR
;------------------------------------------------
;       * * *  Read Test
;------------------------------------------------
         param 1, [TextBasePath.path]
         call ReadToBuffer

;           jECXz jmpError@GetTextTest
        test ECX, ECX
             jz jmpError@GetTextTest
;------------------------------------------------
;       * * *  TestName
;------------------------------------------------
              mov RDI, [pReadBuffer]
              mov [lpMemBuffer], RDI
              xor RCX, RCX
              mov AL,  '#'
              cmp AL, [RDI]
                  jne jmpError@GetTextTest

                  mov RBX, RDI
                  inc RBX
                  mov  CL, TEXT_NAME_LENGTH
                  mov  AL, CHR_LF
                  repne scasb
                    jne jmpError@GetTextTest

                        xor EAX, EAX
                        mov [RDI], AL
;------------------------------------------------
;       * * *  Set Items
;------------------------------------------------
                        mov RSI, RBX
                        call StrTrim

                        sub RDI, RSI
                        mov [pName], RSI
                        mov [NameSize], EDI
                        mov RDI, [pTypeBuffer] 
                        xor RCX, RCX

                        TypeHtmlSection TEST_GET_ITEM1

                        mov RSI, [TextBasePath.name]
                        mov ECX, [TestDataBase.pathsize]
                        rep movsb 

                        SetHtmlSection TEST_GET_ITEM2
                        jmp jmpType@GetTextTest
;------------------------------------------------
;       * * *  Set Error Items
;------------------------------------------------
jmpError@GetTextTest:
         mov RDI, [pTypeBuffer]
;        xor ECX, ECX
         SetHtmlSection TEST_GET_ERROR
;------------------------------------------------
;   * * *  Type Items
;------------------------------------------------
jmpType@GetTextTest:
         rep movsb 

         mov EAX, [Ind]
         inc EAX
         mov [Ind], EAX
;        call WordToStr
         call ByteToStr

;        xor RCX, RCX
         TypeHtmlSection TEST_GET_ITEM3

         mov RSI, [pName]
         mov ECX, [NameSize]
         rep movsb 

         TypeHtmlSection TEST_GET_ITEM4

         mov RSI, [TextBasePath.name]
         mov ECX, [TestDataBase.pathsize]
         rep movsb 

         TypeHtmlSection TEST_GET_ITEM5

         mov RBX, [FileSize]
         call WordToStr

         TypeHtmlSection TEST_GET_ITEM6

         mov [pTypeBuffer], RDI
         jmp jmpTabScan@GetTextTest
;------------------------------------------------
;   * * *  EndForm
;------------------------------------------------
jmpEnd@GetTextTest:
;   xor RCX, RCX
    TypeHtmlSection TEST_GET_END

;   mov [pTypeBuffer], RDI
;   xor EAX, EAX    ;   TEST_POST
    mov RAX, RCX
    ret 
endp
;------------------------------------------------
;   * * *  Create Test  * * *
;------------------------------------------------
proc CreateTest
;------------------------------------------------
;   * * *  Get Test
;------------------------------------------------
    mov   AL, ERR_GET_TEST
    mov  RSI, [AskOption+8]
    test RSI, RSI 
         jz jmpEnd@CreateTest
;------------------------------------------------
;   * * *  Set TestFileName
;------------------------------------------------
;   mov [pName], RSI
    mov RDI, [TextBasePath.name]
    mov RBX, RDI
    CopyString

    mov AL, '.'
    stosb
    mov RDX, RDI

    mov EAX, EXT_TXT
    stosd
;------------------------------------------------
;   * * *  Set BaseFileName
;------------------------------------------------
    mov RDI, [TestBasePath.name]
    mov RSI, RBX
    mov RCX, RDX
    sub RCX, RBX
    rep movsb 

    mov EAX, EXT_TEST
    stosd
;------------------------------------------------
;   * * *  Get Date
;------------------------------------------------
    call GetBaseTime
    mov [TestDataBase.date], EDX
;------------------------------------------------
;   * * *  Read TestTxt
;------------------------------------------------
    param 1, [TextBasePath.path]
    call ReadToBuffer

    mov   AL, BASE_TEXT + ERR_READ
    test ECX, ECX
         jz jmpEnd@CreateTest
;------------------------------------------------
;   * * *  Set Math & Text
;------------------------------------------------
;   R8   = ItemCount
;   R9   = pTestScale
;   R10  = pTestName
;   R11  = pTabQuestion
;   R12  = pTabAnswer
;   R13  = pMath
;   R14d = TestDataBase.answers
;   R15d = TestDataBase.questions
;------------------------------------------------
    mov [TestDataBase.scale], DefaultScaleData
;------------------------------------------------
;   * * *  Set Math & Text
;------------------------------------------------
    xor RAX, RAX
    mov RBX, RAX
    mov RDX, RAX
    mov R8,  RAX    ;    ItemCount
    mov R9,  RAX    ;    TestDataBase.scale
    mov R14, RAX    ;    TestDataBase.answers
    mov R15, RAX    ;    TestDataBase.questions
    mov R13, [lpMemBuffer]
    mov RDI, R13
;   mov R13, RDI    ;    pMath
;   mov [pTabMath], RDI
    add RDI, MAX_QUESTION * 2
    mov R10, RDI
;   mov [TestDataBase.text], R10
;   mov RAX, RBX  ;  0
;   mov RAX, szNotName
    mov RAX, [AskOption+8]
    stosq

;   mov [pTestBase],    RDI
;   mov [pTabQuestion], RDI
;   mov [pTabAnswer],   RDI

    mov R11, RDI   ;   pTabQuestion
    mov R12, RDI   ;   pTabAnswer
    mov RSI, [pReadBuffer]
;------------------------------------------------
;   * * *  Scan Strings
;------------------------------------------------
jmpScan@CreateTest:
    lodsb
    test AL, AL
         jz jmpScanEnd@CreateTest
;------------------------------------------------
;   * * *  StrTrim
;------------------------------------------------
    cmp AL, ' '
        jbe jmpScan@CreateTest
;------------------------------------------------
;   * * *  TestScale
;------------------------------------------------
    cmp AL, '='
        jne jmpGetTestName@CreateTest
;------------------------------------------------
        mov R9, RSI     ;     TestDataBase.scale
        jmp jmpGetText@CreateTest
;------------------------------------------------
;   * * *  TestName
;------------------------------------------------
jmpGetTestName@CreateTest:
    cmp AL, '#'
        jne jmpGetQuestion@CreateTest
;       mov RDI, R10    ;     TestDataBase.text
;       mov [RDI], RSI
        mov [R10], RSI  ;     pName
        jmp jmpGetText@CreateTest
;------------------------------------------------
;   * * *  TestQuestion
;------------------------------------------------
jmpGetQuestion@CreateTest:
    cmp AL, '*'
        jne jmpGetAnswer@CreateTest

    cmp R15w, MAX_QUESTION
        jae jmpScanEnd@CreateTest

        mov RDI, R13    ;   pMath
        mov EAX, EDX
        stosw

        mov R13, RDI 
        mov RDI, R11    ;   pTabQuestion
        mov RAX, RSI
        stosq

        mov R12, RDI
        xor RAX, RAX
        mov RCX, RAX
        mov CL,  MAX_ANSWER
        rep stosq

;       add R11, DATA_FIELD_SIZE
        mov R11, RDI
        mov EAX, R8d    ;   ItemCount
        cmp EAX, R14d   ;   TestDataBase.answers
            jbe jmpItemCount@CreateTest 
            mov R14d, EAX

jmpItemCount@CreateTest:
        xor EBX, EBX
        mov R8d, EBX    ;   ItemCount
        inc R15d
        mov EDX, EBX
        inc EBX
        jmp jmpGetText@CreateTest
;------------------------------------------------
;   * * *  TestAnswer
;------------------------------------------------
jmpGetAnswer@CreateTest:
    cmp AL, '-'
        je jmpGetItem@CreateTest

    cmp AL, '+'
        jne jmpGetText@CreateTest
        or EDX, EBX

jmpGetItem@CreateTest:
    shl EBX, 1
    cmp R8w, MAX_ANSWER
        jae jmpGetText@CreateTest
        mov RAX, RSI
        mov RDI, R12  ;   pTabAnswer
        stosq

        mov R12, RDI
        inc R8d       ;   ItemCount
;------------------------------------------------
;   * * *  TestText
;------------------------------------------------
jmpGetText@CreateTest:
    mov RDI, RSI
    mov RCX, [lpMemBuffer]
    sub RCX, RSI
    mov  AL, CHR_LF
    repne scasb
      jne jmpScanEnd@CreateTest
      mov RSI, RDI
      dec RDI
      xor EAX, EAX
      stosb
      jmp jmpScan@CreateTest
;------------------------------------------------
;   * * *  ScanEnd
;------------------------------------------------
jmpScanEnd@CreateTest:
;   mov RDI,   R13   ;   pMath
;   mov [RDI], RDX
    mov [R13], DX
;   sub R11, R10     ;   ItemCount
;------------------------------------------------
;   * * *  ZeroIndexTable
;------------------------------------------------
    mov RDI, R11
    xor RAX, RAX
    mov RCX, RAX
    mov ECX, ZERO_TABLE_COUNT
    rep stosq
;------------------------------------------------
;   * * *  Create Scale
;------------------------------------------------
;   mov RBX, R9    ;    TestDataBase.scale
;   mov  AL, RR_GET_TEST
    test R9, R9
;        jz jmpEnd@CreateTest
         jz jmpScaleEnd@CreateTest
;------------------------------------------------
;   * * *  TrimpScale
;------------------------------------------------
         mov RSI, R9
         mov RDI, R9
         mov DL,  ' '

jmpTrimpScale@CreateTest:
         lodsb
         test AL, AL
              jz jmpSetScale@CreateTest

         cmp AL, DL
             jbe jmpTrimpScale@CreateTest

         stosb
         jmp jmpTrimpScale@CreateTest
;------------------------------------------------
;   * * *  ScanScale
;------------------------------------------------
jmpSetScale@CreateTest:
;        xor EAX, EAX
         stosb

         mov RDI, [TestDataBase.scale]
         mov RSI, R9
         xor RCX, RCX
         mov RBX, RCX
         mov R8b, '0'
         mov R9b, '9'
         mov BL,  10
         mov CL,  TEST_SCALE_COUNT + 2   ;   3
;------------------------------------------------
;       * * *  StrToWord
;------------------------------------------------
jmpScanScale@CreateTest:
;------------------------------------------------
         xor RDX, RDX
         mov R12, RDX

jmpScanParam@CreateTest:
         lodsb
         cmp AL, R8b
             jb jmpParamEnd@CreateTest

         cmp AL, R9b 
             ja jmpParamEnd@CreateTest

             sub AL, R8b
             mov R12b, AL
             mov EAX, EDX
             mul EBX 
             add EAX, R12d
             mov EDX, EAX
             jmp jmpScanParam@CreateTest

jmpParamEnd@CreateTest:
         xchg EAX, EDX    ;    flag
         stosw
         cmp DL, ','
             jne jmpScaleEnd@CreateTest 

         loop jmpScanScale@CreateTest

jmpScaleEnd@CreateTest:
;        mov RSI, [TestDataBase.scale]
;        mov AX,  [RSI] 
;        inc AX
;        mov [RDI], AX 
         mov word[RDI], MAX_QUESTION + 1    
;------------------------------------------------
;   * * *  Delete Spaces
;------------------------------------------------
;   R8   = DATA_FIELD_SIZE64
;   R9   = ItemSize
;   R10  = TestDataBase.text
;   R11d = FieldSize
;   R12d = TestDataBase.questions (ReCount)
;   R13  = 
;   R14d = ItemCount
;   R15d = TestDataBase.questions
;------------------------------------------------
    mov   AL, ERR_GET_PARAM
    test R15, R15        ;    Question
         jz jmpEnd@CreateTest
         mov RBX, R10    ;    TestDataBase.text
         mov RCX, R11    ;    TableEnd
         sub RCX, R10
         shr ECX, 3
         call TrimTabSpace
;------------------------------------------------
;   * * *  Init CountParam
;------------------------------------------------
;        mov R15d        ;   TestDataBase.questions
         inc R14d        ;   ItemCount = Answer + 1
         mov R9, R14
         shl R9d, 3      ;    ItemSize
;        mov [TestDataBase.fieldsize], R9d 
         xor RCX, RCX
         mov R8,  RCX
         mov R11, RCX    ;   FieldSize
         mov R12, RCX    ;   Count
         mov R8b, DATA_FIELD_SIZE
         lea RBX, [R10+8] ;  pTestBase
         mov RDX, RBX
;------------------------------------------------
;   * * *  Count TestParam
;------------------------------------------------
jmpScanField@CreateTest:
         mov RSI, RBX
         lodsq
         add RAX, [RSI]
             jz jmpNextField@CreateTest
;------------------------------------------------
;   * * *  Count Items 
;------------------------------------------------
             mov RSI, RBX
             mov RDI, RDX
             mov ECX, R14d  ;    ItemCount
             rep movsq

             mov RDI, RDX
             mov ECX, R14d  ;    ItemCount + 1
             inc ECX
             xor RAX, RAX
             repne scasq
             sub RDI, RDX   
             cmp EDI, R11d  ;    FieldSize
                 jb jmpNextItem@CreateTest
                 mov R11d, EDI 
;------------------------------------------------
;   * * *  Next Item 
;------------------------------------------------
jmpNextItem@CreateTest:
             add RDX, R9    ;    TestDataBase.fieldsize
             inc R12d       ;    Items

jmpNextField@CreateTest:
         add RBX, R8   ;   DATA_FIELD_SIZE
         dec R15d
             jnz jmpScanField@CreateTest
;------------------------------------------------
;   * * *  Set TextData 
;------------------------------------------------
    mov R9,  R15
    mov R9d, DATA_TABLE_SIZE
    mov RCX, RBX
    mov R15b, 8
    sub R11d, R15d
    shr R11d, 1      ;    FieldSize / 2
    mov RBX, R12     ;    Count
    mov RAX, R11
    mul EBX

    shl EBX, 1
    add RAX, RBX
    add RAX, RCX
    add RAX, DATA_TABLE_SIZE + TEST_HEADER_SIZE
    mov R13, RAX     ;    pTextBuffer
    mov R8,  RAX     ;    pTextOffset
    mov [pTextBuffer], RAX

    mov RBX, R10     ;    TestDataBase.text
    sub RCX, RBX
    shr ECX, 3    
    push RBX
;------------------------------------------------
;   * * *  Cat DoubleString 
;------------------------------------------------
jmpStrScan@CreateTest:
    mov  RDX, [RBX]
    test RDX, RDX
         jz jmpSkip@CreateTest
;------------------------------------------------
;   * * *  Set TextIndex 
;------------------------------------------------
         push RBX
         push RCX
         mov RDI, R8    ;   pTextOffset
         mov R10, R8 
         sub R10, R13   ;   pTextBuffer
         mov [RBX+R9], R10
;------------------------------------------------
;   * * *  Copy TextDataBase 
;------------------------------------------------
;        mov RDI, [pTextOffset] 
         add RBX, R15
         mov RSI, RDX

jmpCopyText@CreateTest:
         lodsb
         stosb
         test AL, AL
              jnz jmpCopyText@CreateTest

         mov R8, RDI    ;   pTextOffset

jmpStrFind@CreateTest:
         mov  RSI, [RBX]
         test RSI, RSI
              jz jmpNextFind@CreateTest
              mov RDI, RDX

jmpCmpStr@CreateTest:
              mov AL, [RDI]
              test AL, AL
                   jnz jmpCmpNext@CreateTest
                   cmp AL, [RSI]
                       jne jmpNextFind@CreateTest
                       mov [RBX+R9], R10

                       xor RAX, RAX
                       mov [RBX], RAX
                       jmp jmpNextFind@CreateTest

jmpCmpNext@CreateTest:
              cmpsb 
                 je jmpCmpStr@CreateTest

jmpNextFind@CreateTest:
         add RBX, R15
         loop jmpStrFind@CreateTest

         pop RCX
         pop RBX

jmpSkip@CreateTest:
    add RBX, R15
    loop jmpStrScan@CreateTest
;------------------------------------------------
;   * * *  Create Header
;------------------------------------------------
    add RBX, DATA_TABLE_SIZE
    mov RDX, RBX
    mov RDI, RBX
    mov EAX, [TestDataBase.date]
    stosd

    xor RAX, RAX
    mov RCX, RAX
    mov CL,  2
    mov R9,  RCX

    mov EAX, R12d    ;    TestDataBase.questions
    stosw

    shr R11d, CL     ;    ItemCount = FieldSize >> 2
    mov EAX, R11d    ;    TestDataBase.answers
    dec EAX
    stosb
;------------------------------------------------
;   * * *  SetScale
;------------------------------------------------
    mov RSI, [TestDataBase.scale]
    lodsw
    test AX, AX
         jnz jmpSetTime@CreateTest
         mov AX, DEFAULT_ITEMS

jmpSetTime@CreateTest:
    stosw
    lodsw
    test AX, AX
         jnz jmpSetScore@CreateTest
         mov AX, DEFAULT_TIME

jmpSetScore@CreateTest:
    stosw
    lodsw
    stosb

;   xor RCX, RCX
    mov  CL, TEST_SCALE_COUNT
    rep movsw
;------------------------------------------------
;   * * *  Create DataBase
;------------------------------------------------
;   mov R11d, [TestDataBase.answers]
;   mov R12d, [TestDataBase.questions]
;   mov RSI,  [TestDataBase.text]
    pop RSI   ;   TestDataBase.text
    add RSI, DATA_TABLE_SIZE + 8
    mov RBX, [lpMemBuffer]
;   mov RBX, [pTabMath]
    add RBX, R9    

jmpMake@CreateTest:
    mov ECX, R11d
    mov AX, [RBX]
    stosw

jmpItem@CreateTest:
    lodsq
    stosd
    loop jmpItem@CreateTest

    add RBX, R9
    dec R12d
        jnz jmpMake@CreateTest
;------------------------------------------------
;   * * *  Write TestBase 
;------------------------------------------------
;   mov R8, [pTextOffset]
    sub R8, RDX
    dec R8
;   param 3, FileSize
;   param 2, RDX
    param 1, [TestBasePath.path]
    call WriteFromBuffer
;------------------------------------------------
    test ECX, ECX
         jnz jmpListTest@ListAllTests
         mov AL, BASE_TEXT + ERR_WRITE
;------------------------------------------------
;   * * *  End 
;------------------------------------------------
jmpEnd@CreateTest:
    ret
endp
;------------------------------------------------
;   * * *  List All Tests  * * *
;------------------------------------------------
proc ListAllTests

jmpListTest@ListAllTests:
;------------------------------------------------
;   * * *  FormHeader
;------------------------------------------------
    InitHtmlSection CSS_VIEW
    TypeHtmlSection TEST_LIST
    TypeHtmlSection FORM_TITLE 

    mov  CL, TEST_LIST_HEAD1 + TEST_LIST_HEAD2
    mov EDX, [ClientAccess.Mode]
    cmp  DL, ACCESS_ADMIN
        je jmpAdd@ListAllTests
        mov CL, TEST_LIST_HEAD1

jmpAdd@ListAllTests:
    mov RSI, gettext TEST_LIST_HEAD1@
    rep movsb 

    TypeHtmlSection TEST_LIST_HEAD3

    mov [pTypeBuffer], RDI
    mov [Ind], ECX
;------------------------------------------------
;       * * *  Get List TestBase
;------------------------------------------------
    param 1, [TestBasePath.dir]
    call GetFileList

;   mov   AL, BASE_TEST + ERR_GET_TEST
    test ECX, ECX
;        jnz jmpEnd@ListAllTests
         jnz jmpHeader@ListAllTests
;------------------------------------------------
;   * * *  Empty Item
;------------------------------------------------
         mov RDI, [pTypeBuffer]
;        mov RCX, RCX
         mov RSI, RCX
         SetHtmlSection TEST_LIST_EMPTY
         jmp jmpEnd@ListAllTests
;------------------------------------------------
;   * * *  Get BaseTest
;------------------------------------------------
jmpHeader@ListAllTests:
    mov RAX, [lpMemBuffer]
    mov [lpSaveBuffer], RAX
    mov [Count], ECX
;------------------------------------------------
;   * * *  Scan Folder
;------------------------------------------------
jmpTabScan@ListAllTests:
    mov RAX, [lpSaveBuffer]
    mov [lpMemBuffer], RAX
    inc [Ind]
    mov RSI, [pTableFile]
    lodsq
    mov RBX, RAX
    mov [pTableFile], RSI
    mov RSI, RBX
    lodsd
    xor RAX, RAX
    mov RDX, RAX
    lodsb
    mov [RBX+RAX], DL
    mov RBX, RSI
    call OpenTestBase

    mov  RDI, [pTypeBuffer]
    test EAX, EAX
         jnz jmpError@ListAllTests
         xor RCX, RCX
         mov RSI, RCX
         TypeHtmlSection TEST_LIST_ITEM1

         mov RSI, [TestBasePath.name]
         mov ECX, [TestDataBase.pathsize]
         rep movsb

         TypeHtmlSection TEST_LIST_ITEM2

         mov EAX, [Ind]
;        call WordToStr
         call ByteToStr

         TypeHtmlSection TEST_LIST_ITEM3

         mov RSI, [TestBasePath.name]
         mov ECX, [TestDataBase.pathsize]
         rep movsb

         TypeHtmlSection TEST_LIST_ITEM4

         mov RSI, [TestDataBase.text]
         CopyString

         TypeHtmlSection TEST_LIST_ITEM5

         mov EBX, [TestDataBase.tests]
         call WordToStr

         TypeHtmlSection TEST_LIST_ITEM6

         mov EAX, [TestDataBase.time]
         call StrSecond

         TypeHtmlSection TEST_LIST_ITEM6

         mov EBX, [TestDataBase.questions]
         call WordToStr

         TypeHtmlSection TEST_LIST_ITEM6

         mov EBX, [TestDataBase.answers]
         call WordToStr

         TypeHtmlSection TEST_LIST_ITEM7
         jmp jmpNext@ListAllTests
;------------------------------------------------
;   * * *  Set ErrorItems
;------------------------------------------------
jmpError@ListAllTests:
         TypeHtmlSection TEST_GET_ERROR
         mov EAX, [Ind]
;        call WordToStr
         call ByteToStr

         TypeHtmlSection TEST_LIST_ITEM4

         mov RSI, [TestBasePath.name]
         mov ECX, [TestDataBase.pathsize]
         rep movsb

         TypeHtmlSection TEST_LIST_ERROR2

jmpNext@ListAllTests:
    mov [pTypeBuffer], RDI
    dec [Count]
        jnz jmpTabScan@ListAllTests

;   mov RDI, [pTypeBuffer]
;------------------------------------------------
;   * * *  TypeForm
;------------------------------------------------
    SetHtmlSection TEST_LIST_END

jmpEnd@ListAllTests:
    rep movsb 

;   mov pTypeBuffer, RDI
;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX
    ret
endp
;------------------------------------------------
;   * * *  Viewer Test Answers  * * *
;------------------------------------------------
proc ViewTestAnswers
;------------------------------------------------
;   * * *  Get TestName
;------------------------------------------------
    mov   AL, ERR_GET_TEST
    mov  RBX, [AskOption+8]
    test EBX, EBX 
         jz jmpEnd@ViewTestAnswers
;------------------------------------------------
;   * * *  TestBase
;------------------------------------------------
    call OpenTestBase

    test EAX, EAX 
         jnz jmpEnd@ViewTestAnswers
;------------------------------------------------
;
;   * * *  Type FormHeader
;
;------------------------------------------------
    InitHtmlSection CSS_VIEW

    mov AL, '.'
    stosb

    mov RSI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    mov RDX, RSI
    mov EBX, ECX
    rep movsb 

    TypeHtmlSection TEST_VIEW
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TEST_VIEW_HEAD1

    mov RSI, RDX    ;    [TestBasePath.name]
    mov ECX, EBX    ;    [TestDataBase.pathsize]
    rep movsb 

    TypeHtmlSection TEST_VIEW_HEAD2
;   mov pTypeBuffer, RDI
;------------------------------------------------
;       * * *  Set SelectScale
;------------------------------------------------
    mov ECX, [TestDataBase.level]
    mov RAX, RCX 
    shr  AX, 4
    mov R12d, EAX   ;  LevelC
    and  CX, 0Fh
    mov R11d, ECX   ;  LevelB
    mov R13d, [TestDataBase.tests]
    mov R14,  [TestDataBase.scale]
    mov R15,  RCX
    mov R15b, TEST_SCALE_COUNT

jmpScanScale@ViewTestAnswers:
    mov RSI, R14
    xor EAX, EAX
    lodsw
;   cmp EAX, [TestDataBase.tests]
    cmp EAX, R13d
        ja jmpInfo@ViewTestAnswers

;   cmp AX, MAX_QUESTION + 1
;       je jmpInfo@ViewTestAnswers

        mov R10, RAX
        mov R14, RSI
        mov EBX, TEST_SCALE_COUNT + 1   ;   1..10
        sub EBX, R15d
        xor RCX, RCX
        mov RSI, RCX

        TypeHtmlSection TEST_VIEW_SEL1
;------------------------------------------------
;       * * *  Level
;------------------------------------------------
        mov AL, 'A'
        cmp BX, R11w  ;   [LevelB] 
            jb jmpSetLevel@ViewTestAnswers
            mov AL, 'B'
            cmp BX, R12w  ;  [LevelC]
                jb jmpSetLevel@ViewTestAnswers
                mov AL, 'C'

jmpSetLevel@ViewTestAnswers:
        stosb

;       TypeHtmlSection TEST_VIEW_SEL2

;       mov AX, '">'
;       stosw
        movsw
;       mov EBX, Ind
        call WordToStr

        mov AL, '.'
        stosb
;;      xor EBX, EBX
;       mov  BX, [Check]
        mov EBX, R10d
        call WordToStr

        TypeHtmlSection TEST_VIEW_SEL3

;       loop jmpScanScale@ViewTestAnswers
        dec R15b
            jnz jmpScanScale@ViewTestAnswers
;------------------------------------------------
;   * * *  Type Info
;------------------------------------------------
jmpInfo@ViewTestAnswers:
    TypeHtmlSection TEST_VIEW_HEAD3

    mov ECX, [TestDataBase.date]
    mov R12d, ECX
    call StrDate

    TypeHtmlSection TEST_VIEW_HEAD4 

    mov ECX, R12d
    call StrTime

    TypeHtmlSection TEST_VIEW_HEAD5

    mov RSI, [TestDataBase.text]        ;   pTestName 
    CopyString

    TypeHtmlSection TEST_VIEW_HEAD6

    mov EBX, [TestDataBase.tests]
    call WordToStr

    TypeHtmlSection TEST_VIEW_HEAD7

    mov EAX, [TestDataBase.questions]
;   call WordToStr
    call ByteToStr

    mov AX, ' ('
    stosw

    mov EBX, [TestDataBase.answers]
    call WordToStr

    TypeHtmlSection TEST_VIEW_HEAD8
;   mov [pTypeBuffer], RDI
;------------------------------------------------
;   * * *  Type Question
;------------------------------------------------
;   xor ECX, ECX 
    mov R15, RCX

jmpTestScan@ViewTestAnswers:
    inc R15d
    TypeHtmlSection TEST_VIEW_QUEST1

    mov R11, RDI
    mov EBX, R15d
    call WordToStr

    mov RDX, RDI
    TypeHtmlSection TEST_VIEW_QUEST2

    mov RSI, R11 
    mov RCX, RDX
    sub RCX, RSI
    rep movsb 

    TypeHtmlSection TEST_VIEW_QUEST3

    mov RSI, [TestDataBase.index]
    xor EAX, EAX
    lodsw
    mov EBX, EAX

    lodsd
    mov R11, RSI

    mov RSI, [TestDataBase.text]
    add RSI, RAX
    CopyString

    TypeHtmlSection TEST_VIEW_QUEST4
;------------------------------------------------
;   * * *  Type Answer
;------------------------------------------------
    mov RDX, RCX
    mov R14d, [TestDataBase.answers]

jmpAnsScan@ViewTestAnswers:
    mov RSI, R11
    lodsd
    test EAX, EAX 
         jz jmpNext@ViewTestAnswers

    mov EDX, EAX
    mov R11, RSI

    TypeHtmlSection TEST_VIEW_ANSWER1

;   mov  CL, 1
    inc ECX
    mov  AL, '0'
    test BX, CX
         jz jmpSel@ViewTestAnswers
         inc EAX

jmpSel@ViewTestAnswers:
    stosb
    shr EBX, CL
    mov AX, '">'
    stosw
    mov RSI, [TestDataBase.text]
    add RSI, RDX
    CopyString

    TypeHtmlSection TEST_VIEW_ANSWER3

;   loop jmpAnsScan@ViewTestAnswers
    dec R14d
        jnz jmpAnsScan@ViewTestAnswers
;------------------------------------------------
;   * * *  End Item
;------------------------------------------------
jmpNext@ViewTestAnswers:
    xor RCX, RCX
    TypeHtmlSection TEST_VIEW_LINE
;------------------------------------------------
;   * * *  Loop Questions
;------------------------------------------------
    mov RAX, RCX
    mov EAX, [TestDataBase.fieldsize]
    add [TestDataBase.index], RAX
    cmp R15d, [TestDataBase.questions]
        jb jmpTestScan@ViewTestAnswers
;------------------------------------------------
;   * * *  EndForm
;------------------------------------------------
;   mov RDI, [pTypeBuffer] 
;   xor RCX, RCX
    mov  CL, TEST_VIEW_END1 + TEST_VIEW_FILE
    mov EAX, [ClientAccess.Mode]
    cmp  AL,  ACCESS_ADMIN
        je jmpFile@ViewTestAnswers
        mov CL, TEST_VIEW_END1

jmpFile@ViewTestAnswers:
    mov RSI, gettext TEST_VIEW_END1@
    rep movsb 

    TypeHtmlSection TEST_VIEW_END2

;   mov [pTypeBuffer], RDI
;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX

jmpEnd@ViewTestAnswers:
    ret 
endp
;------------------------------------------------
;   * * *  Editor Test Answers  * * *
;------------------------------------------------
proc EditTestAnswers
;------------------------------------------------
;   * * *  Get TestName
;------------------------------------------------
    mov   AL, ERR_GET_TEST
    mov  RBX, [AskOption+8]
    test RBX, RBX 
         jz jmpEnd@EditTestAnswers
;------------------------------------------------
;   * * *  TestBase
;------------------------------------------------
;   mov RBX, [pTestName]
;   mov RAX, [lpMemBuffer]
;   mov [lpSaveBuffer], RAX
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@EditTestAnswers
;------------------------------------------------
;   * * *  Get Question
;------------------------------------------------
    mov  RSI, [AskOption+16]
    test RSI, RSI 
         jnz jmpEdit@EditTestAnswers
;------------------------------------------------
;   * * *  Begin Testing
;------------------------------------------------
         xor EAX, EAX
         inc EAX
         mov [Quest], EAX
         inc EAX
         mov [Next], EAX
         mov EAX, [TestDataBase.questions]
         mov [Prev], EAX
         jmp jmpItems@EditTestAnswers
;------------------------------------------------
;   * * *  Begin Testing
;------------------------------------------------
jmpEdit@EditTestAnswers:
    call StrToWord

    mov EDX, [TestDataBase.questions] 
    cmp EAX, EDX 
        jbe jmpQuest@EditTestAnswers
        xor EAX, EAX
        inc EAX

jmpQuest@EditTestAnswers:
    mov EBX, EAX
    mov [Quest], EAX
    inc EAX
    cmp EAX, EDX 
        jbe jmpNext@EditTestAnswers
        xor EAX, EAX
        inc EAX

jmpNext@EditTestAnswers:
    mov [Next], EAX
    dec EBX
        jnz jmpPrev@EditTestAnswers
        mov EBX, EDX

jmpPrev@EditTestAnswers:
    mov [Prev], EBX
;------------------------------------------------
;   * * *  Checked
;------------------------------------------------
    mov RSI, [AskOption+24]
    call StrToWord

    test EAX, EAX 
         jz jmpItems@EditTestAnswers

         mov EBX, [TestDataBase.fieldsize]
         dec EAX
         mul EBX
         add RAX, [TestDataBase.index]
         mov R14, RAX
         mov RSI, [AskOption+32]
         call StrToWord

         cmp EAX, [R14]
             je jmpItems@EditTestAnswers
             mov [R14], AX
             mov R9, R14             ;  position
             sub R9, [lpSaveBuffer]  ;  pTestBase
             xor R8, R8
             mov R8b, 2

;            param 4, position
;            param 3, 2
             param 2, R14
             param 1, [TestBasePath.path]
             call WriteToPosition 

             mov   AL, BASE_TEST + ERR_WRITE
             test ECX, ECX
                  jz jmpEnd@EditTestAnswers
;------------------------------------------------
;   * * *  Set Items
;------------------------------------------------
jmpItems@EditTestAnswers:
    xor RAX, RAX
    mov EBX, [TestDataBase.fieldsize]
    mov EAX, [Quest]
    mov R10d, EAX
    dec EAX
    mul EBX
    add RAX, [TestDataBase.index]
    mov RSI, RAX 
    xor RAX, RAX
    mov R11, RAX
    mov [ItemCount], R11d

    lodsw
;   mov [Check], AX
    mov EDX, EAX
    mov R14d, EAX

    lodsd
    add RAX, [TestDataBase.text]
    mov [pFind], RAX 

    mov [pTabTest], RSI 
    mov ECX, [TestDataBase.answers]
;------------------------------------------------
;   * * *  Count Items
;------------------------------------------------
jmpScan@EditTestAnswers:
    lodsd
    test EAX, EAX
         jz jmpCount@EditTestAnswers

    test EDX, 1
         jz jmpStep@EditTestAnswers
         inc [ItemCount]

jmpStep@EditTestAnswers:
    shr EDX, 1
    inc R11d
    loop jmpScan@EditTestAnswers
;------------------------------------------------
;   * * *  Set Items
;------------------------------------------------
jmpCount@EditTestAnswers:
    mov [Items],    R11d
;   mov [ItmCount], R11d
;------------------------------------------------
;   * * *  Type FormHeader
;------------------------------------------------
    InitHtmlSection CSS_TEST

    mov AL, '.'
    stosb

    mov RSI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb 

    TypeHtmlSection TEST_EDIT1

    mov EBX, R14d    ;    Check
    call WordToStr

    TypeHtmlSection TEST_EDIT2

    mov EBX, R10d    ;    Quest
    call WordToStr

    TypeHtmlSection TEST_EDIT3

    mov EBX, R11d
    call WordToStr

    TypeHtmlSection TEST_EDIT4
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TEST_EDIT_HEAD1

    mov RSI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb 

    TypeHtmlSection TEST_EDIT_HEAD2

    mov EAX, [TestDataBase.time]
    call StrSecond

    TypeHtmlSection TEST_EDIT_HEAD3
;   mov [pTypeBuffer], RDI
;------------------------------------------------
;   * * *  Scan Selector
;------------------------------------------------
    mov EBX,  [TestDataBase.questions]
;   mov R10d, [Quest]
    mov EAX,  R10d
;   xor EDX,  EDX
    mov RDX,  RCX
    mov R14d, ECX
    mov  DL,  MAX_VIEW_ITEMS
    mov R15d, EBX
    sub R15d, R14d
    cmp R15d, EDX
        jle jmpSetScan@EditTestAnswers
        mov R15d, EDX
        sub EAX, MAX_VIEW_CENTER
        cmp EAX, R14d
            jl jmpSetScale@EditTestAnswers
            mov R14d, EAX

jmpSetScale@EditTestAnswers:
        mov EAX, R14d
        add EAX, EDX
        cmp EAX, EBX
            jl jmpSetScan@EditTestAnswers
            sub EBX, EDX
            mov R14d, EBX

jmpSetScan@EditTestAnswers:
;   mov RDI, [pTypeBuffer]
    mov R12b, 'D'
    mov R13b, 'C'
;------------------------------------------------
;   * * *  Scan Selector
;------------------------------------------------
jmpSelScan@EditTestAnswers:
;   mov DL, 'D'
    mov DL, R12b
    inc R14d
    cmp R14d, R10d
        je jmpSelect@EditTestAnswers
;       mov DL, 'C'
        mov DL, R13b
;------------------------------------------------
;   * * *  TypeScale
;------------------------------------------------
jmpSelect@EditTestAnswers:
    xor RCX, RCX
    TypeHtmlSection TEST_EDIT_SEL1

    mov EAX, EDX 
    stosb

    TypeHtmlSection TEST_EDIT_SEL2

    mov R11, RDI
    mov EBX, R14d
    call WordToStr

;   mov R8,  RDI
    mov RCX, RDI

;   TypeHtmlSection TEST_EDIT_SEL3

    mov EAX, ');">'
    stosd

;   mov RCX, R8
    mov RSI, R11
    sub RCX, R11
    rep movsb 

    TypeHtmlSection TEST_EDIT_SEL4

    dec R15d
        jnz jmpSelScan@EditTestAnswers
;------------------------------------------------
;   * * *  Type Question
;------------------------------------------------
;   mov RDI, [pTypeBuffer]  
    mov R12, [TestDataBase.text]

    TypeHtmlSection TEST_EDIT_QUEST1

;   mov RSI, [TestDataBase.text]
    mov RSI, R12
    CopyString

    TypeHtmlSection TEST_EDIT_QUEST2

    mov R11, RDI
    mov EBX, R10d
    call WordToStr

    mov R13, RDI
    TypeHtmlSection TEST_EDIT_QUEST3 

    mov EBX, [TestDataBase.questions]
    call WordToStr

    TypeHtmlSection TEST_EDIT_QUEST4 

    mov RCX, R13
    mov RSI, R11
    sub RCX, R11
    rep movsb 

    TypeHtmlSection TEST_EDIT_QUEST5

    mov RSI, [pFind]
    CopyString

    TypeHtmlSection TEST_EDIT_QUEST6

    mov EBX, [ItemCount]
    call WordToStr

    TypeHtmlSection TEST_EDIT_QUEST7

;   mov [pTypeBuffer], RDI
;------------------------------------------------
;       * * *  Type Answer Form
;------------------------------------------------
;   R8   = RCX
;   R10  = ItemText
;   R11  = RDI
;   R12  = TestDataBase.text
;   R13w = Check
;   R14  = pTabTest
;   R15d = Items
;------------------------------------------------
;   xor ECX, ECX
    inc ECX 
    mov R13d, ECX
;   mov R12,  [TestDataBase.text]
    mov R14,  [pTabTest]
    mov R15d, [Items]

jmpAnsScan@EditTestAnswers:
    mov RSI, R14
    xor RAX, RAX
    lodsd
    test EAX, EAX 
         jz jmpEndForm@EditTestAnswers
         add RAX, R12
         mov R10, RAX
         mov R14, RSI
;        xor RCX, RCX

         TypeHtmlSection TEST_EDIT_ITEM1

         mov R11, RDI
         mov EBX, R13d
         call WordToStr

         mov R8, RDI
         TypeHtmlSection TEST_EDIT_ITEM2

         mov RCX, R8
         mov RSI, R11
         sub RCX, R11
         rep movsb 

         TypeHtmlSection TEST_EDIT_ITEM3

         mov RSI, R10
         CopyString

         TypeHtmlSection TEST_EDIT_ITEM4

         shl R13w, 1
         dec R15d
             jnz jmpAnsScan@EditTestAnswers
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpEndForm@EditTestAnswers:
;   mov RDI, pTypeBuffer 
    TypeHtmlSection TEST_EDIT_END1

    mov EBX, [Prev]
    call WordToStr

    TypeHtmlSection TEST_EDIT_END2

    mov EBX, [Next]
    call WordToStr

    TypeHtmlSection TEST_EDIT_END3

;   mov [pTypeBuffer], RDI
;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX

jmpEnd@EditTestAnswers:
    ret 
endp
;------------------------------------------------
;   * * *  Set Test Options  * * *
;------------------------------------------------
proc SetTestOptions
;------------------------------------------------
;   * * *  Get Test
;------------------------------------------------
    mov   AL, ERR_GET_TEST
    mov  RBX, [AskOption+8]
    test EBX, EBX 
         jz jmpEnd@SetOptionTest
;------------------------------------------------
;   * * *  TestBase
;------------------------------------------------
    call OpenTestBase

    test EAX, EAX 
         jnz jmpEnd@SetOptionTest
;------------------------------------------------
;   * * *  TestOptions
;------------------------------------------------
    mov  RSI, [AskOption+16]
    test RSI, RSI 
         jz jmpFormHeader@SetOptionTest
;------------------------------------------------
;   * * *  Get Header
;------------------------------------------------
         mov RDI, [lpMemBuffer]
         mov R15,  RDI
         xor R10,  R10
         mov R10b, TEST_SCALE_COUNT + 1

jmpIntScan@SetOptionTest:
         call StrToWord

         stosw
         test EAX, EAX 
              jz jmpIntEnd@SetOptionTest

         dec R10d
             jnz jmpIntScan@SetOptionTest
;------------------------------------------------
;   * * *  Set Header
;------------------------------------------------
jmpIntEnd@SetOptionTest:
         mov RDX, RDI
         mov RSI, R15
         mov EBX, [RSI]  ;  TestDataBase.tests
         mov  CL, TEST_SCALE_COUNT - 1

         movsd     ;     Tests + Time
         movsw     ;     Level
         dec RDI
;------------------------------------------------
;   * * *  Get Scale
;------------------------------------------------
jmpWordScale@SetOptionTest:
         lodsw
         test EAX, EAX 
              jz jmpEndScale@SetOptionTest
              cmp EAX, EBX
                  ja jmpEndScale@SetOptionTest
                  stosw

         loop jmpWordScale@SetOptionTest
;------------------------------------------------
;       * * *  Scale End = Test + 1
;------------------------------------------------
jmpEndScale@SetOptionTest:
;        mov EAX, [TestDataBase.tests]
         mov EAX, EBX
         inc EAX            
         stosw     ;     EndOfScale!

         inc ECX
         xor EAX, EAX
         rep stosw
;------------------------------------------------
;       * * *  Compary Header
;------------------------------------------------
         mov RBX, [pReadBuffer]
         lea RDI, [RBX+TEST_HEADER.tests]
         mov RSI, RDX
;        xor RCX, RCX
         mov  CL, TEST_HEADER_SIZE - TEST_HEADER.tests
         param 3, RCX   ;   count
;        param 2, RSI   ;   Buffer
         repe cmpsb
           je jmpFormHeader@SetOptionTest
;------------------------------------------------
;       * * *  Set TestBase
;------------------------------------------------
              mov RDI, TestDataBase.tests
              mov RSI, RDX
              xor RAX, RAX
              mov RCX, RAX
              lodsw
              stosd
;             mov [TestDataBase.tests], EAX

;             mov EAX, ECX
              lodsw
              stosd
;             mov [TestDataBase.time], EAX

              mov EAX, ECX
              lodsb
              stosd
;             mov [TestDataBase.level], EAX

              mov EAX, ECX
              stosq
              mov [RDI], RSI
;             mov [TestDataBase.scale], RSI
;------------------------------------------------
;       * * *  WriteScale
;------------------------------------------------
              mov CL,  TEST_HEADER.tests
              param 4, RCX
;             param 3, TEST_HEADER_SIZE - TEST_HEADER.tests
;             param 2, Buffer
              param 1, [TestBasePath.path]
              call WriteToPosition 

              mov   AL, BASE_TEST + ERR_WRITE
              test ECX, ECX
                   jz jmpEnd@SetOptionTest
;------------------------------------------------
;   * * *  Type FormHeader
;------------------------------------------------
jmpFormHeader@SetOptionTest:
    xor RAX, RAX
;   mov [Ind], EAX

    mov EAX, [TestDataBase.level]
    mov RCX, RAX
    shr  AX, 4
    mov R12d, EAX   ;  LevelC
    and  CX, 0Fh
    mov R11d, ECX   ;  LevelB

    InitHtmlSection CSS_VIEW

    mov AL, '.'
    stosb

    mov RSI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb 

    TypeHtmlSection TEST_SET1

    mov EAX, R12d   ;    LevelC
    call ByteToStr

    TypeHtmlSection TEST_SET2

    mov EAX, R11d   ;    LevelB
    call ByteToStr

    TypeHtmlSection TEST_SET3

    mov EBX,[TestDataBase.tests]
    mov R13d, EBX
    call WordToStr

    TypeHtmlSection TEST_SET4
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TEST_SET_HEAD1

    mov RSI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb 

    TypeHtmlSection TEST_SET_HEAD2
;   mov pTypeBuffer, RDI
;------------------------------------------------
;       * * *  Set SelectScale
;------------------------------------------------
;   mov R13d,[TestDataBase.tests]
    mov R14, [TestDataBase.scale]
    mov R10,  RCX
    mov R15,  RCX
    mov R15b, TEST_SCALE_COUNT - 2

jmpScanScore@SetOptionTest:
;   xor RCX, RCX
    mov RSI, R14
    mov RAX, RCX
    lodsw

    mov EDX, EAX
    mov R14, RSI
    inc R10d

    TypeHtmlSection TEST_SET_SEL1

    test DX, DX
         jz jmpTypeScore@SetOptionTest

;   cmp EDX, [TestDataBase.tests]
    cmp EDX, R13d
        ja jmpTypeScore@SetOptionTest
;------------------------------------------------
;       * * *  Level
;------------------------------------------------
        mov AL, 'A'
        cmp R10w, R11w  ;   [LevelB] 
            jb jmpSetScore@SetOptionTest
            mov AL, 'B'
            cmp R10w, R12w  ;  [LevelC]
                jb jmpSetScore@SetOptionTest
                mov AL, 'C'

jmpSetScore@SetOptionTest:
        stosb
;------------------------------------------------
;       * * *  Set SelectScore
;------------------------------------------------
jmpTypeScore@SetOptionTest:
;   mov RSI, gettext TEST_SET_SEL2@
    mov CL,  TEST_SET_SEL2
    rep movsb 

    mov EAX, R10d
    call ByteToStr

    TypeHtmlSection TEST_SET_SEL3

    test BL, BL
         je jmpGetScore@SetOptionTest
         mov AL, BL
         stosb

jmpGetScore@SetOptionTest:
    mov AL, BH
    stosb

;   TypeHtmlSection TEST_SET_SEL4
;   mov EAX, ');">'
;   stosd
    movsd

    test BL, BL
         je jmpNumScore@SetOptionTest
         mov AL, BL
         stosb

jmpNumScore@SetOptionTest:
    mov AL, BH
    stosb

;   mov RSI, gettext TEST_SET_SEL5@
    mov  CL, TEST_SET_SEL5
    rep movsb 

;   loop jmpScanScore@SetOptionTest
    dec R15b
        jnz jmpScanScore@SetOptionTest
;------------------------------------------------
;       * * *  Type Selector
;------------------------------------------------
;   xor RCX, RCX
    TypeHtmlSection TEST_SET_EDIT1

    mov R14, [TestDataBase.scale]
    mov R10,  RCX
    mov R15,  RCX
    mov R15b, TEST_SCALE_COUNT - 2

jmpScanScale@SetOptionTest:
    mov RSI, R14
    xor RAX, RAX
    mov RBX, RAX
    lodsw

    mov R14, RSI
    test AX, AX
         jz jmpTypeScale@SetOptionTest

;   cmp EAX, [TestDataBase.tests]
    cmp EAX, R13d
        ja jmpTypeScale@SetOptionTest
        mov RBX, RAX
;------------------------------------------------
;       * * *  Set SelectScore
;------------------------------------------------
jmpTypeScale@SetOptionTest:

    TypeHtmlSection TEST_SET_EDIT2

    call WordToStr

    TypeHtmlSection TEST_SET_EDIT3

    inc R10d
    mov EAX, R10d
    call ByteToStr

    TypeHtmlSection TEST_SET_EDIT4

;   loop jmpScanScale@SetOptionTest
    dec R15b
        jnz jmpScanScale@SetOptionTest
;------------------------------------------------
;       * * *  Type Selector
;------------------------------------------------
;   xor RCX, RCX
    TypeHtmlSection TEST_SET_INFO

    mov EAX, R12d
    call ByteToStr

    mov AX, '..'
    stosw

    mov EAX, R11d
    call ByteToStr

    TypeHtmlSection TEST_SET_NAME

    mov RSI, [TestDataBase.text]        ;   pTestName 
    CopyString

    TypeHtmlSection TEST_SET_TEST

    mov RBX, R13
    call WordToStr

    TypeHtmlSection TEST_SET_TIME

    mov EBX, [TestDataBase.time]
    call WordToStr
;------------------------------------------------
;   * * *  EndForm
;------------------------------------------------
jmpEditScale@SetOptionTest:
;   mov RDI, [pTypeBuffer] 
    TypeHtmlSection TEST_SET_END

;   mov [pTypeBuffer], RDI
;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX

jmpEnd@SetOptionTest:
    ret 
endp
;------------------------------------------------
;   * * *  Export Test To File  * * *
;------------------------------------------------
proc TestToFile
;------------------------------------------------
;   * * *  Get TestName
;------------------------------------------------
    mov   AL,  ERR_GET_TEST
    mov  RBX, [AskOption+8]
    test EBX, EBX 
         jz jmpEnd@TestToFile
;------------------------------------------------
;   * * *  TestBase
;------------------------------------------------
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@TestToFile
;------------------------------------------------
;   * * *  Type FormHeader
;------------------------------------------------
    mov RDI, [lpMemBuffer]
    mov AX, '# '
    stosw

    mov RSI, [TestDataBase.text]
    CopyString

    mov AX, END_LF
    stosw
;------------------------------------------------
;   * * *  Type Question + Time + Level
;------------------------------------------------
    mov AX, '= '
    stosw

    mov EBX, [TestDataBase.tests]
    call WordToStr

    mov AX, ', '
    stosw

    mov EBX, [TestDataBase.time]
    call WordToStr

    mov AX, ', '
    stosw

    mov EBX, [TestDataBase.level]
    call WordToStr
;------------------------------------------------
;   * * *  Type Scale
;------------------------------------------------
    mov R15, RCX
    inc ECX
    mov R10, RCX    ;    Check
    mov R15b, TEST_SCALE_COUNT
    mov R14, [TestDataBase.scale]

jmpScanScale@TestToFile:
    mov RSI, R14
;   xor RAX, RAX
    lodsw
    cmp EAX, [TestDataBase.tests]
        ja jmpQuestions@TestToFile

    cmp AX, R10w
        jb jmpQuestions@TestToFile
        mov R14, RSI
        mov R10w, AX    ;    Check
        mov EBX, EAX
        mov AX, ', '
        stosw
        call WordToStr

        dec R15b
            jnz jmpScanScale@TestToFile
;------------------------------------------------
;   * * *  Type Question
;------------------------------------------------
jmpQuestions@TestToFile:
    mov RBX,  [TestDataBase.index]
    mov R14d, [TestDataBase.questions]

jmpTestScan@TestToFile:
    mov EAX, TAB_QUESTION
    stosd

    mov EDX, [RBX]  ;   Check
    xor RSI, RSI
    mov ESI, [RBX+2]
    add RSI, [TestDataBase.text]
    CopyString

    mov AX, END_LF
    stosw
;------------------------------------------------
;   * * *  Type Answer
;------------------------------------------------
    mov ECX, [TestDataBase.answers]
    mov RSI, RBX
    add RSI, 6

jmpAnsScan@TestToFile:
    mov  EAX, ANSWER_FALSE
    test EDX, 1
         jz jmpItem@TestToFile
         mov EAX, ANSWER_TRUE
;------------------------------------------------
;   * * *  Type Items
;------------------------------------------------
jmpItem@TestToFile:
    stosd
    lodsd
    mov R8, RSI
    add RAX, [TestDataBase.text]
    mov RSI, RAX
    CopyString

    mov AL, CHR_LF
    stosb

    mov  RSI, R8
    mov  EAX, [RSI] 
    test EAX, EAX
         jz jmpNext@TestToFile

    shr EDX, 1
    loop jmpAnsScan@TestToFile
;------------------------------------------------
;   * * *  Loop Questions
;------------------------------------------------
jmpNext@TestToFile:
    add EBX, [TestDataBase.fieldsize]
;------------------------------------------------
    dec R14d
        jnz jmpTestScan@TestToFile
;------------------------------------------------
;   * * *  Set TextPath
;------------------------------------------------
    param 3, RDI
    mov RDX, RDI
    mov RDI, [TextBasePath.name]
    mov RSI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb

    mov AL, '.'
    stosb

    mov EAX, EXT_TXT
    stosd
    param 2, [lpMemBuffer]
    param 1, [TextBasePath.path]
    sub R8, RDX
    call WriteFromBuffer

    test ECX, ECX 
         jnz jmpGetTest@GetTextTest
         mov AL, BASE_TEST + ERR_WRITE

jmpEnd@TestToFile:
    ret
endp
;------------------------------------------------
;   * * *   END  * * *
;------------------------------------------------
