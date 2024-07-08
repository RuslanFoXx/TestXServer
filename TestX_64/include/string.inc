;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
;   SYSTEM: Macros of Strings
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
gettext     equ szTypeForm +;   FormTextOffset
;------------------------------------------------
CSS_TEST    equ 'test'
CSS_VIEW    equ 'view'
CSS_LIST    equ 'list'
;------------------------------------------------
;       * * *  Set Not Section ( without password )
;------------------------------------------------
macro InitHtmlReport style
{
    mov RDI, [lpTypeMemory]
    mov dword[RDI+FORM_STYLE], style

    lea EDI, [EDI+FORM_STYLE+FORM_HTML]
    xor RCX, RCX
    mov RSI, RCX
}
;------------------------------------------------
;       * * *  Set Not Section ( without password )
;------------------------------------------------
macro InitHtmlClient style
{
    mov RDI, [lpTypeMemory]
    mov dword[RDI+FORM_STYLE], style

    lea RDI, [RDI+FORM_STYLE+FORM_HTML+FORM_HEADER]
    xor RCX, RCX
    mov RSI, RCX
}
;------------------------------------------------
;       * * *  Set Section
;------------------------------------------------
macro InitHtmlSection style
{
    mov RDI, [lpTypeMemory]
    mov dword[RDI+FORM_STYLE], style

    mov RDI, [lpTypeBuffer]
    xor RCX, RCX
    mov RSI, RCX
}
;------------------------------------------------
;       * * *  Set Section
;------------------------------------------------
macro SetHtmlSection count
{
	mov ESI, szTypeForm + count#@
	if count <= 0FFh
		mov CL, count
	else \
	if count <= 0FFFFh
		mov CX, count
	else
		mov ECX, count
	end if
}
;------------------------------------------------
;       * * *  Type Section
;------------------------------------------------
macro TypeHtmlSection count
{
	mov ESI, szTypeForm + count#@
	if count <= 0FFh
		mov CL, count
	else \
	if count <= 0FFFFh
		mov CX, count
	else
		mov ECX, count
	end if
	rep movsb  
}
;------------------------------------------------
;       * * *  Copy Section
;------------------------------------------------
macro CopyHtmlSection offset, count
{
	mov ESI, szTypeForm + offset
	if count <= 0FFh
		mov CL, count
	else \
	if count <= 0FFFFh
		mov CX, count
	else
		mov ECX, count
	end if
	rep movsb  
}
;------------------------------------------------
;       * * *  Copy dd-Index to Buffer 
;------------------------------------------------
macro TypeIndex Byte
{
local @TypeIndex

    mov RAX, Byte
    xor RDX, RDX
    mov CL,  10
    div ECX

    mov AH, DL
    add AX, '00'
    mov EDX, EAX

    cmp AL, '0'
        je @TypeIndex
        stosb

@TypeIndex:
    mov AL, DH
    stosb
}
;------------------------------------------------
;       * * *  Copy String to Buffer 
;------------------------------------------------
macro TypeString String
{
    mov RBX, String
    mov RDX, RDI
    mov RDI, RBX
    mov RAX, RAX
    mov RCX, RAX
    mov CL,  MAX_STRING_LENGTH
    repnz scasb

    mov RSI, RBX     ;     string
    mov RCX, RDI
    inc RBX
    sub RCX, RBX
    mov RDI, RDX
    mov RDX, RCX     ;     length
    rep movsb
}
;------------------------------------------------
;       * * *  Copy String to Buffer 
;------------------------------------------------
macro CopyString
{
local @TypeCopyString
;   mov RSI, String

@TypeCopyString:
    lodsb
    stosb
    test AL, AL
         jnz @TypeCopyString

    dec RDI
}
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------
