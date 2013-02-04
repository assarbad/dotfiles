===================
 Oliver's dotfiles
===================
:Author: Oliver Schneider

About
-----
This folder contains my dotfiles, i.e. all kinds of customized settings for
programs I use regularly, starting with the shell (Bash: .bashrc) and not
ending with my favorite editor (Vim: .vimrc).

Pick whatever you like. I have borrowed stuff here and there myself.

One shameless plug, however. I warmly recommend the following books:

- `Bash Cookbook`_ by Carl Albing, JP Vossen, Cameron Newham
- `Practical Vim`_ by Drew Neil (also check out his `vimcasts.org`_)
- `Hacking Vim`_ by Kim Schulz

The mysterious ``GNUmakefile``
------------------------------

You'll also find a ``GNUmakefile`` that can be used for two things.

The default behavior is to create a self-contained installer named
``dotfile_installer``, based on the script of the same basename with the
suffix ``.sh.in``. This installer will contain all the files from this
folder, including the ``.hg`` folder (this is intentional!).

This way you can simply build this file once and download from a location
you trust. Keep in mind that your web server may try to outsmart you, so
you may want to choose an extension such as ``.bin`` or give the MIME type
explicitly. This shouldn't matter in the default build, however, where
the created installer is ``uuencode``-d and thus should behave correctly
when downloaded as 7-bit ASCII.

.. _Bash Cookbook: http://bashcookbook.com/
.. _Practical Vim: http://pragprog.com/book/dnvim/practical-vim
.. _Hacking Vim: http://www.packtpub.com/hacking-vim-cookbook-get-most-out-latest-vim-editor/book
.. _vimcasts.org: http://vimcasts.org/
