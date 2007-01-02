# makefile for rex_pcre library

# === USER SETTINGS ===
# ===========================================================================

# These are default values.
INC_LUA  =
LIB_LUA  =
INC_PCRE =
LIB_PCRE = -lpcre

# If the default settings don't work for your system,
# try to uncomment and edit the settings below.
#INC_LUA  = -I/usr/local/include
#LIB_LUA  = -llua -llualib
#INC_PCRE = -I/usr/local/include
#LIB_PCRE = -lpcre

# Common settings
MYCFLAGS = -W -Wall -O2 $(INC_LUA) $(INC_PCRE)
AR = ar rcu
CC = gcc

# Target name
TRG = rex_pcre

# ===========================================================================
# === END OF USER SETTINGS ===

V = 2.0

DEFS   = -DREX_OPENLIB=luaopen_$(TRG) -DREX_LIBNAME=\"$(TRG)\"
CFLAGS = $(MYCFLAGS) $(DEFS)
OBJ    = lpcre.o lpcre_f.o common.o
TRG_AR = lib$(TRG).a
TRG_SO = $(TRG).so

all: $(TRG_AR) $(TRG_SO)

# static PCRE regexp library binding
ar_pcre: $(TRG_AR)

# dynamic PCRE regexp library binding
so_pcre: $(TRG_SO)

$(TRG_AR): $(OBJ)
	$(AR) $@ $^

$(TRG_SO): $(OBJ)
	ld -o $@.$V -shared $^ $(LIB_PCRE) $(LIB_LUA)
	ln -fs $@.$V $@

clean:
	rm -f $(OBJ) $(TRG_AR) $(TRG_SO)*

# Dependencies
lpcre.o: lpcre.c common.h
lpcre_f.o: lpcre_f.c common.h
common.o: common.c common.h

# (End of Makefile)

