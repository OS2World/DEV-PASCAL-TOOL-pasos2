(*
 * FileName:   setlib.pas
 * $Source: E:/usr/src/c-code/pascal/RCS/LIB/setlib.pas,v $
 * $Author: wjw $
 * $Date: 1993/11/03 15:55:04 $
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

program setlib;
(* MODULE paslib; *)

#include "os2.hp"
(* define DEBUG_SET 3 *)

const
	_intset_size   = 65536;  (* Integer sets contain a max of 65k bits *) 
	_intset_words  = 2048;   (* the number of 32b words to allocate for a set *)
	_intset_last   = 2047;
	_bits_per_word = 32;
	_max_const_set = 10;
type
        byte    = 0..256;
        word    = integer;
        intp    = ^integer;
        intsetp = ^intset;
	regsetp = ^regset;
	
	intset = record
            size   :word;                      (* counting the number of bits *)
            offset :word;                         (* offset for the first bit *)
            bits   :array [0.._intset_last] of word;        (* the actual set *)
        end;
		
	constset = record
            freeset:boolean;
#ifndef ALIGN_FIXED            
            dummy  :array[0..2]of boolean;    (* Align doesnt''t work *)
#endif            
            s      :intsetp;                   (* We need the pointer so we *)
        end;         
		
	regset = record
            size   :word;                      (* counting the number of bits *)
            offset :word;                      (* offset for the first bit *)
            bits   :array [0..0] of word;      (* the actual set *)
        end;         
var 
	_const_set     : array [0.._max_const_set] of constset;

(* routines done in other modules *)
procedure ErrorLib(s :_str; i :word); external;

(* Some of the real work *)

function $StdSetSet(setp :intsetp; i:word) :intsetp;
var
    index, mask :word;
begin
#if DEBUG_SET > 1
	writeln('$SetSet ', i);
#endif
    i     := (i-setp^.offset) 
   ;index := i div _bits_per_word
   ;mask  := $shl(1,i mod _bits_per_word)
#if DEBUG_SET > 3
   ;writeln('Mask: ', mask, ' Org ', setp^.bits[index])
#endif
   ;setp^.bits[index] := $OrWord(setp^.bits[index],mask)
#if DEBUG_SET > 2   
   ;writeln('Result ', setp^.bits[index])
#endif
   ;$StdsetSet := setp
end;

function $StdSetIn(val :word; setp :intsetp ) :boolean;
var
    index, off, mask :word;
begin    
#if DEBUG_SET > 0
    writeln('$SetIn ', val);
#endif
    ;val    := val - setp^.offset
    ;index  := val div _bits_per_word
    ;off    := val mod _bits_per_word
    ;mask   := $shl(1,off)
#if DEBUG_SET > 2
    ;writeln('SetIn setting index = ', index, 'offset = ', off)
#endif
        ;$StdSetIn := $AndWord(setp^.bits[index],mask) <> 0
        ;$StdReleaseSetConst(setp)
end;

procedure $StdWriteSet(setp :intsetp);
var i,index, mask :word;
begin
#if DEBUG_SET > 0
    writeln('$WriteSet: size = ',setp^.size:1,' offset = ', setp^.offset:1);
#endif
     write( '( ')
    ;for i := 0 to setp^.size
     do
       begin
          index  := i div _bits_per_word
         ;mask   := $shl(1,i mod _bits_per_word)
#if DEBUG_SET > 3
   ;writeln('Mask: ', mask, ' Org ', setp^.bits[index], ' Gives: ', $AndWord(setp^.bits[index],mask))
#endif
         ;if ( $AndWord(setp^.bits[index],mask) <> 0 )
          then write(i+setp^.offset:1, ' ')
       end
    ;writeln(' )')
end;

function $StdSetRange(setp :intsetp; start, last :word) :intsetp;
(*  Currently the very blunt method.
 *)
var i :word;
begin
#if DEBUG_SET > 0
    writeln('$SetRange from ',start:1, ' to ', last:1);
#endif
    for i := start to last
    do setp := $StdSetSet(setp,i)
   ;$StdSetRange := setp
end;

function $StdSetUnion(a,b :intsetp):intsetp;
var tmp: intsetp;
	i, newsize, newoffset :word;
begin
#if DEBUG_SET > 0
    writeln('$SetUnion');
#endif
    if A^.size = b^.size
    then
      begin
         tmp       := $StdGetSetConst(a^.size, a^.offset)
        ;$StdSetUnion := tmp
        ;for i := 0 to a^.size div _bits_per_word
         do   (* Join both sets *)
                  tmp^.bits[i] := $OrWord(a^.bits[i],b^.bits[i] )
       end
     else
       begin
          (* this can only happen if one of the sets is a constant 
           * Take the smallest one.
           *)
          if a^.size < b^.size
          then
                begin
                   newsize   := a^.size
                  ;newoffset := a^.offset
                end
          else
                begin
                   newsize   := b^.size
                  ;newoffset := b^.offset
                end
         ;tmp := $StdGetSetConst(newsize,newoffset) 
          (* The operate bitwise on the sets. A much more painfull thing *)
         ;for i := newoffset to newoffset+newsize
          do if $StdSetIn(i,a) OR $StdSetIn(i,b) 
                 then tmp := $StdSetSet(tmp,i)
       end
    ;$StdReleaseSetConst(a)
    ;$StdReleaseSetConst(b)
#if DEBUG_SET > 1
    ;writeln('$SetUnion returns:')       
    ;$StdWriteSet(tmp)
#endif
end;

function $StdSetDiff(a,b :intsetp):intsetp;
var tmp: intsetp;
    i :word;
begin
#if DEBUG_SET > 0
    writeln('$SetDiff');
#endif
     tmp      := $StdGetSetConst(a^.size, a^.offset)
    ;$StdSetDiff := tmp
    ;for i := 0 to a^.size div _bits_per_word
     do   (* Remove all b''s from a*)
              tmp^.bits[i] := $AndWord(a^.bits[i],$InvWord(b^.bits[i]) )
    ;$StdReleaseSetConst(a)
    ;$StdReleaseSetConst(b)
end;

function $StdSetInter(a,b :intsetp):intsetp;
var tmp: intsetp;
    i :word;
begin
#if DEBUG_SET > 0
	writeln('$SetInter');
#endif
         tmp       := $StdGetSetConst(a^.size, a^.offset)
        ;$StdSetInter := tmp
	;for i := 0 to a^.size div _bits_per_word
	 do   (* Remove all bits both in a and b*)
		  tmp^.bits[i] := $AndWord(a^.bits[i],b^.bits[i] )
        ;$StdReleaseSetConst(a)
        ;$StdReleaseSetConst(b)
end;

function $StdSetEqual(a,b :intsetp):boolean;
var equal :boolean;
#ifndef ALIGN_FIXED            
    dummy  :array[0..2]of boolean;    (* Align doesnt''t work *)
#endif            
    i :word;
begin
#if DEBUG_SET > 0
    writeln('$SetEqual');
#endif
    equal := true
   ;for i := 0 to a^.size div _bits_per_word
     do 
        begin
#if DEBUG_SET > 2
          writeln('a: ', a^.bits[i], ' b: ', b^.bits[i] );
#endif
          equal := equal AND (a^.bits[i] = b^.bits[i])
        end
    ;$StdReleaseSetConst(a)
    ;$StdReleaseSetConst(b)
    ;$StdSetEqual := equal
end;

function $StdSetIncl(a,b :intsetp):boolean;
var included :boolean;
#ifndef ALIGN_FIXED            
    dummy  :array[0..2]of boolean;    (* Align doesnt''t work *)
#endif            
    i :word;
begin
#if DEBUG_SET > 0
     writeln('$SetIncl');
#endif
     included := true
    ;for i := 0 to a^.size div _bits_per_word
     do   (* True as long a 'a' does''t have bits other that b''s *)
       included := included 
         AND (b^.bits[i] = $OrWord(a^.bits[i],b^.bits[i]) )
    ;$StdReleaseSetConst(a)
    ;$StdReleaseSetConst(b)
    ;$StdSetIncl := included
end;

function $StdGetSetConst(size, offset :word) :intsetp;
var i :integer;
    ret :intsetp;
    found, dummy1, dummy2,dummy3 :boolean;
begin
#if DEBUG_SET > 0
    writeln('GetSetConst');
    writeln('    For size = ', size, '  offset = ', offset );
#endif
    i := 0
   ;found := false
   ;while( (not found) and (i<=_max_const_set))
    do
      begin
        if _const_set[i].freeset
        then
          begin
             _const_set[i].freeset   := False
            ;_const_set[i].s^.size   := size
            ;_const_set[i].s^.offset := offset
            ;ret                     := _const_set[i].s
            ;found                   := true
#if DEBUG_SET > 1
            ;writeln('Allocated set: ', i:1);
#endif
          end
        else
          i := i+1
      end
   ;if i > _max_const_set
    then
      begin
        ;ErrorLib('GetSetConst: No more free sets!',31)
	;ErrorLib('  Runtime and/or compiler error',31)
        ;CExit(-1)
      end
   ;for i := 0 to size div _bits_per_word
    do ret^.bits[i] := 0
   ;$StdGetSetConst := ret
#if DEBUG_SET > 2
   ;Writeln('$GetSetConst returns:');
   ;$StdWriteSet(ret);
#endif    
end; (* $StdGetSetConst *)

procedure $StdReleaseSetConst(sp :intsetp);
var i :integer;
begin
#if DEBUG_SET > 0
	write('$ReleaseSetConst');
#endif
    for i := 0 to _max_const_set
    do
      if _const_set[i].s = sp
      then
        begin
         _const_set[i].freeset     := True
#if DEBUG_SET > 1
        ;writeln(' Freed: ', i:1);
#endif
        end
#if DEBUG_SET > 0
   ;writeln
#endif
end;

procedure $StdSetCpy(fromset, toset :intsetp; size :word);
(* Assuming that the 'to'-set always contains the correct 
(* size and offset.
 *)
var index :word;
begin
#if DEBUG_SET > 0
    writeln('$SetCpy for size = ', size:1);
    if fromset = NIL then WriteLn('    Copy empty set')
                                     else Writeln('    Copy fromset size = ', fromset^.size:1, 
                                     ' offset = ', fromset^.offset:1 );
    if toset = NIL   then WriteLn('    Copy empty set')
                                     else Writeln('    Copy toset size = ', toset^.size:1,
                                     ' offset = ', toset^.offset:1 );
#endif
     for index := 0 to (size div _bits_per_word)
     do
       begin
#if DEBUG_SET > 3
	writeln('    Index = ', index);
#endif
         if fromset = NIL 
         then toset^.bits[index] := 0
         else toset^.bits[index] := fromset^.bits[index]
       end
    ;$StdReleaseSetConst(fromset)
#if DEBUG_SET > 1       
   ;$StdWriteSet(toset)
#endif
end;

procedure $SetInit;
var i :integer;
begin
#if DEBUG_SET > 0
    writeln('$SetInit');
#endif
    (* allocate the sets *)
    for i := 0 to _max_const_set
    do 
      begin
         new(_const_set[i].s)
        ;_const_set[i].freeset   := True
        ;_const_set[i].s^.size   := 0
        ;_const_set[i].s^.offset := 0
      end
end;

procedure $SetExit;
var i :integer;
begin
#if DEBUG_SET > 0
    writeln('$SetEnd');
#endif
    (* Kill what we allocated *)
    for i := 0 to 2
    do dispose(_const_set[i].s)
end;
    begin
end.
(*
 * $Log: setlib.pas,v $
 * Revision 1.1  1993/11/03  15:55:04  wjw
 * Started adminstration for the RUNTIME LIB
 *
 *
 *      First created by Willem Jan Withagen ( wjw@eb.ele.tue.nl ),
 *                    on Mon July 26 23:30:03 MET 1993
 *)
