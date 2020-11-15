
#TARGET := libdebloat_prof.a
TARGET := libdebloat_prof.so

SRC := $(shell find -type f -name \*.c -print)
OBJ := $(patsubst %.c,$(DEBLOAT_PROF_OBJDIR)/%.o, $(SRC))


all: $(DEBLOAT_PROF_OBJDIR)/$(TARGET)
.PHONY: all


$(DEBLOAT_PROF_OBJDIR)/$(TARGET): $(OBJ)
	#$(AR) rcs $@ $^
	$(CC) $^ -shared -o $@

$(DEBLOAT_PROF_OBJDIR)/%.o: %.c
	$(CC) -c -g -O0 -fPIC $< -o $@
