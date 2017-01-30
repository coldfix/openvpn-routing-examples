#! /bin/bash

# NOTE: If you have iptable rules, do NOT blindly do any of the following.
# You must take care manually that the rule sets do not interfere.

up() {
    # Enable forwarding, see:
    # https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt
    echo 1 > /proc/sys/net/ipv4/ip_forward
    for f in /proc/sys/net/ipv4/conf/*/rp_filter; do
        echo 2 > $f
    done;

    # Avoid duplicate rules and emphasize that we are probably not compatible
    # with other iptable rules:
    false && delete_rules
    # Just kidding, we are not actually doing this. This would temporarily
    # disable rules for already running programs.

    # Mark packets coming from the vpn group
    iptables -t mangle -A OUTPUT -m owner --gid-owner vpn -j MARK --set-mark 42

    # Apply the VPN IP address on outgoing packages
    iptables -t nat -A POSTROUTING -o "$dev" -m mark --mark 42 -j MASQUERADE

    # Route marked packets via VPN table
    ip rule add fwmark 42 table vpn

    #----------------------------------------
    # security measures against leaking traffic on other interfaces:
    #----------------------------------------

    # If the routing table contains no routes, the next matching table can be
    # used - which can result in packages being routed over other interfaces.
    # To prevent this from happening, add a dummy entry that will keep the
    # table alive before its default route is setup and after it goes down:
    ip route add unreachable 0.0.0.0/32 table vpn

    # Fallback measures in case the above is insufficient: establish iptables
    # rules that will prevent traffic going on other interfaces:
    iptables -t mangle -A POSTROUTING -m mark --mark 42 -o lo     -j RETURN
    iptables -t mangle -A POSTROUTING -m mark --mark 42 -o "$dev" -j RETURN
    iptables -t mangle -A POSTROUTING -m mark --mark 42           -j DROP
}

route-up() {
    ip route add default via "$route_vpn_gateway" dev "$dev" table vpn
}

down() {
    # NOTE: do not delete the ip/iptables rules to decrease the likelihood of
    # data leaks
    true;
}

# This is how you can clear the rules, if you want to. This will not be
# executed automatically.
delete_rules() {
    iptables -t mangle -F OUTPUT
    iptables -t mangle -F POSTROUTING
    iptables -t nat    -F POSTROUTING
    ip rule del fwmark 42 table vpn
    ip route del 0.0.0.0 table vpn
    ip route del default table vpn
}

"$script_type" "$@"

# update DNS servers
if [ -x /etc/openvpn/update-resolv-conf ]; then
    /etc/openvpn/update-resolv-conf "$@"
fi
