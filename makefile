
BIN_LIB=CMPSYS
LIBLIST=$(BIN_LIB) CLV1
SHELL=/QOpenSys/usr/bin/qsh

all: test7ifs.rpgle

%.rpgle:
	system -s "CHGATR OBJ('/home/CLV/datainto&datagen/qrpglesrc/$*.rpgle') ATR(*CCSID) VALUE(1252)"
	liblist -a $(LIBLIST);\
	system "CRTBNDRPG PGM($(BIN_LIB)/$*) SRCSTMF('/home/CLV/datainto&datagen/qrpglesrc/$*.rpgle') DBGVIEW(*ALL) OPTION(*EVENTF)"
	