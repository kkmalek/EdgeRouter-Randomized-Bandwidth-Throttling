#!/bin/bash
WAN_IF="eth0"
IFB_IF="ifb0"

echo "[eth0 status]"
/sbin/tc qdisc show dev $WAN_IF
echo
echo "[ifb0 status]"
/sbin/tc qdisc show dev $IFB_IF
