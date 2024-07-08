;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   BASE: Test Editor (Admin)
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Import Text To Test  * * *
;------------------------------------------------
proc GetTextTest
;------------------------------------------------
jmpGetTest@GetTextTest:

    mov EDX, [TextBasePath.dir]
    call GetFileList
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
    mov EDX, ECX
    InitHtmlSection CSS_VIEW
    TypeHtmlSection TEST_GET
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TEST_GET_HEAD

;   mov [pTypeBuffer], EDI
    test EDX, EDX
         jnz jmpTest@GetTextTest

         TypeHtmlSection TEST_GET_EMPTY
         jmp jmpEnd@GetTextTest
;------------------------------------------------
;       * * *  Init Scan Folder
;------------------------------------------------
jmpTest@GetTextTest:
    mov [pTypeBuffer], EDI
    mov EAX, [pTableFile]
    mov [pFind], EAX
    xor ECX, ECX
    mov [Ind], ECX
;------------------------------------------------
;   * * *  Scan Folder
;------------------------------------------------
jmpTabScan@GetTextTest:

    mov ESI, [pFind]
    lodsd
    mov [pFind], ESI
    test EAX, EAX
         jz jmpEnd@GetTextTest
         mov ESI, EAX
         lodsd
;        mov [FileSize], EAX
         push EAX
         xor EAX, EAX
         lodsb
         mov ECX, EAX
         sub AL, FILE_EXT_LENGTH + 1
         mov [TestDataBase.pathsize], EAX
         mov EDI, [TextBasePath.name]
         rep movsb

         mov [pName],    gettext TEST_GET_ERR@
         mov [NameSize], TEST_GET_ERR
;------------------------------------------------
;   * * *  Read Test
;------------------------------------------------
         mov EDX, [TextBasePath.path]
         call ReadToBuffer

             jECXz jmpError@GetTextTest
;        test ECX, ECX
;             jz jmpError@GetTextTest
;------------------------------------------------
;       * * *  TestName
;------------------------------------------------
              mov EDI, [pReadBuffer]
              mov [lpMemBuffer], EDI
              xor ECX, ECX
              mov AL,  '#'
              cmp AL, [EDI]
                  jne jmpError@GetTextTest
                  mov EBX, EDI
                  inc EBX
                  mov  CL, TEXT_NAME_LENGTH
                  mov  AL, CHR_LF
                  repne scasb
                    jne jmpError@GetTextTest
                        xor EAX, EAX
                        mov [EDI], AL
;------------------------------------------------
;   * * *  Set Items
;------------------------------------------------
                        mov ESI, EBX
                        call StrTrim

                        sub EDI, ESI
                        mov [pName], ESI
                        mov [NameSize], EDI
                        mov EDI, [pTypeBuffer] 
                        xor ECX, ECX

                        TypeHtmlSection TEST_GET_ITEM1

                        mov ESI, [TextBasePath.name]
                        mov ECX, [TestDataBase.pathsize]
                        rep movsb 

                        SetHtmlSection TEST_GET_ITEM2
                        jmp jmpType@GetTextTest
;------------------------------------------------
;       * * *  Set Error Items
;------------------------------------------------
jmpError@GetTextTest:
         mov EDI, [pTypeBuffer]
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

;        xor ECX, ECX
         TypeHtmlSection TEST_GET_ITEM3

         mov ESI, [pName]
         mov ECX, [NameSize]
         rep movsb 

         TypeHtmlSection TEST_GET_ITEM4

         mov ESI, [TextBasePath.name]
         mov ECX, [TestDataBase.pathsize]
         rep movsb 

         TypeHtmlSection TEST_GET_ITEM5

;        mov EBX, [FileSize]
         pop EBX
         call WordToStr

         TypeHtmlSection TEST_GET_ITEM6

         mov [pTypeBuffer], EDI
         jmp jmpTabScan@GetTextTest
;------------------------------------------------
;   * * *  EndForm
;------------------------------------------------
jmpEnd@GetTextTest:
;   xor ECX, ECX
    TypeHtmlSection TEST_GET_END

;   mov [pTypeBuffer], EDI
;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX
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
    mov  ESI, [AskOption+4]
    test ESI, ESI 
         jz jmpEnd@CreateTest
;------------------------------------------------
;   * * *  Set TestFileName
;------------------------------------------------
    mov [pName], ESI
    mov EDI, [TextBasePath.name]
    mov EBX, EDI
    CopyString

    mov AL, '.'
    stosb
    mov EDX, EDI
    mov EAX, EXT_TXT
    stosd
;------------------------------------------------
;   * * *  Set BaseFileName
;------------------------------------------------
    mov EDI, [TestBasePath.name]
    mov ESI, EBX
    mov ECX, EDX
    sub ECX, EBX
    rep movsb 

    mov EAX, EXT_TEST
    stosd
;------------------------------------------------
;   * * *  Get Date
;------------------------------------------------
    call GetBaseTime
    mov [TestDataBase.date], EDX
;------------------------------------------------
;   * * *  Read TestText
;------------------------------------------------
    mov EDX, [TextBasePath.path]
    call ReadToBuffer

    mov   AL, BASE_TEXT + ERR_READ
    test ECX, ECX
         jz jmpEnd@CreateTest
;------------------------------------------------
;   * * *  Set Math & Text
;------------------------------------------------
    mov EDI, [lpMemBuffer]
    xor EAX, EAX
    mov EBX, EAX
    mov EDX, EAX
    mov [ItemCount], EAX
    mov [TestDataBase.questions], EAX
    mov [TestDataBase.answers], EAX
    mov [pTestScale], EAX
    mov [TestDataBase.scale], DefaultScaleData
;   mov [pTabMath], EDI
    mov [pMath], EDI
    add EDI, MAX_QUESTION * 2
    mov [TestDataBase.text], EDI
;   mov EAX, EDX  ;  0
;   mov EAX, szNotName
    mov EAX, [AskOption+4]
    stosd
;   mov [pTestBase],    EDI
    mov [pTabQuestion], EDI
    mov [pTabAnswer],   EDI
    mov ESI, [pReadBuffer]
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
        mov [pTestScale], ESI
        jmp jmpGetText@CreateTest
;------------------------------------------------
;   * * *  TestName
;------------------------------------------------
jmpGetTestName@CreateTest:
    cmp AL, '#'
        jne jmpGetQuestion@CreateTest
        mov [pName], ESI
        jmp jmpGetText@CreateTest
;------------------------------------------------
;   * * *  TestQuestion
;------------------------------------------------
jmpGetQuestion@CreateTest:
    cmp AL, '*'
        jne jmpGetAnswer@CreateTest

    cmp [TestDataBase.questions], MAX_QUESTION
        jae jmpScanEnd@CreateTest

        mov EDI, [pMath]
        mov EAX, EDX
        stosw

        mov [pMath], EDI 
        mov EDI, [pTabQuestion]
        mov EAX, ESI
        stosd

        mov [pTabAnswer], EDI
        xor EAX, EAX
        mov ECX, EAX
        mov CL,  MAX_ANSWER
        rep stosd 

;       add [pTabQuestion], DATA_FIELD_SIZE
        mov [pTabQuestion], EDI
;       mov [EDI], EAX
        mov EAX, [ItemCount]
        cmp EAX, [TestDataBase.answers]
            jbe jmpItemCount@CreateTest 
            mov [TestDataBase.answers], EAX

jmpItemCount@CreateTest:
        xor EBX, EBX
        mov [ItemCount], EBX
        inc [TestDataBase.questions]
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
    cmp [ItemCount], MAX_ANSWER
        jae jmpGetText@CreateTest
        mov EAX, ESI
        mov EDI, [pTabAnswer]
        stosd
        mov [pTabAnswer], EDI
        inc [ItemCount]
;------------------------------------------------
;   * * *  TestText
;------------------------------------------------
jmpGetText@CreateTest:
    mov EDI, ESI
    mov ECX, [lpMemBuffer]
    sub ECX, ESI
    mov  AL, CHR_LF
    repne scasb
      jne jmpScanEnd@CreateTest
      mov ESI, EDI
      dec EDI
      xor EAX, EAX
      stosb
      jmp jmpScan@CreateTest
;------------------------------------------------
;   * * *  ScanEnd
;------------------------------------------------
jmpScanEnd@CreateTest:
    mov EDI,  [pMath]
    mov [EDI], DX
    mov EAX, [pName]
    mov EDI, [TestDataBase.text]
    mov [EDI], EAX
;------------------------------------------------
;   * * *  ZeroIndexTable
;------------------------------------------------
    mov EDI, [pTabQuestion]
    xor EAX, EAX
    mov ECX, ZERO_TABLE_COUNT
    rep stosd
;------------------------------------------------
;   * * *  Create Scale
;------------------------------------------------
    mov  EBX, [pTestScale]
;   mov   AL, ERR_GET_TEST
    test EBX, EBX
;        jz jmpEnd@CreateTest
         jz jmpScaleEnd@CreateTest
;------------------------------------------------
;   * * *  TrimpScale
;------------------------------------------------
         mov ESI, EBX
         mov EDI, EBX
         mov  DL, ' '

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

         mov EDI, [TestDataBase.scale]
         mov ESI, EBX
         xor ECX, ECX
         mov EBX, ECX
         mov BL,  10
         mov CL,  TEST_SCALE_COUNT + 2   ;   3

jmpScanScale@CreateTest:
         push ECX
;------------------------------------------------
;       * * *  StrToWord
;------------------------------------------------
         xor ECX, ECX
         mov EDX, ECX

jmpScanParam@CreateTest:
         lodsb
         cmp AL, '0'
             jb jmpParamEnd@CreateTest

         cmp AL, '9' 
             ja jmpParamEnd@CreateTest

             sub AL, '0'
             mov CL, AL
             mov EAX, EDX
             mul EBX 
             add EAX, ECX
             mov EDX, EAX
             jmp jmpScanParam@CreateTest

jmpParamEnd@CreateTest:
         xchg EAX, EDX    ;    flag
         stosw
         pop ECX
         cmp DL, ','
             jne jmpScaleEnd@CreateTest 

         loop jmpScanScale@CreateTest

jmpScaleEnd@CreateTest:
;        mov ESI, [TestDataBase.scale]
;        mov AX,  [ESI] 
;        inc AX
;        mov [EDI], AX 
         mov word[EDI], MAX_QUESTION + 1    
;------------------------------------------------
;   * * *  Delete Spaces
;------------------------------------------------
    mov   AL, ERR_GET_PARAM
    mov  EBX, [TestDataBase.questions]
    test EBX, EBX
         jz jmpEnd@CreateTest

         mov EBX, [TestDataBase.text]
         mov ECX, [pTabQuestion]   ;   TableEnd
         sub ECX, EBX
         shr ECX, 2
         call TrimTabSpace
;------------------------------------------------
;   * * *  Init CountParam
;------------------------------------------------
         mov EAX, [TestDataBase.answers]
         inc EAX
         mov [ItemCount], EAX 
         shl EAX, 2
         mov [TestDataBase.fieldsize], EAX 
;        mov EBX, [pTestBase]
         mov EAX, [TestDataBase.text]
         lea EBX, [EAX+4]
         mov EDX, EBX
         mov ECX, [TestDataBase.questions]
         xor EAX, EAX
         mov [Count], EAX
         mov [Items], EAX
;------------------------------------------------
;   * * *  Count TestParam
;------------------------------------------------
jmpScanField@CreateTest:
         mov ESI, EBX
         lodsd
         add EAX, [ESI]
             jz jmpNextField@CreateTest
             push ECX
;------------------------------------------------
;   * * *  Count Items 
;------------------------------------------------
             mov ESI, EBX
             mov EDI, EDX
             mov ECX, [ItemCount]
             push ECX
             rep movsd

             pop ECX
             inc ECX
             mov EDI, EDX
             xor EAX, EAX
             repne scasd

             sub EDI, EDX   
             cmp EDI, [Items]
                 jb jmpNextItem@CreateTest
                 mov [Items], EDI 
;------------------------------------------------
;   * * *  Next Item 
;------------------------------------------------
jmpNextItem@CreateTest:
             pop ECX
             add EDX, [TestDataBase.fieldsize]
             inc [Count]

jmpNextField@CreateTest:
         add EBX, DATA_FIELD_SIZE
         loop jmpScanField@CreateTest
;------------------------------------------------
;   * * *  Set TextData 
;------------------------------------------------
    mov ECX, EBX
    mov EAX, [Items] 
    shr EAX, 2
    dec EAX
    mov [TestDataBase.answers], EAX
    shl EAX, 2
    mov EBX, [Count]
    mul EBX
    shl EBX, 1
    add EAX, EBX
    add EAX, ECX
    add EAX, DATA_TABLE_SIZE + TEST_HEADER_SIZE
    mov [pTextBuffer], EAX
    mov [pTextOffset], EAX

    mov EBX, [TestDataBase.text]
    sub ECX, EBX
    shr ECX, 2    
;------------------------------------------------
;   * * *  Cat DoubleString 
;------------------------------------------------
jmpStrScan@CreateTest:
    mov  EDX, [EBX]
    test EDX, EDX
         jz jmpSkip@CreateTest
         push EBX
         push ECX
;------------------------------------------------
;   * * *  Set TextIndex 
;------------------------------------------------
         mov EDI, [pTextOffset] 
         mov EAX, EDI 
         sub EAX, [pTextBuffer]
         mov [Ind], EAX
         mov [EBX+DATA_TABLE_SIZE], EAX
         add EBX, 4
;------------------------------------------------
;   * * *  Copy TextDataBase 
;------------------------------------------------
;        mov EDI, [pTextOffset] 
         mov ESI, EDX

jmpCopyText@CreateTest:
         lodsb
         stosb
         test AL, AL
              jnz jmpCopyText@CreateTest

         mov [pTextOffset], EDI  

jmpStrFind@CreateTest:
         mov  ESI, [EBX]
         test ESI, ESI
              jz jmpNextFind@CreateTest
              mov EDI, EDX

jmpCmpStr@CreateTest:
              mov  AL, [EDI]
              test AL, AL
                   jnz jmpCmpNext@CreateTest
                   cmp AL, [ESI]
                       jne jmpNextFind@CreateTest
                       mov EAX, [Ind]
                       mov [EBX+DATA_TABLE_SIZE], EAX
                       xor EAX, EAX
                       mov [EBX], EAX
                       jmp jmpNextFind@CreateTest

jmpCmpNext@CreateTest:
              cmpsb 
                 je jmpCmpStr@CreateTest

jmpNextFind@CreateTest:
         add EBX, 4
         loop jmpStrFind@CreateTest

         pop ECX
         pop EBX

jmpSkip@CreateTest:
    add EBX, 4
    loop jmpStrScan@CreateTest
;------------------------------------------------
;   * * *  Create Header
;------------------------------------------------
    add  EBX, DATA_TABLE_SIZE
    push EBX
    mov EDI, EBX
    mov EAX, [TestDataBase.date]
    stosd

    mov EAX, [TestDataBase.questions]
    mov EDX, EAX
    stosw

    mov EAX, [TestDataBase.answers] 
    dec EAX
    stosb
;------------------------------------------------
;   * * *  SetScale
;------------------------------------------------
    mov ESI, [TestDataBase.scale]
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
    xor ECX, ECX
    mov CL, TEST_SCALE_COUNT
    rep movsw
;------------------------------------------------
;   * * *  Create DataBase
;------------------------------------------------
;   mov ESI, [pTestBase]
    mov ESI, [TestDataBase.text]
    add ESI, DATA_TABLE_SIZE + 4
;   mov EDX, [TestDataBase.questions]
    mov EBX, [lpMemBuffer]
;   mov EBX, [pTabMath]
    add EBX, 2    

jmpMake@CreateTest:
    mov ECX, [TestDataBase.answers]
    mov AX,  [EBX]
    stosw
    rep movsd

    add EBX, 2
    dec EDX
        jnz jmpMake@CreateTest
;------------------------------------------------
;   * * *  Write TestBase 
;------------------------------------------------
    pop EDX
    mov EAX, [pTextOffset]
    sub EAX, EDX
    dec EAX
    push EAX
    push EDX
    mov  EDX, [TestBasePath.path]
    call WriteFromBuffer

    test ECX, ECX
         jnz jmpListTest@ListAllTests
         mov AL, BASE_TEXT + ERR_WRITE

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
    mov ESI, gettext TEST_LIST_HEAD1@
    rep movsb 

    TypeHtmlSection TEST_LIST_HEAD3

    mov [pTypeBuffer], EDI
    mov [Ind], ECX
;------------------------------------------------
;       * * *  Get List TestBase
;------------------------------------------------
    mov EDX, [TestBasePath.dir]
    call GetFileList

;   mov   AL, BASE_TEST + ERR_GET_TEST
    test ECX, ECX
;        jnz jmpEnd@ListAllTests
         jnz jmpHeader@ListAllTests
;------------------------------------------------
;   * * *  Empty Item
;------------------------------------------------
         mov EDI, [pTypeBuffer]
;        mov ECX, ECX
         SetHtmlSection TEST_LIST_EMPTY
         jmp jmpEnd@ListAllTests
;------------------------------------------------
;   * * *  Get BaseTest
;------------------------------------------------
jmpHeader@ListAllTests:
    mov ESI, [pTableFile]
    mov EAX, [lpMemBuffer]
    mov [lpSaveBuffer], EAX
    mov [Count], ECX
;------------------------------------------------
;   * * *  Scan Folder
;------------------------------------------------
jmpTabScan@ListAllTests:
    mov EAX, [lpSaveBuffer]
    mov [lpMemBuffer], EAX
    inc [Ind]

    lodsd
    push ECX
    push ESI

    mov EBX, EAX
    mov ESI, EAX
    lodsd

    xor EAX, EAX
    mov EDX, EAX
    lodsb
    mov [EBX+EAX], DL

    mov EBX, ESI
    call OpenTestBase

    mov EDX, [TestDataBase.pathsize]
    inc EDX
    add [pFind], EDX

    mov  EDI, [pTypeBuffer]
    test EAX, EAX
         jnz jmpError@ListAllTests
         xor ECX, ECX
         TypeHtmlSection TEST_LIST_ITEM1

         mov ESI, [TestBasePath.name]
         mov ECX, [TestDataBase.pathsize]
         rep movsb

         TypeHtmlSection TEST_LIST_ITEM2

         mov EAX, [Ind]
;        call WordToStr
         call ByteToStr

         TypeHtmlSection TEST_LIST_ITEM3

         mov ESI, [TestBasePath.name]
         mov ECX, [TestDataBase.pathsize]
         rep movsb

         TypeHtmlSection TEST_LIST_ITEM4

         mov ESI, [TestDataBase.text]
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

         mov ESI, [TestBasePath.name]
         mov ECX, [TestDataBase.pathsize]
         rep movsb

         TypeHtmlSection TEST_LIST_ERROR2
;------------------------------------------------
jmpNext@ListAllTests:
    mov [pTypeBuffer], EDI
    pop ESI
    pop ECX
    dec ECX
        jnz jmpTabScan@ListAllTests

;   mov EDI, [pTypeBuffer]
;------------------------------------------------
;   * * *  TypeForm
;------------------------------------------------
    SetHtmlSection TEST_LIST_END

jmpEnd@ListAllTests:
    rep movsb 

;   mov pTypeBuffer, EDI
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
    mov  EBX, [AskOption+4]
    test EBX, EBX 
         jz jmpEnd@ViewTestAnswers
;------------------------------------------------
;   * * *  TestBase
;------------------------------------------------
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@ViewTestAnswers
;------------------------------------------------
;   * * *  Type FormHeader
;------------------------------------------------
    InitHtmlSection CSS_VIEW

    mov AL, '.'
    stosb
    mov ESI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    mov EDX, ESI
    mov EBX, ECX
    rep movsb 

    TypeHtmlSection TEST_VIEW
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TEST_VIEW_HEAD1

    mov ESI, EDX    ;    [TestBasePath.name]
    mov ECX, EBX    ;    [TestDataBase.pathsize]
    rep movsb 

    TypeHtmlSection TEST_VIEW_HEAD2
;   mov pTypeBuffer, EDI
;------------------------------------------------
;       * * *  Set SelectScale
;------------------------------------------------
    mov ECX, [TestDataBase.level]
    mov EAX, ECX
    shr  AX, 4
    mov [LevelC], AX
    and  CX, 0Fh
    mov [LevelB], CX
    mov ESI, [TestDataBase.scale]
    mov  CL, TEST_SCALE_COUNT

jmpScanScale@ViewTestAnswers:
    xor EAX, EAX
    lodsw
    cmp EAX, [TestDataBase.tests]
        ja jmpInfo@ViewTestAnswers

;   cmp AX, MAX_QUESTION+1
;       je jmpInfo@ViewTestAnswers
        push ECX
        push ESI
        push EAX
        mov EBX, TEST_SCALE_COUNT + 1   ;  1..10
        sub EBX, ECX
        xor ECX, ECX

        TypeHtmlSection TEST_VIEW_SEL1
;------------------------------------------------
;       * * *  Level
;------------------------------------------------
        mov AL, 'A'
        cmp BX, [LevelB] 
            jb jmpSetLevel@ViewTestAnswers
            mov AL, 'B'
            cmp BX, [LevelC]
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
;       mov BX, [Check]
        pop EBX
        call WordToStr

        TypeHtmlSection TEST_VIEW_SEL3

        pop ESI
        pop ECX
        loop jmpScanScale@ViewTestAnswers
;------------------------------------------------
;   * * *  Type Info
;------------------------------------------------
jmpInfo@ViewTestAnswers:
    TypeHtmlSection TEST_VIEW_HEAD3

    mov ECX, [TestDataBase.date] 
    push ECX
    call StrDate

    TypeHtmlSection TEST_VIEW_HEAD4

;   mov ECX, [TestDataBase.date]
    pop ECX
    call StrTime

    TypeHtmlSection TEST_VIEW_HEAD5

    mov ESI, [TestDataBase.text]        ;   pTestName 
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
;   mov [pTypeBuffer], EDI
;------------------------------------------------
;   * * *  Type Question
;------------------------------------------------
;   xor ECX, ECX 
    mov [Ind], ECX

jmpTestScan@ViewTestAnswers:
    TypeHtmlSection TEST_VIEW_QUEST1

    push EDI
    mov EBX, [Ind]
    inc EBX
    mov [Ind], EBX
    call WordToStr

    mov EDX, EDI
    TypeHtmlSection TEST_VIEW_QUEST2

    pop ESI 
    mov ECX, EDX
    sub ECX, ESI
    rep movsb 

    TypeHtmlSection TEST_VIEW_QUEST3

    mov ESI, [TestDataBase.index]
    xor EAX, EAX
    lodsw
    mov EBX, EAX
;   mov [Check], AX
    lodsd
    push ESI

    mov ESI, [TestDataBase.text]
    add ESI, EAX
    CopyString

    TypeHtmlSection TEST_VIEW_QUEST4
;------------------------------------------------
;   * * *  Type Answer
;------------------------------------------------
    pop ESI
    mov ECX, [TestDataBase.answers]

jmpAnsScan@ViewTestAnswers:
    lodsd
    test EAX, EAX 
         jz jmpNext@ViewTestAnswers

    mov EDX, EAX
    push ECX
    push ESI

    TypeHtmlSection TEST_VIEW_ANSWER1

;   mov CL, 1
    inc ECX
;   mov BX, [Check]

    mov  AL, '0'
    test BX, CX
         jz jmpSel@ViewTestAnswers
         inc EAX

jmpSel@ViewTestAnswers:
    stosb
    shr EBX, CL
;   mov [Check], BX

    mov AX, '">'
    stosw

    mov ESI, [TestDataBase.text]
    add ESI, EDX

    CopyString

    TypeHtmlSection TEST_VIEW_ANSWER3

    pop ESI
    pop ECX
    loop jmpAnsScan@ViewTestAnswers
;------------------------------------------------
;   * * *  End Item
;------------------------------------------------
jmpNext@ViewTestAnswers:
    xor ECX, ECX
    TypeHtmlSection TEST_VIEW_LINE
;------------------------------------------------
;   * * *  Loop Questions
;------------------------------------------------
    mov EAX, [TestDataBase.fieldsize]
    add [TestDataBase.index], EAX
    mov EAX, [Ind]
    cmp EAX, [TestDataBase.questions]
        jb jmpTestScan@ViewTestAnswers
;------------------------------------------------
;   * * *  EndForm
;------------------------------------------------
;   mov EDI, [pTypeBuffer] 
;   xor ECX, ECX
    mov  CL, TEST_VIEW_END1 + TEST_VIEW_FILE
    mov EAX, [ClientAccess.Mode]
    cmp  AL, ACCESS_ADMIN
        je jmpFile@ViewTestAnswers
        mov CL, TEST_VIEW_END1

jmpFile@ViewTestAnswers:
    mov ESI, gettext TEST_VIEW_END1@
    rep movsb 

    TypeHtmlSection TEST_VIEW_END2

;   mov [pTypeBuffer], EDI
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
    mov  EBX, [AskOption+4]
    test EBX, EBX 
         jz jmpEnd@EditTestAnswers
;------------------------------------------------
;   * * *  TestBase
;------------------------------------------------
;   mov EBX, [pTestName]
;   mov EAX, [lpMemBuffer]
;   mov [lpSaveBuffer], EAX
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@EditTestAnswers
;------------------------------------------------
;   * * *  Get Question
;------------------------------------------------
    mov  ESI, [AskOption+8]
    test ESI, ESI 
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
    mov ESI, [AskOption+12]
    call StrToWord

    test EAX, EAX 
         jz jmpItems@EditTestAnswers
         mov EBX, [TestDataBase.fieldsize]
         dec EAX
         mul EBX
         add EAX, [TestDataBase.index]
         push EAX

         mov ESI, [AskOption+16]
         call StrToWord
         pop EDI
         cmp EAX, [EDI]
             je jmpItems@EditTestAnswers

             mov [EDI], AX
             mov ECX, EDI            ;   position
             sub ECX, [lpSaveBuffer] ;   pTestBase
             push ECX

             push 2
             push EDI
             mov  EDX, [TestBasePath.path]
             call WriteToPosition 

             mov   AL, BASE_TEST + ERR_WRITE
             test ECX, ECX
                  jz jmpEnd@EditTestAnswers
;------------------------------------------------
;   * * *  Set Items
;------------------------------------------------
jmpItems@EditTestAnswers:
    mov EBX, [TestDataBase.fieldsize]
    mov EAX, [Quest]
    dec EAX

    mul EBX
    add EAX, [TestDataBase.index]
    mov ESI, EAX 

    xor EAX, EAX
    mov EBX, EAX
    mov [ItemCount], EAX

    lodsw
    mov [Param], EAX
    mov EDX, EAX

    lodsd
    add EAX, [TestDataBase.text]
    mov [pFind], EAX 
    mov [pTabTest], ESI 
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
    inc EBX
    loop jmpScan@EditTestAnswers
;------------------------------------------------
;   * * *  Set Items
;------------------------------------------------
jmpCount@EditTestAnswers:
    mov [Items], EBX
;   mov [ItmCount], EBX
    push EBX
;------------------------------------------------
;
;   * * *  Type FormHeader
;
;------------------------------------------------
    InitHtmlSection CSS_TEST
;------------------------------------------------
    mov AL, '.'
    stosb
    mov ESI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb 

    TypeHtmlSection TEST_EDIT1 

    mov EBX, [Param] 
    call WordToStr

    TypeHtmlSection TEST_EDIT2

    mov EBX, [Quest]
    call WordToStr

    TypeHtmlSection TEST_EDIT3

;   mov EBX, [Items] 
    pop EBX
    call WordToStr

    TypeHtmlSection TEST_EDIT4
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TEST_EDIT_HEAD1

    mov ESI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb 

    TypeHtmlSection TEST_EDIT_HEAD2

    mov EAX, [TestDataBase.time]
    call StrSecond

    TypeHtmlSection TEST_EDIT_HEAD3
;   mov [pTypeBuffer], EDI
;------------------------------------------------
;   * * *  Scan Selector
;------------------------------------------------
    mov EBX, [TestDataBase.questions]
    mov EAX, [Quest]
;   xor EDX, EDX
    mov EDX, ECX
    mov ESI, ECX
    mov  DL, MAX_VIEW_ITEMS
    mov ECX, EBX
    sub ECX, ESI
    cmp ECX, EDX
        jle jmpSetScan@EditTestAnswers
        mov ECX, EDX
        sub EAX, MAX_VIEW_CENTER
        cmp EAX, ESI
            jl jmpSetScale@EditTestAnswers
            mov ESI, EAX

jmpSetScale@EditTestAnswers:
        mov EAX, ESI
        add EAX, EDX
        cmp EAX, EBX
            jl jmpSetScan@EditTestAnswers
            sub EBX, EDX
            mov ESI, EBX

jmpSetScan@EditTestAnswers:
    mov [Ind], ESI
;   mov EDI, [pTypeBuffer]
;------------------------------------------------
;   * * *  Scan Selector
;------------------------------------------------
jmpSelScan@EditTestAnswers:
    push ECX
    inc [Ind]
    mov  DL, 'D'
    mov EAX, [Ind]
    cmp EAX, [Quest]
        je jmpSelect@EditTestAnswers
        mov DL, 'C'
;------------------------------------------------
;   * * *  TypeScale
;------------------------------------------------
jmpSelect@EditTestAnswers:
    xor ECX, ECX
    TypeHtmlSection TEST_EDIT_SEL1

    mov EAX, EDX 
    stosb

    TypeHtmlSection TEST_EDIT_SEL2

    push EDI
    mov EBX, [Ind]
    call WordToStr

;   push EDI
    mov ECX, EDI

;   TypeHtmlSection TEST_EDIT_SEL3

    mov EAX, ');">'
    stosd

;   pop ECX
    pop ESI
    sub ECX, ESI
    rep movsb 

    TypeHtmlSection TEST_EDIT_SEL4

    pop ECX
    loop jmpSelScan@EditTestAnswers
;------------------------------------------------
;   * * *  Type Question
;------------------------------------------------
;   mov EDI, [pTypeBuffer]  
    TypeHtmlSection TEST_EDIT_QUEST1

    mov ESI, [TestDataBase.text]
    CopyString

    TypeHtmlSection TEST_EDIT_QUEST2

    push EDI
    mov EBX, [Quest]
    call WordToStr

    push EDI
    TypeHtmlSection TEST_EDIT_QUEST3

    mov EBX, [TestDataBase.questions]
    call WordToStr

    TypeHtmlSection TEST_EDIT_QUEST4

    pop ECX 
    pop ESI 
    sub ECX, ESI
    rep movsb 

    TypeHtmlSection TEST_EDIT_QUEST5

    mov ESI, [pFind]
    CopyString

    TypeHtmlSection TEST_EDIT_QUEST6

    mov EBX, [ItemCount]
    call WordToStr

    TypeHtmlSection TEST_EDIT_QUEST7
;   mov [pTypeBuffer], EDI
;------------------------------------------------
;       * * *  Type Answer Form
;------------------------------------------------
;   xor EBX, EBX
    inc ECX 
    mov EBX, ECX   ;   Check
    mov ECX, [Items]

jmpAnsScan@EditTestAnswers:
    mov ESI, [pTabTest]
    lodsd
    test EAX, EAX 
         jz jmpEndForm@EditTestAnswers
         push ESI
         push ECX
         push EBX
         add EAX, [TestDataBase.text]
         push EAX
         mov [pTabTest], ESI
;        xor ECX, ECX

         TypeHtmlSection TEST_EDIT_ITEM1

         push EDI
;        mov EBX, Check
         call WordToStr

         mov EDX, EDI
         TypeHtmlSection TEST_EDIT_ITEM2

         pop ESI
         mov ECX, EDX
         sub ECX, ESI
         rep movsb 

         TypeHtmlSection TEST_EDIT_ITEM3

         pop ESI
         CopyString

         TypeHtmlSection TEST_EDIT_ITEM4

         pop EBX
         shl EBX, 1
         pop ECX
         pop ESI
         loop jmpAnsScan@EditTestAnswers
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpEndForm@EditTestAnswers:
;   mov EDI, pTypeBuffer 
    TypeHtmlSection TEST_EDIT_END1

    mov EBX, [Prev]
    call WordToStr

    TypeHtmlSection TEST_EDIT_END2

    mov EBX, [Next]
    call WordToStr

    TypeHtmlSection TEST_EDIT_END3

;   mov [pTypeBuffer], EDI
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
    mov  EBX, [AskOption+4]
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
    mov  ESI, [AskOption+8]
    test ESI, ESI 
         jz jmpFormHeader@SetOptionTest
;------------------------------------------------
;   * * *  Get Header
;------------------------------------------------
         mov EDI, [lpMemBuffer]
         xor ECX, ECX
         mov  CL, TEST_SCALE_COUNT + 1

jmpIntScan@SetOptionTest:
         push ECX
         call StrToWord
         pop ECX
         stosw
         test EAX, EAX 
              jz jmpIntEnd@SetOptionTest
;------------------------------------------------
         loop jmpIntScan@SetOptionTest
;------------------------------------------------
;   * * *  Set Header
;------------------------------------------------
jmpIntEnd@SetOptionTest:
         mov ESI, [lpMemBuffer]
         mov EBX, [ESI]  ;  TestDataBase.tests
         mov EDX, EDI
         mov  CL, TEST_SCALE_COUNT - 1
         movsd     ;     Tests + Time
         movsw     ;     Level
         dec EDI
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
         mov EBX, [pReadBuffer]
         lea EDI, [EBX+TEST_HEADER.tests]
         mov ESI, EDX
;        xor ECX, ECX
         mov  CL, TEST_HEADER_SIZE - TEST_HEADER.tests
         mov EBX, ECX
         repe cmpsb
           je jmpFormHeader@SetOptionTest
;------------------------------------------------
;       * * *  Set TestBase
;------------------------------------------------
              mov EDI, TestDataBase.tests
              mov ESI, EDX
              xor EAX, EAX
              mov ECX, EAX
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
              stosd
              mov [EDI], ESI
;             mov [TestDataBase.scale], RSI
;------------------------------------------------
;       * * *  WriteScale
;------------------------------------------------
              mov  CL, TEST_HEADER.tests
              push ECX
              push EBX   ;   TEST_HEADER_SIZE - TEST_HEADER.tests
              push EDX   ;   Buffer
              mov  EDX, [TestBasePath.path]
              call WriteToPosition 

              mov   AL, BASE_TEST + ERR_WRITE
              test ECX, ECX
                   jz jmpEnd@SetOptionTest
;------------------------------------------------
;   * * *  Type FormHeader
;------------------------------------------------
jmpFormHeader@SetOptionTest:
    mov EAX, [TestDataBase.level]
    mov ECX, EAX
    shr  AX, 4
    mov [LevelC], AX
    and  CX, 0Fh
    mov [LevelB], CX

    InitHtmlSection CSS_VIEW

    mov AL, '.'
    stosb

    mov ESI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb 

    TypeHtmlSection TEST_SET1

    mov AX, [LevelC]
    call ByteToStr

    TypeHtmlSection TEST_SET2

    mov AX, [LevelB]
    call ByteToStr

    TypeHtmlSection TEST_SET3

    mov EBX,[TestDataBase.tests]
    call WordToStr

    TypeHtmlSection TEST_SET4
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TEST_SET_HEAD1

    mov ESI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb 

    TypeHtmlSection TEST_SET_HEAD2
;   mov pTypeBuffer, RDI
;------------------------------------------------
;       * * *  Set SelectScale
;------------------------------------------------
;   xor ECX, ECX
    mov [Ind], ECX
    mov ESI, [TestDataBase.scale]
    mov  CL, TEST_SCALE_COUNT - 2

jmpScanScore@SetOptionTest:
;   xor ECX, ECX
    mov EAX, ECX
    lodsw

    mov EDX, EAX
    push ECX
    push ESI
    mov EBX, [Ind]
    inc EBX
    mov [Ind], EBX

    TypeHtmlSection TEST_SET_SEL1

    test DX, DX
         jz jmpTypeScore@SetOptionTest

    cmp EDX, [TestDataBase.tests]
        ja jmpTypeScore@SetOptionTest
;------------------------------------------------
;       * * *  Level
;------------------------------------------------
        mov AL, 'A'
        cmp BX, [LevelB] 
            jb jmpSetScore@SetOptionTest
            mov AL, 'B'
            cmp BX, [LevelC]
                jb jmpSetScore@SetOptionTest
                mov AL, 'C'

jmpSetScore@SetOptionTest:
        stosb
;------------------------------------------------
;       * * *  Set SelectScore
;------------------------------------------------
jmpTypeScore@SetOptionTest:
;   mov ESI, gettext TEST_SET_SEL2@
    mov  CL, TEST_SET_SEL2
    rep movsb 

    mov EAX, EBX
    call ByteToStr

    TypeHtmlSection TEST_SET_SEL3 

    test BL, BL
         je jmpGetScore@SetOptionTest

         mov AL, BL
         stosb

jmpGetScore@SetOptionTest:
    mov AL, BH
    stosb

;   mov ESI, gettext TEST_SET_SEL4@
;   mov CL,  TEST_SET_SEL4
;   rep movsb 

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

;   mov ESI, gettext TEST_SET_SEL5@
    mov CL,  TEST_SET_SEL5
    rep movsb 

    pop ESI
    pop ECX
;   loop jmpScanScore@SetOptionTest
    dec ECX
        jnz jmpScanScore@SetOptionTest
;------------------------------------------------
;       * * *  Type Selector
;------------------------------------------------
;   xor ECX, EAX
    TypeHtmlSection TEST_SET_EDIT1

;   xor ECX, ECX
    mov [Ind], ECX
    mov ESI, [TestDataBase.scale]
    mov  CL,  TEST_SCALE_COUNT - 2
;------------------------------------------------
jmpScanScale@SetOptionTest:
    push ECX
    xor EAX, EAX
    mov EBX, EAX
    lodsw

    push ESI
    test AX, AX
         jz jmpTypeScale@SetOptionTest

    cmp EAX, [TestDataBase.tests]
        ja jmpTypeScale@SetOptionTest
        mov EBX, EAX
;------------------------------------------------
;       * * *  Set SelectScore
;------------------------------------------------
jmpTypeScale@SetOptionTest:

    TypeHtmlSection TEST_SET_EDIT2

    call WordToStr

    TypeHtmlSection TEST_SET_EDIT3 

    mov EAX, [Ind]
    inc EAX
    mov [Ind], EAX
    call ByteToStr

    TypeHtmlSection TEST_SET_EDIT4

    pop ESI
    pop ECX
    loop jmpScanScale@SetOptionTest
;------------------------------------------------
;
;       * * *  Type Selector
;
;------------------------------------------------
;   xor ECX, EAX
    TypeHtmlSection TEST_SET_INFO

    mov AX, [LevelB]
    call ByteToStr

    mov AX, '..'
    stosw

    mov AX, [LevelC]
    call ByteToStr

    TypeHtmlSection TEST_SET_NAME

    mov ESI, [TestDataBase.text]        ;   pTestName 
    CopyString

    TypeHtmlSection TEST_SET_TEST

    mov EBX, [TestDataBase.tests]
    call WordToStr

    TypeHtmlSection TEST_SET_TIME

    mov EBX, [TestDataBase.time]
    call WordToStr
;------------------------------------------------
;   * * *  EndForm
;------------------------------------------------
jmpEditScale@SetOptionTest:
;   mov EDI, [pTypeBuffer] 
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
    mov   AL, ERR_GET_TEST
    mov  EBX, [AskOption+4]
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
    mov EDI, [lpMemBuffer]
    mov AX, '# '
    stosw

    mov ESI, [TestDataBase.text]
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
;   xor ECX, ECX
    inc ECX
    mov EBX, ECX    ;    Check
    mov ESI, [TestDataBase.scale]
    mov  CL, TEST_SCALE_COUNT
;------------------------------------------------
jmpScanScale@TestToFile:
    xor EAX, EAX
    lodsw
    cmp EAX, [TestDataBase.tests]
        ja jmpQuestions@TestToFile

    cmp AX, BX
        jb jmpQuestions@TestToFile
        push ECX
        push ESI
        push EAX    ;    Check

        mov EBX, EAX
        mov AX, ', '
        stosw
        call WordToStr

        pop EBX    ;    Check
        pop ESI
        pop ECX
        loop jmpScanScale@TestToFile
;------------------------------------------------
;   * * *  Type Question
;------------------------------------------------
jmpQuestions@TestToFile:
    mov EBX, [TestDataBase.index]
    mov ECX, [TestDataBase.questions]

jmpTestScan@TestToFile:
    push ECX
    mov EAX, TAB_QUESTION
    stosd

    mov EDX, [EBX]  ;   Check
    mov ESI, [EBX+2]
    add ESI, [TestDataBase.text]
    CopyString

    mov AX, END_LF
    stosw
;------------------------------------------------
;   * * *  Type Answer
;------------------------------------------------
    mov ECX, [TestDataBase.answers]
    mov ESI, EBX
    add ESI, 6

jmpAnsScan@TestToFile:
    mov EAX, ANSWER_FALSE
    test EDX, 1
         jz jmpItem@TestToFile
         mov EAX, ANSWER_TRUE
;------------------------------------------------
;   * * *  Type Items
;------------------------------------------------
jmpItem@TestToFile:
    stosd
    lodsd
    push ESI

    add EAX, [TestDataBase.text]
    mov ESI, EAX
    CopyString

    mov AL, CHR_LF
    stosb

    pop  ESI
    mov  EAX, [ESI] 
    test EAX, EAX
         jz jmpNext@TestToFile

    shr EDX, 1
    loop jmpAnsScan@TestToFile
;------------------------------------------------
;   * * *  Loop Questions
;------------------------------------------------
jmpNext@TestToFile:
    add EBX, [TestDataBase.fieldsize]
    pop ECX
    loop jmpTestScan@TestToFile
;------------------------------------------------
;   * * *  Set TextPath
;------------------------------------------------
    mov EDX, EDI
    mov EDI, [TextBasePath.name]
    mov ESI, [TestBasePath.name]
    mov ECX, [TestDataBase.pathsize]
    rep movsb

    mov AL, '.'
    stosb
    mov EAX, EXT_TXT
    stosd

    mov EAX, [lpMemBuffer]
    sub EDX, EAX

    push EDX
    push EAX
    mov  EDX, [TextBasePath.path]
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
