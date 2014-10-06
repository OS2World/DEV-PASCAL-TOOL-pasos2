(*
 * FileName:   paslib.pas
 * $Source: E:/usr/src/c-code/pascal/RCS/LIB/paslib.pas,v $
 * $Author: wjw $
 * $Date: 1993/11/03 15:54:56 $
 * $Locker: wjw $
 * $State: Exp $
 * $Revision: 1.1 $
 * Description:
D*      Part of the runtime library which comes with PASCAL for OS/2
D*      
 *
 * History:
 *      First created by Willem Jan Withagen ( wjw@eb.ele.tue.nl ),
 *                    on Mon July 26 23:30:03 MET 1993
 * Copyright:
 *      Copyright (c) 1993 by Willem Jan Withagen and 
 *                      Digital Information Systems group, TUE
 *      For copying and distribution information see the file COPYRIGHT.
 *
 *)

program paslib;
#include <os2.hp>

procedure $IOInit; external;
procedure $IOExit; external;
procedure $HeapInit; external;
procedure $HeapExit; external;
procedure $SetInit; external;
procedure $SetExit; external;

(* Standard routines *)

function $Stdodd(i: integer):boolean;
begin
    $Stdodd := ((abs(i) mod 2) = 1)
end;

function $Stdintabs(i, size: integer):integer;
(*  Take the absolute value of i, where 'i' has 'size' significant bytes.
(*  Assume that the value is correctly expanded to become a parameter
 *)
begin
     if i < 0 then $Stdintabs := -i
              else $Stdintabs := i
end;

procedure $StdHalt(exitval :_word);
(*  Cleanly terminate. By doing StdExit first *)
begin
     $StdExit
    ;Cexit(exitval)
end;

procedure $StdAbort(exitval :_word);
(* Emergency exit, forget about doing StdExit *)
begin
    Cexit(exitval)
end;

procedure $StdInit;
begin
     $IOInit
    ;$HeapInit
    ;$SetInit
end;

procedure $StdExit;
begin
     $SetExit
    ;$HeapExit
    ;$IOExit
end;

begin
end.
(*
 * $Log: paslib.pas,v $
 * Revision 1.1  1993/11/03  15:54:56  wjw
 * Started adminstration for the RUNTIME LIB
 *
 *
 *      First created by Willem Jan Withagen ( wjw@eb.ele.tue.nl ),
 *                    on Mon July 26 23:30:03 MET 1993
 *)
