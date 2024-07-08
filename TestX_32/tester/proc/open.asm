;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   BASE: Open Source DataBase
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Write Index Attributes
;------------------------------------------------
proc SetIndexAttribute
;------------------------------------------------
    mov EDI, Time
;   mov BL,  Attribute
    mov AH, BL
    mov [EDI], AX

    xor EAX, EAX
    mov AL,  2    ;   WORD
    mov ECX, EAX

;   xor EAX, EAX
    mov AL,  INDEX_HEADER_SIZE
    mov EBX, [IndexDataBase.fields]
    sub EBX, [IndexDataBase.session]
    mul EBX
    add EAX, INDEX_HEADER.count + 2

    push EAX 
    push ECX  ;  2
    push EDI  ;  Time 
    mov  EDX, [IndexBasePath]
    call WriteToPosition

;   xor EAX, EAX
    mov AL,  BASE_INDEX + ERR_WRITE
    ret 
endp
;------------------------------------------------
;       * * *  Open IndexBase  * * *
;------------------------------------------------
proc OpenIndexBase

    test EBX, EBX
         jz jmpEnd@OpenIndexBase
         mov [IndexDataBase.session], EBX
;------------------------------------------------
;       * * *  Get BasePath
;------------------------------------------------
    mov EDX, [IndexBasePath]
;   mov EDX, szIndexPath
    call ReadToBuffer
    mov EDX, INDEX_HEADER_SIZE
    cmp ECX, EDX
        jbe jmpEnd@OpenIndexBase
;------------------------------------------------
;       * * *  Get Index
;------------------------------------------------
        mov ESI, [pReadBuffer]
        mov EDI, IndexDataBase
        xor EAX, EAX
        lodsw
        stosd
        mov EBX, EAX
;       mov [IndexDataBase.fields], EAX

;       mov EDX, INDEX_HEADER_SIZE
        mul EDX
        cmp EAX, ECX
            jae jmpEnd@OpenIndexBase
            xchg EAX, EBX
            add  EBX, ESI     ;   text
;           sub EAX, [StoreDataBase.session]
            sub EAX, [EDI]
                js jmpEnd@OpenIndexBase
                mov ECX, INDEX_HEADER_SIZE
                mul ECX
                add ESI, EAX  ;   index
                add EDI, 4
                xor EAX, EAX
                lodsw
                stosd
;               mov [IndexDataBase.group], EAX
                movsd
;               mov [IndexDataBase.date], EAX
;               xor EAX, EAX
                lodsb
                stosd
;               mov [IndexDataBase.count], EAX
;               xor EAX, EAX
                lodsb
                stosd
;               mov [IndexDataBase.attribute], EAX
                lodsw
                add EBX, EAX
                mov [EDI], EBX     ;      for TestCaption
;               mov [IndexDataBase.testname], ESI
                xor EAX, EAX
                ret 

jmpEnd@OpenIndexBase:
;   xor EAX, EAX
    mov AL,  BASE_INDEX + ERR_READ
    ret 
endp
;------------------------------------------------
;       * * *  Open UserBase  * * *
;------------------------------------------------
proc OpenUserBase

    mov EDI, [GroupBasePath.name]
;   mov EBX, User
    call IndexToStr
;------------------------------------------------
;       * * *  Read Test
;------------------------------------------------
    mov EDX, [GroupBasePath.path]
    call ReadToBuffer
    cmp ECX, GROUP_HEAD_SIZE
        jbe jmpEnd@OpenUserBase
        mov ESI, [pReadBuffer]
        mov EDI, UserDataBase
        movsd
;       mov [UserDataBase.date], EAX

        xor EAX, EAX
        lodsb
        stosd
        mov EBX, EAX
;       mov [UserDataBase.count], EAX

        mov EAX, ESI
        stosd
;       mov [UserDataBase.index], ESI

        shl EBX, 2
        cmp EBX, ECX
            jae jmpEnd@OpenUserBase

        add EBX, EAX     ;     for UserCaption
        mov [EDI], EBX
;       mov [UserDataBase.user], ESI
        xor EAX, EAX
        ret 

jmpEnd@OpenUserBase:
;   xor EAX, EAX
    mov AL,  BASE_GROUP + ERR_READ
    ret 
endp
;------------------------------------------------
;       * * *  Open TestBase * * *
;------------------------------------------------
proc OpenTestBase
;------------------------------------------------
;       * * *  Set PathFolder
;------------------------------------------------
;   mov ESI, [Name]
    mov ESI, EBX
    mov EDX, [TestBasePath.name]
    mov EDI, EDX
    CopyString

    mov EAX, EDI
    sub EAX, EDX
    mov [TestDataBase.pathsize], EAX

    mov AL, '.'
    stosb

    mov EAX, EXT_TEST
    stosd
;------------------------------------------------
;       * * *  Read Test
;------------------------------------------------
    mov EDX, [TestBasePath.path]
    call ReadToBuffer
    cmp ECX, TEST_HEADER_SIZE
        jbe jmpEnd@OpenTestBase
;------------------------------------------------
;       * * *  TestHeader
;------------------------------------------------
        mov ESI, [pReadBuffer]
        mov EDI, TestDataBase
;------------------------------------------------
        movsd
;       mov [TestDataBase.date], EAX
        xor EAX, EAX
        lodsw
        stosd
        mov EBX, EAX 
;       mov [TestDataBase.questions], EAX
        xor EAX, EAX
        lodsb
        stosd
        mov EDX, EAX
;       mov [TestDataBase.answers], EAX
;       xor EAX, EAX
        lodsw
        stosd
;       mov [TestDataBase.tests], EAX
;       xor EAX, EAX
        lodsw
        stosd
;       mov [TestDataBase.time], EAX
        xor EAX, EAX
        lodsb
        stosd
;       mov [TestDataBase.level], EAX
        mov EAX, EDX
        inc EAX
        shl EAX, 2
        add EAX, 2
        stosd
;       mov [TestDataBase.fieldsize], EAX
        mul EBX
        mov EBX, EAX 
        mov EAX, ESI
        stosd
;       mov [TestDataBase.scale], ESI
        add EAX, TEST_SCALE_COUNT * 2
        stosd
;       mov [TestDataBase.index], ESI
        add EAX, EBX 
;       mov EBX, EAX     ;       for TestCaption
        mov [EDI], EAX
;       mov [TestDataBase.text], ESI
        sub EAX, ESI
        cmp EAX, ECX
            jae jmpEnd@OpenTestBase
            xor EAX, EAX
            ret 

jmpEnd@OpenTestBase:
;   xor EAX, EAX
    mov AL,  BASE_TEST + ERR_READ
    ret 
endp
;------------------------------------------------
;       * * *  Open TableBase  * * *
;------------------------------------------------
proc OpenTableBase
;------------------------------------------------
;       * * *  Set TablePath
;------------------------------------------------
    mov EDI, [TableBasePath.table]
;   mov ESI, Table
    movsd    ;    TABLE_NAME_LENGTH
    movsd
    movsw

    mov EDI, [TableBasePath.session]
;   mov EBX, [IndexDataBase.session]
    call IndexToStr
;------------------------------------------------
;       * * *  Read Test
;------------------------------------------------
    mov EDX, [TableBasePath.path]
    call ReadToBuffer
    cmp ECX, TABLE_HEADER_SIZE
        jbe jmpEnd@OpenTableBase
        mov ESI, [pReadBuffer]
        mov EDI, TableDataBase.session
        xor EAX, EAX
;       inc EAX
;       stosd
;       mov [TableDataBase.count], EAX
;       xor EAX, EAX
        lodsw
        stosd
;       mov [TableDataBase.session], EAX
;       xor EAX, EAX
        lodsw
        stosd
;       mov [TableDataBase.group], EAX
;       xor EAX, EAX
        lodsw
        stosd
;       mov [TableDataBase.time], EAX
;       xor EAX, EAX
        lodsw
        stosd
        mov EBX, EAX
;       mov [TableDataBase.tests], EAX
        xor EAX, EAX
        lodsb
        stosd
        mov EDX, EAX
;       mov [TableDataBase.items], EAX
;       xor EAX, EAX
        lodsb
        stosd
;       mov [TableDataBase.user], EAX
        movsd
        movsd
;       mov [TableDataBase.start], EAX
;       mov [TableDataBase.close], EAX
        xor EAX, EAX
        lodsw
        stosd
;       mov [TableDataBase.total], EAX
        xor EAX, EAX
        lodsb
        stosd
;       mov [TableDataBase.score], EAX
        mov EAX, EDX
        add AL,  2
        stosd
;       mov [TableDataBase.fieldsize], EAX
        mul EBX
        mov EDX, EAX
        shl EBX, 1
        add EAX, EBX
        mov EBX, EAX
        stosd
;       mov [TableDataBase.tablesize], EBX
        cmp EAX, ECX
            jae jmpEnd@OpenTableBase

        mov EAX, ESI
        stosd
;       mov [TableDataBase.index], ESI
        add EAX, EDX
        stosd
;       mov [TableDataBase.data], ESI
        add EBX, ESI
;       mov EAX, EBX
        mov [EDI], EBX    ;           for TestBaseName
;       mov [TableDataBase.testname], ESI
        xor EAX, EAX
        ret 

jmpEnd@OpenTableBase:
;   xor EAX, EAX
    mov AL,  BASE_TABLE + ERR_READ
    ret 
endp
;------------------------------------------------
;       * * *  Open StoreBase  * * *
;------------------------------------------------
proc OpenStoreBase
;------------------------------------------------
    test EDX, EDX
         jz jmpEnd@OpenStoreBase
;        mov [TableDataBase.count], EDX
         mov [TableDataBase], EDX
;------------------------------------------------
;       * * *  Set StorePath
;------------------------------------------------
    mov EDI, [StoreBasePath.name]
;   mov EBX, [IndexDataBase.session]
    call IndexToStr
;------------------------------------------------
;       * * *  Set TablePath
;------------------------------------------------
    mov EDI, [TableBasePath.session]
    mov ESI, [StoreBasePath.name]
    movsd
    movsb
;------------------------------------------------
;       * * *  Read Test
;------------------------------------------------
    mov EDX, [StoreBasePath.path]
    call ReadToBuffer
    cmp ECX, STORE_HEADER_SIZE
        jbe jmpEnd@OpenStoreBase
        mov ESI, [pReadBuffer]
        mov EDI, TableDataBase
        mov EDX, [EDI]    ;    index
;       mov EDX, [TableDataBase.count]
        dec EDX
        xor EAX, EAX
        lodsb
        cmp EAX, EDX
            jb jmpEnd@OpenStoreBase
            stosd
;           mov [TableDataBase.count], EAX
            push EAX
            push ECX
            mov ECX, EDX
;           xor EAX, EAX
            lodsw
            stosd
;           mov [TableDataBase.session], EAX
;           xor EAX, EAX
            lodsw
            stosd
;           mov [TableDataBase.group], EAX
;           xor EAX, EAX
            lodsw
            stosd
;           mov [TableDataBase.time], EAX
;           xor EAX, EAX
            lodsw
            stosd
            mov EBX, EAX
;           mov [TableDataBase.tests], EAX
            xor EAX, EAX
            lodsb
            stosd
;           mov [TableDataBase.items], EAX
            add AL,  2
            push EAX
            mul EBX
            push EAX
            shl EBX, 1
            add EAX, EBX
            add EAX, TABLE_HEADER_DATA
            mov EBX, EAX
            mul ECX
            mov ECX, ESI
            add ESI, EAX
            xor EAX, EAX
            lodsb
            stosd
;           mov [TableDataBase.user], EAX
            movsd
            movsd
;           mov [TableDataBase.start], EAX
;           mov [TableDataBase.close], EAX
;           xor EAX, EAX
            lodsw
            stosd
;           mov [TableDataBase.total], EAX
            xor EAX, EAX
            lodsb
            stosd
;           mov [TableDataBase.score], EAX
            pop EDX
            pop EAX
            stosd
;           mov [TableDataBase.fieldsize], EAX
            mov EAX, EBX
            stosd
;           mov [TableDataBase.tablesize], EBX
            mov EAX, ESI
            stosd
;           mov [TableDataBase.index], ESI
            add EAX, EDX
            stosd
;           mov [TableDataBase.data], ESI
            mov ESI, ECX
            pop ECX        ;   filesize
            pop EAX        ;   count
            mul EBX
            cmp EAX, ECX
                jae jmpEnd@OpenStoreBase

            add EAX, ESI
            mov EBX, EAX   ;   for TestBaseName
            stosd
;           mov [TableDataBase.testname], ESI
;           mov EAX, ESI
            mov [EDI], ESI
;           mov [TableDataBase.table], ESI
            xor EAX, EAX
            ret 

jmpEnd@OpenStoreBase:
;   xor EAX, EAX
    mov AL,  BASE_STORE + ERR_READ
    ret 
endp
;------------------------------------------------
;       * * *  Delete TableBase + Directory  * * *
;------------------------------------------------
proc DeleteTableBase

    mov EDI, [TableBasePath.dir]
;   mov EBX, [IndexDataBase.session]
    call IndexToStr
;------------------------------------------------
;       * * *  Set TablePath
;------------------------------------------------
    mov EDI, [TableBaseSession.dir]
    mov ESI, [TableBasePath.dir]
    movsd
    movsb

    xor EAX, EAX
    mov [CountFiles], EAX
;------------------------------------------------
;       * * *  Get First Table
;------------------------------------------------
    push FindFileData
    push [TableBaseSession.path]
    call [FindFirstFile]
    cmp EAX, INVALID_HANDLE_VALUE
        je jmpEnd@DeleteTableBase
;------------------------------------------------
        mov [hFind], EAX
;------------------------------------------------
;       * * *  Scan Folder
;------------------------------------------------
jmpFileFind@DeleteTableBase:

        mov EDI, [TableBasePath.name]
        mov ESI, FindFileData.cFileName
        movsd    ;    TABLE_NAME_LENGTH
        movsd
        movsw

        push mrTablePath
        call [DeleteFile]
        test EAX, EAX
             jz jmpFileNext@DeleteTableBase
             inc [CountFiles]

jmpFileNext@DeleteTableBase:
        push FindFileData
        push [hFind]
        call [FindNextFile]
        test EAX, EAX
             jnz jmpFileFind@DeleteTableBase

;jmpClose@DeleteTableBase:
    push [hFind]
    call [FindClose]
;------------------------------------------------
;       * * *  Delete Folder
;------------------------------------------------
    xor EAx, EAX
    mov [mrTableScan + BASE_DIR_LENGTH + BASE_NAME_LENGTH], AL
    push mrTableScan
    call [RemoveDirectory]
    test EAX, EAX
         jz jmpEnd@DeleteTableBase

jmpEnd@DeleteTableBase:
    mov ECX, [CountFiles]
    ret
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------

