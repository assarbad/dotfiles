#!/usr/bin/make -f

TGTDIR ?= $(HOME)
TGTDIR := $(realpath $(TGTDIR))

.DEFAULT: install
.PHONY: install setup clean rebuild help ./append_payload

HOSTNAME ?= $(shell hostname -s)
SRCFILES := .multitailrc .vimrc .tmux.conf .hgrc .bashrc .bash_aliases $(foreach fldr,.bashrc.d .bazaar .gnupg .ssh .vim,$(shell find $(fldr) -type f))
# NOTE: those overrides are limited to files that already exist among the files that are
#       processed by default. That is, files that exist in these folders but have no
#       matching default source file will be ignored.
OVERRIDES:= machine-specific/override/$(HOSTNAME)
APPENDS  := machine-specific/append/$(HOSTNAME)
CUSTOMSCR:= machine-specific/custom

define make_single_rule
install: $(TGTDIR)/$(1) 
.PHONY: $(realpath $$(APPENDS)/$(1)) $(realpath $$(OVERRIDES)/$(1))
$(TGTDIR)/$(1): $$(realpath $(1)) $$(realpath $$(APPENDS)/$(1)) $$(realpath $$(OVERRIDES)/$(1))
	-test -L $$@ && rm -f $$@ || true
	-test -d $$(dir $$@) || mkdir -p $$(dir $$@)
ifdef HARDLINK
	@echo "Linking/copying: $$(notdir $$<) -> $$(dir $$@)"
	cp -lfr $$< $$@ 2>/dev/null || cp -fr $$< $$@
else
	@echo "Copying: $$(notdir $$<) -> $$(dir $$@)"
	cp -fr $$< $$@
endif
	if [ -n "$(realpath $$(APPENDS)/$(1))" ]; then \
		test -f "$(realpath $$(APPENDS)/$(1))" && cat "$(realpath $$(APPENDS)/$(1))" >> "$$@"; \
	fi
	if [ -n "$(realpath $$(OVERRIDES)/$(1))" ]; then \
		test -f "$(realpath $$(OVERRIDES)/$(1))" && cp -fr "$(realpath $$(OVERRIDES)/$(1))" "$$@"; \
	fi
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
setup: ./append_payload $(SETUPS)
else
setup: ./append_payload $(PSETUPS)
	hg -R $(DOTFILES) tip|perl -ple 's/\s+<[^>]+>//g'|tee "$(WEBDIR)/tip.txt" && touch -r $(SENTINEL) "$(WEBDIR)/tip.txt"

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
	tar -vC $(DOTFILES) --exclude-vcs -czf /tmp/$(notdir $@) . && mv /tmp/$(notdir $@) $@

./append_payload:
	./append_payload canrun

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
	-@echo "ALSO NOTE: you may override the hostname using the HOSTNAME variable"
	-@echo "\nAlternative one method to install:"
	-@echo "hg clone https://bitbucket.org/assarbad/dotfiles .dotfiles && make -C .dotfiles install"

.INTERMEDIATE: $(PAYLOAD)

install:
	if [ -d .hg ]; then cp hgrc.dotfiles .hg/hgrc; fi
	if [ -x "$(CUSTOMSCR)/ALL" ]; then TGTDIR="$(TGTDIR)" "$(CUSTOMSCR)/ALL"; fi
	if [ -x "$(CUSTOMSCR)/$(HOSTNAME)" ]; then TGTDIR="$(TGTDIR)" "$(CUSTOMSCR)/$(HOSTNAME)"; fi

$(foreach goal,$(sort $(SRCFILES)),$(eval $(call make_single_rule,$(goal))))
