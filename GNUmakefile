#!/usr/bin/make -f

TGTDIR ?= $(HOME)
TGTDIR := $(realpath $(TGTDIR))

.DEFAULT: install
.PHONY: install test setup clean rebuild help ./append_payload remove-obsolete

HOSTNAME ?= $(shell hostname -s)
SRCFILES := .gitconfig .multitailrc .vimrc .tmux.conf .hgrc .bashrc .bash_aliases $(foreach fldr,.bashrc.d .bazaar .gnupg .ssh .vim,$(shell find $(fldr) -type f|grep -v '/.git/'))
# NOTE: those overrides are limited to files that already exist among the files that are
#       processed by default. That is, files that exist in these folders but have no
#       matching default source file will be ignored.
OVERRIDES:= machine-specific/override/$(HOSTNAME)
APPENDS  := machine-specific/append/$(HOSTNAME)
CUSTOMSCR:= machine-specific/custom
LOCAL_OVERRIDES:= $(TGTDIR)/.local/dotfiles/override
LOCAL_APPENDS  := $(TGTDIR)/.local/dotfiles/append
LOCAL_CUSTOMSCR:= $(TGTDIR)/.local/dotfiles/custom
VIM_RMOLD:= .vim/.remove-obsolete.sh

define make_single_rule
install: $$(TGTDIR)/$(1) 
.PHONY: $$(realpath $$(wildcard $$(APPENDS)/$(1))) $$(realpath $$(wildcard $$(OVERRIDES)/$(1))) $$(realpath $$(wildcard $$(LOCAL_APPENDS)/$(1))) $$(realpath $$(wildcard $$(LOCAL_OVERRIDES)/$(1)))
$$(TGTDIR)/$(1): $$(realpath $(1)) $$(realpath $$(wildcard $$(APPENDS)/$(1))) $$(realpath $$(wildcard $$(OVERRIDES)/$(1))) $$(realpath $$(wildcard $$(LOCAL_APPENDS)/$(1))) $$(realpath $$(wildcard $$(LOCAL_OVERRIDES)/$(1)))
	-@test -L $$@ && rm -f $$@ || true
	-@test -d $$(dir $$@) || mkdir -p $$(dir $$@)
ifdef HARDLINK
	@echo "Linking/copying: $$(notdir $$<) -> $$(dir $$@)"
	@cp -lfr $$< $$@ 2>/dev/null || cp -fr $$< $$@
else
	@echo "Copying: $$(notdir $$<) -> $$(dir $$@)"
	@cp -fr $$< $$@
endif
	@if [ -n "$$(realpath $$(wildcard $$(APPENDS)/$(1)))" ]; then \
		if [ -f "$$(realpath $$(wildcard $$(APPENDS)/$(1)))" ]; then \
			echo "       ... appending $$(APPENDS)/$(1)"; \
			cat "$$(realpath $$(wildcard $$(APPENDS)/$(1)))" >> "$$@"; \
		fi; \
	fi
	@if [ -n "$$(realpath $$(wildcard $$(OVERRIDES)/$(1)))" ]; then \
		if [ -f "$$(realpath $$(wildcard $$(OVERRIDES)/$(1)))" ]; then \
			echo "       ... overwriting with $$(OVERRIDES)/$(1)"; \
			cp -fr "$$(realpath $$(wildcard $$(OVERRIDES)/$(1)))" "$$@"; \
		fi; \
	fi
	@if [ -n "$$(realpath $$(wildcard $$(LOCAL_APPENDS)/$(1)))" ]; then \
		if [ -f "$$(realpath $$(wildcard $$(LOCAL_APPENDS)/$(1)))" ]; then \
			echo "       ... appending $$(LOCAL_APPENDS)/$(1)"; \
			cat "$$(realpath $$(wildcard $$(LOCAL_APPENDS)/$(1)))" >> "$$@"; \
		fi; \
	fi
	@if [ -n "$$(realpath $$(wildcard $$(LOCAL_OVERRIDES)/$(1)))" ]; then \
		if [ -f "$$(realpath $$(wildcard $$(LOCAL_OVERRIDES)/$(1)))" ]; then \
			echo "       ... overwriting with $$(LOCAL_OVERRIDES)/$(1)"; \
			cp -fr "$$(realpath $$(wildcard $$(LOCAL_OVERRIDES)/$(1)))" "$$@"; \
		fi; \
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

.PHONY: all
all: setup

remove-obsolete: $(VIM_RMOLD)
	-@echo "Removing obsolete files from $(TGTDIR)/.vim ..."
	@$< "$(TGTDIR)"

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

test: TGTDIR:=$(HOME)/dotfile-test
test:
	test -d "$(TGTDIR)" && rm -rf "$(TGTDIR)"
	test -d "$(TGTDIR)" || mkdir -p "$(TGTDIR)"
	$(MAKE) TGTDIR="$(TGTDIR)" install

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

install: remove-obsolete
	@test -d .hg && cp hgrc.dotfiles .hg/hgrc
	@test -x "$(CUSTOMSCR)/ALL" && TGTDIR="$(TGTDIR)" "$(CUSTOMSCR)/ALL" || true
	@test -x "$(CUSTOMSCR)/$(HOSTNAME)" && TGTDIR="$(TGTDIR)" "$(CUSTOMSCR)/$(HOSTNAME)" || true
	@test -x "$(LOCAL_CUSTOMSCR)/ALL" && TGTDIR="$(TGTDIR)" "$(LOCAL_CUSTOMSCR)/ALL" || true
	@test -x "$(LOCAL_CUSTOMSCR)/$(HOSTNAME)" && TGTDIR="$(TGTDIR)" "$(LOCAL_CUSTOMSCR)/$(HOSTNAME)" || true
	@test -d "$(TGTDIR)/.gnupg" && chmod g=rX,o= "$(TGTDIR)/.gnupg" || true

$(foreach goal,$(sort $(SRCFILES)),$(eval $(call make_single_rule,$(goal))))

.NOTPARALLEL: install remove-obsolete
.INTERMEDIATE: $(TGTDIR)/$(VIM_RMOLD)
