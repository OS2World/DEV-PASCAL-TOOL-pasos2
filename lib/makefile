#  Makefile
#*
#* FileName:   makefile
#* $Source: E:/usr/src/c-code/pascal/RCS/begend/makefile,v $
#* $Author: wjw $
#* $Date: 1993/09/24 11:05:08 $
#* $Locker: wjw $
#* $State: Exp $
#* $Revision: 
#H  Description:
#
#       General definitions
#       For special commands 
LBIN     = ../bin/
SYSTEM  = apollo
SYSTEM  = # OS2
#
#       Definitions for the GMD Cocktail stuff
include /usr/lib/makefile.gmd
#
#       Compiler definitions
CC       = cc
LDLIBDIR = -L../frontend -L$(GMDLIB) -L./80386 -L../src
LDLIBS   = $(LDLIBDIR) -lfront -l80386 -laux -lreuse
INCLUDES = -I../frontend -I../src -I./80386
#	
APOLLOCF = -W0,-opt,0 
APOLLOLD = -Wl,-A,"stacksize\,0xfffff"
SGICF    =
OS2CF    = -I/emx/include -I$(GMDINC) 
OS2LD    = 
#          The default assumptions
SYSCF    = $(APOLLOCF)
SYSLD    = $(APOLLOLD)

OPTIMIZE = -g
CFLAGS   = $(INCLUDES) $(OPTIMIZE) $(SYSCF) $(SWITCHES)
LDFLAGS  = $(SYSLD)

OTHER_RCS = makefile todo

.SUFFIXES: .lib .a .obj .o .asm .s .pas .p
PASDEBUG = -DDEBUG_IOREAD
LIBSRC   = passtart.asm pashead.inc macros.inc \
	   paslib.pas paslib.inc \
	   iolib.pas \
	   heaplib.pas \
	   setlib.pas \
	   wrtlib.pas writes.inc
	   
LIBSRC   = passtart.s pashead.hs \
	   paslib.p paslib.hs \
	   iolib.p \
	   heaplib.p \
	   setlib.p \
	   wrtlib.p
	   
p.lib: passtart.obj paslib.obj iolib.obj heaplib.obj setlib.obj wrtlib.obj
	-rm p.lib
	lib p.lib +passtart.obj+paslib.obj+iolib.obj+heaplib.obj+setlib.obj+wrtlib.obj;
	
libp.a: passtart.o paslib.o iolib.o heaplib.o setlib.o wrtlib.o
	-rm libp.a
	ar rv libp.a passtart.o paslib.o iolib.o heaplib.o setlib.o wrtlib.o
	ranlib libp.a
	
w.lib: passtart.obj wrtlib.obj paslib.obj setlib.obj 
	-rm w.lib
	lib w.lib +passtart.obj+paslib.obj+wrtlib.obj;
	
clean.lib:
	-rm *.lib
	-rm *.obj
	-rm paslib.asm iolib.asm heaplib.asm setlib.asm
	
#  These rules are for the library modules which are compiled as were 
#  they just regular programs. Only the need to be stripped of their 
#  Pmain body.
#
.pas.asm:
	pc -S $(PASDEBUG) $*.pas
	strpmain $*.asm

.asm.obj:
	pc -c $*.asm

.p.s:
	pc -G -S $(PASDEBUG) $<
	gstrmain $*.s

.s.o:
	pc -G -c $<
	
passtart.o: passtart.S        
	pc -G -c $<

## DEPENDENCIES

passtart.obj: passtart.asm pashead.inc os2.inc macros.inc
paslib.obj: paslib.pas pashead.inc os2.inc macros.inc
iolib.obj: iolib.pas pashead.inc os2.inc macros.inc
heaplib.obj: heaplib.pas pashead.inc os2.inc macros.inc
setlib.obj: setlib.pas pashead.inc os2.inc macros.inc

paslib.o: paslib.p pashead.inc os2.hp 
iolib.o: iolib.p pashead.inc os2.hp
heaplib.o: heaplib.p pashead.inc os2.hp 
setlib.o: setlib.p pashead.inc os2.hp 
 
 
#---------------------------------------------------------------------
#
#	Misc.
#	Print the help info included in the top of this file
help:
	@sed '/#H/!d' ?akefile | sed 's/^#H//' | sed /sed/d $0
					      
#
#	Convert from DOS format to UNIX format.
#	and since tounix doesn't keep the dates set them to now.
#
tounix:
	-tounix ${SOURCES}
	-touch -c ${SOURCES}
					       
do_rcs:                    
	@echo 'Enter a ^d (or ^z) terminated message, describing the change'
	@cat - > /tmp/message
	cii -V -l $(SOURCES) $(OTHER_RCS) < /tmp/message
	@rm /tmp/message
					       
do_rcs.lib:
	@echo 'Enter a ^d (or ^z) terminated message, describing the change'
	@cat - > /tmp/message
	cii -V -l $(LIBSRC) < /tmp/message
	@rm /tmp/message
					       
#
#       Remove all files which are not directly required for any
#       of the executables.
clean: testclean
	-rm -f core *.bak *.BAK *.i barf* *.log *.lst
	-rm -f *.rej *.orig *.tmp *.dep

testclean:        
	-mv pas.exe pas.sav
	-mv passtart.asm passtart.sav
	-rm -f pc*.* test??.* test???.*
	-rm -f *.map *.sbr *.asm *.obj
	-rm *.exe
	-mv pas.tmp pas.exe
	-mv passtart.sav passtart.asm

#
#       Removing all executables, tests, and other files which can be
#       generated from the original sources.        
veryclean: clean
	-rm -f *.cg *.o *.TS

#*
#* History:
#*      First created by Willem Jan Withagen ( wjw@eb.ele.tue.nl )
#*                    on Sun May  2 21:09:41 MET 1993
#* $Log: makefile,v $
#*      Revision 1.2  1993/09/24  11:05:08  wjw
#*      Most of the constructs in the Compiler are now working (Reals ?)
#*
# Revision 1.1  1993/07/26  23:34:05  wjw
# Initial Entry into RCS
#
