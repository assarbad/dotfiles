#!/usr/bin/make -f
# vim: set autoindent smartindent ts=4 sw=4 sts=4 noet filetype=make:
export DOTFILES:=$(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ifeq ($(HOME),)
# cmd.exe has no HOME, only USERPROFILE -- fall back so TGTDIR below isn't empty.
HOME:=$(subst \,/,$(USERPROFILE))
endif
TGTDIR ?= $(HOME)
export TGTDIR:=$(realpath $(TGTDIR))
ifneq ($(DEBUG),)
  DBG:=
else
  DBG:=@
endif
.DEFAULT: install

ifeq ($(COMSPEC)$(ComSpec),) # not on Windows?
SHELL:=$(shell command -v bash)
ifeq ($(strip $(SHELL)),)
$(error No usable 'bash' found in PATH)
endif
else
# Native Make's own SHELL guess may not resolve, silently falling back to
# cmd.exe for recipes. Derive a path from git --exec-path via $(subst) only.
sp:=$(subst x, ,x)
exists = $(wildcard $(subst $(sp),\$(sp),$1))
WINSH_GITEXE:=$(shell git --exec-path)
REALSHELL:=$(subst /mingw64/libexec/git-core,/usr/bin/bash.exe,$(WINSH_GITEXE))
ifeq ($(call exists,$(REALSHELL)),)
REALSHELL:= $(subst /mingw64/libexec/git-core,/usr/bin/sh.exe,$(WINSH_GITEXE))
endif
ifeq ($(call exists,$(REALSHELL)),)
REALSHELL:=$(subst /mingw64/libexec/git-core,/bin/bash.exe,$(WINSH_GITEXE))
endif
ifeq ($(call exists,$(REALSHELL)),)
REALSHELL:=$(subst /mingw64/libexec/git-core,/bin/sh.exe,$(WINSH_GITEXE))
endif
# Fail loudly if we did not land on a real bash.exe/sh.exe.
ifeq ($(filter bash.exe sh.exe,$(notdir $(REALSHELL))),)
$(error No usable bash.exe/sh.exe found: git --exec-path '$(WINSH_GITEXE)' resolved to '$(REALSHELL)'. Run this from a Git Bash shell)
endif
SHELL:=$(subst \,/,$(REALSHELL))

# Normalize HOME/DOTFILES/TGTDIR through cygpath so recipes see a consistent,
# usable path form.
# $(filter) would split on the space in "Program Files"; use $(subst) suffix-
# stripping instead (only one of these ever actually matches).
ifneq ($(SHELL),$(subst /usr/bin/bash.exe,,$(subst /usr/bin/sh.exe,,$(subst /bin/bash.exe,,$(subst /bin/sh.exe,,$(SHELL))))))
$(warning Converting paths to mixed form)
# cygpath.exe lives next to bash.exe/sh.exe; usr/bin is deliberately not on
# PATH under Git for Windows, so "env cygpath" can't find it -- use the full
# path instead, mirroring how REALSHELL itself was resolved above.
WINSH_CYGPATH:=$(subst /mingw64/libexec/git-core,/usr/bin/cygpath.exe,$(WINSH_GITEXE))
export HOME:=$(shell "$(WINSH_CYGPATH)" -m "$(HOME)")
export DOTFILES:=$(shell "$(WINSH_CYGPATH)" -m "$(DOTFILES)")
export TGTDIR:=$(shell "$(WINSH_CYGPATH)" -m "$(TGTDIR)")
else
$(warning SHELL=$(SHELL))
endif
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
