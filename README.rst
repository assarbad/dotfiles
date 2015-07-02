===================
 Oliver's dotfiles
===================
:Author: Oliver Schneider

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

You can also set the variable ``HARDLINK`` to some non-empty value in order to
have ``cp`` attempt to hardlink source and destination. If this fails it will
automatically fall back to default copy.

Another thing you can override is the variable ``HOSTNAME`` which can be used
to pretend that you are installing this on a particular host. Of course this is
mainly useful in conjunction with the ``machine-specific`` settings or those
that may reside in ``~/.local/dotfiles``. Machine-specific settings reside in
one of two places as far as ``make install`` is concerned:

- ``$DOTFILES/machine-specific`` (see the respective ``README.rst`` in that
  folder.
- ``$HOME/.local/dotfiles`` with a layout that mirrors the above one.

The intention of the latter is to allow for machine-specific settings that
will not accidentally end up in the public repository for my dotfiles.

For example a really harmless way to test what would get installed is to
designate a target directory, set a host name and then use the install target::

  #!/usr/bin/env bash
  make HOSTNAME=themachine test

This will default to ``$HOME/dotfile-test`` as ``TGTDIR``.

Hope this is useful for someone else. Write me an email if it is :)

.. _Bash Cookbook: http://bashcookbook.com/
.. _Practical Vim: http://pragprog.com/book/dnvim/practical-vim
.. _Hacking Vim: http://www.packtpub.com/hacking-vim-cookbook-get-most-out-latest-vim-editor/book
.. _vimcasts.org: http://vimcasts.org/
.. _dotfiles: https://github.com/nelstrom/dotfiles
