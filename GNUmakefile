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
ifeq ($(NOLINK),)
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
BUNDLE   := dotfiles.hg

setup: $(SETUPS)

$(SETUP).bin: $(PAYLOAD)
	./append_payload -b "-i=$(notdir $(basename $@)).sh.in" "-o=$(notdir $@)" $(notdir $^)

$(SETUP).sh: $(PAYLOAD)
	./append_payload -u "-i=$(notdir $(basename $@)).sh.in" "-o=$(notdir $@)" $(notdir $^)

$(PAYLOAD): $(filter-out $(addprefix %/,$(BUNDLE) $(SETUPS) $(PAYLOAD)),$(wildcard $(DOTFILES)/*) $(wildcard $(DOTFILES)/.bashrc.d/*))
	@rm -f $(notdir $(SETUPS) $(PAYLOAD) $(BUNDLE))
	@test -d .hg && rm -f .hg/rm -f hg-bundle-*
	hg -R $(dir $@) bundle -a $(BUNDLE)
	tar -C $(DOTFILES) --exclude-vcs -czf /tmp/$(notdir $@) . && mv /tmp/$(notdir $@) $@
	@rm -f $(BUNDLE)

.NOTPARALLEL: rebuild
rebuild: clean setup

clean:
	rm -f $(notdir $(SETUPS) $(PAYLOAD) $(BUNDLE))

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
	-@echo "NOTE: you may set the variable NOLINK to a non-empty value to copy instead of hard-link by default"

.INTERMEDIATE: $(PAYLOAD)

$(foreach goal,$(sort $(SRCFILES)),$(eval $(call make_single_rule,$(goal))))
