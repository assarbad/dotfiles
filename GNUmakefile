#!/usr/bin/make -f
# vim: set autoindent smartindent ts=4 sw=4 sts=4 noet filetype=make:
export DOTFILES := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
TGTDIR ?= $(HOME)
export TGTDIR := $(realpath $(TGTDIR))
ifneq ($(DEBUG),)
  DBG:=
else
  DBG:=@
endif
.DEFAULT: install

ifeq ($(COMSPEC)$(ComSpec),) # not on Windows?
SHELL := $(shell command -v bash)
NPD:=--no-print-directory

# Allow overriding the machine name used for override/append/custom lookup in
# install-dotfiles. Useful for debugging/spoofing, e.g.:
#   make MACHINE=frodo install
ifdef MACHINE
  export MACHINE
endif

.PHONY: all install install.script info test nodel-test help configure.gitconfig bashrc.link clean-legacy

install: clean-legacy install.script configure.gitconfig bashrc.link

install.script: $(DOTFILES)/install-dotfiles
	-$(DBG)test -d "$(DOTFILES)/.hg" && cp hgrc.local "$(DOTFILES)/.hg/hgrc"
	$(DBG)cd $(DOTFILES) && env TGTDIR="$(TGTDIR)" ./install-dotfiles

clean-legacy:
	$(DBG)if [[ -f "$(TGTDIR)/.oldstyle-beroot" ]]; then ( set -x; rm -f -- "$(TGTDIR)/.oldstyle-beroot" ); fi

nodel-test test: TGTDIR:=$(HOME)/dotfile-test
test:
	$(DBG)test -d "$(TGTDIR)" && rm -rf "$(TGTDIR)" || true
	$(DBG)test -d "$(TGTDIR)" || mkdir -p "$(TGTDIR)"
	$(DBG)$(strip $(MAKE) $(NPD)) TGTDIR="$(TGTDIR)" install

nodel-test:
	$(DBG)$(strip $(MAKE) $(NPD)) TGTDIR="$(TGTDIR)" install

help:
	-@echo "USAGE:"
	-@echo ""
	-@echo "  Install into TGTDIR [the default]:"
	-@echo "    make install"
	-@echo ""
	-@echo "    TGTDIR defaults to $$HOME unless you override it."
	-@echo ""
	-@echo "    Ways to override:"
	-@echo "      make TGTDIR=/target/dir install"
	-@echo "      TGTDIR=/target/dir make install"
	-@echo ""
	-@echo "  Install into $$HOME/dotfile-test instead of $$HOME:"
	-@echo "    make test"
	-@echo ""
	-@echo "  Install into $$HOME/dotfile-test instead of $$HOME:"
	-@echo "    make nodel-test"
	-@echo ""
	-@echo "    This will not remove $$HOME/dotfile-test prior to 'make install'"
	-@echo ""
	-@echo "* TO DEBUG: set the variable DEBUG to a non-empty value"
	-@echo ""
	-@echo "Alternative one method to install:"
	-@echo ""
	-@echo "hg clone https://hg.code.sf.net/p/assarbad-dotfiles/code ~/.dotfiles && make -C ~/.dotfiles install"

info:
	-@$(foreach var,DEBUG NPD CURDIR SHELL TGTDIR DOTFILES,echo "$(var) = ${$(var)}";)

.NOTPARALLEL: install test nodel-test
.ONESHELL: help

bashrc.link:
	test -f $(TGTDIR)/.bashrc && rm -f -- $(TGTDIR)/.bashrc
	$$SHELL -c "cd '$(TGTDIR)' && ln --symbolic .bash_profile .bashrc"

else # on Windows

ifeq ($(SHELL),C:/Program Files/Git/usr/bin/sh.exe)
$(warning Converting paths to mixed form)
export HOME:=$(shell /usr/bin/env cygpath -m "$$HOME")
export DOTFILES:=$(shell /usr/bin/env cygpath -m "$$DOTFILES")
export TGTDIR:=$(shell /usr/bin/env cygpath -m "$$TGTDIR")
else
$(warning SHELL=$(SHELL))
endif
FILES_TO_CONSIDER:=\
	refresh-dotfiles \
	.bashrc.d/gpg \
	.bashrc.d/refresh-dotfiles \
	.config/flake8 \
	.config/powershell/refresh-dotfiles.ps1 \
	.config/starship.toml \
	$(wildcard .config/espanso/config/*.yml) \
	$(wildcard .config/espanso/match/*.yml) \
	$(wildcard .config/espanso/match/*.md) \
	$(wildcard .config/cookiecutter/*) \
	$(wildcard .config/rustfmt/*) \
	$(wildcard .config/alacritty/*) \
	.cargo/config.toml \
	$(wildcard .config/git/*) \
	.gnupg/gpg.conf \
	.gnupg/.no-pubkey-fetch \
	.bash_profile \
	.common_profile \
	.zshrc \
	.hgrc \
	.inputrc \
	.vimrc \
	Mercurial.ini
$(warning Installing from DOTFILES=$(DOTFILES) into TGTDIR=$(TGTDIR) with HOME=$(HOME))

clean-windows:
	if [[ -f "$(HOME)/.gitrc.d/gitconfig.LOCAL" && ! -f "$(HOME)/.config/git/gitconfig.LOCAL" ]]; then \
		( set -x; mv -- "$(HOME)/.gitrc.d/gitconfig.LOCAL" "$(HOME)/.config/git"/ ); \
	fi; \
	if [[ -f "$(HOME)/.gitrc.d/gitconfig.USER" && ! -f "$(HOME)/.config/git/gitconfig.USER" ]]; then \
		( set -x; mv -- "$(HOME)/.gitrc.d/gitconfig.USER" "$(HOME)/.config/git"/ ); \
	fi; \
	if [[ -d "$(HOME)/.gitrc.d" ]]; then \
		( set -x; rm -rf -- "$(HOME)/.gitrc.d" ); \
	fi; \
	if [[ -f "$(HOME)/.gitconfig" ]]; then \
		( set -x; rm -f -- "$(HOME)/.gitconfig" ); \
	fi; \
	if [[ -f "$(HOME)/.cargo/config" && ! -f "$(HOME)/.cargo/config.toml" ]]; then \
		( set -x; mv -- "$(HOME)/.cargo/config" "$(HOME)/.cargo/config.toml" ); \
	elif [[ -f "$(HOME)/.cargo/config" && -f "$(HOME)/.cargo/config.toml" ]]; then \
		( set -x; rm -f -- "$(HOME)/.cargo/config" ); \
	fi; \
	if [[ -f "$(HOME)/.bashrc" ]]; then \
		( set -x; rm -f -- "$(HOME)/.bashrc" ); \
	fi
	if [[ -f "$(HOME)/.bashrc.d/rust" ]]; then \
		( set -x; rm -f -- "$(HOME)/.bashrc.d/rust" ); \
	fi
	if [[ -f "$(HOME)/.config/git/gitconfig.gnupg4win" ]]; then \
		( set -x; rm -f -- "$(HOME)/.config/git/gitconfig.gnupg4win" ); \
	fi
	if [[ -f "$(HOME)/.oldstyle-beroot" ]]; then \
		( set -x; rm -f -- "$(HOME)/.oldstyle-beroot" ); \
	fi

install: clean-windows $(addprefix $(HOME)/,$(FILES_TO_CONSIDER)) configure.gitconfig bashrc.link profile.link

$(HOME)/%: %
	@test -d "$(dir $@)" || mkdir -p "$(dir $@)"
	cp -f "$<" "$@"

.PHONY: install $(HOME)/.config/git/gitconfig.LOCAL configure.gitconfig clean-windows bashrc.link profile.link

bashrc.link: $(HOME)/.bash_profile
	cp -alf -- $(TGTDIR)/.bash_profile $(TGTDIR)/.bashrc

profile.link: $(HOME)/.config/powershell/refresh-dotfiles.ps1
	powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(DOTFILES)/configure-powershell-profile.ps1"

endif

configure.gitconfig: $(DOTFILES)/configure-gitconfig
	$(DBG)cd $(DOTFILES) && env TGTDIR="$(TGTDIR)" ./configure-gitconfig
