#!/usr/bin/make -f

TGTDIR ?= $(HOME)
TGTDIR := $(realpath $(TGTDIR))

.PHONY: all

SRCFILES := .vimrc .tmux.conf .hgrc .bashrc .bash_aliases .vim $(wildcard .bashrc.d/*)

define make_single_rule
all: $(TGTDIR)/$(1)
$(TGTDIR)/$(1): $(realpath $(1))
	-@test -L $$@ && rm -f $$@ || true
	-@test -d $$(dir $$@) || mkdir -p $$(dir $$@)
	cp -flr $$^ $$@
endef

$(foreach goal,$(SRCFILES),$(eval $(call make_single_rule,$(goal))))
