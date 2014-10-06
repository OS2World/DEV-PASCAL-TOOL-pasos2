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
#include "os2.inc"
(* define DEBUG_HEAP 2 *)
const
          (* our overhead per allocation 
          (* It''s where we keep the size of the current allocation.
           *)
	  _new_overhead          = 4;
          DOSSUB_USED            = 64;
          _heap_size_init        = 1000000;
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
	 _rc := Dos32SubAlloc(_heap_start, hack.offset, size+_new_overhead) 
	;if _rc <> 0 
	 then 
	   begin
              write('New(',__LINE__:1,'): Error in Dos32SubAlloc: rc = ', _rc:1, ' nothing allocated.')
             ;writeln
             ;writeln('     For block of size:', size:1)
             ;_rc := Dos32exit(1,1)
	   end
#ifdef DEBUG_HEAP     
	 else writeln('        allocated item starts at: ', hack.offset)
#endif     
	;hack.offsetp^ := size+_new_overhead        (* put requested size in     *)
	;p := hack.offset+4                         (* return the corrected size *)
	;_heap_free := _heap_free + (((size+_new_overhead) div 8) *8)
#if DEBUG_HEAP > 1
	;writeln('        Free starts at: ', _heap_free)
#endif     
end;   (* $new *)

procedure $Stddispose(VAR p:_word);
(* Return the allocated memory back to the heap 
(* The size of the allocated piece was remembered during creation.
 *)
var
   _rc  :_word;           (* the result of the latest OS operation *)
   hack :record  (* make pointer and word equal so we can hack''m *)
             case integer of
             1:  (offset  :_word);
             2:  (offsetp :intp)
         end; 
begin
         hack.offset := p - _new_overhead   (* Get the pointer to the size piece *)
#if DEBUG_HEAP > 1
        ;writeln('Freeing at :',hack.offset, ' for: ',p)
#endif         
	;_rc := Dos32SubFree(_heap_start, p-_new_overhead, hack.offsetp^ )
	;if _rc <> 0 
	 then 
	   begin
              writeln('Dispose(',__LINE__:1,'): Error in Dos32SubFree: rc = ', _rc:1 )
	   end
end;   (* $dispose *)

procedure $HeapInit;
(*  Initialise all kind of things which are in the STD-library.
 *)
var
        _rc       : _word;              (* the result of the latest OS operation *)
begin
	 (* No Errors yet *)
	 _rc := 0
	
        (* Memory/Heap initialisation *)
        ;_heap_size := _heap_size_init
        ;_rc := Dos32AllocMem( _heap_start, _heap_size, PAG_READ+PAG_WRITE) 
        ;if _rc <> 0 
         then writeln('HeapInit(',__LINE__:1,'): Error in Dos32AllocMem: rc = ', _rc)
#ifdef DEBUG_HEAP     
	 else writeln('Memory starts at: ', _heap_start)
#endif
	;_heap_free := _heap_start + DOSSUB_USED
	;_rc := Dos32SubSet( _heap_start, DOSSUB_INIT+DOSSUB_SPARSE_OBJ, _heap_size)
	;if _rc <> 0 
         then writeln('HeapInit(',__LINE__:1,'): Error in Dos32SubSet: rc = ', _rc)
#ifdef DEBUG_HEAP     
	 else writeln('Heap starts at: ', _heap_start)
#endif     
end;

procedure $HeapExit;
var
        _rc       : _word;              (* the result of the latest OS operation *)
begin
    (* Heap termination, return what we asked for *)
    _rc := Dos32FreeMem( _heap_start )
   ;if _rc <> 0 
    then writeln('HeapExit(',__LINE__:1,'): Error in Dos32FreeMem: rc = ', _rc)
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
