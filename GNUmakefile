#!/usr/bin/make -f

TGTDIR ?= $(HOME)
TGTDIR := $(realpath $(TGTDIR))

.PHONY: install setup clean rebuild help

SRCFILES := .multitailrc .vimrc .tmux.conf .hgrc .bashrc .bash_aliases $(shell find .bashrc.d -type f) $(shell find .vim -type f)

define make_single_rule
install: $(TGTDIR)/$(1)
$(TGTDIR)/$(1): $(realpath $(1))
	-@test -L $$@ && rm -f $$@ || true
	-@test -d $$(dir $$@) || mkdir -p $$(dir $$@)
ifdef HARDLINK
	@echo "Linking/copying: $$(notdir $$^) -> $$(dir $$@)"
	@cp -lfr $$^ $$@ 2>/dev/null || cp -fr $$^ $$@
else
	@echo "Copying: $$(notdir $$^) -> $$(dir $$@)"
	@cp -fr $$^ $$@
endif
endef

DOTFILES := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
PAYLOAD  := dotfiles.tgz
SETUP    := dotfile_installer
SETUPS   := $(SETUP).sh $(SETUP).bin
ifdef WEBDIR
PSETUPS   := $(patsubst %,$(WEBDIR)/%,$(SETUPS))
endif
SENTINEL := $(DOTFILES)/.hg/store/00changelog.i

ifndef WEBDIR
setup: $(SETUPS) 
else
setup: $(PSETUPS)
	hg -R $(DOTFILES) tip|perl -ple 's/\s+<[^>]+>//g'|tee "$(WEBDIR)/tip.txt"

$(WEBDIR)/%: %
	cp -a $< $@
endif

$(filter %.bin,$(SETUPS)): $(PAYLOAD) $(SENTINEL)
	./append_payload -b "-i=$(notdir $(basename $@)).sh.in" "-o=$(notdir $@)" $(notdir $<)

$(filter %.sh,$(SETUPS)): $(PAYLOAD) $(SENTINEL)
	./append_payload -u "-i=$(notdir $(basename $@)).sh.in" "-o=$(notdir $@)" $(notdir $<)

$(PAYLOAD): $(SENTINEL)
	hg -R $(DOTFILES) update
	@rm -f $(notdir $(SETUPS) $(PAYLOAD))
	tar -C $(DOTFILES) --exclude-vcs -czf /tmp/$(notdir $@) . && mv /tmp/$(notdir $@) $@


.NOTPARALLEL: rebuild
rebuild: clean setup

clean:
	rm -f $(notdir $(SETUPS) $(PAYLOAD))

help:
	-@echo "USAGE:\n"
	-@echo "  Create the installer script with payload:"
	-@echo "    make setup\n"
	-@echo "Install into TGTDIR:"
	-@echo "    make install\n"
	-@echo "    TGTDIR defaults to $$HOME unless you override it.\n"
	-@echo "    Ways to override:"
	-@echo "      make TGTDIR=/target/dir install"
	-@echo "      TGTDIR=/target/dir make install"
	-@echo "\n"
	-@echo "NOTE: you may set the variable HARDLINK to a non-empty value to hard-link instead of copying by default"
	-@echo "\nAlternative one method to install:"
	-@echo "hg clone https://bitbucket.org/assarbad/dotfiles .dotfiles && make -C .dotfiles install"

.INTERMEDIATE: $(PAYLOAD)

$(foreach goal,$(sort $(SRCFILES)),$(eval $(call make_single_rule,$(goal))))
