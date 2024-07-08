;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   SYSTEM: File
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  ReadFileName  * * *
;------------------------------------------------
proc ReadToBuffer

;   mov EDX, pFileName
    xor EAX, EAX
    mov [ReadBytes], EAX
;------------------------------------------------
;       * * *  OpenFile
;------------------------------------------------
;   xor EAX, EAX
    push EAX
    push FILE_ATTRIBUTE_READONLY
    push OPEN_EXISTING
    push EAX
    push FILE_SHARE_READ
    push GENERIC_READ
    push EDX
    call [CreateFile]

    cmp EAX, INVALID_HANDLE_VALUE
        je jmpEnd@ReadToBuffer
;------------------------------------------------
;       * * *  Get FileSize
;------------------------------------------------
        mov [hFile], EAX
        push EAX
        push ReadBytes
        push EAX
        call [GetFileSizeEx]
;------------------------------------------------
;       * * *  ReadFile to Buffer  * * *
;------------------------------------------------
        mov ECX, [ReadBytes]
           jECXz jmpClose@ReadToBuffer
            xor EAX, EAX
            push EAX
            push ReadBytes
            push ECX
            push [lpMemBuffer]
            push [hFile]
            call [ReadFile]

            test EAX, EAX
                 jz jmpClose@ReadToBuffer
                 mov ECX, [ReadBytes]
                    jECXz jmpClose@ReadToBuffer

                     mov EDI, [lpMemBuffer]
                     mov [pReadBuffer], EDI
                     add EDI, ECX
                     xor EAX, EAX
                     stosb
                     mov [lpMemBuffer], EDI

;                    mov  AX, MIN_BUFFER_SIZE
;                    add EAX, EDI
;                    cmp EAX, [TabSocketIoData]
;                        jb jmpClose@ReadToBuffer
;                        xor EAX, EAX
;                        dec EAX
;                        mov [ReadBytes], EAX
jmpClose@ReadToBuffer:
;       push [hFile]
        call [CloseHandle]

jmpEnd@ReadToBuffer:
    mov ECX, [ReadBytes]
    ret 
endp
;------------------------------------------------
;       * * *  WriteFileName  * * *
;------------------------------------------------
proc WriteFromBuffer __buffer__,__writebytes__

;   mov EDX, pFileName
    xor EAX, EAX
    mov [ReadBytes], EAX
;------------------------------------------------
;       * * *  OpenFile
;------------------------------------------------
    push EAX
    push FILE_ATTRIBUTE_NORMAL
    push CREATE_ALWAYS
    push EAX
    push FILE_SHARE_READ
    push GENERIC_WRITE
    push EDX
    call [CreateFile]

    cmp EAX, INVALID_HANDLE_VALUE
        je jmpEnd@WriteFromBuffer
;       mov [hFile], EAX
        push EAX
;------------------------------------------------
;       * * *  WriteFile from Buffer
;------------------------------------------------
        xor ECX, ECX
        push ECX
        push ReadBytes
        push [__writebytes__]
        push [__buffer__]
        push EAX
        call [WriteFile]

;       test EAX, EAX
;            jz jmpClose@WriteFromBuffer
;            mov ECX, [ReadBytes]
;               jECXz jmpClose@WriteFromBuffer
;jmpClose@Close:
;       push [hFile]
        call [CloseHandle]

jmpEnd@WriteFromBuffer:
    mov ECX, [ReadBytes]
    ret 
endp
;------------------------------------------------
;       * * *  WriteIndexFile
;------------------------------------------------
proc WriteToPosition  __buffer__,__writebytes__,__index__

;   mov EDX, pFileName
    xor EAX, EAX
    mov [ReadBytes], EAX
;------------------------------------------------
;       * * *  OpenFile
;------------------------------------------------
    push EAX
    push FILE_ATTRIBUTE_NORMAL
    push OPEN_ALWAYS
    push EAX
    push FILE_SHARE_READ
    push GENERIC_WRITE
    push EDX
    call [CreateFile]

    cmp EAX, INVALID_HANDLE_VALUE
        je jmpEnd@WriteToPosition

        mov [hFile], EAX
        push EAX
;------------------------------------------------
;       * * *  FileSeek
;------------------------------------------------
        mov ECX, [__index__]
           jECXz jmpWrite@WriteToPosition
            push FILE_BEGIN
            xor EDX, EDX
            push EDX
            push ECX
            push EAX
            call [SetFilePointer]

            cmp EAX, INVALID_SET_FILE_POINTER
                je jmpClose@WriteToPosition
;------------------------------------------------
;       * * *  WriteFile from Buffer
;------------------------------------------------
jmpWrite@WriteToPosition:
        xor EAX, EAX
        push EAX
        push ReadBytes
        push [__writebytes__]
        push [__buffer__]
        push [hFile]
        call [WriteFile]

;       test EAX, EAX
;            jz jmpClose@WriteToPosition
;            mov ECX, [ReadBytes]
;               jECXz jmpClose@WriteToPosition

jmpClose@WriteToPosition:
;       push [hFile]
        call [CloseHandle]

jmpEnd@WriteToPosition:
    mov ECX, [ReadBytes]
    ret
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
