c.f. http://coldfix.de/2017/01/29/vpn-box/#configure-application-to-use-vpn-tunnel

Overview
========

Example for setting up a separate VPN adapter. Applications must be configured
individually to use the VPN interface.

Files::

    route-up-nopull.sh      The script that sets up the VPN.

    ovpn_example.conf       Example openvpn config. Not functional without the
                            certificate information files.

    pia.auth                Put your credentials here.

Preparations
============

Perform the following one-time setup:

.. code-block:: bash

    echo "10 vpn" >> /etc/iproute2/rt_tables

Usage
=====

Start VPN:

.. code-block:: bash

    openvpn --script-security 2 --route-noexec --route-up ./route-up-nopull.sh

Define an ``ifip`` function (for convenience):

.. code-block:: bash

    ifip() { ifconfig "$1" | grep 'inet ' | sed -r 's/^.*inet +([0123456789.]+).*$/\1/'; }

Start a particular application using the VPN:

.. code-block:: bash

    wget --bind-address="$(ifip tun0)" http://ipecho.net/plain -O - -q; echo


Warning
=======

DNS requests may go over the unencrypted connection.
