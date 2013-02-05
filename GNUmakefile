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
	cp -lfr $$^ $$@ 2>/dev/null || cp -fr $$^ $$@
endef

SETUP    := dotfile_installer
PAYLOAD  := dotfiles.tgz
DOTFILES := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

setup: $(SETUP)

dotfile_installer: $(PAYLOAD)
	./append_payload -u "-i=$@.sh.in" "-o=$@" $^

$(PAYLOAD): $(filter-out $(DOTFILES)/$(SETUP),$(wildcard $(DOTFILES)/*) $(wildcard $(DOTFILES)/.bashrc.d/*))
	tar -C $(DOTFILES) -czf /tmp/$(notdir $@) . && mv /tmp/$(notdir $@) $@

.NOTPARALLEL: rebuild
rebuild: clean setup

clean:
	rm -f $(SETUP) $(PAYLOAD)

.INTERMEDIATE: $(PAYLOAD)

$(foreach goal,$(SRCFILES),$(eval $(call make_single_rule,$(goal))))
