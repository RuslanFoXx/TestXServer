;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   MAIN: ParamPath + KeyWords
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
include 'form\form.inc'
;------------------------------------------------
;       * * *  Define ErrorMask  * * *
;------------------------------------------------
ADD_YEAR_VALUE         equ   20
GET_INDEX              equ   0Fh
EDIT_ACCESS            equ    2

MODE_SYSTEM            equ    0h  ;      SYS
MODE_USER              equ   01h  ;      USR
MODE_GROUP             equ   02h  ;      GRP
MODE_TABLE             equ   03h  ;      TBL
MODE_STORE             equ   04h  ;      ARH
MODE_TEST              equ   05h  ;      TST

PROC_GET               equ  010h  ;      GET
PROC_ADD               equ  020h  ;      GET
PROC_LIST              equ  030h  ;      LST
PROC_VIEW              equ  040h  ;      TAB
PROC_EDIT              equ  050h  ;      EDT
PROC_SET               equ  060h  ;      SET
PROC_BASE              equ  070h  ;      DAT
PROC_REPORT            equ  080h  ;      REP
;------------------------------------------------
;       * * *  Base
;------------------------------------------------
MODE_SYSTEM            equ    0h  ;      SYS
BASE_TEXT              equ  010h  ;      TXT
BASE_SCALE             equ  020h  ;      SCL
BASE_INDEX             equ  030h  ;      IND
BASE_GROUP             equ  040h  ;      USR
BASE_TABLE             equ  050h  ;      TBL
BASE_STORE             equ  060h  ;      STR
BASE_TEST              equ  070h  ;      TST
;------------------------------------------------
;       * * *  Error
;------------------------------------------------
ERR_GET_BUFFER         equ   00h  ;      Buffer
ERR_GET_DATE           equ   01h  ;      Date
ERR_GET_POST           equ   02h  ;      Request

ERR_GET_USER           equ   03h  ;      User
ERR_GET_PART           equ   04h  ;      Session
ERR_GET_GROUP          equ   05h  ;      Group
ERR_GET_TABLE          equ   06h  ;      Table
ERR_GET_STORE          equ   07h  ;      Store
ERR_GET_TEST           equ   08h  ;      Test
ERR_GET_PARAM          equ   09h  ;      Param

ERR_READ               equ   0Ah  ;      Read
ERR_WRITE              equ   0Bh  ;      Write
ERR_DIRECTORY          equ   0Ch  ;      Directory

TEST_PROC              equ    0h
TEST_TYPE              equ   01h  ;      TYPE
TEST_END               equ   80h

TEST_NUMBER            equ   81h  ;      HELLO
ACCESS_DENIED          equ   82h  ;      PSW
TEST_NOT_FOUND         equ   83h
TEST_CLOSE             equ   84h  ;      END
;------------------------------------------------
;       * * *  Define System Error  * * *
;------------------------------------------------
ERROR_SYSTEM           equ   '#ERR'
ERROR_PARAM            equ   'err '
;------------------------------------------------
;       * * *  Define ProcClient [MODE_USER]  * * *
;------------------------------------------------
ASK_TableClient        equ   'cx'  ;  not password !
ASK_GroupSession       equ   'gx'
;------------------------------------------------
;       * * *  Define ProcTest [MODE_TEST]  * * *
;------------------------------------------------
ASK_GetTextTest        equ   'tg'
ASK_CreateTest         equ   'tc'
ASK_ListAllTests       equ   'tl'
ASK_ViewTestAnswers    equ   'tv'
ASK_EditTestAnswers    equ   'tx'
ASK_SetTestOptions     equ   'tp'
ASK_TestToFile         equ   'tf'
;------------------------------------------------
;       * * *  Define ProcGroup [MODE_GROUP]  * * *
;------------------------------------------------
ASK_ImportGroup        equ   'gg'
ASK_CreateGroup        equ   'gc'
ASK_ListGroups         equ   'gl'
;------------------------------------------------
;       * * *  Define ProcTable [MODE_TABLE]  * * *
;------------------------------------------------
ASK_GetTableTest       equ   'bg'
ASK_CreateGroupBase    equ   'bc'
ASK_ListSession        equ   'bl'
ASK_ViewBaseClients    equ   'bv'
ASK_ViewTableClient    equ   'bx'
;------------------------------------------------
;       * * *  Define ProcStore [MODE_STORE]  * * *
;------------------------------------------------
ASK_StoreToBase        equ   'sz'
ASK_CreateStore        equ   'sc'
ASK_ViewStoreBase      equ   'sv'
ASK_ViewStoretClient   equ   'sx'
;------------------------------------------------
;       * * *  Define ProcReport [MODE_REPORT]  * * *
;------------------------------------------------
ASK_ReportTest         equ   'pt'
ASK_ReportStore        equ   'ps'
ASK_ReportTable        equ   'px'   ;  param TRUE  !
ASK_ReportTable        equ   'pz'   ;  param FALSE !
;------------------------------------------------
;       * * *  Define String
;------------------------------------------------
SET_X_ERROR            equ       21
CHR_CR                 equ       0Dh        ; Пустая строка в заголовке: "\r"
CHR_LF                 equ       0Ah        ; Пустая строка в заголовке: "\r"
END_LF                 equ     0A0Ah        ; Пустая строка в заголовке: "\r\r"
END_CR                 equ     0D0Dh        ; Пустая строка в заголовке: "\n\n"
END_CRLF               equ 0A0D0A0Dh        ; Пустая строка в заголовке: "\r\n\r\n"
CHR_CRLF               equ     0A0Dh        ; Пустая строка в заголовке: "\r\n"

CONTENT_ID             equ 3D444952h        ; 'RID='.
SET_CASE_UP            equ      0DFh        ; C and 223
SET_CASE_DOWN          equ       20h        ; c or  32

METHOD_CASE_UP         equ   0DFDFDFDFh     ; AAAA and 223
METHOD_CASE_DOWN       equ   020202020h     ; aaaa or  32

TXT                    equ 7478742Eh
DTB                    equ 6274642Eh
EER_N                  equ 5F524545h
END_OF_SCALE           equ 0A302C20h        ; ', 0\n'

TAB_QUESTION           equ 202A0A0Ah        ; '\n\n* '
ANSWER_TRUE            equ 20202B09h        ; '\t+  '
ANSWER_FALSE           equ 20202D09h        ; '\t-  '

FLT_FIND               equ     2A2Eh        ; '.*'
EXT_TXT                equ   747874h        ; '.txt'
EXT_TEST               equ   627464h        ; '.dtb'
EXT_USR                equ   727375h        ; '.usr'
EXT_TAB                equ   626174h        ; '.tab'
EXT_ARCH               equ   626467h        ; '.gdb'
;------------------------------------------------
;       * * *  Define String
;------------------------------------------------
MIN_TABLE_CODE         equ 10000
MAX_TABLE_CODE         equ 99999
MAX_TABLE_COUNT        equ   5
MAX_INDEX_COUNT        equ   5
;------------------------------------------------
;       * * *  Define Path
;------------------------------------------------
FILE_EXT_LENGTH        equ   4

TEXT_NAME_LENGTH       equ 255
GROUP_NAME_LENGTH      equ   5              ;       group\00000
BASE_NAME_LENGTH       equ   5              ;       base\00000
TABLE_NAME_LENGTH      equ  10              ;       base\00000\0000000000

TEXT_DIR_LENGTH        equ   5              ;       text\
TEST_DIR_LENGTH        equ   5              ;       test\
USER_DIR_LENGTH        equ   5              ;       user\
BASE_DIR_LENGTH        equ   5              ;       base\
GROUP_DIR_LENGTH       equ   6              ;       group\
STORE_DIR_LENGTH       equ   6              ;       store\
TABLE_DIR_LENGTH       equ   BASE_DIR_LENGTH  + BASE_NAME_LENGTH + 1 ;      Base\00000\
TABLE_NUM_LENGTH       equ   TABLE_DIR_LENGTH + MAX_TABLE_COUNT      ;      Base\00000\00000
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
