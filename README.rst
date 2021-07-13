 Oliver's dotfiles
===================

About
-----
This folder contains my dotfiles, i.e. all kinds of customized settings for
programs I use regularly, starting with the shell (Bash: ``.bashrc``) and not
ending with my favorite editor (Vim: ``.vimrc``).

Pick whatever you like. I have borrowed stuff here and there myself.

One shameless plug, however. I warmly recommend the following books:

- `Bash Cookbook`_ by Carl Albing, JP Vossen, Cameron Newham
- `Practical Vim`_ by Drew Neil (also check out his `vimcasts.org`_ and dotfiles_)
- `Hacking Vim`_ by Kim Schulz

The mysterious ``GNUmakefile``
------------------------------

You'll also find a ``GNUmakefile`` that can be used for two things.

- ``make`` (default and alias for ``make install``)
- ``make setup``

The ``setup`` behavior is to create a self-contained installer named
``dotfile_installer.sh`` (``uuencode``-d), based on the script of
the same basename with the suffix ``.sh.in``. In addition a second
version named ``dotfile_installer.bin`` gets created as well. This
installer will contain all the files from this folder, including
the ``.hg`` folder (this is intentional!).

This way you can simply build this file once and download from a location
you trust. It makes it possible to bootstrap my dotfiles conveniently on
a system, even if no Mercurial is available (yet).

The other thing is to install it to your ``$HOME`` folder directly after
checking it out into a working copy. To do this, make sure you are in the
folder in which the dotfiles reside (``~/.dotfiles`` on my systems;
``$DOTFILES`` for the remainder of this document) and then run ``make install``.
If you would want to use an alternate target location you'd have to set
the ``TGTDIR`` variable in one of two ways when invoking ``make``:

- ``TGTDIR=/my/custom/target/directory make install``
- ``make TGTDIR=/my/custom/target/directory install``

Local customizations
~~~~~~~~~~~~~~~~~~~~

To keep local customizations of the dotfiles you have ``~/.local/dotfiles``
at your disposal.

This folder contains the settings which override the global ones or get
appended (on a per-file basis) to the respective global settings.

The structure of this folder is that there are three top-level subfolders:

* ``append``
* ``custom``
* ``override``

Underneath ``append`` and ``override`` there will be a moniker for each
respective machine in the form of a directory or a symlink to a directory.

The moniker is either ``_.domain.tld``, i.e. leading underscore followed by
the domain part that would be returned by ``hostname -f`` or the short name
of the host, i.e. without any dots.

If the moniker exists as short name, it will take precedence.

Files in ``~/.local/dotfiles/override`` will *always* be written to ``TGTDIR``.
Files in ``~/.local/dotfiles/append`` will only be written if they already
exist in ``TGTDIR``.

Files that have already been appended will carry a marker as their last line.

**NOTE** this is a limitation. The marker will be a line starting with a hash
mark. That is ``#``. This creates a single-line comment in most configuration
files. However, where this is not true you *have* to use one of the other two
mechanisms for customization.

The ``~/.local/dotfiles/custom`` *differs* in that it contains any or none of
the following items:

* an executable file named ``PRE`` that will always be executed if it exists
  and passed the appropriate ``TGTDIR`` environment variable.
  It gets executed _prior_ to other customizations (such as ``append`` and
  ``override``).
* an executable file named ``ALL`` that will always be executed if it exists
  and passed the appropriate ``TGTDIR`` environment variable.
* an executable file named ``$(whoami)@$(hostname -s)`` (``user@hostname``)
  takes precedence over an executable file named ``$(hostname -f)`` (just the
  ``hostname``).
    - **NB:** the ``ALL`` script gets executed unconditionally and before all
      other scripts, if it exists.
    - If neither ``$(whoami)@$(hostname -s)`` nor ``$(hostname -f)`` existed
      (or if neither was executable), a script named after the domain (see
      above; example ``_.domain.tld``) would also be taken into account.
* an executable file named ``POST`` that will always be executed if it exists
  and passed the appropriate ``TGTDIR`` environment variable.
  It gets executed _after_ all other customizations, including all the
  customization.

Testing without overwriting ``$HOME``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you simply want to test out what would be written, there are two special
targets in the make file: ``test`` and ``nodel-test``. Where ``nodel-test``
will more closely reproduce what would happen on subsequent runs of the ``install``
target, ``test`` will remove the target dir up front and create a fresh one.

Both targets will default to ``$HOME/dotfile-test`` for ``TGTDIR``.

Epilogue
--------

Hope this is useful for someone else. Write me an email if it is :)

.. _Bash Cookbook: http://bashcookbook.com/
.. _Practical Vim: http://pragprog.com/book/dnvim/practical-vim
.. _Hacking Vim: http://www.packtpub.com/hacking-vim-cookbook-get-most-out-latest-vim-editor/book
.. _vimcasts.org: http://vimcasts.org/
.. _dotfiles: https://github.com/nelstrom/dotfiles
