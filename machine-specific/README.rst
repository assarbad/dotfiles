===========================
 Machine-specific settings
===========================
:Author: Oliver Schneider

``machine-specific`` folder
---------------------------
This folder contains the settings which override the global ones or get
appended (on a per-file basis) to the respective global settings.

Please mind the ``.hgignore`` file in the parent folder.

The structure of this folder is that there are three top-level subfolders:

* ``append``
* ``custom``
* ``override``

Underneath ``append`` and ``override`` there will be the (short) hostname for
each respective machine, inside of which a lives folder structure that
resembles the structure of the ``$HOME`` directory on the target machine.
There's one important aspect here. Only files that already exist in the global
settings will be considered from the ``append`` and ``override`` folders.

Inside of ``custom`` there will be scripts (must be executable!) named after
the (short) hostname of the target machine that will be run after the other
processing has finished. The special script ``ALL`` will be called right before
the machine-specific script, if it exists an is excutable.
The custom scripts should use the environment variable ``TGTDIR`` and fall back
to using ``HOME`` if the former isn't set.
