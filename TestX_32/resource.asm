;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   MAIN: Main + Config + Start
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;   * * *  Init Procedures * * *
;------------------------------------------------
IndexBasePath equ MaxQueuedProcess
;section '.code' code readable executable
;------------------------------------------------
;   * * *  Includes System Modules
;------------------------------------------------
;include 'debug\info.asm'

include 'http\header.asm'
include 'http\method.asm'

include 'system\param.asm'
include 'system\report.asm'
include 'system\config.asm'

include 'tester\string.asm'
include 'tester\hash.asm'
include 'tester\time.asm'
include 'tester\file.asm'
;------------------------------------------------
;   * * *  Includes Thread Modules
;------------------------------------------------
include 'thread\service.asm'
include 'thread\listen.asm'
include 'thread\route.asm'
include 'thread\process.asm'
;------------------------------------------------
;   * * *  Includes Base Modules
;------------------------------------------------
include 'tester\proc\proc.asm'
include 'tester\proc\open.asm'
include 'tester\proc\list.asm'

include 'tester\base\start.asm'
include 'tester\base\test.asm'
include 'tester\base\client.asm'
include 'tester\base\group.asm'
include 'tester\base\table.asm'
include 'tester\base\store.asm'
include 'tester\base\report.asm'
;------------------------------------------------
;   * * *  Import Library Procedures * * *
;------------------------------------------------
section '.idata' import data readable writeable

;DD 0,0,0, RVA szUser32,     RVA LibraryUser32
DD 0,0,0,  RVA szKernel32,   RVA LibraryKernel32
DD 0,0,0,  RVA szWinSocket2, RVA LibraryWinSocket2
DD 0,0,0,  RVA szAdvAPI32,   RVA LibraryAdvAPI32
DD 0,0,0,0,0
;------------------------------------------------
;   * * *  Import Table User32 * * *
;------------------------------------------------
;LibraryUser32:

;MessageBox                  DD RVA szMessageBox
;EndUser32                   DD NULL
;------------------------------------------------
;   * * *  Import Table Kernel32 * * *
;------------------------------------------------
LibraryKernel32:

GetLastError                 DD RVA szGetLastError
VirtualAlloc                 DD RVA szVirtualAlloc
VirtualFree                  DD RVA szVirtualFree
GetTickCount                 DD RVA szGetTickCount
GetLocalTime                 DD RVA szGetLocalTime
GetSystemTime                DD RVA szGetSystemTime 
GetCommandLine               DD RVA szGetCommandLine
;GetEnvironmentStrings       DD RVA szGetEnvironmentStrings
;FreeEnvironmentStrings      DD RVA szFreeEnvironmentStrings
;InitializeCriticalSection   DD RVA szInitializeCriticalSection
;EnterCriticalSection        DD RVA szEnterCriticalSection
;LeaveCriticalSection        DD RVA szLeaveCriticalSection
;DeleteCriticalSection       DD RVA szDeleteCriticalSection
CreateIoCompletionPort       DD RVA szCreateIoCompletionPort
GetQueuedCompletionStatus    DD RVA szGetQueuedCompletionStatus
;PostQueuedCompletionStatus  DD RVA szPostQueuedCompletionStatus
;GetStdHandle                DD RVA szGetStdHandle
SetHandleInformation         DD RVA szSetHandleInformation
CloseHandle                  DD RVA szCloseHandle
Sleep                        DD RVA szSleep
CreateEvent                  DD RVA szCreateEvent
SetEvent                     DD RVA szSetEvent
CreateThread                 DD RVA szCreateThread
ExitThread                   DD RVA szExitThread
;CreateProcess               DD RVA szCreateProcess
ExitProcess                  DD RVA szExitProcess
;GetExitCodeProcess          DD RVA szGetExitCodeProcess
WaitForSingleObject          DD RVA szWaitForSingleObject
;WaitForMultipleObjects      DD RVA szWaitForMultipleObjects
;TerminateProcess            DD RVA szTerminateProcess
;CreatePipe                  DD RVA szCreatePipe
;PeekNamedPipe               DD RVA szPeekNamedPipe
FindFirstFile                DD RVA szFindFirstFile
FindNextFile                 DD RVA szFindNextFile
FindClose                    DD RVA szFindClose
CreateFile                   DD RVA szCreateFile
;GetFileAttributes           DD RVA szGetFileAttributes
GetFileType                  DD RVA szGetFileType
GetFileSizeEx                DD RVA szGetFileSizeEx
SetFilePointer               DD RVA szSetFilePointer
ReadFile                     DD RVA szReadFile
WriteFile                    DD RVA szWriteFile
;MoveFile                    DD RVA szMoveFile
DeleteFile                   DD RVA szDeleteFile
;GetCurrentDirectory         DD RVA szGetCurrentDirectory
;SetCurrentDirectory         DD RVA szSetCurrentDirectory
CreateDirectory              DD RVA szCreateDirectory
RemoveDirectory              DD RVA szRemoveDirectory
EndTableKernel32             DD NULL
;------------------------------------------------
;   * * *  Import Table WinSocket2 * * *
;------------------------------------------------
LibraryWinSocket2:

;htons                       DD RVA szHtons
;inet_ntoa                   DD RVA szInet_ntoa
;inet_addr                   DD RVA szInet_addr
setsockopt                   DD RVA szSetSockOpt
bind                         DD RVA szBinding
listen                       DD RVA szListen
shutdown                     DD RVA szShutdown
closesocket                  DD RVA szCloseSocket
WSAStartup                   DD RVA szWSAStartup
WSAGetLastError              DD RVA szWSAGetLastError
WSACreateEvent               DD RVA szWSACreateEvent
WSAEnumNetworkEvents         DD RVA szWSAEnumNetworkEvents
WSAWaitForMultipleEvents     DD RVA szWSAWaitForMultipleEvents
WSAEventSelect               DD RVA szWSAEventSelect
WSACloseEvent                DD RVA szWSACloseEvent
WSASocket                    DD RVA szWSASocket
WSAAccept                    DD RVA szWSAAccept
WSASend                      DD RVA szWSASend
WSARecv                      DD RVA szWSARecv
WSACleanup                   DD RVA szWSACleanup
EndTableWinSocket2           DD NULL
;------------------------------------------------
;   * * *  Import Table AdvAPI32 * * *
;------------------------------------------------
LibraryAdvAPI32:

SetServiceStatus             DD RVA szSetServiceStatus
RegisterServiceCtrlHandler   DD RVA szRegisterServiceCtrlHandler
StartServiceCtrlDispatcher   DD RVA szStartServiceCtrlDispatcher
EndTableAdvAPI32             DD NULL
;------------------------------------------------
;   * * *  Init Service Dispacher  * * *
;------------------------------------------------
ServiceTable                 DD szServiceName, ServiceMain, NULL, NULL
SizeOfAddrIn                 DD SOCKADDR_IN_SIZE
;------------------------------------------------
;       * * *  Access Selector
;------------------------------------------------
RunProcModule:

;LPVOID TableClient, GroupSession 
LPVOID ReportTest, ReportGroup, ReportStore, ReportTable, ReportTable
;------------------------------------------------
;       * * *  Selector Read Procedures
;------------------------------------------------
LPVOID ListGroupBase,   ViewBaseClients, ViewTableClient
LPVOID ViewStoreClient, ViewStoreBase
LPVOID ListGroups,      GroupSession 
;------------------------------------------------
;       * * *  Selector Edit Procedures
;------------------------------------------------
LPVOID GetTableTest, CreateGroupBase
;------------------------------------------------
;       * * *  Selector Admin Procedures
;------------------------------------------------
LPVOID StoreToBase, CreateStore
LPVOID ImportGroup, CreateGroup
LPVOID GetTextTest, CreateTest, ListAllTests, ViewTestAnswers , EditTestAnswers, SetTestOptions, TestToFile
;------------------------------------------------
;       * * *  Define Month
;------------------------------------------------
GetDateMonth:
	DW TEST_GET_ERR@
	DW GROUP_LIST_JAN@
	DW GROUP_LIST_FEB@
	DW GROUP_LIST_MAR@
	DW GROUP_LIST_APR@
	DW GROUP_LIST_MAY@
	DW GROUP_LIST_JUN@
	DW GROUP_LIST_JUL@
	DW GROUP_LIST_AUG@
	DW GROUP_LIST_SEP@
	DW GROUP_LIST_OCT@
	DW GROUP_LIST_NOV@
	DW GROUP_LIST_DEC@

GetLenMonth:
	DB TEST_GET_ERR
	DB GROUP_LIST_JAN
	DB GROUP_LIST_FEB
	DB GROUP_LIST_MAR
	DB GROUP_LIST_APR
	DB GROUP_LIST_MAY
	DB GROUP_LIST_JUN
	DB GROUP_LIST_JUL
	DB GROUP_LIST_AUG
	DB GROUP_LIST_SEP
	DB GROUP_LIST_OCT
	DB GROUP_LIST_NOV
	DB GROUP_LIST_DEC

DefaultScaleData:
	DW DEFAULT_ITEMS
	DW DEFAULT_TIME
	DW 67, 1, 6, 12, 16, 18, DEFAULT_ITEMS + 1
	DW 6 dup(0)
;------------------------------------------------
;       * * *  WinAPI ProcNames
;------------------------------------------------
SERVICE_NAME_LENGTH = 10

;szUser32                     DB 'USER32.DLL',0
szKernel32                    DB 'KERNEL32.DLL',0
szAdvAPI32                    DB 'ADVAPI32.DLL',0
szWinSocket2                  DB 'WS2_32.DLL',0

szServiceName                 DB 'AntXServer',0
;szServiceName                DB 'AntTestXServer',0
;szMessageBox                 DB 0,0, 'MessageBoxA',0

szGetLastError                DB 0,0, 'GetLastError',0
szVirtualAlloc                DB 0,0, 'VirtualAlloc',0
szVirtualFree                 DB 0,0, 'VirtualFree',0
szGetTickCount                DB 0,0, 'GetTickCount',0
szGetLocalTime                DB 0,0, 'GetLocalTime',0
szGetSystemTime               DB 0,0, 'GetSystemTime',0
szGetCommandLine              DB 0,0, 'GetCommandLineA',0
;szGetEnvironmentStrings      DB 0,0, 'GetEnvironmentStringsA',0
;szFreeEnvironmentStrings     DB 0,0, 'FreeEnvironmentStringsA',0
;szInitializeCriticalSection  DB 0,0, 'InitializeCriticalSection',0
;szEnterCriticalSection       DB 0,0, 'EnterCriticalSection',0
;szLeaveCriticalSection       DB 0,0, 'LeaveCriticalSection',0
;szDeleteCriticalSection      DB 0,0, 'DeleteCriticalSection',0
szCreateIoCompletionPort      DB 0,0, 'CreateIoCompletionPort',0
szGetQueuedCompletionStatus   DB 0,0, 'GetQueuedCompletionStatus',0
;szPostQueuedCompletionStatus DB 0,0, 'PostQueuedCompletionStatus',0
;szGetStdHandle               DB 0,0, 'GetStdHandle',0
szSetHandleInformation        DB 0,0, 'SetHandleInformation',0
szCloseHandle                 DB 0,0, 'CloseHandle',0
szSleep                       DB 0,0, 'Sleep',0
szCreateEvent                 DB 0,0, 'CreateEventA',0
szSetEvent                    DB 0,0, 'SetEvent',0
szCreateThread                DB 0,0, 'CreateThread',0
szExitThread                  DB 0,0, 'ExitThread',0
;szCreateProcess              DB 0,0, 'CreateProcessA',0
szExitProcess                 DB 0,0, 'ExitProcess',0
;szGetExitCodeProcess         DB 0,0, 'GetExitCodeProcess',0
szWaitForSingleObject         DB 0,0, 'WaitForSingleObject',0
;szWaitForMultipleObjects     DB 0,0, 'WaitForMultipleObjects',0
;szTerminateProcess           DB 0,0, 'TerminateProcess',0
;szCreatePipe                 DB 0,0, 'CreatePipe',0
;szPeekNamedPipe              DB 0,0, 'PeekNamedPipe',0
szFindFirstFile               DB 0,0, 'FindFirstFileA',0
szFindNextFile                DB 0,0, 'FindNextFileA',0
szFindClose                   DB 0,0, 'FindClose',0
szCreateFile                  DB 0,0, 'CreateFileA',0
;szGetFileAttributes          DB 0,0, 'GetFileAttributesA',0
szGetFileType                 DB 0,0, 'GetFileType',0
szGetFileSizeEx               DB 0,0, 'GetFileSizeEx',0
szSetFilePointer              DB 0,0, 'SetFilePointer',0
szReadFile                    DB 0,0, 'ReadFile',0
szWriteFile                   DB 0,0, 'WriteFile',0
;szMoveFile                   DB 0,0, 'MoveFileA',0
szDeleteFile                  DB 0,0, 'DeleteFileA',0
;szGetCurrentDirectory        DB 0,0, 'GetCurrentDirectoryA',0
szSetCurrentDirectory         DB 0,0, 'SetCurrentDirectoryA',0
szCreateDirectory             DB 0,0, 'CreateDirectoryA',0
szRemoveDirectory             DB 0,0, 'RemoveDirectoryA',0

;szHtons                      DB 0,0, 'htons',0
;szInet_ntoa                  DB 0,0, 'inet_ntoa',0
;szInet_addr                  DB 0,0, 'inet_addr',0
szSetSockOpt                  DB 0,0, 'setsockopt',0
szBinding                     DB 0,0, 'bind',0
szListen                      DB 0,0, 'listen',0
szShutdown                    DB 0,0, 'shutdown',0
szCloseSocket                 DB 0,0, 'closesocket',0
szWSAStartup                  DB 0,0, 'WSAStartup',0
szWSAGetLastError             DB 0,0, 'WSAGetLastError',0
szWSACreateEvent              DB 0,0, 'WSACreateEvent',0
szWSAEnumNetworkEvents        DB 0,0, 'WSAEnumNetworkEvents',0
szWSAWaitForMultipleEvents    DB 0,0, 'WSAWaitForMultipleEvents',0
szWSAEventSelect              DB 0,0, 'WSAEventSelect',0
szWSACloseEvent               DB 0,0, 'WSACloseEvent',0
szWSASocket                   DB 0,0, 'WSASocketA',0
szWSAAccept                   DB 0,0, 'WSAAccept',0
szWSASend                     DB 0,0, 'WSASend',0
szWSARecv                     DB 0,0, 'WSARecv',0
szWSACleanup                  DB 0,0, 'WSACleanup',0

szSetServiceStatus            DB 0,0, 'SetServiceStatus',0
szRegisterServiceCtrlHandler  DB 0,0, 'RegisterServiceCtrlHandlerA',0
szStartServiceCtrlDispatcher  DB 0,0, 'StartServiceCtrlDispatcherA',0
;------------------------------------------------
;   * * *  Init Server Headers  * * *
;------------------------------------------------
;szHeaderMethod               DB 'HTTP/1.1 200 '
szHeaderServer                DB 13,10, 'Server: WebTestXServer 1.1.75 x32'
szVersionServer               DB 13,10, 'Date: '
szHeaderType                  DB ' GMT'
                              DB 13,10, 'Content-Type: '
szHeaderDisposition           DB 13,10, 'Content-Disposition: '
szHeaderLength                DB 13,10, 'Content-Length: '
szHeaderConnection            DB 13,10, 'Connection: '
szClose                       DB 'close'
szKeepAlive                   DB 'keep-alive'
szKeepAliveEnd:
;szHeaderOptions              DB 13,10, 'Allow: GET, POST, OPTIONS'
;                             DB 13,10, 'Last-Modified: Wed, 13 Mar 2024 10:00:00 GMT'
;szBody                       DB 13,10,13,10, '<!DOCTYPE html>'
;------------------------------------------------
;   * * *  Init Const Strings  * * *
;------------------------------------------------
szTagOk                       DB 2, 'Ok'
szHeaderTextHtml              DB 9, 'text/html'
;szDisposition                DB 6, 'inline'
;------------------------------------------------
;   * * *  Define Tester Path  * * *
;------------------------------------------------
szTextDirPath                 DB 'text\*.txt', 0
szTestDirPath                 DB 'test\*.dtb', 0
szUserDirPath                 DB 'user\*.txt', 0

szGroupDirPath                DB 'group\00000.usr', 0
szStoreDirPath                DB 'store\00000.gdb', 0
szTablePath                   DB 'base\00000\0000000000.tab', 0
szIndexDirPath                DB 'base\table.ind', 0
;------------------------------------------------
;   * * *  MethodWords + ConfigWords
;------------------------------------------------
sMonthDateHeader              DB 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec '
sWeekDateHeader               DB 'Sun,Mon,Tue,Wed,Thu,Fri,Sat,'
sServerConfigParam            DB 5,'Stack',7,'Connect',7,'Process',4,'Time',6,'Buffer',6, 'Header',4,'Recv',4,'Send',4,'File',4,'Temp',4,'Base',6,'Report'
sHostPathParam                DB 7,'Address',4,'Site',4,'Code',4,'Page'
sGetHttpMethod                DB 3,'200',3,'201',3,'400',3,'403',3,'404',3,'500',3,'501',3,'503'
sRunningExtParam              DB 3,'Ask',4,'Type',11,'Disposition'
sAccessUserParam              DB 3,'Key',4,'User',4,'Mode',9,'IPAddress',0,0
sHexScaleChar                 DB '0123456789ABCDEF'
;------------------------------------------------
;   * * *  Define Tester Path
;------------------------------------------------
KeyRunProccess                DB 'ptpgpspzpx'      ;    not pasword
KeyReadProccess               DB 'blbvbxsxsvglgx'  ;    set pasword
KeyEditProccess               DB 'bgbcszscgggc'
KeyAdminProccess              DB 'tgtctltvtxtstf'
;------------------------------------------------
TextBaseError                 DB 'SYS_TXT_SCL_IND_USR_TBL_STR_TST_'
TextCodeError                 DB 'BufferDateRequestUserSessionGroupTableStoreTestParamReadWriteDirectory'
TextIndexError                DB 0, 6, 10, 17, 21, 28, 33, 38, 43, 47, 52, 56, 61, 70
szTypeForm                    DB FORM_RESURSE_SIZE dup('@')
;------------------------------------------------
;       * * *  Init Server Params  * * *
;------------------------------------------------
section '.data' data readable writeable  ;  added 2 sections
;------------------------------------------------
sStrByteScale     DD MAX_INT_SCALE dup(?)
ServerTime           SYSTEMTIME ?
LocalTime            SYSTEMTIME ?

;Key                 DWORD ?
Method               DWORD ?
Param                DWORD ?

TotalAccess          DWORD ?
TotalProcess         DWORD ?

GetUsrAccess         LPASK_ACCESS ?
GetRunProc           LPASK_EXT ?
SetRunProc           LPASK_EXT ?
pBuffer              PCHAR ?
pFind                PCHAR ?
;------------------------------------------------
;       * * *  Init Service DataSection
;------------------------------------------------
ThreadServerCtrl     DWORD ?
ThreadSocketCtrl     DWORD ?
ThreadListenCtrl     DWORD ?
ThreadProcessCtrl    DWORD ?

;hFile               HANDLE ?
hFileReport          HANDLE ?
hPortIOSocket        HANDLE ?
hStatus              SERVICE_STATUS_HANDLE ?

SrvStatus            SERVICE_STATUS ?
dSecurity            SECURITY_ATTRIBUTES ?
Address              sockaddr_in ?
;------------------------------------------------
;       * * *  Init Config DataSection
;------------------------------------------------
SocketDataSize       DWORD ?

ServerResurseId      DWORD ?
SetOptionPort        DWORD ?
CountProcess         DWORD ?

PostBytes            DWORD ?
TotalBytes           DWORD ?
CountBytes           DWORD ?

TransBytes           DWORD ?
TransFlag            DWORD ?

ServerConfig         SERVER_CONFIG ?
lppTagRespont        RESPONT_HEADER ?
lppReportMessages DD REPORT_MESSAGE_COUNT dup(?)
;------------------------------------------------
;       * * *  Init Table Buffer
;------------------------------------------------
TabSocketIoData      LPPORT_IO_DATA ?

TabListenReport      LPREPORT_INFO ?
GetListenReport      LPREPORT_INFO ?
SetListenReport      LPREPORT_INFO ?
MaxListenReport:

TabRouteReport       LPREPORT_INFO ?
GetRouteReport       LPREPORT_INFO ?
SetRouteReport       LPREPORT_INFO ?
MaxRouteReport:

TabQueuedProcess     LPPORT_IO_DATA ?
GetQueuedProcess     LPPORT_IO_DATA ?
SetQueuedProcess     LPPORT_IO_DATA ?
MaxQueuedProcess     LPPORT_IO_DATA ?
;------------------------------------------------
;       * * *  Init Report DataSection
;------------------------------------------------
lpFileReport         LPREPORT_INFO ?

ListenReport         ACCEPT_HEADER ?
RouterHeader         REPORT_HEADER ?
;------------------------------------------------
SystemReport         REPORT_INFO ?
TimeOutReport        REPORT_INFO ?
;------------------------------------------------
;       * * *  Init Router DataSection
;------------------------------------------------
lpPortIoCompletion   LPVOID ?
lpSocketIoData       LPPORT_IO_DATA ?
TransferredBytes     DWORD ?
;------------------------------------------------
;       * * *  Init Listener DataSection
;------------------------------------------------
WSockVer             WSADATA ?
ListenEvent          WSANETWORKEVENTS ?

ListenSocket         SOCKET ?
NetworkEvent         WSAEVENT ?
RunProcessEvent      HANDLE ?
;------------------------------------------------
;       * * *  Init Process DataSection
;------------------------------------------------
DefAskFile           ASK_EXT ?
TabAskFile        DB ASK_EXT_SIZE * MAX_RUN_PROC dup(?)
;------------------------------------------------
;       * * *  Init Access Clients 
;------------------------------------------------
;ClientAccess        ASK_ACCESS ?
TabUsrAccess      DB ASK_ACCESS_SIZE * MAX_USR_ACCESS dup(?)
;------------------------------------------------
;       * * *  Init Tester DataSection
;------------------------------------------------
TabConfig:
TableBasePath        TABLE_PATH ?
TableBaseScan        BASE_PATH ?
TestBasePath         BASE_PATH ?
StoreBasePath        BASE_PATH ?
GroupBasePath        BASE_PATH ?
UserBasePath         BASE_PATH ?
TextBasePath         BASE_PATH ?

pReadBuffer          PCHAR ?   ;   file.asm
;pWriteBuffer        PCHAR ?

lpSystemBuffer       PCHAR ?
lpTypeMemory         PCHAR ?
lpMemBuffer          PCHAR ?
lpSaveBuffer         PCHAR ?
lpTypeBuffer         PCHAR ?
pTypeBuffer          PCHAR ?
pPostBuffer          PCHAR ?

pRandGroup           PWORD ?
pRandQuest           PWORD ?
pRandAnswer          PWORD ?

LocalYear            DWORD ?
DateRandom           DWORD ?
ReadBytes            DWORD ?,? ;   GetFileSizeEx()
FileSize             DWORD ?
BaseSize             DWORD ?   ;   AddTable()

hFile                HANDLE ?
hFind                HANDLE ?
FindFileData         WIN32_FIND_DATA ?
ClientAccess         SYSTEM_MODE ?

IndexDataBase        INDEX_BASE ?
TestDataBase         TEST_BASE ?
UserDataBase         USER_BASE ?
TableDataBase        TABLE_BASE ?

;Param               DWORD ?

;Check               WORD ?
LevelB               WORD ?
LevelC               WORD ?

Ind                  DWORD ? 
Count                DWORD ?
Time                 DWORD ?
Date                 DWORD ?
Year                 DWORD ?
Month                DWORD ?
Question             DWORD ?
Quest                DWORD ?
Next                 DWORD ?
Prev                 DWORD ?

Fields               DWORD ?
Items                DWORD ?
ItemCount            DWORD ?
CountFiles           DWORD ?   ;   list.asm

NameSize             DWORD ?
PathSize             DWORD ?   ;   GetGroup()

;pFind               PCHAR ?
pTestScale           PCHAR ?
pTextBuffer          PCHAR ?
pTextOffset          PCHAR ?

pTableFile           PCHAR ?
pTableUser           PCHAR ?
pTableData           PCHAR ?
pTabQuestion         PCHAR ?
pTabAnswer           PCHAR ?

pTabTest             PCHAR ?
pTabData             PCHAR ?
pTabCheck            PCHAR ?
pTabGroup            PCHAR ?

pName                PCHAR ?
pMath                PCHAR ?
pUserName            PCHAR ?
pItemCheck           PCHAR ?

AskBuffer         DB HTTP_HEADER_SIZE dup(?)
AskOption            PCHAR MAX_OPTION dup(?)
;------------------------------------------------
;       * * *  Init Buffers
;------------------------------------------------
szFileName           DB MAX_PATH_SIZE dup(?)
szBuffer             DB MAX_PATH_SIZE dup(?)
szReportName         DB MAX_PATH_SIZE dup(?)
szFuckName           DB MAX_PATH_SIZE dup(?)

_DataBuffer_         DB DATA_BUFFER_OFFSET dup(?)
                     DB CONFIG_BUFFER_SIZE dup(?)
szTextReport         DB REPORT_BUFFER_SIZE dup(?)
;EndOfData           DB ?
;section '.reloc' fixups data readable discardable   ; needed for Win32s
;------------------------------------------------
;   * * *   END  * * *
;------------------------------------------------
