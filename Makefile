CC      := gcc
LD      := ld
CFLAGS  := -fPIC -O2 -Wall -Werror -fno-stack-protector
LDFLAGS := -shared
SOURCE  := $(wildcard pinyin/*.c)
OBJS    := $(patsubst %.c,%.o,$(SOURCE))
TARGET_LIB := pinyin.so
LUA_LIBDIR ?= /usr/local/openresty/lualib

all:$(OBJS)
	@echo $(OBJS)
	$(LD) $(LDFLAGS) -o $(TARGET_LIB) $(OBJS)
	@rm *.o pinyin/*.o -rf
	@luajit pyf_test.lua

%.o:%.c
	@echo Compiling $< ...
	@$(CC) -c $(CFLAGS) $< -o $*.o

.PHONY: clean

install: pinyin.so
	cp pinyin.so $(LUA_LIBDIR)
	cp pyf.lua $(LUA_LIBDIR)/resty

clean:
	rm *.so *.o pinyin/*.so pinyin/*.o -rf