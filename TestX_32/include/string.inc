;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
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
    mov EDI, [lpTypeMemory]
    mov dword[EDI+FORM_STYLE], style

    lea EDI, [EDI+FORM_STYLE+FORM_HTML]
    xor ECX, ECX
}
;------------------------------------------------
;       * * *  Set Not Section ( without password )
;------------------------------------------------
macro InitHtmlClient style
{
    mov EDI, [lpTypeMemory]
    mov dword[EDI+FORM_STYLE], style

    lea EDI, [EDI+FORM_STYLE+FORM_HTML+FORM_HEADER]
    xor ECX, ECX
}
;------------------------------------------------
;       * * *  Set Section
;------------------------------------------------
macro InitHtmlSection style
{
    mov EDI, [lpTypeMemory]
    mov dword[EDI+FORM_STYLE], style

    mov EDI, [lpTypeBuffer]
    xor ECX, ECX
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
;       * * *  Copy String to Buffer 
;------------------------------------------------
macro TypeString String
{
    mov EBX, String
    mov EDX, EDI
    mov EDI, EBX
    mov EAX, EAX
    mov ECX, EAX
    mov CL,  MAX_STRING_LENGTH
    repnz scasb

    mov ESI, EBX     ;     string
    mov ECX, EDI
    inc EBX
    sub ECX, EBX
    mov EDI, EDX
    mov EDX, ECX     ;     length
    rep movsb
}
;------------------------------------------------
;       * * *  Copy String to Buffer 
;------------------------------------------------
macro CopyString
{
local TypeCopyString
;   mov ESI, String

TypeCopyString:
    lodsb
    stosb
    test AL, AL
         jnz TypeCopyString

    dec EDI
}
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------
