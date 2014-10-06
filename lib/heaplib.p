(*
 * FileName:   heaplib.pas
 * $Source: E:/usr/src/c-code/pascal/RCS/LIB/heaplib.pas,v $
 * $Author: wjw $
 * $Date: 1993/11/03 15:55:02 $
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

program heaplib;
(* module heaplib; *)
(*  Memory allocation with NEW/DISPOSE 
(*  We use OS/2 to request the heap at a fixed size, 
(*      DosSubSetMen, DosSubUnsetMem
(*  Then other OS/2 functions are used to allocate pieces of this heap.
(*      DosSubAllocate, DosSubFree
(*  They can be made sparsely allocated, and thus only use heap when needed.
 *)
#include "os2.hp"
(* define DEBUG_HEAP 2 *)
const
          (* our overhead per allocation 
          (* It''s where we keep the size of the current allocation.
           *)
	  _new_overhead          = 4;
          
type
          intp = ^integer;
var
          _heap_start :_word;
          _heap_size  :_word;
          _heap_free  :_word;
	
procedure $Stdnew(VAR p:_word; size :_word);
(*  Allocate a piece of the heap, 
(*  During deallocation we need the size of the previously allocated item
(*  so this is stored at the start, and the pointer returned is incremented
(*  by 4
 *)
var
   _rc  :_word;           (* the result of the latest OS operation *)
   hack :record  (* make pointer and word equal so we can hack''m *)
			case integer of
                        1: (offset  :_word);
			2: (offsetp :intp)
		 end; 
begin
     (* Get the space *)
     _rc := Cmalloc(size+_new_overhead) 
    ;if _rc = 0 
     then 
       begin
          write('New(',__LINE__:1,'): Error in Dos32SubAlloc: rc = ', _rc:1, ' nothing allocated.')
         ;writeln
         ;writeln('     For block of size:', size:1)
         ;Cexit(1)
       end
#ifdef DEBUG_HEAP     
         else writeln('        allocated item starts at: ', _rc)
#endif     
    ;hack.offset := _rc
    ;hack.offsetp^ := size+_new_overhead        (* put requested size in     *)
    ;p := hack.offset+4                         (* return the corrected size *)
end;   (* $new *)

procedure $Stddispose(VAR p:_word);
(* Return the allocated memory back to the heap 
(* The size of the allocated piece was remembered during creation.
 *)
begin
    CFree(p-_new_overhead )
end;   (* $dispose *)

procedure $HeapInit;
begin
end;

procedure $HeapExit;
begin
end;


begin
end.
(*
 * $Log: heaplib.pas,v $
 * Revision 1.1  1993/11/03  15:55:02  wjw
 * Started adminstration for the RUNTIME LIB
 *
 *
 *      First created by Willem Jan Withagen ( wjw@eb.ele.tue.nl ),
 *                    on Mon July 26 23:30:03 MET 1993
 *)
