(*
 * FileName:   iolib.pas
 * $Source: E:/usr/src/c-code/pascal/RCS/LIB/iolib.pas,v $
 * $Author: wjw $
 * $Date: 1993/11/03 15:55:00 $
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

program iolib;
(* MODULE paslib; *)

#include "os2.hp"

const
	_stdin              = 0;
        _in                 = 0;
	_stdout             = 1;
        _out                = 1;
	_stderr             = 2;
        _error              = 2;
	_Boolean_Write_Size = 5;
        _MAX_BUF            = 256;
	_MinInt             = -2147483648;
        _InitMagic          = 168101130;   (* 0xa55a5aa5 *)

#ifndef DEBUG_IOLIB
	_fill_char          = ' ';
#else
	_fill_char          = '.';
#endif    

type
	intp = ^integer;
	_filebuf   = array[1.._Max_buf] of char;
        _bigbuf    = array[1.._Max_buf] of char;
	_filedescr = record
            bufpoint    :_word;     (* By making this a pointer to the first 
                                    (* available item, file^ is still usuable 
                                     *)
            handle      :_word;
            fname       :_filename; (* The name of the file when opened.*)
            namelen     :_word;
            bufstart    :_word;
            bufend      :_word;
            elemsize    :_word;
            fileopen    :Boolean;
            fileinp     :Boolean;
            filetxt     :Boolean;
            bufempty    :Boolean;
            bufeoln     :Boolean;
            bufeof      :Boolean;
            IsTTY       :Boolean;
            Initialised :_word;     (* contains magic if it was already inited *)
            (* Initialised means that there is a valid name in the descriptor *)
            
            (* The buffer is always at the end that way is it possibe to
            (* vary its size with the type it wants to write
             *)
            buffer   :_filebuf;
        end;
var 
	(* Files to operate on *)
        input  :_filedescr;
        output :_filedescr;
        errout :_filedescr;
	DumpingHandle :Boolean; (* True when dumping handle *)

procedure _Int2Str(i: integer; Var buf :_bigbuf; Var size: _word); forward;

procedure ErrorLib(VAR s :_str; i :_word);
var
    rcnt   :_word;
    buffer :_bigbuf;
begin
     with errout
     do
       begin
          rcnt := Cwrite( handle, s, i)
         ;Buffer[1] := CR
         ;Buffer[2] := LF
         ;rcnt := Cwrite( handle, Buffer, 2)
       end
end;

procedure ErrorLibCode(VAR s :_str; i :_word; code: _word);
var
    rcnt   :_word;
    size   :integer;
begin
     with errout
     do
       begin
         ;rcnt := CWrite( handle, s, i)
         ;_Int2Str(code, Buffer, size)
         ;rcnt := CWrite( handle, Buffer, size)
         ;Buffer[1] := CR
         ;Buffer[2] := LF
         ;rcnt := CWrite( handle, Buffer, 2)
       end
end;

(* I/O *)
procedure $DumpHandle(VAR f :_filedescr);
(*  Dump the status of the file in 'f' on the list file 'lf'
(*  DumpingHandle is a flag which is set when a Handle is being Dumped.
(*  and reset after the dumping. This is to prevent recursive dumping
(*  until the stack fills up.
 *)
var
   length :_word;
begin
  if not DumpingHandle then
  with f
  do
    begin
      DumpingHandle := True
      (* bufpoint :_word;     (* By making this a pointer to the first 
                              (* available item, file^ is still usuable 
                               *)
      ;writeln( 'handle      =  ', handle   )
      ;writeln( 'fname       =  ', fname:namelen )
      ;writeln( 'buffer      = |', buffer:bufend, '|' )
      ;writeln( 'bufstart    =  ', bufstart )
      ;writeln( 'bufend      =  ', bufend   )
      ;writeln( 'elemsize    =  ', elemsize )
      ;writeln( 'fileopen    =  ', fileopen )
      ;writeln( 'fileinp     =  ', fileinp  )
      ;writeln( 'filetxt     =  ', filetxt  )
      ;writeln( 'bufempty    =  ', bufempty )
      ;writeln( 'bufeoln     =  ', bufeoln  )
      ;writeln( 'bufeof      =  ', bufeof   )
      ;writeln( 'IsTTY       =  ', IsTTY    )
      ;writeln( 'Initialised =  ', (Initialised = _InitMagic) )
      ;DumpingHandle := False
    end
end;

procedure _FlushWriteBuffer(VAR f :_filedescr);
(* Some thing might be in the buffer which still has to be written.
 *)
var
    rcnt     :_word;
begin
  with f
  do 
    begin
      if (Bufstart < BufEnd)
      then
        begin
           rcnt := CWrite( handle, Buffer, Bufend-BufStart)
          ;if rcnt = -1
           then ErrorLib('Error in _FlushWriteBuffer    ', 30)
          ;Bufstart := 1
          ;Bufend   := Bufstart
          ;Bufpoint := $StrAddr(Buffer)
          ;Bufempty := True
        end
    end
end;

procedure $StdPut(VAR f :_filedescr);
var
    _rc, rcnt :_word;
begin
  with f
  do 
   if filetxt
   then
     begin
       if (Bufend < _MAX_BUF)
       then
         begin
           Bufend   := Bufend+1
          ;Bufpoint := BufPoint+1
          ;Bufempty := False
        end
     end
   else
     begin
       (* Its a binary file *)
       rcnt := CWrite(handle, buffer, elemsize)
     end
end;

procedure $StdWriteBin(Var f :_filedescr; Var from :_str);
begin
    (* First copy the current contents *)
    $memcopy(from, f.buffer, f.elemsize)
    (* Then put new data *)
   ;$StdPut(f)
end;  (* $StdWriteBin *)

procedure $StdWriteln(Var f :_filedescr);
var
    _rc  :_word;              (* the result of the latest OS operation *)
    rcnt :_word;
begin
  _FlushWriteBuffer(f)
 ;with f
  do 
    begin
       Buffer[1] := CR
      ;Buffer[2] := LF
      ;rcnt := CWrite( f.handle, Buffer, 2)
      ;if rcnt = -1
       then ErrorLib('Error in StdWriteln           ', 30)
    end
end;

procedure _WriteSpace(Var f:_filedescr; SpaceSize: integer);
(*  Write the requested number of spaces.
(*  It could be done a little more efficient.
(*  Note that it requires the buffer to be flushed first.
(*  This is not done here.
(*  It uses it''s own private buffer, since the file buffer 
(*  could be holding somethiing
 *)
var 
    _rc    : _word;              (* the result of the latest OS operation *)
    rcnt   :_word;
    count  :integer;
    locbuf :_bigbuf;
begin
  with f
  do 
    begin
      ;for count := 1 to SpaceSize
       do  locbuf[count] := ' '
      ;rcnt := CWrite( handle, locBuf, SpaceSize)
      ;if rcnt = -1
       then ErrorLib('Error in _WriteSpace          ', 30)
    end
end;

procedure $StdWriteChar(Var f:_filedescr; c: char; WrtSize: integer);
(*  Print the specified CHAR c on F. 
(*  It has to be printed in a WrtSize area.
(*  [6.9.3.2] specifies that spaces should be added to the front of the written
(*            character.
 *)
var
    _rc  : _word;              (* the result of the latest OS operation *)
    rcnt :_word;
begin
   _FlushWriteBuffer(f)
  ;if WrtSize <> 1
     then
        begin  (* add spaces *)
           ;_WriteSpace(f,WrtSize-1)
        end
    ;with f
     do 
       begin
          Buffer[1] := c
         ;rcnt := CWrite( handle, Buffer, 1)
         ;if rcnt = -1
          then ErrorLib('Error in $StdWriteChar        ', 30)
       end
end;

procedure $StdWriteString(Var f:_filedescr; Var s: _str; StrSize, WrtSize: integer);
(*  Print the specified string on F. The allocated size of the string is
(*  StrSize. 
(*  It has to be printed in a WrtSize area.
(*  [6.9.3.6] specifies that spaces should be added to the end of the written
(*            string.
 *)
var
    _rc  : _word;              (* the result of the latest OS operation *)
    rcnt :_word;
begin
   _FlushWriteBuffer(f)
  ;if WrtSize <= StrSize
      then
        begin  (* Use WrtSize since this is at most the actual string length *)
           rcnt := CWrite( f.handle, s, WrtSize)
          ;if rcnt = -1
           then ErrorLib('Error in $StdWriteString      ', 30)
        end
      else
        begin  (* Give the full string, and add spaces *)
            rcnt := CWrite( f.handle, s, StrSize)
           ;if rcnt = -1
            then ErrorLib('Error in $StdWriteString      ', 30)
           ;_WriteSpace(f,WrtSize-StrSize)
        end
end;

procedure $StdWriteBoolean(Var f:_filedescr; b: boolean; WrtSize: integer);
(*  Print the Boolean b c on F. 
(*  It has to be printed in a WrtSize area.
(*  [6.9.3.5] specifies that spaces should be added to the front of the written
(*            character.
 *)
var
    rcnt :_word;
begin
   _FlushWriteBuffer(f)
  ;if WrtSize > _Boolean_Write_Size
     then
         begin  (* add spaces *)
            _WriteSpace(f,WrtSize-_Boolean_Write_Size)
         end
     (* Now write the string *)   
    ;if b then $StdWriteString(f, 'True',  4 ,WrtSize)
          else $StdWriteString(f, 'False', 5 ,WrtSize)
end; (* $StdWriteBoolean *)

procedure _Int2Str(i: integer; Var buf :_bigbuf; Var size: _word);
const
    base = 10;
var
    index                   (* point to where the next char has to be stored *)
   ,j         : Integer;
    Negative  : Boolean;
begin
   (* first, store backwards the character representation of Abs(I) in Buf *)
   (* MinInt is a number value which can only be represented when it is 
        * negative. As such it is not possibe to use the algorithm below *)
   size := 0
  ;if I = _MinInt
     then
       begin 
          Buf := '-2147483648'
         ;size := 11
       end
     else
       begin
         if I = 0 
           then
             begin 
                index := _Max_buf-1
               ;Buf[_Max_buf] := '0' 
             end
           else
             begin
                Negative := (I < 0)
               ;if Negative 
                then I := -I              (* This doesn''t work if I is MinInt *)
               ;index := _Max_buf           (* Start at the end of the buffer *)
               ;while I > 0 do
                  begin
                     Buf[index] := Chr (I MOD Base + Ord('0')) 
                    ;index := index - 1 
                    ;I := I DIV Base 
                  end
               ;if Negative 
                then
                   (* Insert a leading minus *)
                   begin 
                      Buf[index] := '-' 
                     ;index := index - 1
                   end
            end
         (* now, write it out 
         (* The first character is at Buf[index+1] uptil Buf[_Max_buf]
          *)
        ;size := _Max_buf - index
        ;for j := 1 to size    
         do  Buf[j] := Buf[index+j]
     end
end; (* _Int2Str *)

procedure $StdWriteInt(Var f:_filedescr; i: integer; WrtSize: integer);
const
    base = 10;
var 
    _rc       : _word;              (* the result of the latest OS operation *)
    size      : Integer;
    rcnt      : _word;
begin
   _FlushWriteBuffer(f)
  ;_Int2Str(i, f.buffer, size)
  ;if size < WrtSize
   then _WriteSpace(f,WrtSize-size)
  ;rcnt := CWrite( f.handle, f.Buffer, size)
  ;if rcnt = -1
   then ErrorLib('Error in $StdWriteInteger     ', 30)

end; (* $StdWriteInt *)

procedure _CheckBufEOLN(VAR f:_Filedescr); forward;

procedure _FillReadBuf(VAR f :_filedescr);
(*  Read a line at the time into Buffer, but only when the last item is
(*  consumed:
(*    Bufempty OR (Bufstart = Bufend+1)
(*  Do not care for CR/LF combinations. If they occur they should be truncated 
(*  to just CR.
 *)
var
    _rc  : _word;              (* the result of the latest OS operation *)
    rcnt : _word;
begin
  with f do
    begin
      if bufeof 
      then 
        begin
          ErrorLib('File already at EOF           ', 30)
         ;CExit(-1)
        end
     ;if bufstart > bufend
      then 
        begin
          ErrorLib('File pointers are corrupt.    ', 30)
         ;CExit(-1)
        end
     ;if Bufempty OR (Bufstart = Bufend)
      then
        (* Need to read new data into buffer *)
        begin
           rcnt := CRead(handle, Buffer, _Max_buf)
          ;if rcnt = -1
           then ErrorLib('Error in _FillReadBuf         ', 30)
          ;bufeof   := rcnt = 0
          ;bufempty := rcnt = 0
          ;BufPoint := $StrAddr(Buffer)
          ;Bufstart := 1
          ;Bufend   := Bufstart+rcnt
          ;_CheckBufEOLN(f)
        end
    end
end; (* _FillReadBuf(VAR f :_filedescr); *)

procedure _CheckBufEOLN(VAR f:_Filedescr);
(*  Fix the current buffer contents.
(*  If there is a CR/LF combination in the buffer make shure that the
(*  f^ returns a ' '. and that eoln is set.
 *)
begin
    with f
    do
      begin
        ;bufeoln  := (Buffer[Bufstart] = CR) OR (Buffer[Bufstart] = LF)
        ;if (bufeoln)
         then
           begin
              BufStart := bufstart +1
             ;Bufpoint := bufpoint +1
             ;_FillReadBuf(f)         (* Make shure there''s enough *)
             ;Buffer[Bufstart] := ' ' (* Kill the LF *)
           end
      end     
end;
           
procedure $StdGet(VAR f :_filedescr);
(*  Advance the pointer for the _filedescr.
(*  Currently only implemented for Text files. (or files with byte size 
(*  elements.)
(*  Note that $StdGet() will skip eoln''s without hesitation.
 *)
var
    _rc, rcnt :_word;

begin
 ;with f do
    if filetxt
    then
      begin
        Bufstart := Bufstart+1
       ;BufPoint := BufPoint+1
       ;_FillReadBuf(f)
       ;_CheckBufEOLN(f)
      end
    else
      begin
        (* Get from a binary file *)
        rcnt := CRead(handle, buffer, elemsize)
       ;if rcnt = -1
        then ErrorLib('Error in StdGet for bin file. ', 30)
       ;bufeof := rcnt = 0
      end
end; (* $StdGet(f :_filedescr); *)

procedure $StdReadBin(Var f :_filedescr; VAR dest :_str);
begin
    (* First copy the current contents *)
    $memcopy(f.buffer, dest, f.elemsize)
    (* Then get new data *)
   ;$StdGet(f)
end;  (* $StdReadBin *)

procedure $StdReadln(Var f :_filedescr);
(* Flush anything on the current line 
(* including the current EOLN.
 *)
var
    rcnt :_word;
    done :Boolean;
begin
   with f do
     begin
       done := bufeoln OR bufeof
      ;while not done
       do
         begin
           $StdGet(f)
          ;done := bufeoln OR bufeof
         end
      ;if bufeoln
       then
         begin
           (* Only need to go to the next character 
           (* That is sort of hard since the buffering requires the
           (* next line to be entered as well. Maybe a diffentiation on
           (* terminal input should be done. Especially if we''re going to 
           (* implement something as TURBO''s keypressed.
            *)
           $StdGet(f)
         end
     end
end;

function $StdEoln(Var f:_filedescr):Boolean;
begin
    if not (f.bufeof or f.bufeoln)
    then _FillReadBuf(f)
   ;$StdEoln := f.bufeoln;
end; (* $StdEoln *)

function $Stdeof(Var f:_filedescr):Boolean;
(* Check if it is really at end of file *)
begin
    if f.filetxt AND not f.bufeof
    then _FillReadBuf(f)
   ;$Stdeof := f.bufeof
end; (* $StdEoln *)

procedure $StdReadChar(Var f:_filedescr; Var c: char);
(*  Read a character from 'f' into 'c'.
(*  The end of line character gets treated like a ' '
 *)
begin
   (* Now copy the data into the request string *)
   _FillReadBuf(f)
  ;c := f.buffer[f.bufstart]
  ;$StdGet(f)
end;  (* $StdReadChar *)

procedure $StdReadString(Var f:_filedescr; Var s: _str; ReadSize: integer);
(*  Read text from 'f' into 's'.
(*  The maximum number to read is ReadSize characters.
(*  If less than ReadSize characters are recieved, 
(*     OR the input buffer has EOLN
(*  then the remainder of the buffer is filled with spaces
 *)
var
    count : integer;
begin
  count := 1
 ;with f do
  begin
     _FillReadBuf(f)
     (* Now copy the data into the request string *)
    ;while (count < ReadSize) 
           and not $Stdeoln(f) 
           and not $Stdeof(f)
     do
       begin
         s[count] := buffer[bufstart]
        ;count := count+1
        ;$StdGet(f)
       end
     (* Fill the remainder with chr(0) chars *)
    ;while (count < Readsize)   
     do
       begin
         s[count] := chr(0)
        ;count    := count+1
       end
  end           
end;      (* $StdReadString *)

procedure $StdReadInt(Var f:_filedescr; Var i: integer);
(*  Read integer from 'f' into 'i'.
(*  Characters are read from Buffer until it is exhausted or it is
(*  not a digit any longer.
(*  [6.9.1.c]  if V is a variable-access possessing the interger-type (or 
(*     subrange thereof), read(f,v) shall cause the reading from f of a 
(*     sequence of charaters, Preceding spaces and end-of-lines shall be 
(*      skipped. It shall be an error if the rest of the sequence does not 
(*      form a signed-integer according to the the syntax of 6.5.1. Reading 
(*      shall cease as soon as the buffer-variable f^ does not have attributed 
(*      to it a character contained by the signed-integer. The value of the 
(*      signed-integer thus read shall be assignment-compatible with the type 
(*      possessed by V, and shall be attributed to v.
(*  NB: In no circumstances is ReadInt allowed to skip EOLN or EOF after it 
(*      has found an initial part of the integer.
(*      
 *)
var
    _rc      : _word;              (* the result of the latest OS operation *)
    j        : integer;
    c        : char;
	Sign     : integer;
begin
     _FillReadBuf(f)
     (* Set the default return value *)
    ;i    := 0
    ;Sign := 1
     (* Is there anything in the buffer? *)
    ;with f do
      begin
        ;If NOT bufeof
         then
           begin
             (* First skip white space *)
             while (Buffer[BufStart] = ' ')
             do
               begin
                 $StdGet(f)
               end
             (* determine the sign *)
            ;if (Buffer[BufStart] = '-')
             then Sign := -1
            ;if (Sign = -1) OR (Buffer[BufStart] = '+')
             then 
               begin
                 $StdGet(f)
               end
             (* Now get the number *)
            ;if ('0' <= Buffer[BufStart]) AND (Buffer[BufStart] <= '9')
             then
               begin
                 (* Go get all numbers *)
                 i := (ord(Buffer[BufStart])-ord('0'))
                ;$StdGet(f)
                ;while ('0' <= Buffer[BufStart]) AND (Buffer[BufStart] <= '9')
                 do
                   begin
                      (* We ignore overflow *)
                      i := i*10 + (ord(Buffer[BufStart])-ord('0'))
                     ;$StdGet(f)
                   end
               end
             else
               begin
                 writeln('Buffer = |',Buffer[BufStart],'|')
                ;ErrorLib('No integer found              ', 30)
               end
             (* Now apply the sign *) 
            ;i := i * Sign
           end
         else
           ErrorLib('No integer found(EOF)         ', 30     )
      end 
end;

procedure $StdAssign(Var f: _filedescr; name :_filename; maxstr :_word);
(* The PASCAL file 'f' has to be linked to the OS-file called 'name'
(* The maximumsize of the string is maxstr. But the name coudl either
(* be terminated by a ' ' or a '\0'
(* Only the file is not opened yet, since we don''t know what is going on
(* for reading or writting.
 *)
var
    _rc   :_word;
    i     :integer;
    ended :boolean;
begin
     i:=1
    ;ended := false
    ;with f 
     do
       while( NOT ended)
       do
         begin
            fname[i] := name[i]
           ;ended := (name[i] = ' ') or (name[i] = chr(0)) or (i >= maxstr)
           ;I := I+1
         end
     (* Just add terminate for OS/2 or Clib *)
    ;f.fname[i]    := chr(0)
    ;f.namelen     := i
    ;f.initialised := _InitMagic
    ;f.handle      := -1
end;

procedure $StdReset(Var f: _filedescr;
                      name :_str; namesize :_word;
                      textfile :Boolean; size :_word
                      );
(*  Open the file with the descriptor for reading, and start at the beginning 
(*  of the file.
 *)
var
    _rc     :_word;
    result  :_word;
    hdltype, dummy :_word;
begin
  with f
  do
    begin
       if (Initialised <> _InitMagic)
          OR (    (handle <> _stdin)
              AND (handle <> _stdout)
              AND (handle <> _stderr))
       then
         begin
           if initialised <> _InitMagic
           then
             begin
                $memcopy(name,fname,namesize)
               ;namelen := namesize
             end
           else
             begin
                (* Make shure the file was closed, then open it.
                (* but only if it was not one of the standard files
                 *)
                if handle <> -1
                then _rc := CClose(handle)
              end
           ;handle:= COpen(fname,O_RDONLY+O_BINARY)
           ;if(handle = -1) 
            then
              writeln('StdReset(',__LINE__:1,'): Error in Dos32Open')
            else
              begin
                 if initialised <> _InitMagic
                 then
                   begin
                      $memcopy(name,fname,namesize)
                     ;namelen := namesize
                   end
                ;bufstart := 1
                ;bufpoint := $StrAddr(buffer)
                ;Bufend   := bufstart 
                ;Bufempty := True
                ;elemsize := size
                ;Fileopen := True
                ;FileTxt := textfile
                ;Bufeoln  := False
                ;Bufeof   := False
                ;isTTY    := (Cisatty(handle) <>0)
                 (* Is it allowed to prefetch the buffer ? *)     
                ;if not isTTY
                 then
                     $StdGet(f)
                ;Initialised := _InitMagic
              end
          end
     end
end;

procedure $StdRewrite(Var f: _filedescr; 
                      name :_str; namesize :_word;
                      textfile :Boolean; size :_word
                      );
(*  Open the file with the descriptor for writing, and start at the beginning 
(*  of the file.
 *)
var
    _rc    :_word;
    result :_word;
    hdltype, dummy :_word;
begin
  with f
  do
    begin
      ;if (Initialised <> _InitMagic)
          OR (    (handle <> _stdin)
              AND (handle <> _stdout)
              AND (handle <> _stderr))
       then
         begin
           if initialised <> _InitMagic
           then
             begin
                $memcopy(name,fname,namesize)
               ;namelen := namesize
             end
           else
             begin
                (* Make shure the file was closed, then open it.
                (* but only if it was not one of the standard files
                 *)
                if handle <> -1
                then _rc := CClose(handle)
              end
           ;handle := Copen(fname, O_WRONLY+O_BINARY)
           ;if(handle = -1) 
            then
              writeln('StdReset(',__LINE__:1,'): Error in Dos32Open.')
            else
              with f
              do
                begin
                  ;bufstart := 1
                  ;bufpoint := $StrAddr(buffer)
                  ;Bufend   := bufstart 
                  ;Bufempty := True
                  ;elemsize := size
                  ;Fileopen := True
                  ;Fileinp  := False
                  ;Filetxt  := textfile
                  ;Bufeoln  := False
                  ;Bufeof   := False
                  ;isTTY    := (Cisatty(handle) <>0)
                end
         end
    end                
end; (* StdRewrite *)

procedure _TextInit(VAR f :_filedescr; hdl :_word; 
                    name :_str; namesize :_word;
                    forinput, opened :Boolean
                     );
(* Initialise the descriptor with handle 'hdl' as being a Text mode descriptor
(* Either for in/output as described by the second parameter
(* It could also be a file already opened by the system.
 *)
var
   _rc, hdltype, dummy :_word;
begin
     with f do
     begin
         $memcopy(name,fname,namesize)
        ;namelen     := namesize
        ;handle      := hdl
        ;bufstart    := 1
        ;Bufend      := bufstart
        ;BufPoint    := $StrAddr(buffer)
        ;elemsize    := 1
        ;Bufempty    := True
        ;Fileopen    := opened
        ;fileinp     := forinput
        ;filetxt     := True
        ;Bufeoln     := False
        ;Bufeof      := False
         (* This assumes that these handles are opened already *)
        ;isTTY       := (Cisatty(handle) <>0)
        ;Initialised := _InitMagic
     end
end;

(* Startup and Exit code *)

procedure $IOInit;
(*  Initialise all kind of things which are in the IO-library.
 *)
begin
    ;DumpingHandle := False
     (* _input.buf initialisation *)
    ;_TextInit(input, _stdin, 'input', 5, True, True )
    (* Output initialisation *)
    ;_TextInit(output, _stdout, 'output', 6, False, True )
    (* Error out initialisation *)
    ;_TextInit(errout, _stderr, 'errout', 6, False, True )
end;

procedure $IOExit;
(*  Called when the User part of the program is done.
 *)
begin
end;

begin
end.
(*
 * $Log: iolib.pas,v $
 * Revision 1.1  1993/11/03  15:55:00  wjw
 * Started adminstration for the RUNTIME LIB
 *
 *      First created by Willem Jan Withagen ( wjw@eb.ele.tue.nl ),
 *                    on Mon July 26 23:30:03 MET 1993
 *)
