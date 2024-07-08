;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   BASE: Group Get + Add + View (Admin)
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Import Text To Group  * * *
;------------------------------------------------
proc ImportGroup

    mov EDX, [UserBasePath.dir]
    call GetFileList
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
    mov EDX, ECX

    InitHtmlSection CSS_VIEW
    TypeHtmlSection GROUP_GET
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection GROUP_GET_HEAD

;   mov [pTypeBuffer], EDI

    test EDX, EDX
         jnz jmpTest@ImportGroup

         TypeHtmlSection GROUP_GET_EMPTY
         jmp jmpEnd@ImportGroup
;------------------------------------------------
;       * * *  Init Scan Folder
;------------------------------------------------
jmpTest@ImportGroup:
    mov [pTypeBuffer], EDI

    mov EAX, [pTableFile]
    mov [pFind], EAX

    xor ECX, ECX
    mov [Ind], ECX
;------------------------------------------------
;       * * *  Scan Folder
;------------------------------------------------
jmpTabScan@ImportGroup:
    mov ESI, [pFind]
    lodsd
    mov [pFind], ESI

    test EAX, EAX
         jz jmpEnd@ImportGroup

         mov ESI, EAX
         lodsd
;        mov [FileSize], EAX
         push EAX

         xor EAX, EAX
         lodsb
         mov ECX, EAX
         sub AL, FILE_EXT_LENGTH + 1
         mov [PathSize], EAX
         mov EDI, [UserBasePath.name]
         rep movsb

         mov [pName],    gettext GROUP_GET_ERR@
         mov [NameSize], GROUP_GET_ERR
;------------------------------------------------
;       * * *  Read Table
;------------------------------------------------
         mov EDX, [UserBasePath.path]
         call ReadToBuffer

         jECXz jmpError@ImportGroup
;        test ECX, ECX
;             jz jmpError@ImportGroup
;------------------------------------------------
;       * * *  TestName
;------------------------------------------------
              mov EBX, [pReadBuffer]
              mov [lpMemBuffer], EBX
;------------------------------------------------
              mov EDI, EBX
              xor ECX, ECX
              mov CL,  TEXT_NAME_LENGTH
              mov AL,  CHR_LF
              repne scasb
                jne jmpError@ImportGroup

                    xor EAX, EAX
                    mov [EDI], AL
;------------------------------------------------
;       * * *  Set Items
;------------------------------------------------
                    mov ESI, EBX
                    call StrTrim

                    sub EDI, ESI
                    mov [NameSize], EDI
                    mov [pName], ESI

                    mov EDI, [pTypeBuffer] 
                    xor ECX, ECX

                    TypeHtmlSection GROUP_GET_ITEM1

                    mov ESI, [UserBasePath.name]
                    mov ECX, [PathSize]
                    rep movsb 

                    SetHtmlSection GROUP_GET_ITEM2
                    jmp jmpType@ImportGroup
;------------------------------------------------
;       * * *  Set Error Items
;------------------------------------------------
jmpError@ImportGroup:
         mov EDI, [pTypeBuffer]
;        xor ECX, ECX
         SetHtmlSection GROUP_GET_ERROR
;------------------------------------------------
;       * * *  Type Items
;------------------------------------------------
jmpType@ImportGroup:
         rep movsb 

         mov EAX, [Ind]
         inc EAX
         mov [Ind], EAX

;        call WordToStr
         call ByteToStr

;        xor ECX, ECX
         TypeHtmlSection GROUP_GET_ITEM3

         mov ESI, [pName]
         mov ECX, [NameSize]
         rep movsb 

         TypeHtmlSection GROUP_GET_ITEM4

         mov ESI, [UserBasePath.name]
         mov ECX, [PathSize]
         rep movsb 

         TypeHtmlSection GROUP_GET_ITEM5

;        mov EBX, [FileSize]
         pop EBX
         call WordToStr

         TypeHtmlSection GROUP_GET_ITEM6

         mov [pTypeBuffer], EDI
         jmp jmpTabScan@ImportGroup
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpEnd@ImportGroup:
    xor ECX, ECX
    TypeHtmlSection GROUP_GET_END

;   mov [pTypeBuffer], EDI
    mov EAX, ECX
;   xor EAX, EAX    ;   TEST_POST
    ret 
endp
;------------------------------------------------
;       * * *  Delete Group  * * *
;------------------------------------------------
proc DelGroup

    mov ESI, [AskOption+4]
    call StrToWord

    mov  AL,  ERR_GET_GROUP 
    test EBX, EBX 
         jz jmpEnd@DelGroup

         mov EDI, [GroupBasePath.name]
         call IndexToStr
;------------------------------------------------
;       * * *  Delete Group
;------------------------------------------------
    push [GroupBasePath.path]
    call [DeleteFile] 

    mov   DL, MODE_GROUP + PROC_SET
    test EAX, EAX
         jz jmpEnd@DelGroup

         xor RDX, RDX        ;       TEST_POST
         mov [AskOption+4], EDX

jmpEnd@DelGroup:
    mov EAX, EDX
    ret 
endp
;------------------------------------------------
;       * * *  Create Group Users  * * *
;------------------------------------------------
proc CreateGroup

    mov  AL, ERR_GET_GROUP
    mov ESI, [AskOption+4]
    test ESI, ESI 
         jz jmpEnd@CreateGroup
;------------------------------------------------
;       * * *  Get UserList
;------------------------------------------------
    mov EDI, [UserBasePath.name]
    CopyString

    mov AL, '.'
    stosb
    mov EAX, EXT_TXT
    stosd
;------------------------------------------------
;       * * *  Get UserBuffer
;------------------------------------------------
;   mov RAX, [lpMemBuffer]
;   mov [lpSaveBuffer], RAX    ;    InitUp !!!
    add [lpMemBuffer], MAX_GROUP * 4 + 16
;------------------------------------------------
;       * * *  Get UserData
;------------------------------------------------
    mov EDX, [UserBasePath.path]
    call ReadToBuffer

    mov   AL, BASE_TEXT + ERR_READ
    test ECX, ECX
         jz jmpEnd@CreateGroup
;------------------------------------------------
;       * * *  Get UserData
;------------------------------------------------
jmpBase@CreateGroup:
    mov ESI, [lpSaveBuffer]
    mov EDI, [pReadBuffer]
    mov EDX, 4
    xor EBX, EBX

jmpScan@CreateGroup:
    mov [ESI], EDI
    add ESI, EDX
    inc EBX
    mov AL, CHR_LF
    repne scasb
      jne jmpCatSpace@CreateGroup

          dec EDI
          xor EAX, EAX
          stosb
          jmp jmpScan@CreateGroup
;------------------------------------------------
;       * * *  Cat DoubleSpace
;------------------------------------------------
jmpCatSpace@CreateGroup:
    mov ECX, EBX
    push EBX
;   mov [UserDataBase.count], EBX
    mov EBX, [lpSaveBuffer]
    call TrimTabSpace
;------------------------------------------------
;       * * *  Sort UserLisr
;------------------------------------------------
    mov ESI, [lpSaveBuffer]
    mov EDI, ESI
    xor EBX, EBX
    pop ECX
;   mov ECX, [UserDataBase.count]

jmpStrScan@CreateGroup:
    lodsd
    test EAX, EAX
         jz jmpStrNext@CreateGroup
         inc EBX
         stosd

jmpStrNext@CreateGroup:
    loop jmpStrScan@CreateGroup

;   xor ECX, ECX
    mov [EDI], ECX

    mov  AX, BASE_TEXT + ERR_GET_USER
    inc ECX
    cmp EBX, ECX
        jbe jmpEnd@CreateGroup
;------------------------------------------------
;       * * *  Sort UserLisr
;------------------------------------------------
    push EBX
;   mov [UserDataBase.count], EBX
    mov ECX, EBX
    dec ECX

    mov EDX, [lpSaveBuffer]
    add EDX, 4
    call SetTabSort
;------------------------------------------------
;       * * *  Create UserBase
;------------------------------------------------
    call GetBaseTime

    mov EDI, [lpMemBuffer]
    mov EAX, EDX
    stosd

    pop EAX
;   mov EAX, [UserDataBase.count]
    mov ECX, EAX
    dec EAX
;       jz jmpScanEnd@CreateGroup
        stosb
        mov EBX, EDI
        shl EAX, 2
        add EDI, EAX
        mov EDX, EDI
        mov ESI, [lpSaveBuffer]

jmpTabScan@CreateGroup:
        lodsd

        push ESI
        mov ESI, EAX

jmpCopyUser@CreateGroup:
        lodsb
        stosb
        test AL, AL
             jnz jmpCopyUser@CreateGroup

        pop ESI
        dec ECX
            jz jmpFindFree@CreateGroup

            mov EAX, EDI
            sub EAX, EDX
            mov [EBX], EAX
            add EBX, 4
            jmp jmpTabScan@CreateGroup
;------------------------------------------------
;       * * *  Find FreeGroup
;------------------------------------------------
jmpFindFree@CreateGroup:
;   xor ECX, ECX
    mov [IndexDataBase.group], ECX

    mov EDX, [lpMemBuffer]
    sub EDI, EDX
    dec EDI

    push EDI    ;    for WriteFromBuffer
    push EDX    ;    for WriteFromBuffer

    push FindFileData
    push [GroupBasePath.dir]

    call [FindFirstFile]

    cmp EAX, INVALID_HANDLE_VALUE
        je jmpUser@CreateGroup
        mov [hFind], EAX
;------------------------------------------------
;       * * *  Scan Folder
;------------------------------------------------
jmpFind@CreateGroup:
        mov ESI, FindFileData.cFileName
        call StrToWord

        cmp EAX, [IndexDataBase.group]
            jb jmpNext@CreateGroup 
            mov [IndexDataBase.group], EAX 

jmpNext@CreateGroup:
        push FindFileData
        push [hFind]
        call [FindNextFile]

        test EAX, EAX
             jnz jmpFind@CreateGroup

        push [hFind]
        call [FindClose]
;------------------------------------------------
;       * * *  Set GroupPath
;------------------------------------------------
jmpUser@CreateGroup:
    mov EDI, [GroupBasePath.name]
    mov EBX, [IndexDataBase.group]
    inc EBX
    call IndexToStr
;------------------------------------------------
;       * * *  Write UserBase
;------------------------------------------------
    mov EDX, [GroupBasePath.path]
    call WriteFromBuffer

    xor EAX, EAX
    mov [AskOption+4], EAX

    test ECX, ECX
         jnz jmpListGroup@ListGroups
         mov AL, BASE_GROUP + ERR_WRITE

jmpEnd@CreateGroup:
    ret 
endp
;------------------------------------------------
;       * * *  List Group Users  * * *
;------------------------------------------------
proc ListGroups
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
jmpListGroup@ListGroups:

    mov EDX, [GroupBasePath.dir]
    call GetFileList

    mov [IndexDataBase.count], ECX
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
    InitHtmlSection CSS_VIEW
    mov EDX, [ClientAccess.Mode]

    mov CX,  GROUP_LIST_HEAD1 + GROUP_LIST_HEAD2
    cmp DL,  ACCESS_ADMIN
        je jmpAdd@ListGroups
        mov CX, GROUP_LIST_HEAD1

jmpAdd@ListGroups:
    mov ESI, gettext GROUP_LIST_HEAD1@
    rep movsb 

    TypeHtmlSection GROUP_LIST_HEAD3
    TypeHtmlSection FORM_TITLE 

    mov CL,  GROUP_LIST_HEAD4 + GROUP_LIST_HEAD5

;   mov EDX, [ClientAccess.Mode]
    cmp DL,  ACCESS_ADMIN
        je jmpKey@ListGroups
        mov CL, GROUP_LIST_HEAD4

jmpKey@ListGroups:
    mov ESI, gettext GROUP_LIST_HEAD4@
    rep movsb 

    TypeHtmlSection GROUP_LIST_HEAD6

    mov [pTypeBuffer], EDI
;------------------------------------------------
;       * * *  Items Selector
;------------------------------------------------
    mov ESI, [AskOption+4]
    call StrToWord

    mov  EBX, [LocalYear]
    test EAX, EAX 
         jnz jmpYear@ListGroups
         mov EAX, EBX
;------------------------------------------------
;       * * *  Scan Selector
;------------------------------------------------
jmpYear@ListGroups:
    mov [Year], EAX 
    mov ESI, ZERO_YEAR - DELTA_YEAR
    xor EDX, EDX
    mov  DL, MAX_YEAR_ITEMS
    mov ECX, EBX
    sub ECX, ESI
    cmp ECX, EDX
        jbe jmpSetScan@ListGroups

        mov ECX, EDX
        sub EAX, MAX_YEAR_CENTER
        cmp EAX, ESI
            jb jmpSetScale@ListGroups
            mov ESI, EAX

jmpSetScale@ListGroups:
        mov EAX, ESI
        add EAX, EDX
        cmp EAX, EBX
            jb jmpSetScan@ListGroups
            sub EBX, EDX
            mov ESI, EBX

jmpSetScan@ListGroups:
    mov [Ind], ESI
    mov EDI, [pTypeBuffer]
    inc ECX
;------------------------------------------------
;       * * *  Scale
;------------------------------------------------
jmpSelScan@ListGroups:
    push ECX
    mov  DL, 'A'
    mov EAX, [Ind]
    cmp EAX, [Year]
        je jmpSelect@ListGroups
        mov DL, 'B'
;------------------------------------------------
;       * * *  TypeScale
;------------------------------------------------
jmpSelect@ListGroups:
    TypeHtmlSection GROUP_LIST_SEL1

    mov EAX, EDX 
    stosb

;   mov ESI, gettext GROUP_LIST_SEL2@
    mov CL,  GROUP_LIST_SEL2
    rep movsb 

    mov EDX, ECX
    mov CL,  10
    mov EAX, [Ind]

    div ECX
    mov AH, DL
    add AX, '00'
    mov EDX, EAX
    stosw

;   mov ESI, gettext GROUP_LIST_SEL3@
    mov CL,  GROUP_LIST_SEL3
    rep movsb 

    mov EAX, EDX 
    stosw

;   mov ESI, gettext GROUP_LIST_SEL4@
    mov CL,  GROUP_LIST_SEL4
    rep movsb 

    inc [Ind]
    pop ECX
    loop jmpSelScan@ListGroups
;------------------------------------------------
;       * * *  Set PathFolder
;------------------------------------------------
    TypeHtmlSection GROUP_LIST_FIND

;   mov [pTypeBuffer], EDI
;   xor ECX, ECX
    cmp ECX, [IndexDataBase.count]
        je jmpFindEmpty@ListGroups
;------------------------------------------------
;       * * *  Init Scan Folder
;------------------------------------------------
    mov [pTypeBuffer], EDI
    mov [Ind],   ECX
    mov [Month], ECX
    sub [Year],  ZERO_YEAR - DELTA_YEAR

    mov EAX, [pTableFile]
    mov [pFind], EAX
;------------------------------------------------
;       * * *  Scan Folder
;------------------------------------------------
jmpTabScan@ListGroups:

    mov ESI, [pFind]
    lodsd
    mov [pFind], ESI

    test EAX, EAX
         jz jmpEmpty@ListGroups

         lea ESI, [EAX+5]
         call StrToWord
;------------------------------------------------
;       * * *  Get Base
;------------------------------------------------
         mov [IndexDataBase.group], EBX
         call OpenUserBase

         mov  EDI, [pTypeBuffer] 
         test EAX, EAX
              jnz jmpError@ListGroups

              mov EAX, [pReadBuffer]
              mov [lpMemBuffer], EAX

              mov EAX, [UserDataBase.date]
              mov EBX, EAX
              shr EAX, 26
              cmp EAX, [Year] 
                  jne jmpTabScan@ListGroups
;------------------------------------------------
;       * * *  Set Spliter
;------------------------------------------------
             xor ECX, ECX
             shr EBX, 22
             and EBX, 15
             cmp EBX, [Month] 
                 je jmpItem@ListGroups

                 mov [Month], EBX 
                 TypeHtmlSection GROUP_LIST_MON1

                 mov EAX, ECX
                 mov CL,  [GetLenMonth+EBX]
                 mov AX,  [GetDateMonth+EBX*2]
                 lea ESI, [szTypeForm+EAX]
                 rep movsb

                 TypeHtmlSection GROUP_LIST_MON2
;------------------------------------------------
;       * * *  Set Items
;------------------------------------------------
jmpItem@ListGroups:
             TypeHtmlSection GROUP_LIST_ITEM1

             mov EBX, [IndexDataBase.group]
             call WordToStr

             TypeHtmlSection GROUP_LIST_ITEM2

             mov EAX, [Ind]
             inc EAX
             mov [Ind], EAX

;            call WordToStr
             call ByteToStr

             TypeHtmlSection GROUP_LIST_ITEM3

             mov ESI, [UserDataBase.user]
             CopyString

             TypeHtmlSection GROUP_LIST_ITEM4

             mov EBX, [UserDataBase.count]
             call WordToStr

             TypeHtmlSection GROUP_LIST_ITEM5

             mov ECX, [UserDataBase.date]
             call StrDate

             TypeHtmlSection GROUP_LIST_ITEM6

             mov [pTypeBuffer], EDI
             jmp jmpTabScan@ListGroups
;------------------------------------------------
;       * * *  Set ErrorItems
;------------------------------------------------
jmpError@ListGroups:
;        xor ECX, ECX
         TypeHtmlSection GROUP_LIST_ERROR1

         mov EBX, [IndexDataBase.group]
         call WordToStr

         TypeHtmlSection GROUP_LIST_ERROR2

         mov ECX, [UserDataBase.date]
         call StrDate

         TypeHtmlSection GROUP_LIST_ERROR3

         mov [pTypeBuffer], EDI
         jmp jmpTabScan@ListGroups
;------------------------------------------------
;       * * *  TableEmpty
;------------------------------------------------
jmpEmpty@ListGroups:
    xor ECX, ECX
    cmp ECX, [Ind]
        jne jmpEnd@ListGroups
;------------------------------------------------
jmpFindEmpty@ListGroups:
        TypeHtmlSection GROUP_LIST_EMPTY
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpEnd@ListGroups:
    TypeHtmlSection GROUP_LIST_END

;   mov [pTypeBuffer], EDI
;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX
    ret 
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
