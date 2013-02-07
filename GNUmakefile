#!/usr/bin/make -f

TGTDIR ?= $(HOME)
TGTDIR := $(realpath $(TGTDIR))

.PHONY: install setup clean rebuild

SRCFILES := .multitailrc .vimrc .tmux.conf .hgrc .bashrc .bash_aliases .vim $(wildcard .bashrc.d/*)

define make_single_rule
install: $(TGTDIR)/$(1)
$(TGTDIR)/$(1): $(realpath $(1))
	-@test -L $$@ && rm -f $$@ || true
	-@test -d $$(dir $$@) || mkdir -p $$(dir $$@)
	test -d $$^ || cp -lfr $$^ $$@ 2>/dev/null || cp -fr $$^ $$@
	test -d $$^ && cp -lfr $$^ $$(dir $$@) 2>/dev/null || cp -fr $$^ $(dir $$@)/
endef

DOTFILES := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
PAYLOAD  := dotfiles.tgz
SETUP    := dotfile_installer
SETUPS   := $(SETUP).sh $(SETUP).bin

setup: $(SETUPS)

$(SETUP).bin: $(PAYLOAD)
	./append_payload -b "-i=$(notdir $(basename $@)).sh.in" "-o=$(notdir $@)" $(notdir $^)

$(SETUP).sh: $(PAYLOAD)
	./append_payload -u "-i=$(notdir $(basename $@)).sh.in" "-o=$(notdir $@)" $(notdir $^)

$(PAYLOAD): $(filter-out $(addprefix %/,$(SETUPS) $(PAYLOAD)),$(wildcard $(DOTFILES)/*) $(wildcard $(DOTFILES)/.bashrc.d/*))
	@rm -f $(notdir $(SETUPS) $(PAYLOAD))
	tar -C $(DOTFILES) -czf /tmp/$(notdir $@) . && mv /tmp/$(notdir $@) $@

.NOTPARALLEL: rebuild
rebuild: clean setup

clean:
	rm -f $(notdir $(SETUPS) $(PAYLOAD))

.INTERMEDIATE: $(PAYLOAD)

$(foreach goal,$(SRCFILES),$(eval $(call make_single_rule,$(goal))))
