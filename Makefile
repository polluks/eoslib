TARGET_EXEC ?= eos

BUILD_DIR ?= ./build
SRC_DIRS ?= ./src

CC = zcc
AS = z88dk-z80asm

SRCS := $(shell find $(SRC_DIRS) -name '*.cpp' -or -name '*.c' -or -name '*.s')
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

CFLAGS  = +coleco -subtype=adam
LDFLAGS = -xeos

INC_DIRS  := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# -----------------------------
# z88dk share dir detection
# -----------------------------
# Allow user override: `make install Z88DK_SHARE=/opt/z88dk`
ifndef Z88DK_SHARE
  ifneq (,$(wildcard /usr/share/z88dk))
    Z88DK_SHARE := /usr/share/z88dk
  else ifneq (,$(wildcard /usr/local/share/z88dk))
    Z88DK_SHARE := /usr/local/share/z88dk
  else
    $(error Could not find z88dk share directory (tried /usr/share/z88dk and /usr/local/share/z88dk). Set Z88DK_SHARE=/path/to/z88dk)
  endif
endif

# ZCCCFG auto-configuration (can be overridden: `make ZCCCFG=/custom/path`)
ZCCCFG ?= $(Z88DK_SHARE)/lib/config
export ZCCCFG

$(TARGET_EXEC).lib: $(OBJS)
	$(AS) $(LDFLAGS) $(OBJS)

# c source
$(BUILD_DIR)/%.c.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

.PHONY: install check clean

install: src/eos.h eos.lib
	install -D src/eos.h $(Z88DK_SHARE)/include/eos.h
	install -D eos.lib   $(Z88DK_SHARE)/lib/clibs/eos.lib

check:
	$(MAKE) -C tests/console-output/

clean:
	$(RM) -r eos.lib $(BUILD_DIR)

-include $(DEPS)

MKDIR_P ?= mkdir -p

