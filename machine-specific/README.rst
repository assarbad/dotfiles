===========================
 Machine-specific settings
===========================
:Author: Oliver Schneider

``machine-specific`` folder
---------------------------
This folder contains the settings which override the global ones or get
appended (on a per-file basis) to the respective global settings.

Please mind the ``.hgignore`` file in the parent folder.

The structure of this folder is that there are two top-level subfolders:

* ``append``
* ``override``

Underneath will be the (short) hostname for each respective machine, followed
by a structure that resembles the structure of the ``$HOME`` directory on the
target machine.
