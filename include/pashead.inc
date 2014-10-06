; MASM code to be used in every module assembled.
; define the default used segments
; and give them a name.
        .386
        includelib p
	includelib doscalls

; Do some assembler dependant stuff.        
GLOB   MACRO text
  IFNDEF TASM
       EXTERNDEF text
  ELSE
       GLOBAL text
  ENDIF
       ENDM
;  Typical assembler stuff for MASM
IFDEF MASM
        .MODEL FLAT,OS_OS2
CODE    SEGMENT PAGE PUBLIC FLAT 'CODE'
CODE    ENDS

DATA    SEGMENT PAGE PUBLIC FLAT 'DATA'
DATA    ENDS

CONST   SEGMENT PAGE PUBLIC FLAT 'CONST'
CONST   ENDS

BSS     SEGMENT PAGE PUBLIC FLAT 'BSS'
BSS     ENDS

STACK   SEGMENT PAGE STACK FLAT 'STACK'
STACK   ENDS

DGROUP  GROUP DATA,CONST,BSS,STACK
        ASSUME CS:FLAT,DS:FLAT,ES:FLAT,SS:FLAT

ENDIF

;  Typical assembler stuff for TASM
IFDEF TASM
        MODEL FLAT
        MASM
	QUIRKS
        VERSION M520

_STACK   SEGMENT PAGE STACK USE32 'STACK'
_STACK   ENDS

DGROUP  GROUP _DATA,_BSS,_STACK
        ASSUME CS:FLAT,DS:FLAT,ES:FLAT,SS:FLAT

ENDIF

; includes the standard available things
        include  macros.inc
        .code
        ;  These are defined in the startup module
        ;  Variables allocated in the startup.
        ;
        ;  Routines defined/created in the startup
        ;  The reason for this is that OS/2 routines do not kill the 
        ;  parameters on the stack after they return. 
        ;  The PASCAL std call mechanism does require this.
        GLOB  _$DOS32OPEN:PROC
	GLOB  _$DOS32CLOSE:PROC
	GLOB  _$DOS32QUERYHTYPE:PROC
        GLOB  _$DOS32WRITE:PROC
        GLOB  _$DOS32READ:PROC
        GLOB  _$DOS32EXIT:PROC
        GLOB  _$DOS32ALLOCMEM:PROC
        GLOB  _$DOS32FREEMEM:PROC
        GLOB  _$DOS32SUBALLOC:PROC
        GLOB  _$DOS32SUBFREE:PROC
        GLOB  _$DOS32SUBSET:PROC
        GLOB  _$DOS32SUBUNSET:PROC

        GLOB _$$$memcpy:PROC
        GLOB _$$memcpy:PROC
        GLOB _$$memcopy:PROC
        GLOB _$$shl:PROC
        GLOB _$$AndWord:PROC
        GLOB _$$OrWord:PROC
        GLOB _$$InvWord:PROC
	GLOB _$$straddr:PROC
        
        ;  Defined in the paslib
        GLOB _$$Stdodd:PROC
        GLOB _$$Stdintabs:PROC
        
        GLOB  _$$StdInit:PROC
        GLOB  _$$StdExit:PROC
        ;  From the I/O Lib
        ;  These names need to be rerouted since the backend uses the normal
        ;  generated names, but The library uses these descriptors.
        
        ;
        ;  Routines
        GLOB  _$$StdWriteInt:PROC
        GLOB  _$$StdWriteChar:PROC
        GLOB  _$$StdWriteln:PROC
        GLOB  _$errorlib:PROC
        GLOB  _$errorlibcode:PROC
        GLOB  _$$stdwriteln:PROC
        GLOB  _$$stdwritechar:PROC
        GLOB  _$$stdwritestring:PROC
        GLOB  _$$stdwriteboolean:PROC
        GLOB  _$$stdwritebin:PROC
        GLOB  _$$stdreadln:PROC
        GLOB  _$$stdreadchar:PROC
        GLOB  _$$stdreadstring:PROC
        GLOB  _$$stdreadint:PROC
        GLOB  _$$stdreadbin:PROC
        GLOB  _$$stdassign:PROC
        GLOB  _$$stdreset:PROC
        GLOB  _$$stdrewrite:PROC
        GLOB  _$$stdeoln:PROC
        GLOB  _$$stdeof:PROC
        GLOB  _$$stdget:PROC
        GLOB  _$$stdput:PROC
        ;     
        ;  Routines from writelib.pas for very "elementary testing"
        ;  Some part of the testset only needs wrtoke,wrtwrong.
        ;  And they could even be implemented in assembler.
        GLOB  _$wrtwrong:PROC
        GLOB  _$wrtoke:PROC

        ;  From heaplib.pas
        GLOB  _$_heap_start:DWORD
        GLOB  _$_heap_size:DWORD
        GLOB  _$$Stdnew:PROC
        GLOB  _$$Stddispose:PROC
        
        ;  From Setlib.pas
        GLOB  _$$SetInit:PROC
        GLOB  _$$SetExit:PROC
        GLOB  _$$StdGetSetConst:PROC
        GLOB  _$$StdReleaseSetConst:PROC
        GLOB  _$$StdSetSet:PROC
        GLOB  _$$StdSetCpy:PROC
        GLOB  _$$StdSetRange:PROC
        GLOB  _$$StdSetUnion:PROC
        GLOB  _$$StdSetDiff:PROC
        GLOB  _$$StdSetInter:PROC
        GLOB  _$$StdSetIn:PROC
        GLOB  _$$StdSetEqual:PROC
        GLOB  _$$StdSetIncl:PROC
        GLOB  _$$StdWriteSet:PROC

        .data
        GLOB  _$displ:DWORD

        .data?
        ;  File handles for the three files standard available in PASCAL
_$output equ _$_out_descr 
_$input  equ _$_in_descr
_$errout equ _$_err_descr
        GLOB  _$_out_descr:BYTE
        GLOB  _$_in_descr:BYTE
        GLOB  _$_err_descr:BYTE
        
