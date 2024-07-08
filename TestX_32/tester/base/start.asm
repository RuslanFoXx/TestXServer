;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   BASE: Prompt Client + Admin
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Starting Tester  * * *
;------------------------------------------------
proc TestBegin

    xor ECX, ECX
    mov EBX, ECX
    mov EDX, gettext CLIENT_NUMBER@
    mov BL,  CLIENT_NUMBER
    cmp AL,  TEST_NUMBER
        je jmpType@TestBegin

    mov EDX, gettext ADMIN_PASSWORD@
    mov BL,  ADMIN_PASSWORD
    cmp AL,  ACCESS_DENIED
        je jmpType@TestBegin

    mov EDX, gettext CLIENT_FINISH@
    mov BL,  CLIENT_FINISH
    cmp AL,  TEST_CLOSE
        je jmpType@TestBegin

    mov EDX, gettext CLIENT_NOT_FOUND@
    mov BL,  CLIENT_NOT_FOUND
    cmp AL,  TEST_NOT_FOUND
        je jmpType@TestBegin
;------------------------------------------------
;   * * *  Type Error Code
;------------------------------------------------
    mov ESI, EAX
    mov EDI, AskBuffer
;   mov ESI, gettext SYSTEM_ERROR@
;   mov CL,  SYSTEM_ERROR
;   rep movsb 
    mov EAX, 'PRC_'
    stosd

    mov EBX, [ClientAccess.Process]
    mov AX, word[sStrByteScale+2+EBX*4]
    stosw

    mov AX, '  '
    stosw

    xor ECX, ECX
    mov  CL, GET_INDEX 
    mov EBX, ESI
    shr EBX, 4
    and EBX, ECX
    mov EAX, dword[TextBaseError+EBX*4]
    stosd

    mov EBX, ESI
    and EBX, ECX
    lea ESI,[TextIndexError+EBX]
    xor EAX, EAX
    lodsb
    mov CL, [ESI]
    sub ECX, EAX
    lea ESI,[TextCodeError+EAX]
    rep movsb

    mov EDX, AskBuffer
    mov EBX, EDI
    sub EBX, EDX
;------------------------------------------------
;   * * *  Type Form
;------------------------------------------------
jmpType@TestBegin:
    InitHtmlSection CSS_TEST
    CopyHtmlSection FORM_GET@, FORM_GET + FORM_GET_PARAM + FORM_TITLE

    mov EAX, [ClientAccess.Mode]
    test EAX, EAX
         jnz jmpAdmin@TestBegin
;------------------------------------------------
;   * * *  Client (MODE_READ_WRITE)
;------------------------------------------------
         TypeHtmlSection FORM_CLIENT_STATUS

         mov ESI, EDX   ;   offset szBuffer 
         mov ECX, EBX
         rep movsb 

         mov ESI, gettext FORM_CLIENT_END@
         mov CX,  FORM_CLIENT_END + FORM_POST + FORM_YEAR + FORM_END

;        CopyHtmlSection FORM_CLIENT_END@, FORM_CLIENT_END + FORM_POST + FORM_YEAR + FORM_END
         ret
;------------------------------------------------
;   * * *  Admin (MODE_READ_WRITE & MODE_ADMIN)
;------------------------------------------------
jmpAdmin@TestBegin:
;   mov ESI, getform FORM_ADMIN_STATUS@
    mov CL,  FORM_ADMIN_STATUS
    rep movsb 

    mov ESI, EDX    ;   offset szBuffer 
    mov ECX, EBX
    rep movsb

    TypeHtmlSection FORM_ADMIN_END

    mov ESI, [lpTypeBuffer]
    mov word[ESI+FORM_GET], ASK_ListGroups

    mov ESI, gettext FORM_POST@
    mov CX,  FORM_POST + FORM_YEAR + FORM_END

;   CopyHtmlSection FORM_POST@, FORM_POST + FORM_YEAR + FORM_END

jmpEnd@TestBegin:
    ret 
endp
;------------------------------------------------
;       * * *  List Group Tables  * * *
;------------------------------------------------
proc GroupSession

;local Part DWORD ?
;local User DWORD ?
;local Date DWORD ?
;local Ind DWORD ?
;------------------------------------------------
;       * * *  Get Part
;------------------------------------------------
    mov ESI, [AskOption+4]
    xor EAX, EAX
    mov [AskOption + 4], EAX
    call StrToWord

;   mov   AL, ERR_GET_PART
    test EBX, EBX 
;        jz jmpEnd@GroupSession
         jz jmpListGroup@ListGroups
;------------------------------------------------
;       * * *  Get IndexBase
;------------------------------------------------
;   mov [IndexDataBase.part], EBX
    call OpenIndexBase

    test EAX, EAX
;        jnz jmpEnd@GroupSession
         jnz jmpListGroup@ListGroups
;------------------------------------------------
;       * * *  Get TestBase
;------------------------------------------------
;   mov EBX, [IndexDataBase.name]
;   mov EBX, ESI
    call OpenTestBase

    test EAX, EAX
         jnz jmpEnd@GroupSession
;------------------------------------------------
;       * * *  Set GroupPath
;------------------------------------------------
    mov EBX, [IndexDataBase.group]
    call OpenUserBase

    test EAX, EAX
         jnz jmpEnd@GroupSession
;------------------------------------------------
;       * * *  Set FileTable
;------------------------------------------------
    mov EDI, [TableBasePath.session]
    mov EBX, [IndexDataBase.session]
    call IndexToStr

    mov EDI, [TableBaseScan.dir]
    mov ESI, [TableBasePath.session]
    movsd
    movsb
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
;   mov EDX, ECX
    InitHtmlClient  CSS_TEST
    TypeHtmlSection TABLE_GROUP
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TABLE_GROUP_HEAD1

    mov ESI, [GroupBasePath.name]
    movsd
    movsb

    TypeHtmlSection TABLE_GROUP_HEAD2

    mov ESI, [UserDataBase.user]
    CopyString

    TypeHtmlSection TABLE_GROUP_HEAD3

    mov EBX, [TestDataBase.tests]
    call WordToStr

    TypeHtmlSection TABLE_GROUP_HEAD4

    mov ESI, [TableBasePath.session]
    movsd
    movsb

    TypeHtmlSection TABLE_GROUP_HEAD5

    mov ESI, [TestDataBase.text]
    CopyString

    TypeHtmlSection TABLE_GROUP_HEAD6

    mov ECX, [UserDataBase.date] 
    push ECX
    call StrDate

    TypeHtmlSection TABLE_GROUP_HEAD7

    pop ECX
    call StrTime

    TypeHtmlSection TABLE_GROUP_HEAD8
    TypeHtmlSection CLIENT_NAME
    TypeHtmlSection TABLE_GROUP_HEAD9

    mov [pTypeBuffer], EDI
;------------------------------------------------
;       * * *  Init Scan Folder
;------------------------------------------------
    push FindFileData
    push [TableBaseScan.path]
    call [FindFirstFile]

    cmp EAX, INVALID_HANDLE_VALUE
        je jmpEndForm@GroupSession
        mov [hFind], EAX
;------------------------------------------------
;       * * *  Read Table
;------------------------------------------------
jmpTabScan@GroupSession:
        mov ESI, FindFileData.cFileName
        mov EDI, [TableBasePath.table]
        movsd    ;    TABLE_NAME_LENGTH
        movsd
        movsw

        mov EDX, [TableBasePath.path]
        call ReadToBuffer

        cmp ECX, TABLE_HEADER_SIZE
            jbe jmpNext@GroupSession

            mov ESI, [pReadBuffer]
            mov [lpMemBuffer], ESI
            xor EAX, EAX
            lodsd
            shr EAX, 16
            cmp EAX, [IndexDataBase.group]
                jne jmpNext@GroupSession
;------------------------------------------------
;       * * *  Get User
;------------------------------------------------
                xor EBX, EBX
                mov BL, [ESI+TABLE_HEADER.user-4]
                dec EBX
                mov ESI, [UserDataBase.index]
                mov EDX, [ESI+EBX*4]                
                add EDX, [UserDataBase.user]
;------------------------------------------------
;       * * *  Get Table
;------------------------------------------------
                mov EDI, [pTypeBuffer]
                xor ECX, ECX

                TypeHtmlSection TABLE_GROUP_USER

                mov ESI, FindFileData.cFileName
                movsd    ;    TABLE_NAME_LENGTH
                movsd
                movsw
                mov AX, '">'
                stosw
;------------------------------------------------
;       * * *  Get User
;------------------------------------------------
                mov ESI, EDX
                CopyString
                TypeHtmlSection TABLE_GROUP_DEV
                mov [pTypeBuffer], EDI 

jmpNext@GroupSession:
        push FindFileData
        push [hFind]
        call [FindNextFile]

        test EAX, EAX
             jnz jmpTabScan@GroupSession

        push [hFind]
        call [FindClose]
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpEndForm@GroupSession:
    mov EDI, [pTypeBuffer]
    xor ECX, ECX
    TypeHtmlSection TABLE_GROUP_END

;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX

jmpEnd@GroupSession:
    ret 
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
