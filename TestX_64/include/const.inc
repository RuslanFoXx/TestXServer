;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   RESURSE: Define KeyWord Constants
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  Config Mode Params
;------------------------------------------------
CFG_PARAM_ENUM              equ   31        ;   SERVER_CONFIG_PARAM + HOST_COUNT + RESPONT_HEADER_COUNT + ASK_EXT_PARAM + ASK_ACCESS_PARAM

CFG_INDEX_RESPONT           equ  136        ;   SERVER_CONFIG_PARAM + HOST_COUNT ( 9 + 3 + 4 )
CFG_INDEX_PROCESS           equ  200        ;   SERVER_CONFIG_PARAM + RESPONT_HEADER_COUNT ( 16 + 8 )
CFG_INDEX_ACCESS            equ  224        ;   CFG_INDEX_PROCESS + ASK_EXT_PARAM ( 24 + 3 )

CFG_OFFSET_PROCESS          equ  200        ;   CFG_INDEX_PROCESS ( 200 )
CFG_OFFSET_ACCESS           equ  256        ;   CFG_INDEX_ACCESS + ASK_ACCESS_SIZE ( 224 - 32 )
;------------------------------------------------
;       * * *  Define Constant KeyWords  * * *
;------------------------------------------------
HEADER_HTTP_VER64           equ 0312E312F50545448h  ;   HTTP/1.1-версия.
CONTENT_ID                  equ 3D444952h   ; 'RID='.

ASK_EMPTY                   equ       002h  ; Пустая строка "/"
CHR_CR                      equ        0Dh  ; Пустая строка в заголовке: "\r"
CHR_LF                      equ        0Ah  ; Пустая строка в заголовке: "\n"
END_CRLF                    equ  0A0D0A0Dh  ; Пустая строка в заголовке: "\r\n\r\n"
CHR_CRLF                    equ      0A0Dh  ; Пустая строка в заголовке: "\r\n"

EXT_LOG                     equ 000676F6Ch  ; "log"
EXT_INI                     equ 000696E69h  ; "ini"
EXT_HTML                    equ 0006D7468h  ; "htm"

ASK_MODE                    equ 07068702Eh  ; ".php"
INS_TMP                     equ 0706D742Eh  ; ".tmp"

SET_CASE_UP                 equ       0DFh  ; C AND 223
SET_CASE_DOWN               equ       020h  ; c OR  32

KEY_CASE_UP                 equ 0DFDFDFDFh  ; 'A-Z' AND 223
KEY_CASE_DOWN               equ 020202020h  ; 'a-z' OR  32
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------
