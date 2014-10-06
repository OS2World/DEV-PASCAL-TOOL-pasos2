/*
;*
;* FileName:   passtart.S
;* $Source: E:/usr/src/c-code/pascal/RCS/LIB/passtart.S,v $
;* $Author: wjw $
;* $Date: 1993/11/03 15:54:50 $
;* $Locker: wjw $
;* $State: Exp $
;* $Revision: 1.1 $
;* Description:
;*      Part of the runtime library which comes with PASCAL for OS/2
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
 */     
        .file "passtart"
        .text
        .globl _main
	.align 2,0x90
_main:  /* enter */
        pushl %ebp
        movl %esp,%ebp
	call _$LocInit
        call _$$stdinit
        call _$$Pmain
	call _$$stdexit
        leave
        ret
        
_dummy: /* just to please the linker */
        call ___main
        ret
        
_$LocInit:
        /* Set modes to binary for the std-channels */
	push $Lbin
	push $__streamv+(0*48)
        call __fsetmode
        push $Lbin
        push $__streamv+(1*48)
        call __fsetmode
        push $Lbin
        push $__streamv+(2*48)
        call __fsetmode
        addl $(6*4), %esp
        ret
        
Lbin:   .asciz "b"
        
        .data
        /* The place to save PASCAL's active static links */
        .globl _$displ
.comm   _$displ, 4*64        
        / And the TOS for a one time return value.
.lcomm  _$$retsave, 4

	/  Using this macro, it is possible to imitate the C call mechanism
        /  as long as there is only ONE c-call going on at the time.
        /  'size' indicates the number of parameters

#define CCALL(name,size)               \
       .globl _$c ## name             ;\
_$c ## name:                           \
        popl _$$retsave(,1)           ;\
        call _ ## name                ;\
        add $size*4,%esp              ;\
        pushl _$$retsave(,1)          ;\
        ret

        /  These routines are available with $-prefix to be called from the
        /  PASCAL programs.
CCALL( open,   2 )
CCALL( close,  1 )
CCALL( write,  3 )
CCALL( read,   3 )
CCALL( isatty, 1 )
CCALL( exit,   1 )
CCALL( malloc, 1 )
CCALL( free,   1 )

        / Additional routines which are use from the generated code
        / But are not easily programmed in straight PASCAL
        .globl _$$memcpy
        .globl _$$memcopy
_$$memcpy:
_$$memcopy:
        / copy param1 to param2 for param3 bytes
        / Currently just the dumb and simple way, could be better by doing
        / dword alligned moves, and patches at the begin and and.
        movl 8(%esp),%edi       / Param 2 (Destination)
        movl 4(%esp),%esi       / Param 1 (Source)
        movl 12(%esp),%ecx
        cld
        rep; movsb
        ret $12

	.globl _$$orword
_$$orword:
        movl 8(%esp),%eax
        orl  4(%esp),%eax
        ret $8
	.globl _$$andword
_$$andword:
        movl 4(%esp),%eax
        andl 8(%esp),%eax
        ret $8
	.globl _$$invword
_$$invword:
        movl 4(%esp),%eax
        notl %eax
        ret $4
	.globl _$$shl
_$$shl: 
        movl 4(%esp),%eax
        movl 8(%esp),%ecx
        shl %cl,%eax
        ret $8
	.globl _$straddr
	.globl _$$straddr
_$straddr:
_$$straddr:
        / The parameter is actually an address
        / This is returned
        mov 4(%esp),%eax
        ret $4

/*
;*
;* $Log: $
;*
;*      First created by Willem Jan Withagen ( wjw@eb.ele.tue.nl ),
;*                    on Mon July 26 23:30:03 MET 1993
;* 
 */
