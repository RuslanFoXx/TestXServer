;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   BASE: Group Get + Add + View (Admin)
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Import Text To Group  * * *
;------------------------------------------------
proc ImportGroup

    param 1, [UserBasePath.dir]
    call GetFileList
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
    mov RDX, RCX
    InitHtmlSection CSS_VIEW
    TypeHtmlSection GROUP_GET
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection GROUP_GET_HEAD

;   mov [pTypeBuffer], RDI
    test EDX, EDX
         jnz jmpTest@ImportGroup

         TypeHtmlSection GROUP_GET_EMPTY
         jmp jmpEnd@ImportGroup
;------------------------------------------------
;       * * *  Init Scan Folder
;------------------------------------------------
jmpTest@ImportGroup:
    mov [pTypeBuffer], RDI
    mov RAX, [pTableFile]
    mov [pFind], RAX

    xor RCX, RCX
    mov [Ind], ECX
;------------------------------------------------
;       * * *  Scan Folder
;------------------------------------------------
jmpTabScan@ImportGroup:
    mov RSI, [pFind]
    lodsq
    mov [pFind], RSI
    test RAX, RAX
         jz jmpEnd@ImportGroup

         mov RSI, RAX
         xor RAX, RAX
         lodsd
         mov [FileSize], RAX
         xor EAX, EAX
         lodsb
         mov RCX, RAX
         sub AL, FILE_EXT_LENGTH + 1
         mov [PathSize], EAX
         mov RDI, [UserBasePath.name]
         rep movsb

         mov [pName],    gettext GROUP_GET_ERR@
         mov [NameSize], GROUP_GET_ERR
;------------------------------------------------
;       * * *  Read Test
;------------------------------------------------
         param 1, [UserBasePath.path]
         call ReadToBuffer

         jECXz jmpError@ImportGroup
;        test ECX, ECX
;             jz jmpError@ImportGroup
;------------------------------------------------
;       * * *  TestName
;------------------------------------------------
              mov RBX, [pReadBuffer]
              mov [lpMemBuffer], RBX
              mov RDI, RBX
              xor RCX, RCX
              mov CL,  TEXT_NAME_LENGTH
              mov AL,  CHR_LF
              repne scasb
                jne jmpError@ImportGroup

                    xor EAX, EAX
                    mov [RDI], AL
;------------------------------------------------
;       * * *  Set Items
;------------------------------------------------
                    mov RSI, RBX
                    call StrTrim

                    sub RDI, RSI
                    mov [NameSize], EDI
                    mov [pName], RSI

                    mov RDI, [pTypeBuffer] 
                    xor RCX, RCX
                    mov RSI, RCX

                    TypeHtmlSection GROUP_GET_ITEM1

                    mov RSI, [UserBasePath.name]
                    mov ECX, [PathSize]
                    rep movsb 

                    SetHtmlSection GROUP_GET_ITEM2
                    jmp jmpType@ImportGroup
;------------------------------------------------
;       * * *  Set Error Items
;------------------------------------------------
jmpError@ImportGroup:
         mov RDI, [pTypeBuffer]
;        xor RCX, RCX
         mov RSI, RCX
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

;        xor RCX, RCX
         TypeHtmlSection GROUP_GET_ITEM3

         mov RSI, [pName]
         mov ECX, [NameSize]
         rep movsb 

         TypeHtmlSection GROUP_GET_ITEM4

         mov RSI, [UserBasePath.name]
         mov ECX, [PathSize]
         rep movsb 

         TypeHtmlSection GROUP_GET_ITEM5

         mov RBX, [FileSize]
         call WordToStr

         TypeHtmlSection GROUP_GET_ITEM6

         mov [pTypeBuffer], RDI
         jmp jmpTabScan@ImportGroup
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpEnd@ImportGroup:
    xor RCX, RCX
    TypeHtmlSection GROUP_GET_END

;   mov [pTypeBuffer], RDI
;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX
    ret
endp
;------------------------------------------------
;       * * *  Delete Group  * * *
;------------------------------------------------
proc DelGroup

    mov RSI, [AskOption+8]
    call StrToWord

    mov   AL, ERR_GET_GROUP 
    test EBX, EBX 
         jz jmpEnd@DelGroup

         mov RDI, [GroupBasePath.name]
         call IndexToStr
;------------------------------------------------
;       * * *  Delete Group
;------------------------------------------------
    xor RAX, RAX
    mov  AL, 32
    sub RSP, RAX

    param 1, [GroupBasePath.path]
    call [DeleteFile] 

    mov   DX, MODE_GROUP + PROC_SET
    test EAX, EAX
         jz jmpEnd@DelGroup   

         xor RDX, RDX   ;   TEST_POST
         mov [AskOption+8], RDX

jmpEnd@DelGroup:
    xor RAX, RAX
    mov AL,  32
    add RSP, RAX
    mov EAX, EDX    ;    return error
    ret 
endp
;------------------------------------------------
;       * * *  Create Group Users  * * *
;------------------------------------------------
proc CreateGroup

    mov   AL, ERR_GET_USER
    mov  RSI, [AskOption+8]
    test RSI, RSI
         jz jmpEnd@CreateGroup
;------------------------------------------------
;       * * *  Get UserList
;------------------------------------------------
    mov RDI, [UserBasePath.name]
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
    add [lpMemBuffer], MAX_GROUP * 8 + 16
;------------------------------------------------
;       * * *  Get UserData
;------------------------------------------------
    param 1, [UserBasePath.path]
    call ReadToBuffer

    mov AL, BASE_TEXT + ERR_READ
    test ECX, ECX
         jz jmpEnd@CreateGroup
;------------------------------------------------
;       * * *  Get UserData
;------------------------------------------------
    mov R12, [lpSaveBuffer]
    mov RDI, [pReadBuffer]
;   mov RDI, [pUserName]
    mov RSI, R12
    xor R8,  R8
    mov R10, R8
    mov R8b, 8

jmpScan@CreateGroup:
    mov [RSI], RDI
    add RSI, R8
    inc R10d
    mov AL, CHR_LF
    repne scasb
      jne jmpCatSpace@CreateGroup

          dec RDI
          xor EAX, EAX
          stosb
          jmp jmpScan@CreateGroup
;------------------------------------------------
;       * * *  Cat DoubleSpace
;------------------------------------------------
jmpCatSpace@CreateGroup:
    mov RCX, R10
;   mov RBX, [lpSaveBuffer]
    mov RBX, R12
    call TrimTabSpace
;------------------------------------------------
;       * * *  Sort UserLisr
;------------------------------------------------
    mov RSI, R12
    mov RDI, R12
    mov RCX, R10
    xor RBX, RBX

jmpStrScan@CreateGroup:
    lodsq
    test RAX, RAX
         jz jmpStrNext@CreateGroup

         inc EBX
         stosq
;------------------------------------------------
jmpStrNext@CreateGroup:
    loop jmpStrScan@CreateGroup

;   xor RCX, RCX
    mov [RDI], RCX

    mov  AX, BASE_TEXT + ERR_GET_USER
    inc ECX
    cmp EBX, ECX
        jbe jmpEnd@CreateGroup
;------------------------------------------------
;       * * *  Sort UserLisr
;------------------------------------------------
    mov [UserDataBase.count], EBX
    mov ECX, EBX
    dec ECX
;   mov R12, [lpSaveBuffer]
    add R12, R8
    call SetTabSort
;------------------------------------------------
;       * * *  Create UserBase
;------------------------------------------------
    call GetBaseTime

    mov RDI, [lpMemBuffer]
    mov EAX, EDX
    stosd

;   xor RAX, RAX
;   mov R8,  RAX
    xor R8,  R8
    mov R8b, 4
    mov EAX, [UserDataBase.count]
    mov ECX, EAX
    dec EAX
;       jz jmpScanEnd@CreateGroup

        stosb
        mov RBX, RDI
        shl EAX, 2
        add RDI, RAX
        mov RDX, RDI
        mov RSI, [lpSaveBuffer]

jmpTabScan@CreateGroup:
        lodsq

        mov R12, RSI
        mov RSI, RAX

jmpCopyUser@CreateGroup:
        lodsb
        stosb
        test AL, AL
             jnz jmpCopyUser@CreateGroup

        dec ECX
            jz jmpFindFree@CreateGroup

            mov RAX, RDI
            sub RAX, RDX

            mov [RBX], EAX
            add RBX, R8

            mov RSI, R12
            jmp jmpTabScan@CreateGroup
;------------------------------------------------
;       * * *  Find FreeGroup
;------------------------------------------------
jmpFindFree@CreateGroup:
;   xor ECX, ECX
    mov [IndexDataBase.group], ECX
    mov [pFind], RDI

    xor RAX, RAX
    mov  AL, 32
    sub RSP, RAX

    param 2, FindFileData
    param 1, [GroupBasePath.dir]
    call [FindFirstFile]

    cmp RAX, INVALID_HANDLE_VALUE
        je jmpUser@CreateGroup
        mov [hFind], RAX
;------------------------------------------------
;       * * *  Scan Folder
;------------------------------------------------
jmpFind@CreateGroup:
        mov RSI, FindFileData.cFileName
        call StrToWord

        cmp EAX, [IndexDataBase.group]
            jb jmpNext@CreateGroup 
            mov [IndexDataBase.group], EAX 

jmpNext@CreateGroup:
        param 2, FindFileData
        param 1, [hFind]
        call [FindNextFile]

        test EAX, EAX
             jnz jmpFind@CreateGroup

        param 1, [hFind]
        call [FindClose]
;------------------------------------------------
;       * * *  Set GroupPath
;------------------------------------------------
jmpUser@CreateGroup:
    xor RCX, RCX    ;   TEST_POST
    mov CL,  32
    add RSP, RCX

    mov RDI, [GroupBasePath.name]
    mov EBX, [IndexDataBase.group]
    inc EBX
    call IndexToStr
;------------------------------------------------
;       * * *  Write UserBase
;------------------------------------------------
    param 3, [pFind]
    param 2, [lpMemBuffer]
    param 1, [GroupBasePath.path]
    sub R8, RDX
    dec R8
    call WriteFromBuffer

    xor RAX, RAX
    mov [AskOption+8], RAX

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

    param 1, [GroupBasePath.dir]
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
    mov RSI, gettext GROUP_LIST_HEAD1@
    rep movsb 

    TypeHtmlSection GROUP_LIST_HEAD3
    TypeHtmlSection FORM_TITLE

    mov  CL, GROUP_LIST_HEAD4 + GROUP_LIST_HEAD5
;   mov EDX, [ClientAccess.Mode]
    cmp DL, ACCESS_ADMIN
        je jmpKey@ListGroups
        mov CL, GROUP_LIST_HEAD4

jmpKey@ListGroups:
    mov RSI, gettext GROUP_LIST_HEAD4@
    rep movsb

    TypeHtmlSection GROUP_LIST_HEAD6

    mov [pTypeBuffer], RDI
;------------------------------------------------
;       * * *  Items Selector
;------------------------------------------------
;   R10d = Year
;   R14d = Begin
;   R15d = Count
;------------------------------------------------
    mov RSI, [AskOption+8]
    call StrToWord

    mov  ECX, [LocalYear]
    test EAX, EAX 
         jnz jmpYear@ListGroups
         mov EAX, ECX
;------------------------------------------------
;       * * *  Scan Selector
;------------------------------------------------
jmpYear@ListGroups:
    mov R10d, EAX   ;   Year 
    mov R14d, ZERO_YEAR - DELTA_YEAR
    xor RDX, RDX
    mov DX,  MAX_YEAR_ITEMS
    mov R15d, ECX
    sub R15d, R14d
    cmp R15d, EDX
        jbe jmpSetScan@ListGroups

        mov R15d, EDX
        sub EAX,  MAX_YEAR_CENTER
        cmp EAX,  R14d
            jb jmpSetScale@ListGroups
            mov R14d, EAX

jmpSetScale@ListGroups:
        mov EAX, R14d
        add EAX, EDX
        cmp EAX, ECX
            jb jmpSetScan@ListGroups
            sub ECX, EDX
            mov R14d, ECX

jmpSetScan@ListGroups:
    mov RDI, [pTypeBuffer]
    xor RCX, RCX
    inc R15d
;------------------------------------------------
;       * * *  Scale
;------------------------------------------------
jmpSelScan@ListGroups:
    mov  DL, 'A'
    cmp R14d, R10d
        je jmpSelect@ListGroups
        mov DL, 'B'
;------------------------------------------------
;       * * *  TypeScale
;------------------------------------------------
jmpSelect@ListGroups:
    TypeHtmlSection GROUP_LIST_SEL1

    mov EAX, EDX 
    stosb

;   mov RSI, gettext GROUP_LIST_SEL2@
    mov CL,  GROUP_LIST_SEL2
    rep movsb 

    mov RDX, RCX
    mov CL,  10
    mov EAX, R14d

    div ECX
    mov AH, DL
    add AX, '00'
    mov EDX, EAX
    stosw

;   mov RSI, gettext GROUP_LIST_SEL3@
    mov CL,  GROUP_LIST_SEL3
    rep movsb 

    mov EAX, EDX 
    stosw

;   mov RSI, gettext GROUP_LIST_SEL4@
    mov CL,  GROUP_LIST_SEL4
    rep movsb 

    inc R14d
    dec R15d
        jnz jmpSelScan@ListGroups
;------------------------------------------------
;       * * *  Set PathFolder
;------------------------------------------------
    TypeHtmlSection GROUP_LIST_FIND

;   mov [pTypeBuffer], RDI
;   xor ECX, ECX
    cmp ECX, [IndexDataBase.count]
        je jmpFindEmpty@ListGroups
;------------------------------------------------
;       * * *  Init Scan Folder
;------------------------------------------------
    mov [pTypeBuffer], RDI
    mov [Ind],   ECX
    mov [Month], ECX

    sub R10d, ZERO_YEAR - DELTA_YEAR
    mov [Year], R10d

    mov RAX, [pTableFile]
    mov [pFind], RAX
;------------------------------------------------
;       * * *  Scan Folder
;------------------------------------------------
jmpTabScan@ListGroups:
    mov RSI, [pFind]
    lodsq
    mov [pFind], RSI
    test RAX, RAX
         jz jmpEmpty@ListGroups
         lea RSI, [RAX+5]
         call StrToWord
;------------------------------------------------
;       * * *  Get Base
;------------------------------------------------
         mov [IndexDataBase.group], EBX
         call OpenUserBase

         mov  RDI, [pTypeBuffer] 
         test EAX, EAX
              jnz jmpError@ListGroups

              mov RAX, [pReadBuffer]
              mov [lpMemBuffer], RAX

              xor RAX, RAX
              mov RCX, RAX
              mov EAX, [UserDataBase.date]
              mov RBX, RAX
              shr EAX, 26
              cmp EAX, [Year] 
                  jne jmpTabScan@ListGroups
;------------------------------------------------
;       * * *  Set Spliter
;------------------------------------------------
;            xor RCX, RCX
;------------------------------------------------
             shr EBX, 22
             and EBX, 15
             cmp EBX, [Month] 
                 je jmpItem@ListGroups
                 mov [Month], EBX 

                 TypeHtmlSection GROUP_LIST_MON1

                 mov RAX, RCX
                 mov CL,  [GetLenMonth+RBX]
                 mov AX,  [GetDateMonth+RBX*2]
                 lea RSI, [szTypeForm+RAX]
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

             mov RSI, [UserDataBase.user]
             CopyString

             TypeHtmlSection GROUP_LIST_ITEM4

             mov EBX, [ UserDataBase.count]
             call WordToStr

             TypeHtmlSection GROUP_LIST_ITEM5

             mov ECX, [UserDataBase.date]
             call StrDate

             TypeHtmlSection GROUP_LIST_ITEM6

             mov [pTypeBuffer], RDI
             jmp jmpTabScan@ListGroups
;------------------------------------------------
;       * * *  Set ErrorItems
;------------------------------------------------
jmpError@ListGroups:
;        xor RCX, RCX
         TypeHtmlSection GROUP_LIST_ERROR1

         mov EBX, [IndexDataBase.group]
         call WordToStr

         TypeHtmlSection GROUP_LIST_ERROR2

         mov ECX, [UserDataBase.date]
         call StrDate

         TypeHtmlSection GROUP_LIST_ERROR3

         mov [pTypeBuffer], RDI
         jmp jmpTabScan@ListGroups
;------------------------------------------------
;       * * *  TypeForm
;------------------------------------------------
jmpEmpty@ListGroups:
    xor RCX, RCX
    cmp ECX, [Ind]
        jne jmpEnd@ListGroups

jmpFindEmpty@ListGroups:
        TypeHtmlSection GROUP_LIST_EMPTY
;------------------------------------------------
;       * * *  TypeForm
;------------------------------------------------
jmpEnd@ListGroups:
    TypeHtmlSection GROUP_LIST_END 

;   mov [pTypeBuffer], RDI
;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX
    ret 
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
