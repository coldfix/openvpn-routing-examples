#! /bin/sh
ip route add default via "$route_vpn_gateway" dev "$dev" table vpn
ip rule add from "$ifconfig_local"/32 table vpn
ip rule add to "$route_vpn_gateway"/32 table vpn
ip route flush cache
