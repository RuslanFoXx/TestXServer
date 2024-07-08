;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   MAIN: Define Memory
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;   * * *  Include System Library
;          you can simply switch between win64ax and win64wx here
;------------------------------------------------
include 'win64a.inc'
include 'equates\wsock32.inc'

include 'include\type.inc'
include 'include\base.inc'
include 'include\const.inc'
include 'include\resource.inc'
include 'include\tester.inc'
include 'include\string.inc'
;------------------------------------------------
;       * * *  System Constant  * * *
;------------------------------------------------
SET_SERVICE_MODE          equ TRUE
SET_DEBUF_MODE            equ FALSE   ;   TRUE / FALSE

STACK_FRAME_SIZE          equ 1FFFFFh ;   2MB all = 90716
STACK_FRAME_CLEAR         equ 908     ;   7252 + 8 / 8
;STACK_FRAME_CLEAR         equ ( szFileName - ThreadServerCtrl ) / 4 + 1
 
DELTA_ZERO_YEAR           equ  2000
MAX_INT_SCALE             equ  256

FILE_APPEND_DATA          equ 4

SET_WSA_VER               equ 0202h
INTERNET_PORT             equ 20480
ERROR_NETNAME_DELETED     equ 64
ERROR_IO_PENDING          equ 997
INVALID_SOCKET            equ -1
INVALID_SET_FILE_POINTER  equ -1

FD_ACCEPT_ERROR           equ 12
SOL_SOCKET                equ 0FFFFh
SO_REUSEADDR              equ  4
SD_BOTH                   equ  2
IPPROTO_TCP               equ  6

SERVICE_WIN32_OWN_PROCESS equ 010h
SERVICE_CONTROL_STOP      equ 001h
SERVICE_CONTROL_SHUTDOWN  equ 005h

SERVICE_ACCEPT_STOP       equ 001h
SERVICE_ACCEPT_SHUTDOWN   equ 004h

SERVICE_START_PENDING     equ 002h
SERVICE_STOP_PENDING      equ 003h
SERVICE_RUNNING           equ 004h
;------------------------------------------------
;       * * *  Limit Constants
;------------------------------------------------
MAX_CONFIG_COUNT          equ  1024
MAX_PARAM_LENGTH          equ   255

DATA_BUFFER_OFFSET        equ   256
CONFIG_BUFFER_SIZE        equ 16384
REPORT_BUFFER_SIZE        equ  2048    ;   2 * MAX_PATH_SIZE
MIN_BUFFER_SIZE           equ 16384
HTTP_HEADER_SIZE          equ 255

MAX_PATH_SIZE             equ  1024
MAX_URL_SIZE              equ  1024
NET_MAX_FILE              equ 01FFFFFFFFFFFh
LOG_MAX_FILE              equ 1000000

FORM_HEADER_SIZE          equ   256
HTTP_HEADER_SIZE          equ  4096
NET_MIN_FRAME             equ   256
NET_MAX_FRAME             equ 16384
;------------------------------------------------
;       * * *  Socket Constants
;------------------------------------------------
MAX_NET_PROC              equ (MAXIMUM_WAIT_OBJECTS-1)
MAX_RUN_PROC              equ 255
MAX_USR_ACCESS            equ 16

MAX_PROCESS               equ 4096
MAX_SOCKET                equ 65535  ;  131072
MAX_REPORT                equ 16384

MAX_NET_TIMEOUT           equ 3600   ; sec !
WAIT_SERVICE_HINT         equ 5000
WAIT_LIST_TIMEOUT         equ 2000   ; INFINITE
WAIT_PORT_TIMEOUT         equ 2000
WAIT_POST_TIMEOUT         equ 2000
WAIT_PROC_TIMEOUT         equ 2000
WORK_PROC_TIMEOUT         equ  500
WORK_EXIT_TIMEOUT         equ 1000
;------------------------------------------------
;       * * *  Status To Send/Revc  * * *
;              Send/Recv | File/Buffer | Conn/Close
;------------------------------------------------
SET_TRANS_BIT             equ  1   ;  0001
SET_SEND_BIT              equ  2   ;  0010
SET_FILE_BIT              equ  4   ;  0100
SET_PROC_BIT              equ  8   ;  1000

ROUTE_RECV_CONNECT        equ  0   ;  0000
ROUTE_RECV_BUFFER         equ  1   ;  0001
ROUTE_RECV_FILE           equ  5   ;  0101
ROUTE_RECV_END            equ  2   ;  0010

ROUTE_SEND_BUFFER         equ  3   ;  0011
ROUTE_SEND_FILE           equ  7   ;  0111

ROUTE_PROC_RECV           equ  8   ;  1000
ROUTE_PROC_SEND           equ  9   ;  1010
ROUTE_CLOSE               equ  0
;------------------------------------------------
;       * * *  Tester Constants  * * *
;------------------------------------------------
REPORT_TABLE_LIST         equ    5
ACCESS_USER               equ    1
ACCESS_READ_ONLY          equ    6
ACCESS_READ_WRITE         equ   13 ;  7 + ACCESS_READ_ONLY
ACCESS_ADMIN              equ   15 ;  2 + ACCESS_READ_WRITE

TOTAL_PROCESS_COUNT       equ   25 ; 11 + ACCESS_ADMIN

MIN_MEM_QUANT             equ 4096
MAX_MEMORY_SIZE           equ  512 * MIN_MEM_QUANT
MAX_BUFFER_SIZE           equ  256 * MIN_MEM_QUANT
MAX_SORT_NAME             equ   80
FILEPATH_SIZE             equ 1024
MAX_STRING_LENGTH         equ   80
FORMAT_SIZE               equ 1024

TABLE_PATH_SIZE           equ 2048
MAX_POST_SIZE             equ 1024
MAX_OPTION                equ   64

MAX_QUESTION              equ 1024
MAX_ANSWER                equ   16
DATA_FIELD_SIZE           equ  136   ; ( 1 + 16 ) * 8
DATA_TABLE_SIZE           equ 139264 ; ( 1 + 16 ) * 1024 * 8
ZERO_TABLE_COUNT          equ 17408  ; ( 1 + 16 ) * 1024

GET_ITEM                  equ  127
SET_ITEM_TRUE             equ  128

MAX_FILES                 equ  256
MAX_GROUP                 equ  256
MAX_VIEW_ITEMS            equ   40
MAX_VIEW_CENTER           equ   20 ; MAX_VIEW_ITEMS / 2
MAX_YEAR_ITEMS            equ    6
MAX_YEAR_CENTER           equ    3 ; MAX_YEAR / 2

DEFAULT_ITEMS             equ   20
DEFAULT_TIME              equ 1800 ; 30 * 60

GET_TIME                  equ   11
DELTA_YEAR                equ 2000
ZERO_YEAR                 equ 2020
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
