(*
 * FileName:   os2.inc
 * $Source: $
 * $Author: wjw $
 * $Date: 1993/09/24 11:05:01 $
 * $Locker: wjw $
 * $State: Exp $
 * $Revision: $
 * Description:
 *      Part of the runtime library which comes with PASCAL for OS/2
 *      
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
(* Used parts of OS/2 
(* To be include in modules which want to interface with the OS/2 library
(* functions.
(* Or to the few functions coded in Assembler in the main assembler module.
 *)
const 
          (* Response resulttypes for the DosOpen call *)
          FILE_EXISTED      = 1;
          FILE_CREATED      = 2;
          FILE_TRUNCATED    = 3;
          (* Attributes for a file *)
          FILE_NORMAL       = 0;
          FILE_READONLY     = 1;
          FILE_HIDDEN       = 2;
          FILE_SYSTEM       = 4;
          FILE_DIRECTORY    = 16;
          FILE_ARCHIVED     = 32;
          (* Open FLAG options *)
          OPEN_ACTION_FAIL_IF_NEW       = 0;
          OPEN_ACTION_CREATE_IF_NEW     = 16;
          OPEN_ACTION_FAIL_IF_EXISTS    = 0;
          OPEN_ACTION_OPEN_IF_EXISTS    = 1;
          OPEN_ACTION_REPLACE_IF_EXISTS = 2;
          (* Open modes *)
          OPEN_ACCESS_READONLY     = 0;
          OPEN_ACCESS_WRITEONLY    = 1;
          OPEN_ACCESS_READWRITE    = 2;
          OPEN_SHARE_DENYREADWRITE = 16;
          OPEN_SHARE_DENYWRITE     = 32;
          OPEN_SHARE_DENYREAD      = 48;
          OPEN_SHARE_DENYNONE      = 64;
          OPEN_FLAGS_NOINHERIT     = 128;        (* Handle is private *)
          OPEN_FLAGS_NO_LOCALITY   = 0;
          OPEN_FLAGS_SEQUENTIAL    = 256;
          OPEN_FLAGS_RANDOM        = 512;
          OPEN_FLAGS_RANDOMSEQUENTIAL = 768;     (* Mostly random *)
          OPEN_FLAGS_NO_CACHE      = 4096;       (* Don''t go through system cache *)
          OPEN_FLAGS_FAIL_ON_ERROR = 8192;       (* no Error handler *)
          OPEN_FLAGS_WRITE_THROUGH = 16384;
          OPEN_FLAGS_DASD          = 32768;      (* when opening a "drive" *)
          
          (* What is connected to the handle? *)
          HANDLE_TYPE_FILE         = 0;
          HANDLE_TYPE_CHAR_DEV     = 1;
          HANDLE_TYPE_PIPE         = 2;
          HANDLE_TYPE_DEV_MASK     = 255;
          HANDLE_TYPE_PROTECTED    = 16384;
          HANDLE_TYPE_LOCAL        = 0;
          HANDLE_TYPE_REMOTE       = 32768;
          
          (* Possible setting for extended attributes *)
          OPEN_NO_EA_BUF           = 0;
          
          (* Flags for the memory allocation space *)
          PAG_READ          = 1;
          PAG_WRITE         = 2;
          PAG_EXECUTE       = 4;
          PAG_GUARD         = 8;
          PAG_COMMIT        = 16;
          OBJ_TILE          = 64;
        
          (* Flags for the creation of heap space *)
          DOSSUB_INIT       = 1;
          DOSSUB_GROW       = 2;
          DOSSUB_SPARSE_OBJ = 4;
          DOSSUB_SERIALIZE  = 8;
        
          (* specific return values *)
          ERROR_DOSSUB_OVERLAP   = 312;
          ERROR_DOSSUB_CORRUPTED = 532;
          
          (* The maximum size of a file name *)
          MAX_PATH = 256;

(*  We need some defines since the current PASCAL version doesn''t allow for
(*  Constant expressions to be assigned to constants.
(*  So this way the get include as full computed functions
 *)
#define CR                    chr(13)
#define LF                    chr(10)


type
    _word     = integer;
    _str      = array[1..8] of char;
    _filename = array[1..MAX_PATH] of char;
    
FUNCTION  Dos32Open (path: _str;        (* The name to give to the file *)
                     VAR fhdl: _word;   (* Where to leave the handle *)
                     VAR result: _word; (* What was actually done *)
                     newsize: _word;    (* when creating/replacing a file *)
                     attribs: _word;    (* what attributs are set on the file *)
                     openflag: _word;   (* What when file (does)not exist? *)
                     openmode: _word;   
                     EA_buf: _word      (* Address of extended attribute buffer *)
                    ):_word; external;

FUNCTION  Dos32Close(fhdl :_word        (* handle to close *)
                     ):_word; external;
                     
FUNCTION  Dos32Write( fhdl: _word;      (* Handle to write to *)
                      str: _str;        (* String to write *)
                      cnt: _word;       (* Number of bytes to write *)
                      VAR  rcnt: _word  (* Actual number written *)
                      ):_word; external;
					
FUNCTION  Dos32Read ( fhdl: _word;      (* Handle to read from *)
                      str: _str;        (* String to read into *)
                      cnt: _word;       (* Number of bytes to read *)
                      VAR  rcnt: _word  (* Actual number read *)
                      ):_word; external;

FUNCTION  Dos32QueryHType( fhdl         :_word;
                           VAR state    :_word;
                           VAR flag_word :_word
                         ): _word;external;
                         
FUNCTION  Dos32exit(  w1 :_word;        (* 0=current thread, 1=ALL threads *)
                      w2 :_word         (* Exit code *)
                     ): _word; external;

FUNCTION  Dos32AllocMem (VAR Start :_word; Size :_word; Flags :_word
                        ):_word; external;
FUNCTION  Dos32FreeMem  (Start :_word
                        ):_word; external;
FUNCTION  Dos32SubSet   (Start :_word; Flags :_word; Size :_word
                        ):_word; external;
FUNCTION  Dos32SubUnset (Start :_word
                        ):_word; external;
FUNCTION  Dos32SubAlloc (Start :_word; VAR offset:_word; Size :_word
                        ):_word; external;
FUNCTION  Dos32SubFree  (Start :_word; offset:_word; Size :_word
                        ):_word; external;

(* And somethings coded in assembler *)
          (* Copy a piece of memory, but it should not overlap *)
procedure $memcopy(VAR source, dest :_str; size :_word );   external;
          
          (* Return the address of a string *)
function  $StrAddr(Var src:_str):_word;                     external;
          (* Logic operations *)
function  $shl(v,s :_word): _word;                          external;
function  $Andword(a,b :_word): _word;                      external;
function  $Orword(a,b :_word): _word;                       external;
function  $Invword(a :_word): _word;                        external;

(*
 * $Log: $
 *
 *      First created by Willem Jan Withagen ( wjw@eb.ele.tue.nl ),
 *                    on Mon July 26 23:30:03 MET 1993
 *)
