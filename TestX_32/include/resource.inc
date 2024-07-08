;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   RESURSE: Define Param + Headers
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  HTTP Request Date  * * *
;------------------------------------------------
SET_WEEK_HEADER             equ   8
SET_DAY_HEADER              equ  13
SET_MONTH_HEADER            equ  16
SET_YEAR_HEADER             equ  22
SET_HOUR_HEADER             equ  25
SET_MINUTE_HEADER           equ  28
SET_SECOND_HEADER           equ  31
;------------------------------------------------
;       * * *  HTTP Request Method  * * *
;------------------------------------------------
HTTP_200_OK                 equ   0
HTTP_201_CREATE             equ   4
HTTP_400_BAD_REQUEST        equ   8
HTTP_403_FORBIDDEN          equ  12
HTTP_404_NOT_FOUND          equ  16
HTTP_405_ALLOWED            equ   ?
HTTP_500_INTERNAL           equ  20
HTTP_501_NOT_IMPLEMENT      equ  24
HTTP_503_BUSY               equ  28
;------------------------------------------------
;       * * *  Service Errors
;------------------------------------------------
REPORT_MESSAGE_COUNT        equ 83
SYS_ERR_ConfigFile          equ  0

SYS_ERR_Dispatcher          equ  1
SYS_ERR_Register            equ  2
SYS_ERR_StartPending        equ  3
SYS_ERR_Start               equ  4
SYS_ERR_StopPending         equ  5
SYS_ERR_Stop                equ  6
;------------------------------------------------
;       * * *  Socket Errors
;------------------------------------------------
SYS_ERR_WSAversion          equ  7
SYS_ERR_Socket              equ  8
SYS_ERR_Option              equ  9
SYS_ERR_Binding             equ 10
SYS_ERR_Listen              equ 11
SYS_ERR_NetEvent            equ 12
SYS_ERR_SetEvent            equ 13
SYS_ERR_SocketPort          equ 14
SYS_ERR_ProcEvent           equ 15

SYS_ERR_ThreadRouter        equ 16
SYS_ERR_ThreadListen        equ 17
SYS_ERR_ThreadProcess       equ 18
;------------------------------------------------
;       * * *  System Errors
;------------------------------------------------
SYS_ERR_CommandLine         equ 19
SYS_ERR_TableBuffer         equ 20
;------------------------------------------------
;       * * *  Config Errors
;------------------------------------------------
CFG_ERR_SystemParam         equ 21
CFG_ERR_SystemValue         equ 22
CFG_ERR_HostParam           equ 23
CFG_ERR_HostValue           equ 24
CFG_ERR_AccessParam         equ 22
PRC_ERR_Date                equ 23
;------------------------------------------------
;       * * *  TimeOut (lpTimeIoData)
;------------------------------------------------
SYS_ERR_TimeShutDown        equ 25
;------------------------------------------------
;       * * *  Processes (lpProcIoData)
;------------------------------------------------
PRC_ERR_WaitProc            equ 26
PRC_ERR_ExitProc            equ 27
SRV_ERR_SetDirectory        equ 28
PRC_ERR_PipeSize            equ 29
;------------------------------------------------
;       * * *  Listen Errors (lpListIoData)
;------------------------------------------------
NET_ERR_SocketMemory        equ 36    ;    for CloseListenPort
NET_ERR_FindSocket          equ 37
NET_ERR_PortSocket          equ 38
NET_ERR_SendListen          equ 39
NET_ERR_RecvHeader          equ 40    ;    end CloseListenPort

NET_ERR_WaitConnect         equ 41

NET_ERR_GetConnect          equ 42
NET_ERR_SetConnect          equ 43
NET_ERR_Accept              equ 44
;------------------------------------------------
;       * * *  Router SendFile (lpSockIoData)
;------------------------------------------------
SRV_ERR_WaitRoute           equ 45
SRV_ERR_RouteMode           equ  ?

SRV_ERR_FileAttributes      equ  ?
SRV_ERR_OpenFile            equ 48
SRV_ERR_OpenSize            equ  ?
SRV_ERR_ReadFile            equ 50
SRV_ERR_ReadSize            equ 51

SRV_ERR_SendRouter          equ 52
SRV_ERR_ReadClose           equ 53
;------------------------------------------------
;       * * *  Router RecvFile (lpSockIoData)
;------------------------------------------------
SRV_ERR_SaveFile            equ 54
SRV_ERR_WriteFile           equ 55
SRV_ERR_SaveSize            equ 56
SRV_ERR_SizeWrite           equ  ?
SRV_ERR_RecvSize            equ 58

SRV_ERR_RecvRouter          equ 59
SRV_ERR_SaveClose           equ 60
;------------------------------------------------
;       * * *  Router Errors
;------------------------------------------------
SRV_ERR_SocketClose         equ 61
SRV_ERR_WriteClose          equ 62
SRV_ERR_ShutDown            equ 63

SRV_MSG_Send                equ 64
SRV_MSG_Recv                equ 65
SRV_MSG_Save                equ 66
;------------------------------------------------
;       * * *  Server Connect
;------------------------------------------------
SYS_MSG_Start               equ 67
SYS_MSG_Stop                equ 68
SYS_MSG_ShutDown            equ 69

SRV_MSG_Connected           equ 70
SRV_MSG_Disconnected        equ 71
SRV_MSG_BreakConnect        equ 72
SRV_MSG_TimeOut             equ 73
SRV_MSG_Close               equ 74
;------------------------------------------------
;       * * *  Server Resurse
;------------------------------------------------
SRV_ERR_Method              equ 75
SRV_ERR_Header              equ 76
SRV_ERR_Url                 equ 77
SRV_ERR_PathSize            equ 78
SRV_MSG_OpenAccess          equ 79
SRV_MSG_RecvDataSize        equ 80

NET_MSG_ConnectLimit        equ 81
SRV_MSG_ProcessLimit        equ 82

MSG_NO_ERROR                equ SRV_MSG_Send
MSG_NO_INFORMATION          equ SYS_MSG_Start
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------
