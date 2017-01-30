c.f. http://coldfix.de/2017/01/29/vpn-box/#start-applications-with-dedicated-user-group

Overview
========

Example for setting up VPN such that it will affect only applications started
under a dedicated user group.

Files::

    setup-for-group.sh      The script that sets up the VPN.

    ovpn_example.conf       Example openvpn config. Not functional without the
                            certificate information files.

    pia.auth                Put your credentials here.

Preparations
============

Perform the following one-time setup:

.. code-block:: bash

    echo "10 vpn" >> /etc/iproute2/rt_tables

    groupadd vpn

Usage
=====

Start VPN:

.. code-block:: bash

    openvpn --script-security 2 --route-noexec \
            --up       ./setup-for-group.sh \
            --route-up ./setup-for-group.sh \
            --down     ./setup-for-group.sh

Start application that should be tunneled:

.. code-block:: bash

    sudo -g vpn -- wget http://ipecho.net/plain -O - -q; echo

Warning
=======

This method can leak traffic if for some reason the routing
table/iptable rules are ineffective, e.g.:

- some unforseen edge-case is not covered
- one or more of the rules is deleted (playing with your firewall?)
- other rules interfere
- before the rules are created

To emphasize: Before the rules are in effect there is no protection at all.
The implementation given here sets up the rules after starting the VPN rather
than at system boot, which means that programs will happily communicate over
the default interface until the VPN is first started.

In fact, it would be much better to setup all static rules (i.e. everything
done in the ``up()`` function except for the MASQUERADE rule) at system boot
time rather than when the VPN starts.
