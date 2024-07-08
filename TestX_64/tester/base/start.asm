;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   MAIN: Prompt Client + Admin
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Starting Tester  * * *
;------------------------------------------------
proc TestBegin

    xor RCX, RCX
    mov RBX, RCX
    mov R15, RCX
    mov R15d, gettext CLIENT_NUMBER@
    mov BL,  CLIENT_NUMBER
    cmp AL,  TEST_NUMBER
        je jmpType@TestBegin

    mov R15d, gettext ADMIN_PASSWORD@
    mov BL,  ADMIN_PASSWORD
    cmp AL,  ACCESS_DENIED
        je jmpType@TestBegin

    mov R15d, gettext CLIENT_FINISH@
    mov BL,  CLIENT_FINISH
    cmp AL,  TEST_CLOSE
        je jmpType@TestBegin

    mov R15d, gettext CLIENT_NOT_FOUND@
    mov BL,  CLIENT_NOT_FOUND
    cmp AL,  TEST_NOT_FOUND
        je jmpType@TestBegin
;------------------------------------------------
;   * * *  Type Error Code
;------------------------------------------------
    mov R8,   RAX
    mov R15d, AskBuffer
    mov RDI,  R15
;   mov RSI, gettext SYSTEM_ERROR@
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
    mov EBX, R8d
    shr EBX, 4
    and EBX, ECX
    mov EAX, dword[TextBaseError+RBX*4]
    stosd

    lea RSI,[TextIndexError+RBX]
    xor EAX, EAX
    lodsb
    mov CL, [RSI]
    sub ECX, EAX
    lea ESI,[TextCodeError+RBX]
	rep movsb

    mov RBX, RDI
    sub RBX, R15
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

         mov RSI, R15   ;   offset szBuffer 
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

    mov RSI, R15    ;   offset szBuffer 
    mov ECX, EBX
    rep movsb

    TypeHtmlSection FORM_ADMIN_END

    mov RSI, [lpTypeBuffer]
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
    mov RSI, [AskOption+8]
    xor RAX, RAX
    mov [AskOption + 8], RAX
;------------------------------------------------
    call StrToWord
;------------------------------------------------
;   mov  AL,  ERR_GET_PART
    test EBX, EBX 
;        jz jmpEnd@GroupSession
         jz jmpListGroup@ListGroups
;------------------------------------------------
;       * * *  Get IndexBase
;------------------------------------------------
;   mov [IndexDataBase.session], EBX
    call OpenIndexBase

    test EAX, EAX
;        jnz jmpEnd@GroupSession
         jnz jmpListGroup@ListGroups
;------------------------------------------------
;       * * *  Set TestBase
;------------------------------------------------
;   mov RBX, [IndexDataBase.name]
;   mov RBX, RSI
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
    mov RDI, [TableBasePath.session]
    mov EBX, [IndexDataBase.session]
    call IndexToStr

    mov RDI, [TableBaseScan.dir]
    mov RSI, [TableBasePath.session]
    movsd
    movsb
;------------------------------------------------
;       * * *  FormHeader
;------------------------------------------------
    InitHtmlClient  CSS_TEST
    TypeHtmlSection TABLE_GROUP
    TypeHtmlSection FORM_TITLE
    TypeHtmlSection TABLE_GROUP_HEAD1

    mov RSI, [GroupBasePath.name]
    movsd
    movsb

    TypeHtmlSection TABLE_GROUP_HEAD2

    mov RSI, [UserDataBase.user]
    CopyString

    TypeHtmlSection TABLE_GROUP_HEAD3

    mov EBX, [TestDataBase.tests]
    call WordToStr

    TypeHtmlSection TABLE_GROUP_HEAD4

    mov RSI, [TableBasePath.session]
    movsd
    movsb

    TypeHtmlSection TABLE_GROUP_HEAD5

    mov RSI, [TestDataBase.text]
    CopyString

    TypeHtmlSection TABLE_GROUP_HEAD6

    mov ECX, [UserDataBase.date] 
    mov R11d, ECX  
    call StrDate

    TypeHtmlSection TABLE_GROUP_HEAD7

    mov ECX, R11d 
    call StrTime

    TypeHtmlSection TABLE_GROUP_HEAD8
    TypeHtmlSection CLIENT_NAME
    TypeHtmlSection TABLE_GROUP_HEAD9

    mov [pTypeBuffer], RDI
;------------------------------------------------
;       * * *  Init Scan Folder
;------------------------------------------------
;   xor RCX, RCX
    mov  CL, 32
    sub RSP, RCX

    param 2, FindFileData 
    param 1, [TableBaseScan.path]
    call [FindFirstFile]

    cmp RAX, INVALID_HANDLE_VALUE
        je jmpEndForm@GroupSession
        mov [hFind], RAX
;------------------------------------------------
;       * * *  Read Table
;------------------------------------------------
jmpTabScan@GroupSession:
        mov RSI, FindFileData.cFileName
        mov RDI, [TableBasePath.table]
        movsq    ;    TABLE_NAME_LENGTH
        movsw

        param 1, [TableBasePath.path]
        call ReadToBuffer

        cmp ECX, TABLE_HEADER_SIZE
            jbe jmpNext@GroupSession

            mov RSI, [pReadBuffer]
            mov [lpMemBuffer], RSI
            xor EAX, EAX

            lodsd
            shr EAX, 16
            cmp EAX, [IndexDataBase.group]
                jne jmpNext@GroupSession
;------------------------------------------------
;       * * *  Get User
;------------------------------------------------
                xor RBX, RBX
                mov RDX, RBX
                mov BL, [RSI+TABLE_HEADER.user-4]
                dec RBX

                mov RSI, [UserDataBase.index]
                mov EDX, [RSI+RBX*4]
                add RDX,  [UserDataBase.user]
;------------------------------------------------
;       * * *  Get Table
;------------------------------------------------
                mov RDI, [pTypeBuffer]
                xor RCX, RCX
                mov RSI, RCX
;------------------------------------------------
                TypeHtmlSection TABLE_GROUP_USER
;------------------------------------------------
                mov RSI, FindFileData.cFileName
                movsd    ;    TABLE_NAME_LENGTH
                movsd
                movsw
                mov AX, '">'
                stosw
;------------------------------------------------
;       * * *  Get User
;------------------------------------------------
                mov RSI, RDX
                CopyString
                TypeHtmlSection TABLE_GROUP_DEV
                mov [pTypeBuffer], RDI 
;------------------------------------------------
jmpNext@GroupSession:
        param 2, FindFileData 
        param 1, [hFind]
        call [FindNextFile]

        test EAX, EAX
             jnz jmpTabScan@GroupSession

        param 1, [hFind]
        call [FindClose]
;------------------------------------------------
;       * * *  EndForm
;------------------------------------------------
jmpEndForm@GroupSession:
    xor RCX, RCX    ;   TEST_POST
    mov  CL, 32
    add RSP, RCX
;   xor RCX, RCX
    mov RDI, [pTypeBuffer]
    TypeHtmlSection TABLE_GROUP_END

;   xor EAX, EAX    ;   TEST_POST
    mov EAX, ECX

jmpEnd@GroupSession:
    ret 
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
