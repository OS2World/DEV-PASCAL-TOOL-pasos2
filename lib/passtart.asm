;*
;* FileName:   passtart.inc
;* $Source: E:/usr/src/c-code/pascal/RCS/LIB/passtart.asm,v $
;* $Author: wjw $
;* $Date: 1993/11/03 15:54:50 $
;* $Locker: wjw $
;* $State: Exp $
;* $Revision: 1.1 $
;* Description:
;*      Part of the runtime library which comes with PASCAL for OS/2
;*      
;*
;* History:
;*      First created by Willem Jan Withagen ( wjw@eb.ele.tue.nl ),
;*                    on Mon July 26 23:30:03 MET 1993
;* Copyright:
;*      Copyright (c) 1993 by Willem Jan Withagen and 
;*                      Digital Information Systems group, TUE
;*      For copying and distribution information see the file COPYRIGHT.
;*
;* 
        .386
        include pashead.inc

IFDEF TASM
_STACK   SEGMENT
        db 128*1024 DUP(?)
_STACK   ENDS
ELSE
STACK   SEGMENT PAGE STACK FLAT 'STACK'
        db 128*1024 DUP(?)
STACK   ENDS
ENDIF

        .data
        ;  Specify the DISPLAY save location where all the dynamic pointers are 
        ;  kept. 64 Levels should be more than sufficient.
_$DISPL         DD 64 DUP(0)
$$$RetSave      DD 1 DUP(0)

        .code
	;  Stuff called in the OS/2 libs.
        GLOB  DOS32OPEN:PROC
        GLOB  DOS32CLOSE:PROC
        GLOB  DOS32WRITE:PROC
        GLOB  DOS32READ:PROC
        GLOB  DOS32QUERYHTYPE:PROC
        GLOB  DOS32EXIT:PROC
        GLOB  DOS32ALLOCMEM:PROC
        GLOB  DOS32FREEMEM:PROC
        GLOB  DOS32SUBALLOC:PROC
        GLOB  DOS32SUBFREE:PROC
        GLOB  DOS32SUBSET:PROC
        GLOB  DOS32SUBUNSET:PROC
        
        ;  Using this macro, it is possible to imitate the C call mechanism
        ;  as long as there is only ONE C call going one at the time.
        ;  'size' indicates the number of parameters
CCALL   MACRO name,size
    _$&name  PROC
        pop [$$$retsave]
        call name
        add esp,size*4
        push [$$$retsave]
        ret
    _$&name  ENDP        
ENDM

        ;  These routines are available with $-prefix to be called from the
        ;  PASCAL programs. The number gives the actual number of parameters
	;  that are on the stack when the $$name is called.
CCALL   DOS32OPEN      ,8
CCALL   DOS32CLOSE     ,1
CCALL   DOS32WRITE     ,4
CCALL   DOS32READ      ,4
CCALL   DOS32QUERYHTYPE,3
CCALL   DOS32EXIT      ,2
CCALL   DOS32AlLOCMEM  ,3
CCALL   DOS32FREEMEM   ,1
CCALL   DOS32SUBALLOC  ,3
CCALL   DOS32SUBFREE   ,3
CCALL   DOS32SUBSET    ,3
CCALL   DOS32SUBUNSET  ,1

        GLOB _$$Pmain:PROC
        GLOB _$$StdInit:PROC
        GLOB _$$StdExit:PROC
$$$Startmain PROC
        ;  First set something up which looks like an old Framepointer
$$$Start::
        mov ebp, esp
        call _$$StdInit     ; Initialise the funtime system
        call _$$Pmain       ; Execute the user program
        ;  Probably a call to flush/close all pascal handles?
        call _$$StdExit
        ;  Return to the calling system.
        push 0
        push 1
        call DOS32EXIT
        ret
$$$Startmain ENDP        

        ; Additional routines which are use from the generated code
        ; But are not easily programmed in PASCAL straight
_$$memcpy PROC
_$$memcopy PROC
        ; This will evaluate to use $$$memcpy
        ; But $$..... can not be used from PASCAL.
_$$memcopy ENDP
        ; copy param1 to param2 for param3 bytes
        ; Currently just the dumb and simple way, could be better by doing
        ; dword alligned moves, and patches at the begin and and.
        mov edi, [esp+8]       ; Param 2 (Destination)
        mov esi, [esp+4]       ; Param 1 (Source)
        mov ecx, [esp+12]
        cld
        rep movsb
        ret 12
_$$memcpy ENDP

_$$OrWord PROC
        mov eax,[esp+8]
        or  eax,[esp+4]
        ret 8
_$$OrWord ENDP

_$$AndWord PROC
        mov eax,[esp+4]
        and eax,[esp+8]
        ret 8
_$$AndWord ENDP

_$$InvWord PROC
        mov eax,[esp+4]
        not eax
        ret 4
_$$InvWord ENDP

_$$shl   PROC 
        mov eax,[esp+4]
        mov ecx,[esp+8]
        shl eax,cl
        ret 8
_$$shl   ENDP

_$$straddr   PROC
        ; The parameter is actually an address
        ; This is returned
        mov eax,[esp+4]
        ret 4
_$$straddr   ENDP

	END $$$Start
;*
;* $Log: passtart.asm,v $
;; Revision 1.1  1993/11/03  15:54:50  wjw
;; Started adminstration for the RUNTIME LIB
;;
;*
;*      First created by Willem Jan Withagen ( wjw@eb.ele.tue.nl ),
;*                    on Mon July 26 23:30:03 MET 1993
;* 
