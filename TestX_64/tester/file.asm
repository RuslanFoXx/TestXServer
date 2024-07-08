;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   SYSTEM: File
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
;       * * *  ReadFileName  * * *
;------------------------------------------------
proc ReadToBuffer

    xor RAX, RAX
    param 4, RAX
    mov [ReadBytes], RAX
    mov AL,  64
    sub RSP, RAX
;------------------------------------------------
;       * * *  OpenFile
;------------------------------------------------
    param 7, R9  ;  0
    param 6, FILE_ATTRIBUTE_READONLY
    param 5, OPEN_EXISTING
    param 3, FILE_SHARE_READ 
    param 2, GENERIC_READ 
;   param 1, pFilePath
    call [CreateFile]
    cmp RAX, INVALID_HANDLE_VALUE
        je jmpEnd@ReadToBuffer
;------------------------------------------------
;       * * *  Get FileSize
;------------------------------------------------
        mov [hFile], RAX

        param 1, RAX
        param 2, ReadBytes
        call [GetFileSizeEx]
;------------------------------------------------
;       * * *  ReadFile to Buffer  * * *
;------------------------------------------------
        mov RCX, [ReadBytes]
           jECXz jmpClose@ReadToBuffer
            xor RAX, RAX
            param 5, RAX
            param 4, ReadBytes
            param 3, RCX
            param 2, [lpMemBuffer]
            param 1, [hFile]
            call [ReadFile]

            test EAX, EAX
                 jz jmpClose@ReadToBuffer
                 mov RCX, [ReadBytes]
                    jECXz jmpClose@ReadToBuffer

                     mov RDI, [lpMemBuffer]
                     mov [pReadBuffer], RDI
                     add RDI, RCX
                     xor RAX, RAX
                     stosb
                     mov [lpMemBuffer], RDI

;                    mov  AX, MIN_BUFFER_SIZE
;                    add RAX, RDI
;                    cmp RAX, [TabSocketIoData]
;                        jb jmpClose@ReadToBuffer
;                        xor RAX, RAX
;                        dec RAX
;                        mov [ReadBytes], RAX
jmpClose@ReadToBuffer:
        param 1, [hFile]
        call [CloseHandle]

jmpEnd@ReadToBuffer:
    mov RCX, [ReadBytes]
    xor RAX, RAX
    mov AL,  64
    add RSP, RAX
    ret
endp
;------------------------------------------------
;       * * *  WriteFileName  * * *
;------------------------------------------------
proc WriteFromBuffer

    mov [WriteBytes],   R8
    mov [pWriteBuffer], RDX

    xor RAX, RAX
    param 4, RAX
    mov [ReadBytes], RAX
    mov AL,  64
    sub RSP, RAX
;------------------------------------------------
;       * * *  OpenFile
;------------------------------------------------
    param 7, R9
    param 6, FILE_ATTRIBUTE_NORMAL
    param 5, CREATE_ALWAYS
;   param 4, 0
    param 3, FILE_SHARE_READ 
    param 2, GENERIC_WRITE
;   param 1, pFilePath
    call [CreateFile]
    cmp RAX, INVALID_HANDLE_VALUE
        je jmpEnd@WriteFromBuffer
        mov [hFile], RAX
;------------------------------------------------
;       * * *  WriteFile from Buffer
;------------------------------------------------
        param 1, RAX
        xor RAX, RAX
        param 5, RAX
        param 4, ReadBytes
        param 3, [WriteBytes]
        param 2, [pWriteBuffer]
        call [WriteFile]
;       test EAX, EAX
;            jz jmpClose@WriteFromBuffer
;            mov RCX, [ReadBytes]
;               jECXz jmpClose@WriteFromBuffer
;jmpClose@Close:
        param 1, [hFile]
        call [CloseHandle]

jmpEnd@WriteFromBuffer:
    mov RCX, [ReadBytes]
    xor RAX, RAX
    mov AL,  64
    add RSP, RAX
    ret
endp
;------------------------------------------------
;       * * *  WriteIndexFile
;------------------------------------------------
proc WriteToPosition

    mov [WriteIndex],   R9
    mov [WriteBytes],   R8
    mov [pWriteBuffer], RDX

    xor RAX, RAX
    param 4, RAX
    mov [ReadBytes], RAX
    mov AL,  64
    sub RSP, RAX
;------------------------------------------------
;       * * *  OpenFile
;------------------------------------------------
    param 7, R9
    param 6, FILE_ATTRIBUTE_NORMAL
    param 5, OPEN_ALWAYS
    param 3, FILE_SHARE_READ 
    param 2, GENERIC_WRITE
;   param 1, pFilePath
    call [CreateFile]
    cmp RAX, INVALID_HANDLE_VALUE
        je jmpEnd@WriteToPosition
        mov [hFile], RAX
;------------------------------------------------
;       * * *  FileSeek
;------------------------------------------------
        mov RDX, [WriteIndex]
        test EDX, EDX
             jz jmpWrite@WriteToPosition
             param 1, RAX
;            param 2, [WriteIndex]
             param 3, 0
             param 4, FILE_BEGIN
             call [SetFilePointer]
             cmp EAX, INVALID_SET_FILE_POINTER
                 je jmpClose@WriteToPosition
;------------------------------------------------
;       * * *  WriteFile from Buffer
;------------------------------------------------
jmpWrite@WriteToPosition:
        xor RAX, RAX
        param 5, RAX
        param 4, ReadBytes
        param 3, [WriteBytes]
        param 2, [pWriteBuffer]
        param 1, [hFile]
        call [WriteFile]
;       test EAX, EAX
;            jz jmpClose@WriteToPosition
;            mov RCX, [ReadBytes]
;               jECXz jmpClose@WriteToPosition

jmpClose@WriteToPosition:
        param 1, [hFile]
        call [CloseHandle]

jmpEnd@WriteToPosition:
    mov RCX, [ReadBytes]
    xor RAX, RAX
    mov AL,  64
    add RSP, RAX
    ret
endp
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
