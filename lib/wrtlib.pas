(*
 * FileName:   wrtlib.pas
 * $Source: E:/usr/src/c-code/pascal/RCS/LIB/wrtlib.pas,v $
 * $Author: wjw $
 * $Date: 1993/11/03 15:55:06 $
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

program wrtlib;

const
    _in                 = 0;
    _out                = 1;
    _error              = 2;
    _Boolean_Write_Size = 5;
    _Max_buf            = 256;
type
    _str  = array [1..8] of char;  (* Make it bigger than the default non copy 
                                   (* REF value *)
    word = integer;
var 
    _WBuf : array [1.._Max_buf] of char;
    
(* Used parts of OS/2 *)    
FUNCTION  Dos32Write( fhdl: word;      (* Handle to write to *)
                      str: _str;       (* String to write *)
                      cnt: word;       (* Number of bytes to write *)
                      VAR  rcnt: word  (* Actual number written *)
                      ):word; external;
                      
FUNCTION  Dos32Read ( fhdl: word;      (* Handle to read from *)
                      str: _str;       (* String to read into *)
                      cnt: word;       (* Number of bytes to read *)
                      VAR  rcnt: word  (* Actual number read *)
                      ):word; external;
                      
(* And somethings coded in assembler *)
          (* Copy a piece of memory, but it should not overlap *)
procedure $memcopy(VAR source, dest :_str; size :word ); external;

(* The most simple part of the library.
(* Getting this to compile right allow testing of a large part of the 
(* test files 
(* They don''t need an extra '$', since they get called straight from the
(* pascal code.
 *)
procedure WrtWrong;
var
    _rc  :word;
    rcnt :word;
begin
     _WBuf := 'wrong'
    ;_WBuf[6] := chr(13)
    ;_WBuf[7] := chr(10)
    ;_rc := Dos32Write( _out, _WBuf, 7, rcnt)
end;

procedure WrtOke;
var
    _rc  :word;
    rcnt :word;
begin
     _WBuf := 'oke'
    ;_WBuf[4] := chr(13)
    ;_WBuf[5] := chr(10)
    ;_rc := Dos32Write( _out, _WBuf, 5, rcnt)
end;

begin
end.
(*
 * $Log: wrtlib.pas,v $
 * Revision 1.1  1993/11/03  15:55:06  wjw
 * Started adminstration for the RUNTIME LIB
 *
 *
 *      First created by Willem Jan Withagen ( wjw@eb.ele.tue.nl ),
 *                    on Mon July 26 23:30:03 MET 1993
 *)
