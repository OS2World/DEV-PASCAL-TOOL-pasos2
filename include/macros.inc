;*
;* FileName:   macros.inc
;* $Source: E:/usr/src/c-code/pascal/RCS/LIB/macros.inc,v $
;* $Author: wjw $
;* $Date: 1993/11/03 15:54:54 $
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
;
;      Macros used for boolean logical operations
;      Note that a boolean true is everything which is not ZERO
;
@@LXOR        MACRO   ea_op,reg,lreg
      LOCAL   @@jump1,@@jump2
      OR      reg,reg
      JNZ SHORT       @@jump1
      cmp     ea_op,0
      SETZ    lreg
      JMP SHORT       @@jump2
@@jump1:
      cmp     ea_op,0
      SETNZ   lreg
@@jump2:
      ENDM
;
;     Set the resulting register if both operands are TRUE
@@LAND        MACRO   ea_op,reg,lreg
      LOCAL   @@jump
      OR      reg,reg
      JZ SHORT       @@jump
      CMP     ea_op,0
@@jump:
      SETNZ   lreg
      ENDM
      
;
;     Set the resulting register if either operand is TRUE
@@LOR MACRO   ea_op,reg,lreg
      LOCAL   @@jump
      OR      reg,ea_op
      JNZ SHORT       @@jump
      CMP     reg,0
@@jump:
      SETNZ   lreg
      ENDM
;
;     Jump to the 'cond_l' label if (ea_op OR reg)
;     Test both operands in sucession and act on each of the tests.
@@COND_LOR    MACRO   ea_op,reg,cond_l
      OR      reg,ea_op
      JZ     cond_l
      ENDM
 
;
;     Jump to the 'cond_l' label if NOT (ea_op OR reg)
@@COND_LNOR    MACRO   ea_op,reg,cond_l
      LOCAL   @@jump
      OR      reg,reg
      JNZ SHORT       @@jump   ; Short circuit the next test.
      CMP     ea_op,0
      JZ     cond_l
@@jump:
      ENDM
 
;
;     Jump to the 'cond_l' label if (ea_op AND reg)
;     Test both operands in sucession and act on each of the tests.
@@COND_LAND    MACRO   ea_op,reg,cond_l
      LOCAL   @@jump
      OR      reg,reg
      JZ SHORT       @@jump   ; Short circuit the next test.
      CMP     ea_op,0
      JNZ     cond_l
@@jump:
      ENDM
 
;
;     Jump to the 'cond_l' label if NOT (ea_op AND reg)
;     Test both operands in sucession and act on each of the tests.
@@COND_LNAND    MACRO   ea_op,reg,cond_l
      OR      reg,reg
      JZ      cond_l   ; Short circuit the next test.
      CMP     ea_op,0
      JZ     cond_l
      ENDM
 
@@COND_LXOR   MACRO   ea_op,reg,cond_l
      LOCAL   @@jump1,@@jump2
      OR      reg,reg
      JZ SHORT        @@jump1
      CMP     ea_op,0
      JZ      cond_l
      JMP SHORT       @@jump2
@@jump1:
      CMP     ea_op,0
      JNZ     cond_l
@@jump2:
      ENDM

;*
;* $Log: macros.inc,v $
;*     Revision 1.1  1993/11/03  15:54:54  wjw
;*     Started adminstration for the RUNTIME LIB
;*
;*
;*      First created by Willem Jan Withagen ( wjw@eb.ele.tue.nl ),
;*                    on Mon July 26 23:30:03 MET 1993
;* 
