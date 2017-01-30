c.f. http://coldfix.de/2017/01/29/vpn-box/#recommended-solution

Overview
========

Example for moving your VPN adapter to a linux `network namespace`_.

.. _network namespace: https://lwn.net/Articles/580893/

Files::

    move-to-netns.sh        The script that moves the VPN interface to the
                            network namespace.

    update-resolv-conf      Script to update DNS information.

    ovpn_example.conf       Example openvpn config. Not functional without the
                            certificate information files.

    pia.auth                Put your credentials here.

Usage
=====

Establish VPN connection:

.. code-block:: bash

    sudo openvpn --ifconfig-noexec --route-noexec --script-security 2 \
                 --up move-to-netns.sh --down move-to-netns.sh

Start a command inside the VPN network namespace:

.. code-block:: bash

    sudo ip netns exec vpn sudo -u "$(whoami)" -- wget http://ipecho.net/plain -O - -q; echo
    sudo ip netns exec vpn sudo -u "$(whoami)" -- ping google.com


Tweaks
======

vpnbox command
--------------

Shortcut:

.. code-block:: bash
    :caption: /usr/local/bin/vpnbox

    #! /bin/sh
    sudo ip netns exec vpn sudo -u "$(whoami)" -- "$@"

Command completion:

.. code-block:: bash
    :caption: ~/.zshrc

    compdef _precommand vpnbox

password
--------

Execute ``sudo visudo`` and add the following to allow starting programs in
the netns without having to enter a password:

.. code-block:: bash
    :caption: /etc/sudoers

    # put this near the end of the file:
    alice ALL=(ALL:ALL) NOPASSWD: /usr/bin/ip netns exec vpn sudo -u alice -- *

firefox
-------

First setup a new profile called *vpn* using ``firefox -p``.

Then add a command like this to start the profile in a tunneled instance:

.. code-block:: bash
    :caption: /usr/local/bin/foxtunnel

    #! /bin/sh
    vpnbox firefox -P vpn --no-remote --private-window "${1-http://ipecho.net/plain}"
