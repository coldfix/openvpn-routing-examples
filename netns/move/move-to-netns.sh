#! /bin/sh

up() {
    # create network namespace
    ip netns add vpn || true

    # bring up loop device
    ip netns exec vpn ip link set dev lo up

    # move VPN tunnel to netns
    ip link set dev "$1" up netns vpn mtu "$2"

    # configure tunnel in netns
    ip netns exec vpn ip addr add dev "$1" \
            "$4/${ifconfig_netmask:-30}" \
            ${ifconfig_broadcast:+broadcast "$ifconfig_broadcast"}
    if [ -n "$ifconfig_ipv6_local" ]; then
            ip netns exec vpn ip addr add dev "$1" \
                    "$ifconfig_ipv6_local"/112
    fi

    # set route in netns
    ip netns exec vpn ip route add default via "$route_vpn_gateway"
}

down() { true; }

"$script_type" "$@"

# update DNS servers in netns
if [ -x ./update-resolv-conf ]; then
    ip netns exec vpn ./update-resolv-conf "$@"
fi
