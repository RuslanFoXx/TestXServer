;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
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

;   mov EDX, Filter
;   mov [pFind], RBX   ;   Index
    mov [CountFiles], MAX_FILES
;------------------------------------------------
;       * * *  Get First Index
;------------------------------------------------
    push FindFileData
    push EDX
    call [FindFirstFile]

    cmp EAX, INVALID_HANDLE_VALUE
        je jmpEnd@GetIndexList
        mov [hFind], EAX
;------------------------------------------------
;       * * *  Scan Folder
;------------------------------------------------
jmpFileFind@GetIndexList:
    mov ESI, FindFileData.cFileName
    call StrToWord

    test EAX, EAX
         jz jmpNext@GetIndexList

         mov EDI, [lpMemBuffer]
         stosd
         mov [lpMemBuffer], EDI
         dec [CountFiles]
             jz jmpClose@GetIndexList
;------------------------------------------------
;       * * *  Set Error Items
;------------------------------------------------
jmpNext@GetIndexList:
    push FindFileData
    push [hFind]
    call [FindNextFile]

    test EAX, EAX
         jnz jmpFileFind@GetIndexList

jmpClose@GetIndexList:
    push [hFind]
    call [FindClose]

    xor EAX, EAX
    mov EDI, [lpMemBuffer]
    mov [EDI], EAX

jmpEnd@GetIndexList:
    mov ECX, MAX_FILES
    sub ECX, [CountFiles]
    ret
endp
;------------------------------------------------
;       * * *  List Files  * * *
;------------------------------------------------
proc GetFileList
;------------------------------------------------
;       * * *  Get FilesBuffer
;------------------------------------------------
;   mov EDX, Filter
;   mov [pFind], EBX   ;   Table
    mov [CountFiles], MAX_FILES

    mov EAX, [lpMemBuffer]
    mov [pTableFile], EAX
    mov [pFind], EAX
    add EAX, MAX_FILES * 4 + 8
    mov [lpMemBuffer], EAX
;------------------------------------------------
;       * * *  Get First Table
;------------------------------------------------
    push FindFileData
    push EDX
    call [FindFirstFile]

    cmp EAX, INVALID_HANDLE_VALUE
        je jmpEnd@GetFileList
        mov [hFind], EAX
;------------------------------------------------
;       * * *  Scan Folder
;------------------------------------------------
jmpFileFind@GetFileList:
        mov EDX, FindFileData.cFileName
        mov ECX, FILEPATH_SIZE
        mov EDI, EDX
        xor EAX, EAX
        repnz scasb
          jnz jmpClose@GetFileList

          mov ECX, EDI
          sub ECX, EDX

          mov EDI, [pFind]
          mov EAX, [lpMemBuffer]
          stosd
          mov [pFind], EDI
          mov EDI, EAX
          mov ESI, EDX
          mov EAX, [FindFileData.nFileSizeLow]
          stosd

          mov EAX, ECX
          stosb
          rep movsb

          mov [lpMemBuffer], EDI
          dec [CountFiles]
              jz jmpClose@GetFileList

    push FindFileData
    push [hFind]
    call [FindNextFile]

    test EAX, EAX
         jnz jmpFileFind@GetFileList

jmpClose@GetFileList:
    push [hFind]
    call [FindClose]

    xor EAX, EAX
    mov ECX, EAX
    mov EDI, [pFind]
    mov [EDI], EAX
;------------------------------------------------
;       * * *  Sort FileList
;------------------------------------------------
    mov EDX, [pTableFile]
    xor ECX, ECX

jmpGet@GetFileList:
    mov  EBX, EDX
    mov  EAX,[EBX] 
    test EAX, EAX
         jz jmpEnd@GetFileList
         push EDX

jmpScan@GetFileList:
         add EBX, 4
         mov ESI, [EBX] 
         test ESI, ESI
              jz jmpChang@GetFileList

              mov EDI, [EDX] 
;             mov ESI, [EBX]
              mov CL,  5
              add EDI, ECX
              add ESI, ECX
              mov CL,  MAX_SORT_NAME
              repe cmpsb
                ja jmpScan@GetFileList

                   mov EDX, EBX
                   jmp jmpScan@GetFileList

jmpChang@GetFileList:
         mov EDI, EDX
         pop EDX
         cmp EDX, EDI
             je jmpNext@GetFileList
             mov  EAX, [EDX] 
             xchg EAX, [EDI] 
             mov [EDX], EAX  

jmpNext@GetFileList:
    add EDX, 4
    jmp jmpGet@GetFileList

jmpEnd@GetFileList:
    mov ECX, MAX_FILES
    sub ECX, [CountFiles]
    ret
endp
;------------------------------------------------
;       * * *  Scan Table  * * *
;------------------------------------------------
proc GetTableList
;------------------------------------------------
;       * * *  Set TablePath
;------------------------------------------------
;   mov [IndexDataBase.group], EAX
    mov EDI, [TableBasePath.session]
    mov EBX, [IndexDataBase.session]
    call IndexToStr

    mov EDI, [TableBaseScan.dir]
    mov ESI, [TableBasePath.session]
    movsd
    movsb
;------------------------------------------------
;       * * *  Get FilesBuffer
;------------------------------------------------
    mov EDI, [lpMemBuffer]
    mov [pTableFile], EDI
;------------------------------------------------
    mov EAX, ECX
;   mov ECX, [UserDataBase.count]
    mov CX,  MAX_GROUP + 1
;   xor EAX, EAX
    rep stosd

    mov [CountFiles],  MAX_GROUP
    mov [lpMemBuffer], EDI
;------------------------------------------------
;       * * *  Get First Table
;------------------------------------------------
    push FindFileData 
    push [TableBaseScan.path]
    call [FindFirstFile]

    cmp EAX, INVALID_HANDLE_VALUE
        je jmpEnd@GetTableList

        mov [hFind], EAX
        mov EDI, Time  ;  Param
        mov ESI, IndexDataBase.session
        lodsd
        stosw
        lodsd
        stosw
;------------------------------------------------
;       * * *  Read Table
;------------------------------------------------
jmpFileFind@GetTableList:
        mov ESI, FindFileData.cFileName
        mov EDI, [TableBasePath.table]
        movsd    ;    TABLE_NAME_LENGTH
        movsd
        movsw

        mov EDX, [TableBasePath.path]
        call ReadToBuffer

        cmp ECX, TABLE_HEADER_SIZE
            jbe jmpNext@GetTableList
;------------------------------------------------
;       * * *  Set Index GroupBase
;------------------------------------------------
;       mov EAX, [ESITable.close]
;       test EAX, EAX
;            jz jmpNext@GetTableList

             mov EBX, [pReadBuffer]
             mov ESI, EBX
             xor EAX, EAX

             lodsd              ;    RSITable.session + ugroup
             cmp EAX, [Time]    ;    Param
                 jne jmpNext@GetTableList

                 xor EAX, EAX
                 mov EDX, EAX
                 mov [EBX], EAX
                 mov [Ind], EAX
                 mov [ItemCount], EAX
;------------------------------------------------
;       * * *  Set Field
;------------------------------------------------
                 mov DL,  2
                 add ESI, EDX   ;    RSITable.time

;                xor EAX, EAX
                 lodsw
                 mov ECX, EAX   ;    RSITable.questions

                 xor EAX, EAX   ;    RSITable.answers
                 lodsb

                 add EDX, EAX
                 mov [Items], EAX
;------------------------------------------------
;       * * *  Set IndexName
;------------------------------------------------
                 mov EDI, [pTableFile]
                 xor EAX, EAX
                 lodsb          ;    RSITable.user

                 mov [EDI+EAX*4], EBX
;------------------------------------------------
;       * * *  Set DataTable
;------------------------------------------------
                 lea EDI, [EBX+TABLE_HEADER_SIZE] ; RSITable.index
                 mov EAX, EDX   ;    RSITable.data
                 mul ECX

                 add EAX, EDI
                 mov EDX, EAX   ;    RSITable.data
                 lea EBX, [EDX+ECX*2] ; RSITable.testname
;------------------------------------------------
;       * * *  If start + close
;------------------------------------------------
                 lodsd          ;    RSITable.start
                 test EAX, EAX
                      jz jmpBase@GetTableList

                 mov  EAX, [ESI] ;    RSITable.close
                 test EAX, EAX
                      jnz jmpBase@GetTableList

                      mov ESI, EDI ; RSITable.index
                      mov EDI, EDX ; RSITable.data
                      push ESI

jmpItem@GetTableList:
                          push ECX
                          mov ECX, [Items]
;                         add ESI, 2
                          inc ESI
                          inc ESI
                          xor EBX, EBX  
                          mov EDX, EBX
                          inc EDX

jmpScan@GetTableList:
                          lodsb
                          test AL, SET_ITEM_TRUE
                               jz jmpSkip@GetTableList
                               or EBX, EDX

jmpSkip@GetTableList:
                          shl EDX, 1
                          loop jmpScan@GetTableList

                          mov AX, [EDI]
                          test AX, AX
                               jz jmpCheck@GetTableList

                               inc [ItemCount]
                               cmp AX, BX
                                   jne jmpCheck@GetTableList
                                   inc [Ind]
jmpCheck@GetTableList:
                          add EDI, 2
                          pop ECX
                          loop jmpItem@GetTableList
;------------------------------------------------
;       * * *  Set Index GroupBase
;------------------------------------------------
                      mov EBX, EDI    ;    RSITable.testname
                      mov EDI, [pReadBuffer]

                      mov EAX, [Ind]
                      stosw           ;    EDITable.session

                      mov EAX, [ItemCount]
                      mov [EDI], AX   ;    EDITable.group
                      pop EDI
;------------------------------------------------
;       * * *  Set TestName
;------------------------------------------------
jmpBase@GetTableList:
                 mov ESI, [TableBasePath.table]
                 movsd    ;    TABLE_NAME_LENGTH
                 movsd
                 movsw

                 mov ESI, EBX
                 mov CL,  INDEX_NAME_SIZE
                 rep movsb

                 mov [lpMemBuffer], EDI
                 dec [CountFiles]
                     jz jmpEnd@GetTableList

jmpNext@GetTableList:
                 push FindFileData 
                 push [hFind]
                 call [FindNextFile]

                 test EAX, EAX
                      jnz jmpFileFind@GetTableList

                 push [hFind]
                 call [FindClose]

jmpEnd@GetTableList:
    mov ECX, MAX_GROUP
    sub ECX, [CountFiles]
    ret 
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
