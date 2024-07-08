;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   BASE: Store Set + Add (Admin)
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  ReStore Base Tables
;------------------------------------------------
proc StoreToBase
;------------------------------------------------
;       * * *  Get Table
;------------------------------------------------
    mov RSI, [AskOption+8]
    call StrToWord
    mov   AL, ERR_GET_PART
    test EBX, EBX 
         jz jmpEnd@StoreToBase
;------------------------------------------------
;       * * *  Open Groupsession
;------------------------------------------------
;   mov [IndexDataBase.session], EBX
    call OpenIndexBase
    test EAX, EAX 
         jnz jmpEnd@StoreToBase
;------------------------------------------------
;       * * *  Open OpenStoreBase
;------------------------------------------------
    mov EBX, [IndexDataBase.session]
    xor EDX, EDX
    inc EDX   ;    table = 1
    call OpenStoreBase
    test EAX, EAX
         jnz jmpEnd@StoreToBase
;------------------------------------------------
;       * * *  Base Folder
;------------------------------------------------
    mov RDI, [TableBaseScan.dir]
    mov RSI, [StoreBasePath.name]
    movsd
    movsb

    xor RAX, RAX
    param 2, RAX  ;   0
    mov [RDI], AL
;   xor RAX, RAX
    mov  AL, 32
    sub RSP, RAX
;   param 2, 0
    param 1, [TableBaseScan.path]
    call [CreateDirectory]

    mov RDX, RAX
    xor RAX, RAX
    mov AL,  32
    add RSP, RAX
    mov   AL, BASE_STORE + ERR_DIRECTORY
    test EDX, EDX
         jz jmpEnd@StoreToBase
;------------------------------------------------
;       * * *  Set TestName + FileSize
;------------------------------------------------
;   mov [mrTablePath + BASE_DIR_LENGTH + BASE_NAME_LENGTH], '\'
    mov RSI, [pReadBuffer] 
    mov RDX, [lpMemBuffer] 
    mov RDI, RDX
    inc RSI  ;  STORE_HEADER.session
;   xor RCX, RCX
;   mov CL,  TABLE_HEADER.user
;   rep movsb    
    movsq
    movsb

    mov [pFind], RDI
    xor RAX, RAX
    mov EAX, [TableDataBase.tablesize]
    add RDI, RAX
    mov RSI, [TableDataBase.testname]
    CopyString

    sub RDI, RDX
    mov [FileSize], RDI

    mov EAX, [TableDataBase.count]
    inc EAX
    mov [Param], EAX
;------------------------------------------------
;       * * *  Write Table
;------------------------------------------------
jmpTabScan@StoreToBase:
    mov RSI, [TableDataBase.table]
    xor RBX, RBX
    mov RCX, RBX
;   mov EBX, [TableDataBase.user]
    mov  BL, [RSI] 
    mov RDI, [pFind]
    mov ECX, [TableDataBase.tablesize]
    add [TableDataBase.table], RCX
    rep movsb

    mov RDI, [TableBasePath.index]
    call IndexToStr
;------------------------------------------------
;       * * *  Write To Table
;------------------------------------------------
    param 3, [FileSize]
    param 2, [lpMemBuffer]   ;    pTableBase
    param 1, [TableBasePath.path]
    call WriteFromBuffer

    cmp RCX, [FileSize]
        jne jmpEnd@StoreToBase

    dec [Param]
        jnz jmpTabScan@StoreToBase
;------------------------------------------------
;       * * *  Set Store Attributes
;------------------------------------------------
    mov EAX, [IndexDataBase.count]
;   mov  BL, TABLE_STATUS_CREATE
    xor EBX, EBX
    call SetIndexAttribute

    mov  EBX, [IndexDataBase.group]
;   mov  EBX, [IndexDataBase.session]
    test ECX, ECX
         jnz jmpGroupTable@ListGroupBase
;        jnz jmpViewStore@ViewStoreClients

jmpEnd@StoreToBase:
    ret
endp
;------------------------------------------------
;       * * *  Create Store From Base
;------------------------------------------------
proc CreateStore

    xor RAX, RAX
    mov AL,  32
    sub RSP, RAX
;------------------------------------------------
;       * * *  Get Table
;------------------------------------------------
    mov RSI, [AskOption+8]
    call StrToWord
    mov   AL, ERR_GET_PART
    test EBX, EBX 
         jz jmpEnd@CreateStore
;------------------------------------------------
;       * * *  Open GroupSession
;------------------------------------------------
;   mov [IndexDataBase.session], EBX
    call OpenIndexBase

    test EAX, EAX 
         jnz jmpEnd@CreateStore
;------------------------------------------------
;       * * *  Init Scan Folder
;------------------------------------------------
    mov RDI, [TableBasePath.session]
    mov EBX, [IndexDataBase.session]
    call IndexToStr

    mov RDI, [TableBaseScan.dir]
    mov RSI, [TableBasePath.session]
    movsd
    movsb

;   xor ECX, ECX
    mov [CountFiles], ECX
    mov [IndexDataBase.count], ECX
;------------------------------------------------
;       * * *  Init Scan Folder
;------------------------------------------------
    param 2, FindFileData 
    param 1, [TableBaseScan.path]
    call [FindFirstFile]
    mov RDX, RAX
    mov  AL, BASE_TABLE + ERR_READ
    cmp RDX, INVALID_HANDLE_VALUE
        je jmpEnd@CreateStore
        mov [hFind], RDX

        mov RAX, [lpMemBuffer]
        mov [pTableFile], RAX
        mov [pFind], RAX
        xor RDX, RDX
        mov DX,  MAX_FILES * TABLE_NAME_LENGTH
        add RAX, RDX
        mov [lpMemBuffer], RAX
;------------------------------------------------
;       * * *  Get First Table
;------------------------------------------------
        mov RDI, [TableBasePath.table]
        mov RSI, FindFileData.cFileName
        movsq    ;    TABLE_NAME_LENGTH
        movsw

        param 1, [TableBasePath.path]
        call ReadToBuffer
        xor RBX, RBX
        mov  BL, TABLE_HEADER_SIZE
        cmp RCX, RBX
            jbe jmpClose@CreateStore

            mov RDX, [lpMemBuffer]
            mov RSI, [pReadBuffer]

            mov [FileSize], RCX
            mov [lpMemBuffer], RSI
            mov [lpSaveBuffer], RDX

            inc RDX  ;  STORE_HEADER.session
            mov RDI, RDX
            mov [pTabCheck], RDX
            movsq
            movsb        

            mov [pTableData], RDI   ;    TableDataBase.user
            mov RSI, IndexDataBase.session
            mov RDI, RDX
            sub RCX, RBX
            lodsd    ;    IndexDataBase.session
            stosw    ;    TableDataBase.session

            lodsd
            stosw    ;    TableDataBase.group
            lodsd    ;    IndexDataBase.date

            mov RSI, RDI 
            xor RAX, RAX
            mov R8,  RAX 
            mov R8b, 2 ;  TableDataBase.time
            sub RDX, R8
            add RSI, R8
            mov RDI, RDX 
;           xor EAX, EAX
            lodsw    ;    TableDataBase.questions
            mov EBX, EAX
            xor EAX, EAX
            lodsb    ;    TableDataBase.answers

            add EAX, R8d; answers + 2
            mul EBX
            shl EBX, 1
            add EAX, EBX
            cmp RAX, RCX
                jae jmpClose@CreateStore
                sub ECX, EAX  ;   pathsize
                add AX,  TABLE_HEADER_DATA
                mov [TableDataBase.tablesize], EAX
                mov [NameSize], ECX

                sub RDI, RCX
                mov [TableDataBase.testname], RDI
;------------------------------------------------
;       * * *  Read Table
;------------------------------------------------
jmpTabScan@CreateStore:
        mov RDI, [TableBasePath.table]
        mov RDX, FindFileData.cFileName
        mov RSI, RDX
        movsq    ;    TABLE_NAME_LENGTH
        movsw

        mov RDI, [pFind]
;       mov RSI, FindFileData.cFileName
        mov RSI, RDX
        movsq    ;    TABLE_NAME_LENGTH
        movsw

        mov [pFind], RDI
        inc [CountFiles]

        param 1, [TableBasePath.path]
        call ReadToBuffer
        cmp RCX, [FileSize]
            jne jmpNext@CreateStore
;------------------------------------------------
;       * * *  Add TableField
;------------------------------------------------
;           xor EAX, EAX
;           mov [mrTablePath + TABLE_DIR_LENGTH + BASE_NAME_LENGTH], AL
;           mov RSI, mrTablePath + TABLE_DIR_LENGTH
;           call StrToInt

;           mov RDX, RAX
            mov RSI, [pReadBuffer]
            mov RDI, [pTabCheck]

            mov [lpMemBuffer], RSI
            xor RCX, RCX
            cmp ECX, [RSI+TABLE_HEADER.start]
                je jmpNext@CreateStore

            cmp ECX, [RSI+TABLE_HEADER.close]
                je jmpNext@CreateStore

            mov CL, TABLE_HEADER.user
            repe cmpsb
             jne jmpNext@CreateStore

                 mov RDI, [pTableData]
                 mov ECX, [TableDataBase.tablesize]
;                mov EAX, EDX
;                    stosw
                 rep movsb

                 mov [pTableData], RDI
                 inc [IndexDataBase.count]
;------------------------------------------------
;       * * *  Set Error Items
;------------------------------------------------
jmpNext@CreateStore:
        param 2, FindFileData 
        param 1, [hFind]
        call [FindNextFile]

        test EAX, EAX
             jnz jmpTabScan@CreateStore

jmpClose@CreateStore:
        param 1, [hFind]
        call [FindClose]
;------------------------------------------------
;       * * *  Write To Store
;------------------------------------------------
    mov   BL, TABLE_STATUS_DELETE
    mov  EAX, [IndexDataBase.count]
    test EAX, EAX
         jz jmpSetAttributes@CreateStore

         mov RBX, [lpSaveBuffer]
         mov [RBX], AL
;        mov [RBX+STORE_HEADER.count], AL

         mov RDI, [StoreBasePath.name]
         mov RSI, [TableBasePath.session]
         movsd
         movsb

         mov RSI, [TableDataBase.testname]
         mov RDI, [pTableData]
         xor ECX, ECX
         mov ECX, [NameSize]
         rep movsb
;------------------------------------------------
;       * * *  Write To Store
;------------------------------------------------
         param 3, RDI
         sub  R8, RBX   ;   FileSize
         param 2, RBX   ;   SaveBuffer
         param 1, [StoreBasePath.path]
         call WriteFromBuffer

         jECXz jmpEnd@CreateStore
               mov EAX, [IndexDataBase.count]
               mov BL, TABLE_STATUS_ARHIVE
;------------------------------------------------
;       * * *  Set Store Attributes
;------------------------------------------------
jmpSetAttributes@CreateStore:
;   mov EAX, [IndexDataBase.count]
;   mov BL,  TABLE_STATUS_ARHIVE
    call SetIndexAttribute
    jECXz jmpEnd@CreateStore
;------------------------------------------------
;       * * *  Delete TableBase + Directory
;------------------------------------------------
;   mov RSI, [pTableFile] 
;   mov RCX, [CountFiles] 

jmpDeleteFile@CreateStore:
    mov RDI, [TableBasePath.table]
;   mov ESI, cFileName
    mov RSI, [pTableFile] 
    movsq    ;    TABLE_NAME_LENGTH
    movsw

    mov [pTableFile], RSI 
;------------------------------------------------
    param 1, [TableBasePath.path]
    call [DeleteFile]
;   test EAX, EAX
;        jz jmpDirError@CreateStore

    dec [CountFiles]
        jnz jmpDeleteFile@CreateStore
;------------------------------------------------
;       * * *  Delete Folder
;------------------------------------------------
    xor EAX, EAX
    mov RDI, [TableBaseScan.name]
    mov [RDI], AL

    param 1, [TableBaseScan.path]
    call [RemoveDirectory]
    test EAX, EAX
         jz jmpDirError@CreateStore
         xor RAX, RAX
         mov  AL, 32
         add RSP, RAX
         mov EBX, [IndexDataBase.group]
         jnz jmpGroupTable@ListGroupBase

;        mov EBX, [IndexDataBase.session]
;        jnz jmpViewStore@ViewStoreClients

jmpDirError@CreateStore:
    mov AL, BASE_STORE + ERR_DIRECTORY

jmpEnd@CreateStore:
    xor RCX, RCX
    mov  CL, 32
    add RSP, RCX
    ret
endp
;------------------------------------------------
;       * * *  Viewer Store Clients  * * *
;------------------------------------------------
proc ViewStoreBase
;------------------------------------------------
;       * * *  Get Part
;------------------------------------------------
    mov RSI, [AskOption+8]
    call StrToWord

    mov   AL, ERR_GET_PART
    test EBX, EBX 
         jz jmpEnd@ViewStoreBase
;------------------------------------------------
;       * * *  Get IndexBase
;------------------------------------------------
;   mov [IndexDataBase.session], EBX

jmpViewStore@ViewStoreBase:
    call OpenIndexBase

    test EAX, EAX
         jnz jmpEnd@ViewStoreBase
;------------------------------------------------
;       * * *  Open OpenStoreBase
;------------------------------------------------
    mov EBX, [IndexDataBase.session]
    xor EDX, EDX
    inc EDX   ;    table = 1
    call OpenStoreBase
    test EAX, EAX 
         jnz jmpEnd@ViewStoreBase
;------------------------------------------------
;       * * *  Set TestBase
;------------------------------------------------
    mov RBX, [TableDataBase.testname]
    call OpenTestBase
    test EAX, EAX
         jnz jmpEnd@ViewStoreBase
;------------------------------------------------
;       * * *  Set GroupPath
;------------------------------------------------
    mov EBX, [TableDataBase.group]
    call OpenUserBase
    test EAX, EAX
         jnz jmpEnd@ViewStoreBase
;------------------------------------------------
;       * * *  Get FilesBuffer
;------------------------------------------------
    mov RDX, [lpMemBuffer]
;   mov [pTableFile], EDX
    mov ECX, [UserDataBase.count]
;   mov ECX, MAX_GROUP + 1
    mov RDI, RDX
    xor RAX, RAX
    rep stosq
;------------------------------------------------
;       * * *  Get TableList
;------------------------------------------------
    mov RDI, RDX
    mov RCX, RAX
    mov RBX, RAX
    mov RDX, RAX    
    mov RSI, [TableDataBase.table]
    mov EDX, [TableDataBase.tablesize]
    mov ECX, [TableDataBase.count]
;------------------------------------------------
;       * * *  Set IndexName
;------------------------------------------------
jmpScanStore@ViewStoreBase:
;   xor RAX, RAX
    mov AL, [RSI]
;   mov RDI,  [pTableFile]
    mov [RDI+RAX*8], RSI
    inc EBX
    mov [RSI], BL
    add RSI, RDX
    loop jmpScanStore@ViewStoreBase
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
    InitHtmlSection CSS_VIEW
    TypeHtmlSection STORE_VIEW1

    mov RSI, [StoreBasePath.name]
    movsd
    movsb

    TypeHtmlSection STORE_VIEW2

    mov EBX, [IndexDataBase.group]
    call WordToStr

    TypeHtmlSection STORE_VIEW3
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TABLE_VIEW_HEAD1

    mov RSI, [GroupBasePath.name]
    movsd
    movsb

    TypeHtmlSection TABLE_VIEW_HEAD2

    mov RSI, [UserDataBase.user]
    CopyString

    TypeHtmlSection TABLE_VIEW_HEAD3

    mov RSI, [StoreBasePath.name]
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
;       * * *  Type Items
;------------------------------------------------
    mov R12, RCX   ;   index 
    mov [pTypeBuffer], RDI
;   mov RSI,  [pTableFile]
    mov RSI,  [lpMemBuffer]
    mov R15d, [UserDataBase.count]
    inc R15d

jmpScanTable@ViewStoreBase:
    lodsq
    test RAX, RAX
         jz jmpEndItem@ViewStoreBase
         mov R14, RSI
         mov RSI, RAX    ;    pTableBase
;        mov RDI, TableDataBase.user
         mov RDI, TableDataBase.start

         xor RAX, RAX
         mov RCX, RAX
;        mov EAX, ECX
         lodsb
;        stosd
         mov EBX, EAX
;        mov [TableDataBase.user], EAX
         movsq
;        mov [TableDataBase.start], EAX
;        mov [TableDataBase.close], EAX

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
;       * * *  Header Item
;------------------------------------------------
         mov RDI, [pTypeBuffer] 
         xor RCX, RCX

         TypeHtmlSection TABLE_VIEW_ITEM1

;        mov EAX, [TableDataBase.user]
         mov EAX, EBX   ;  index
         call ByteToStr

         TypeHtmlSection TABLE_VIEW_ITEM2

         mov EAX, R12d    ;    user
         call ByteToStr

         TypeHtmlSection TABLE_VIEW_ITEM3

         mov RBX, RCX
;        mov EBX, [TableDataBase.user]
         mov EBX, R12d    ;    user
         dec EBX
         mov RSI, [UserDataBase.index]
         mov RAX, RCX
         mov EAX, [RSI+RBX*4]
         mov RSI, [UserDataBase.user]
         add RSI, RAX
         CopyString

         TypeHtmlSection TABLE_VIEW_ITEM4

         mov RSI, [TableDataBase.testname]
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
         TypeHtmlSection TABLE_VIEW_CLOSE1

         mov ECX, [TableDataBase.close]
         mov R10d, ECX
         call StrDate

         mov EAX, '<br>'
         stosd

;        mov ECX, [TableDataBase.close]
         mov ECX, R10d
         call StrTime

         TypeHtmlSection TABLE_VIEW_CLOSE2

         mov ECX, [TableDataBase.tests]
         mov EAX, [TableDataBase.total]
         call StrPercent

         TypeHtmlSection TABLE_VIEW_CLOSE3

         mov EBX, [TableDataBase.score]
         call WordToStr

         TypeHtmlSection TABLE_VIEW_CLOSE4
;------------------------------------------------
;       * * *  End Item
;------------------------------------------------
         mov [pTypeBuffer], RDI
         mov RSI, R14

jmpEndItem@ViewStoreBase:
    inc R12d
    dec R15d
        jnz jmpScanTable@ViewStoreBase
;------------------------------------------------
;       * * *  End Item
;------------------------------------------------
;   xor RCX, RCX
    mov  CL, STORE_VIEW_END1 + STORE_VIEW_ARCH
    mov EAX, [ClientAccess.Mode]
    cmp AL,  ACCESS_ADMIN
        je jmpTable@ViewStoreBase
        mov CL, STORE_VIEW_END1

jmpTable@ViewStoreBase:
    mov RSI, gettext STORE_VIEW_END1@
    rep movsb 
;------------------------------------------------
;       * * *  End Item
;------------------------------------------------
;   xor RCX, RCX
    TypeHtmlSection STORE_VIEW_END2

;   mov [pTypeBuffer], RDI
;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX

jmpEnd@ViewStoreBase:
    ret 
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
