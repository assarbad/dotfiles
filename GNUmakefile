#!/usr/bin/make -f
# vim: set autoindent smartindent ts=4 sw=4 sts=4 noet filetype=make:
export DOTFILES:=$(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Native Windows make has no usable Unix shell. Git Bash/MSYS sessions commonly
# inherit COMSPEC, so only reject it when no Unix-like shell marker is present.
ifneq ($(strip $(COMSPEC)$(ComSpec)),)
ifeq ($(strip $(MSYSTEM)$(OSTYPE)),)
$(error Native Windows/cmd.exe environments are unsupported; run make from Git Bash or another supported Unix-like shell)
endif
endif

TGTDIR ?= $(HOME)
export TGTDIR:=$(realpath $(TGTDIR))
ifneq ($(DEBUG),)
  DBG:=
else
  DBG:=@
endif
.DEFAULT: install

SHELL:=$(shell command -v bash)
ifeq ($(strip $(SHELL)),)
$(error No usable 'bash' found in PATH)
endif
NPD:=--no-print-directory

# Allow overriding the machine name used for override/append/custom lookup in
# install-dotfiles. Useful for debugging/spoofing, e.g.:
#   make MACHINE=frodo install
ifdef MACHINE
  export MACHINE
endif

.PHONY: all install install.script info test nodel-test help configure.gitconfig bashrc.link profile.link

install: install.script configure.gitconfig bashrc.link profile.link

install.script: $(DOTFILES)/install-dotfiles
	-$(DBG)test -d "$(DOTFILES)/.hg" && cp hgrc.local "$(DOTFILES)/.hg/hgrc"
	$(DBG)cd $(DOTFILES) && env TGTDIR="$(TGTDIR)" ./install-dotfiles

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

# Try a symlink first; fall back to a hardlink copy where symlinks aren't permitted
bashrc.link: $(TGTDIR)/.bash_profile
	test -f $(TGTDIR)/.bashrc && rm -f -- $(TGTDIR)/.bashrc
	cd $(TGTDIR) && (ln --symbolic .bash_profile .bashrc || cp -alf .bash_profile .bashrc)

# Windows-only in practice; harmless no-op elsewhere since it just probes for
# pwsh.exe/powershell.exe before doing anything (mirrors configure-gitconfig's
# own tool-detection gating style).
profile.link: $(DOTFILES)/configure-powershell-profile.ps1
	@for name in pwsh.exe powershell.exe; do \
		bin="$$(command -v "$$name" 2>/dev/null || true)"; \
		if [ -z "$$bin" ] && [ "$$name" = "powershell.exe" ] && [ -n "$(WINSH_CYGPATH)" ]; then \
			cand="$$($(WINSH_CYGPATH) -m "$$WINDIR\\System32\\WindowsPowerShell\\v1.0\\powershell.exe" 2>/dev/null)"; \
			[ -x "$$cand" ] && bin="$$cand"; \
		fi; \
		if [ -n "$$bin" ]; then \
			echo "[INFO] wiring refresh-dotfiles via $$bin"; \
			"$$bin" -NoProfile -ExecutionPolicy Bypass -File "$(DOTFILES)/configure-powershell-profile.ps1"; \
		fi; \
	done

configure.gitconfig: $(DOTFILES)/configure-gitconfig
	$(DBG)cd $(DOTFILES) && env TGTDIR="$(TGTDIR)" ./configure-gitconfig
