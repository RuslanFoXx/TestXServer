;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   MAIN: Structures + DataType
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  DataType  * * *
;------------------------------------------------
BYTE                         equ db
WORD                         equ dw
DWORD                        equ dd
QWORD                        equ dd
PWORD                        equ dd
PCHAR                        equ dd
LPVOID                       equ dd
HANDLE                       equ dd
SOCKET                       equ dd
LPHANDLE                     equ dd
WSAEVENT                     equ dd
SERVICE_STATUS_HANDLE        equ dd

STARTUPINFO_SIZE             equ 104
STARTUPINFO_COUNT            equ 13
PROCESS_INFORMATION_COUNT    equ  3
SOCKADDR_IN_SIZE             equ 16
MAXIMUM_WAIT_OBJECTS         equ 64
MAX_PATH_SIZE                equ 1024
MAX_URL_SIZE                 equ 1024
;------------------------------------------------
;       * * *  SERVICE_STATUS  * * *
;------------------------------------------------
struct SERVICE_STATUS
  dwServiceType               dd ?
  dwCurrentState              dd ?
  dwControlsAccepted          dd ?
  dwWin32ExitCode             dd ?
  dwServiceSpecificExitCode   dd ?
  dwCheckPoint                dd ?
  dwWaitHint                  dd ?
ends

LPSERVICE_STATUS             equ LPVOID
SERVICE_STATUS_SIZE          equ 28
SERVICE_STATUS_COUNT         equ  7
;------------------------------------------------
;       * * *  SECURITY_ATTRIBUTES  * * *
;------------------------------------------------
struct SECURITY_ATTRIBUTES
  nLength                     dd ?
  lpSecurityDescriptor        dd ?
  bInheritHandle              dd ?
ends

LPSECURITY_ATTRIBUTES        equ LPVOID
SECURITY_ATTRIBUTES_SIZE     equ 12
;------------------------------------------------
;       * * *  WSABUF  * * *
;------------------------------------------------
struct WSABUF
  len                         dd ?
  buf                         dd ?
ends

LPWSABUF                      equ LPVOID
PWSABUF_SIZE                  equ 8
;------------------------------------------------
;       * * *  WSAOVERLAPPED  * * *
;------------------------------------------------
struct WSAOVERLAPPED
  Internal                    dd ?
  InternalHigh                dd ?
  OffsetLow                   dd ?
  OffsetHigh                  dd ?
  hEvent                      dd ?
ends

LPWSAOVERLAPPED               equ LPVOID
WSAOVERLAPPED_SIZE            equ 20
;------------------------------------------------
;       * * *  WSANETWORKEVENTS  * * *
;------------------------------------------------
struct WSANETWORKEVENTS
  lNetworkEvents              dd ?
  iErrorCode                  dd 10 dup(?)
ends

LPWSANETWORKEVENTS           equ LPVOID
WSANETWORKEVENTS_SIZE        equ 44
;------------------------------------------------
;       * * *  RESPONT_HEADER  * * *
;------------------------------------------------
struct RESPONT_HEADER
  Http_200_Ok                 dd ?
  Http_201_Create             dd ?
  Http_400_BadRequest         dd ?
  Http_403_Forbidden          dd ?
  Http_404_NotFound           dd ?
; Http_405_Allowed            dd ?
  Http_500_Internal           dd ?
  Http_501_NotImplement       dd ?
  Http_503_Busy               dd ?
ends

LPRESPONT_HEADER             equ LPVOID
RESPONT_HEADER_SIZE          equ 32
RESPONT_HEADER_COUNT         equ  8
;------------------------------------------------
;       * * *  SERVER_CONFIG  * * *
;------------------------------------------------
struct SERVER_CONFIG
  MaxRecvSize                 dd ?
  MaxReportStack              dd ?
  MaxConnections              dd ?
  MaxRunning                  dd ?
  MaxTimeOut                  dd ?
  BufferSize                  dd ?
  HeadSize                    dd ?
  RecvSize                    dd ?
  SendSize                    dd ?
  MaxRecvFileSize             dd ?

  lpTempFolder                dd ?
  lpBaseFolder                dd ?
  lpReportPath                dd ?
  lpHostAddress               dd ?
  lpHostFolder                dd ?
  lpCodeFolder                dd ?
  lpDefPage                   dd ?
ends

LPSERVER_CONFIG              equ LPVOID
SERVER_CONFIG_SIZE           equ 68
SERVER_CONFIG_COUNT          equ 17
SERVER_CONFIG_PARAM          equ 16
SERVER_CONFIG_DWORD          equ  9
SERVER_CONFIG_HOST           equ  6
;------------------------------------------------
;       * * *  SYSTEM_MODE  * * *
;------------------------------------------------
struct SYSTEM_MODE
  Mode                        dd ?
  Process                     dd ?
ends
;------------------------------------------------
;       * * *  ASK_ACCESS  * * *
;------------------------------------------------
struct ASK_ACCESS
  Key                         dd ?
  User                        dd ?
  Mode                        dd ?
  Address                     dd ?
ends

LPASK_ACCESS                 equ LPVOID
ASK_ACCESS_SIZE              equ 16
ASK_ACCESS_COUNT             equ  4
ASK_ACCESS_PARAM             equ  4
;------------------------------------------------
;       * * *  SOCKTIME  * * *
;------------------------------------------------
struct SOCKTIME
  Year                        dw ?
  Second                      dw ?
  Minute                      dw ?
  Hour                        dw ?
  Month                       dw ?
  Day                         dw ?
ends
;------------------------------------------------
;       * * *  ASK_EXT  * * *
;------------------------------------------------
struct ASK_EXT
  AskExt                     dd ?
  Type                       dd ?
  Disposition                dd ?
  Reserved                   dd ?
ends

LPASK_EXT                   equ LPVOID
ASK_EXT_SIZE                equ 16
ASK_EXT_COUNT               equ  4
ASK_EXT_PARAM               equ  3
;------------------------------------------------
;       * * *  PORT_IO_DATA  * * *
;------------------------------------------------
struct PORT_IO_DATA
  Overlapped                  WSAOVERLAPPED ?  ;   20
  WSABuffer                   WSABUF ?         ;   8
  ExtRunProc                  dd ?
  TimeLimit                   dd ?    ;    For Accept
  TablePort                   dd ?
  Socket                      dd ?    ;    For Report
  Address                     db 16 dup (?)
  Client                      dd ?
  ResurseId                   dd ?    ;    Clear Memory
  TransferredBytes            dd ?
  ExitCode                    dd ?    ;    End Report
  Connection                  dw ?
  Route                       dw ?
  hProcess                    dd ?
  hFile                       dd ?
  TotalBytes                  dd ?    ;    GetFileSize = QWord !!!
  CountBytes                  dd ?
  UrlSize                     dw ?
  Path                        db MAX_PATH_SIZE+2 dup (?)
  Buffer                      dd ?
ends

LPPORT_IO_DATA               equ LPVOID
PORT_DATA_SIZE               equ 1128     ;     102 + MAX_PATH_SIZE + 2
PORT_CLEAR_COUNT             equ 10
;PORT_INIT_COUNT             equ ACCEPT_HEADER_COUNT
;------------------------------------------------
;       * * *  REPORT_HEADER  * * *
;------------------------------------------------
struct REPORT_HEADER
  Index                       dd ?
  Error                       dd ?
ends

LPREPORT_HEADER              equ LPVOID
REPORT_HEADER_SIZE           equ  8
REPORT_HEADER_COUNT          equ  2
;------------------------------------------------
;       * * *  REPORT_INFO  * * *
;------------------------------------------------
struct REPORT_INFO
  Index                       dd ?
  Error                       dd ?
  Socket                      dd ?
  Address                     db 16 dup (?)
  Client                      dd ?
  ResurseId                   dd ?
  TransferredBytes            dd ?
  ExitCode                    dd ?
  UrlSize                     dw ?,?
; UrlPath                     db FILENAME_SIZE dup (?)
ends

LPREPORT_INFO                equ LPVOID
REPORT_INFO_SIZE             equ 48
REPORT_INFO_COUNT            equ 12
REPORT_INFO_PORT             equ  9
REPORT_INFO_PATH_SIZE        equ REPORT_INFO_SIZE + MAX_PATH_SIZE
;------------------------------------------------
;       * * *  ACCEPT_HEADER  * * *
;------------------------------------------------
struct ACCEPT_HEADER
  TimeLimit                   dd ?   ;   Index
  TablePort                   dd ?   ;   Error
  Socket                      dd ?
  Address                     db 16 dup (?)
ends

LPACCEPT_HEADER              equ LPVOID
ACCEPT_HEADER_SIZE           equ 28
ACCEPT_HEADER_COUNT          equ  7
ACCEPT_HEADER_REPORT         equ  7
ACCEPT_HEADER_CLEAR          equ  2
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
