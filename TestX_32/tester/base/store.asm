;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
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
    mov ESI, [AskOption+4]
    call StrToWord

    mov   AL, ERR_GET_PART
    test EBX, EBX 
         jz jmpEnd@StoreToBase
;------------------------------------------------
;       * * *  Open GroupPart
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
    mov EDI, [TableBaseScan.dir]
    mov ESI, [StoreBasePath.name]
    movsd
    movsb

    xor EAX, EAX
    mov [EDI], AL

    push EAX
    push [TableBaseScan.path]
    call [CreateDirectory]
;------------------------------------------------
    mov  EDX, EAX
    mov   AL, BASE_STORE + ERR_DIRECTORY
    test EDX, EDX
         jz jmpEnd@StoreToBase
;------------------------------------------------
;       * * *  Set TestName + FileSize
;------------------------------------------------
;   mov [mrTablePath + BASE_DIR_LENGTH + BASE_NAME_LENGTH], '\'
    mov ESI, [pReadBuffer] 
    mov EDX, [lpMemBuffer] 
    mov EDI, EDX
    inc ESI  ;  STORE_HEADER.session
;   xor ECX, ECX
;   mov CL,  TABLE_HEADER.user
;   rep movsb    
    movsd
    movsd
    movsb

    mov [pFind], EDI
    add EDI, [TableDataBase.tablesize]
    mov ESI, [TableDataBase.testname]
    CopyString

    sub EDI, EDX
    mov [FileSize], EDI

;   mov [Param], EAX
    mov EDX, [TableDataBase.count]
;------------------------------------------------
;       * * *  Write Table
;------------------------------------------------
jmpTabScan@StoreToBase:
    push EDX

    mov ESI, [TableDataBase.table]
    xor EBX, EBX
    mov  BL, [ESI] 
;   mov EBX, [TableDataBase.user]
    mov EDI, [pFind]
    mov ECX, [TableDataBase.tablesize]
    add [TableDataBase.table], ECX
    rep movsb

    mov EDI, [TableBasePath.index]
    call IndexToStr
;------------------------------------------------
;       * * *  Write To Table
;------------------------------------------------
    push [FileSize]
    push [lpMemBuffer]
    mov  EDX, [TableBasePath.path]
    call WriteFromBuffer

    pop EDX
    mov  AL, BASE_STORE + ERR_WRITE
    cmp ECX, [FileSize]
        jne jmpEnd@StoreToBase

    dec EDX
        jnz jmpTabScan@StoreToBase
;------------------------------------------------
;       * * *  Set Store Attributes
;------------------------------------------------
    mov EAX, [IndexDataBase.count]
;   mov BL,  TABLE_STATUS_CREATE
    xor EBX, EBX
    call SetIndexAttribute

    mov  EBX, [IndexDataBase.group]
;   mov  EBX, [IndexDataBase.session]
    test ECX, ECX
         jnz jmpGroupTable@ListGroupBase
;        jnz jmpViewStore@ViewStoreBase

jmpEnd@StoreToBase:
    ret
endp
;------------------------------------------------
;       * * *  Create Store From Base
;------------------------------------------------
proc CreateStore
;------------------------------------------------
;       * * *  Get Table
;------------------------------------------------
    mov ESI, [AskOption+4]
    call StrToWord

    mov   AL, ERR_GET_PART
    test EBX, EBX 
         jz jmpEnd@CreateStore
;------------------------------------------------
;       * * *  Open GroupPart
;------------------------------------------------
;   mov [IndexDataBase.session], EBX
    call OpenIndexBase

    test EAX, EAX 
         jnz jmpEnd@CreateStore
;------------------------------------------------
;       * * *  Init Scan Folder
;------------------------------------------------
    mov EDI, [StoreBasePath.name]
    mov EBX, [IndexDataBase.session]
    call IndexToStr

    mov EDI, [TableBaseScan.dir]
    mov ESI, [StoreBasePath.name]
    movsd
    movsb

;   xor ECX, ECX
    mov [CountFiles], ECX
    mov [IndexDataBase.count], ECX

    push FindFileData 
    push [TableBaseScan.path] 
    call [FindFirstFile]

    mov EDX, EAX
    mov  AL, BASE_TABLE + ERR_READ
    cmp EDX, INVALID_HANDLE_VALUE
        je jmpEnd@CreateStore
;------------------------------------------------
        mov [hFind], EDX
        mov EAX, [lpMemBuffer]
        mov [pTableFile], EAX
        mov [pFind], EAX
        add EAX, MAX_FILES * TABLE_NAME_LENGTH
        mov [lpMemBuffer], EAX
;------------------------------------------------
;       * * *  Get First Table
;------------------------------------------------
        mov EDI, [TableBasePath.table]
        mov ESI, FindFileData.cFileName
        movsd    ;    TABLE_NAME_LENGTH
        movsd
        movsw

        mov EDX, [TableBasePath.path]
        call ReadToBuffer

        xor EBX, EBX
        mov  BL, TABLE_HEADER_SIZE
        cmp ECX, EBX
            jbe jmpClose@CreateStore

            mov EDX, [lpMemBuffer]
            mov ESI, [pReadBuffer]
            mov [FileSize], ECX

            mov [lpMemBuffer], ESI
            mov [lpSaveBuffer], EDX
            inc EDX  ;  STORE_HEADER.session
            mov EDI, EDX
            mov [pTabCheck], EDX
            movsd
            movsd
            movsb         

            mov [pTableData], EDI  ;   TableDataBase.user
            mov ESI, IndexDataBase.session
            mov EDI, EDX
            sub ECX, EBX

            lodsd    ;    IndexDataBase.session
            stosw    ;    TableDataBase.session

            lodsd
            stosw    ;    TableDataBase.group
            lodsd    ;    IndexDataBase.date

            mov ESI, EDI
            xor EAX, EAX
            mov AL,  2
            sub EDX, EAX
            add ESI, EAX
;           add ESI, 2 ;  TableDataBase.time
            mov EDI, EDX 
;           xor EAX, EAX
            lodsw    ;    TableDataBase.questions
            mov EBX, EAX
            xor EAX, EAX
            lodsb    ;    TableDataBase.answers

            add AL, 2;    answers + 2
            mul EBX
            shl EBX, 1
            add EAX, EBX
            cmp EAX, ECX
                jae jmpClose@CreateStore
                sub ECX, EAX  ;   pathsize
                add AX,  TABLE_HEADER_DATA
                mov [TableDataBase.tablesize], EAX
                mov [NameSize], ECX
                sub EDI, ECX
                mov [TableDataBase.testname], EDI
;------------------------------------------------
;       * * *  Read Table
;------------------------------------------------
jmpTabScan@CreateStore:
        mov EDI, [TableBasePath.table]
        mov EDX, FindFileData.cFileName
        mov ESI, EDX
        movsd    ;    TABLE_NAME_LENGTH
        movsd
        movsw

        mov EDI, [pFind]
;       mov ESI, FindFileData.cFileName
        mov ESI, EDX
        movsd    ;    TABLE_NAME_LENGTH
        movsd
        movsw

        mov [pFind], EDI
        inc [CountFiles]

        mov EDX, [TableBasePath.path]
        call ReadToBuffer
;------------------------------------------------
        cmp ECX, [FileSize]
            jne jmpNext@CreateStore
;------------------------------------------------
;       * * *  Add TableField
;------------------------------------------------
;           xor EAX, EAX
;           mov [mrTablePath + TABLE_DIR_LENGTH + BASE_NAME_LENGTH], AL
;           mov ESI, mrTablePath + TABLE_DIR_LENGTH
;           call StrToInt
;           mov EDX, EAX
            mov ESI, [pReadBuffer]
            mov EDI, [pTabCheck]
            mov [lpMemBuffer], ESI

            xor ECX, ECX
            cmp ECX, [ESI+TABLE_HEADER.start]
                je jmpNext@CreateStore

            cmp ECX, [ESI+TABLE_HEADER.close]
                je jmpNext@CreateStore

            mov CL, TABLE_HEADER.user
            repe cmpsb
             jne jmpNext@CreateStore
                 mov EDI, [pTableData]
                 mov ECX, [TableDataBase.tablesize]
;                mov EAX, EDX
;                    stosw
                 rep movsb

                 mov [pTableData], EDI
                 inc [IndexDataBase.count]
;------------------------------------------------
;       * * *  Set Error Items
;------------------------------------------------
jmpNext@CreateStore:
    push FindFileData 
    push [hFind]
    call [FindNextFile]

    test EAX, EAX
         jnz jmpTabScan@CreateStore

jmpClose@CreateStore:
    push [hFind]
    call [FindClose]
;------------------------------------------------
;       * * *  Write To Store
;------------------------------------------------
    mov BL,  TABLE_STATUS_DELETE
    mov EAX, [IndexDataBase.count]
    test EAX, EAX
         jz jmpSetAttributes@CreateStore
         mov EBX, [lpSaveBuffer]
         mov [EBX], AL
;        mov [EBX+STORE_HEADER.count], AL

         mov EDI, [StoreBasePath.name]
         mov ESI, [TableBasePath.session]
         movsd
         movsb

         mov ESI, [TableDataBase.testname]
         mov EDI, [pTableData]
         mov ECX, [NameSize]
         rep movsb
;------------------------------------------------
;       * * *  Write To Store
;------------------------------------------------
         sub EDI, EBX
         push EDI   ;   FileSize
         push EBX   ;   SaveBuffer
         mov  EDX, [StoreBasePath.path]
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
    mov ESI, [pTableFile] 
    mov ECX, [CountFiles] 

jmpDeleteFile@CreateStore:
    mov EDI, [TableBasePath.table]
;   mov ESI, cFileName
    movsd    ;    TABLE_NAME_LENGTH
    movsd
    movsw

    push ECX
    push ESI
    push [TableBasePath.path]
    call [DeleteFile]

;   test EAX, EAX
;        jz jmpDirError@CreateStore

    pop ESI
    pop ECX
    loop jmpDeleteFile@CreateStore
;------------------------------------------------
;       * * *  Delete Folder
;------------------------------------------------
    xor EAX, EAX
    mov EDI, [TableBaseScan.name]
    mov [EDI], AL
    push [TableBaseScan.path]
    call [RemoveDirectory]

    mov  EBX, [IndexDataBase.group]
;   mov  EBX, [IndexDataBase.session]
    test EAX, EAX
         jnz jmpGroupTable@ListGroupBase
;        jnz jmpViewStore@ViewStoreBase

;jmpDirError@CreateStore:
    mov AL, BASE_STORE + ERR_DIRECTORY

jmpEnd@CreateStore:
    ret
endp
;------------------------------------------------
;       * * *  Viewer Store Clients  * * *
;------------------------------------------------
proc ViewStoreBase
;------------------------------------------------
;       * * *  Get Part
;------------------------------------------------
    mov ESI, [AskOption+4]
    call StrToWord

    mov   AL, ERR_GET_PART
    test EBX, EBX 
         jz jmpEnd@ViewStoreBase
;------------------------------------------------
;       * * *  Get IndexBase
;------------------------------------------------
;   mov [IndexDataBase.part], EBX

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
    mov EBX, [TableDataBase.testname]
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
    mov EDX, [lpMemBuffer]
;   mov [pTableFile], EDX
    mov ECX, [UserDataBase.count]
;   mov ECX, MAX_GROUP + 1
    mov EDI, EDX
    xor EAX, EAX
    rep stosd
;------------------------------------------------
;       * * *  Get TableList
;------------------------------------------------
    mov EBX, EAX
    mov EDI, EDX
    mov ESI, [TableDataBase.table]
    mov EDX, [TableDataBase.tablesize]
    mov ECX, [TableDataBase.count]
;------------------------------------------------
;       * * *  Set IndexName
;------------------------------------------------
jmpScanStore@ViewStoreBase:
;   xor EAX, EAX
    mov AL, [ESI]
;   mov EDI,  [pTableFile]
    mov [EDI+EAX*4], ESI
    inc EBX
    mov [ESI], BL
    add ESI, EDX
    loop jmpScanStore@ViewStoreBase
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
    InitHtmlSection CSS_VIEW
    TypeHtmlSection STORE_VIEW1

    mov ESI, [StoreBasePath.name]
    movsd
    movsb

    TypeHtmlSection STORE_VIEW2

    mov EBX, [IndexDataBase.group]
    call WordToStr

    TypeHtmlSection STORE_VIEW3
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TABLE_VIEW_HEAD1

    mov ESI, [GroupBasePath.name]
    movsd
    movsb

    TypeHtmlSection TABLE_VIEW_HEAD2

    mov ESI, [UserDataBase.user]
    CopyString

    TypeHtmlSection TABLE_VIEW_HEAD3

    mov ESI, [StoreBasePath.name]
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
    call StrDate

    TypeHtmlSection TABLE_VIEW_HEAD6

    mov ECX, [IndexDataBase.date]
    call StrTime

    TypeHtmlSection TABLE_VIEW_HEAD7

;   mov [pTypeBuffer], EDI
;------------------------------------------------
;       * * *  Init Scan
;------------------------------------------------
    mov [Ind], ECX 
    mov [pTypeBuffer], EDI

;   mov ESI, [pTableFile]
    mov ESI, [lpMemBuffer]
    mov ECX, [UserDataBase.count]
    inc ECX
;------------------------------------------------
;       * * *  Type Items
;------------------------------------------------
jmpScanTable@ViewStoreBase:
    lodsd 
    test EAX, EAX
         jz jmpEndItem@ViewStoreBase

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
;------------------------------------------------
;       * * *  Header Item
;------------------------------------------------
         mov EDI, [pTypeBuffer] 
;        xor ECX, ECX

         TypeHtmlSection TABLE_VIEW_ITEM1

;        mov EAX, [TableDataBase.user]   ;  index
         mov EAX, EBX
         call ByteToStr

         TypeHtmlSection TABLE_VIEW_ITEM2

         mov EAX, [Ind]   ;    user
         push EAX
         call ByteToStr

         TypeHtmlSection TABLE_VIEW_ITEM3

         pop EBX
         dec EBX    ;    user

         mov ESI, [UserDataBase.index]
         mov ESI, [ESI+EBX*4]                
         add ESI, [UserDataBase.user]
         CopyString

         TypeHtmlSection TABLE_VIEW_ITEM4

         mov ESI, [TableDataBase.testname]
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

         mov  ECX, [TableDataBase.close]
         push ECX
         call StrDate

         mov EAX, '<br>'
         stosd

;        mov ECX, [TableDataBase.close]
         pop ECX
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
         mov [pTypeBuffer], EDI
         pop ESI
         pop ECX

jmpEndItem@ViewStoreBase:
    inc [Ind]
    dec ECX
        jnz jmpScanTable@ViewStoreBase
;------------------------------------------------
;       * * *  End Item
;------------------------------------------------
;   xor ECX, ECX
    mov  CL, STORE_VIEW_END1 + STORE_VIEW_ARCH
    mov EAX, [ClientAccess.Mode]
    cmp AL,  ACCESS_ADMIN
        je jmpTable@ViewStoreBase
        mov CL, STORE_VIEW_END1

jmpTable@ViewStoreBase:
    mov ESI, gettext STORE_VIEW_END1@
    rep movsb 

    TypeHtmlSection STORE_VIEW_END2

;   mov [pTypeBuffer], EDI
;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX

jmpEnd@ViewStoreBase:
    ret 
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
