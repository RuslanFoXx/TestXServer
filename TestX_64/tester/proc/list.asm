;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   BASE: List + Scan
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;   pFind
;   pTableFile
;   CountFiles
;   Items
;   ItemCount
;   Ind
;------------------------------------------------
;       * * *  GetIndexList  * * *
;------------------------------------------------
proc GetIndexList

;   param 1, Filter
;   mov [pFind], RBX   ;   Index
    xor RAX, RAX
    mov AL,  32   ;   for 4 + 0
    sub RSP, RAX
    mov AX, MAX_FILES
    mov [CountFiles], EAX
;------------------------------------------------
;       * * *  Get First Index
;------------------------------------------------
    param 2, FindFileData 
;   param 1, Filter
    call [FindFirstFile]

    cmp RAX, INVALID_HANDLE_VALUE
        je jmpEnd@GetIndexList
        mov [hFind], RAX
;------------------------------------------------
;       * * *  Scan Folder
;------------------------------------------------
jmpFileFind@GetIndexList:
    mov RSI, FindFileData.cFileName
    call StrToWord

    test EAX, EAX
         jz jmpNext@GetIndexList

         mov RDI, [lpMemBuffer]
         stosq
         mov [lpMemBuffer], RDI
         dec [CountFiles]
             jz jmpClose@GetIndexList
;------------------------------------------------
;       * * *  Set Error Items
;------------------------------------------------
jmpNext@GetIndexList:
    param 2, FindFileData 
    param 1, [hFind]
    call [FindNextFile]

    test EAX, EAX
         jnz jmpFileFind@GetIndexList
;------------------------------------------------
jmpClose@GetIndexList:
    param 1, [hFind]
    call [FindClose]

    xor R8, R8
    mov RDI, [lpMemBuffer]
    mov [RDI], R8

    mov R8b, 32
    add RSP, R8

jmpEnd@GetIndexList:
    xor RCX, RCX
    mov  CX, MAX_FILES
    sub ECX, [CountFiles]
    ret
endp
;------------------------------------------------
;       * * *  GetFileList  * * *
;------------------------------------------------
proc GetFileList

;   param 1, Filter
;   mov [pFind], RBX   ;   Table
    xor RAX, RAX
    mov AL,  32
    sub RSP, RAX
    mov  AX, MAX_FILES
    mov [CountFiles], EAX
;------------------------------------------------
;       * * *  Get FilesBuffer
;------------------------------------------------
    mov RBX, [lpMemBuffer]
    mov [pTableFile], RBX
    mov [pFind], RBX
    mov  AX, MAX_FILES * 8 + 16
    add RAX, RBX
    mov [lpMemBuffer], RAX
;------------------------------------------------
;       * * *  Get First Table
;------------------------------------------------
    param 2, FindFileData 
;   param 1, Filter
    call [FindFirstFile]

    cmp RAX, INVALID_HANDLE_VALUE
        je jmpEnd@GetFileList
        mov [hFind], RAX
;------------------------------------------------
;       * * *  Scan Folder
;------------------------------------------------
jmpFileFind@GetFileList:
        mov RDX, FindFileData.cFileName
        xor RCX, RCX
        mov  CX, FILEPATH_SIZE
        mov RDI, RDX
        xor RAX, RAX
        repnz scasb
          jnz jmpClose@GetFileList

          mov RCX, RDI
          sub RCX, RDX
          mov RDI, [pFind]
          mov RAX, [lpMemBuffer]
          stosq
          mov [pFind], RDI

          mov RDI, RAX
          mov RSI, RDX
          mov EAX, [FindFileData.nFileSizeLow]
          stosd

          mov RAX, RCX
          stosb
          rep movsb

          mov [lpMemBuffer], RDI
          dec [CountFiles]
              jz jmpClose@GetFileList
;------------------------------------------------
;       * * *  Set Error Items
;------------------------------------------------
    param 2, FindFileData 
    param 1, [hFind]
    call [FindNextFile]

    test EAX, EAX
         jnz jmpFileFind@GetFileList

jmpClose@GetFileList:
    param 1, [hFind]
    call [FindClose]

    xor RCX, RCX
    mov RDI, [pFind]
    mov [RDI], RCX

    mov CL,  32
    add RSP, RCX
;------------------------------------------------
;       * * *  Sort FileList
;------------------------------------------------
    mov R12, [pTableFile]
    mov R8, RCX
    mov R9, RCX
    mov R9b, 5
    mov R8b, 8
;------------------------------------------------
;       * * *  Sort FileList
;------------------------------------------------
    mov R12, [pTableFile]
    mov RCX, R8
    mov R9b, 5
    mov R8b, 8

jmpGet@GetFileList:
    mov  RBX, R12
    mov  RAX,[RBX]
    test RAX, RAX
         jz jmpEnd@GetFileList
         mov RDX, R12

jmpScan@GetFileList:
         add RBX, R8
         mov RSI, [RBX] 
         test RSI, RSI
              jz jmpChang@GetFileList
              mov RDI, [RDX] 
;             mov RSI, [RBX] 
              add RSI, R9
              add RDI, R9
              mov CL,  MAX_SORT_NAME
              repe cmpsb
                ja jmpScan@GetFileList
                   mov RDX, RBX
                   jmp jmpScan@GetFileList

jmpChang@GetFileList:
         cmp RDX, R12
             je jmpNext@GetFileList
             mov  RAX, [R12] 
             xchg RAX, [RDX] 
             mov [R12], RAX 

jmpNext@GetFileList:
    add R12, R8
    jmp jmpGet@GetFileList

jmpEnd@GetFileList:
    xor RCX, RCX
    mov  CX, MAX_FILES
    sub ECX, [CountFiles]
    ret
endp
;------------------------------------------------
;
;       * * *  Scan Table  * * *
;
;------------------------------------------------
proc GetTableList
;------------------------------------------------
;       * * *  Set TablePath
;------------------------------------------------
;   mov [IndexDataBase.group], EAX
    mov RDI, [TableBasePath.session]
    mov EBX, [IndexDataBase.session]
    call IndexToStr

    mov RDI, [TableBaseScan.dir]
    mov RSI, [TableBasePath.session]
    movsd
    movsb
;------------------------------------------------
;       * * *  Get First Table
;------------------------------------------------
;   xor RCX, RCX
    mov RAX, RCX
    mov CL,  32
    sub RSP, RCX
;------------------------------------------------
;       * * *  Get FilesBuffer
;------------------------------------------------
    mov RDI, [lpMemBuffer]
    mov [pTableFile], RDI
;   mov ECX, [UserDataBase.count]
    mov CX,  MAX_GROUP + 1
;   xor EAX, EAX
    rep stosq

    mov CX, MAX_GROUP
    mov [CountFiles],  ECX
    mov [lpMemBuffer], RDI
;------------------------------------------------
;       * * *  Get First Table
;------------------------------------------------
    param 2, FindFileData 
    param 1, [TableBaseScan.path]
    call [FindFirstFile]

    cmp RAX, INVALID_HANDLE_VALUE
        je jmpEnd@GetTableList
        mov [hFind], RAX

        mov RDI, Time
        mov RSI, IndexDataBase.session
        lodsd
        stosw
        lodsd
        stosw
;------------------------------------------------
;       * * *  Read Table
;------------------------------------------------
jmpFileFind@GetTableList:
        mov RSI, FindFileData.cFileName
        mov RDI, [TableBasePath.table]
        movsq    ;    TABLE_NAME_LENGTH
        movsw

        param 1, [TableBasePath.path]
        call ReadToBuffer

        cmp ECX, TABLE_HEADER_SIZE
            jbe jmpNext@GetTableList
;------------------------------------------------
;       * * *  Set Index GroupBase
;------------------------------------------------
;   R8   = 2
;   R9d  = Ind
;   R10d = ItemCount
;   R11  = pReadBuffer
;   R12  = Table
;   R13  =
;   R14  = Items
;   R15  = Questions
;------------------------------------------------
;       mov  EAX, [RSITable.close]
;       test EAX, EAX
;            jz jmpNext@GetTableList
             mov RBX, [pReadBuffer]
             mov RSI, RBX
             xor RAX, RAX
             lodsd              ;    RSITable.session + ugroup
             cmp EAX, [Time]
                 jne jmpNext@GetTableList

                 xor RAX, RAX
                 mov [RBX], EAX

                 mov R8,  RAX
                 mov R9,  RAX   ;    Ind
                 mov R10, RAX   ;    ItemCount
;------------------------------------------------
;       * * *  Set Field
;------------------------------------------------
                 mov R8b, 2     ;    Step
                 add RSI, R8    ;    RSITable.time

;                xor EAX, EAX
                 lodsw
                 mov R15, RAX   ;    RSITable.questions

;                xor EAX, EAX   ;    RSITable.answers
                 mov RAX, R8
                 lodsb
                 mov R14, RAX   ;    Items
;------------------------------------------------
;       * * *  Set IndexName
;------------------------------------------------
                 mov RDI, [pTableFile]                 
                 mov RAX, R8
                 lodsb          ;    RSITable.user

                 mov R11, RBX   ;    pReadBuffer
                 mov [RDI+RAX*8], RBX
;------------------------------------------------
;       * * *  Set DataTable
;------------------------------------------------
                 lea R12, [RBX+TABLE_HEADER_SIZE] ; RSITable.index
                 mov RAX, R14   ;    RSITable.data
                 add EAX, R8d
                 mul R15d
                 add RAX, R12
                 mov RDX, RAX   ;    RSITable.data
                 lea RBX, [RDX+R15*2] ; RSITable.testname
;------------------------------------------------
;       * * *  If start + close
;------------------------------------------------
                 lodsd          ;    RSITable.start
                 test EAX, EAX
                      jz jmpBase@GetTableList

                 mov EAX, [RSI] ;    RSITable.close
                 test EAX, EAX
                      jnz jmpBase@GetTableList

                      mov RSI, R12
                      mov RDI, RDX

jmpItem@GetTableList:
                          mov ECX, R14d   ;   Items
                          add RSI, R8
                          xor RBX, RBX  
                          mov RDX, RBX
                          inc EDX

jmpScan@GetTableList:
                          lodsb
                          test AL, SET_ITEM_TRUE
                               jz jmpSkip@GetTableList
                               or EBX, EDX

jmpSkip@GetTableList:
                          shl EDX, 1
                          loop jmpScan@GetTableList

                          mov AX, [RDI]
                          test AX, AX
                               jz jmpCheck@GetTableList

                               inc R10d      ;   ItemCount
                               cmp AX, BX
                                   jne jmpCheck@GetTableList
                                   inc R9d   ;   Ind
jmpCheck@GetTableList:
                          add RDI, R8
                          dec R15d
                              jnz jmpItem@GetTableList
;------------------------------------------------
;       * * *  Set Index GroupBase
;------------------------------------------------
                      mov RBX, RDI
                      mov RDI, R11     ;   pReadBuffer
                      mov EAX, R9d     ;   EDITable.session   = Ind
                      stosw

                      mov [RDI], R10w  ;   EDITable.group = ItemCount
;------------------------------------------------
jmpBase@GetTableList:
                 mov RSI, [TableBasePath.table]
                 mov RDI, R12
                 movsq    ;    TABLE_NAME_LENGTH
                 movsw

                 mov RSI, RBX
                 mov CL,  INDEX_NAME_SIZE
                 rep movsd

                 mov [lpMemBuffer], RDI
                 dec [CountFiles]
                     jz jmpEnd@GetTableList
;------------------------------------------------
jmpNext@GetTableList:
                 param 2, FindFileData 
                 param 1, [hFind]
                 call [FindNextFile]

                 test EAX, EAX
                      jnz jmpFileFind@GetTableList

                 param 1, [hFind]
                 call [FindClose]
;------------------------------------------------
jmpEnd@GetTableList:
;------------------------------------------------
    xor RCX, RCX
    mov  CL, 32
    add RSP, RCX
    mov  CX, MAX_GROUP
    sub ECX, [CountFiles]
    ret 
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
