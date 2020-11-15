export

.PHONY: all

CC := gcc
AR := ar


TOP_LEVEL := $(shell pwd)

OBJDIR    := $(TOP_LEVEL)/build
SRCDIR    := $(TOP_LEVEL)/src

DEBLOAT_PROF_SRCDIR := $(SRCDIR)/debloat_prof
DEBLOAT_PROF_OBJDIR := $(OBJDIR)/debloat_prof



all: mkdirs
	$(MAKE) -C $(DEBLOAT_PROF_SRCDIR) all

mkdirs: $(DEBLOAT_PROF_OBJDIR)

$(OBJDIR)/%:
	@mkdir -p $@

clean:
	rm -rf $(OBJDIR)

