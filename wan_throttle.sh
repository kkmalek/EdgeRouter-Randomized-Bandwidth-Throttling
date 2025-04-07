#!/bin/bash
# Usage: ./wan_throttle.sh --on  or ./wan_throttle.sh --off

LOG_FILE="/config/scripts/wan_throttle.log"
WAN_IF="eth0"
IFB_IF="ifb0"
TC="/sbin/tc"

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

enable_ifb() {
    modprobe ifb numifbs=1
    ip link set $IFB_IF up
}

throttle_on() {
    enable_ifb
    $TC qdisc del dev $WAN_IF root 2>/dev/null
    $TC qdisc add dev $WAN_IF root tbf rate 200kbit burst 15kb latency 70ms
    $TC qdisc del dev $WAN_IF ingress 2>/dev/null
    $TC qdisc add dev $WAN_IF handle ffff: ingress
    $TC filter add dev $WAN_IF parent ffff: protocol ip u32 match u32 0 0 action mirred egress redirect dev $IFB_IF
    $TC qdisc del dev $IFB_IF root 2>/dev/null
    $TC qdisc add dev $IFB_IF root tbf rate 200kbit burst 15kb latency 70ms
    echo "$(timestamp): [ENABLED] Bidirectional WAN bandwidth limited to 200kbps" >> $LOG_FILE
}

throttle_off() {
    $TC qdisc del dev $WAN_IF root 2>/dev/null
    $TC qdisc del dev $WAN_IF ingress 2>/dev/null
    $TC qdisc del dev $IFB_IF root 2>/dev/null
    echo "$(timestamp): [DISABLED] WAN bandwidth limit removed" >> $LOG_FILE
}

case "$1" in
    --on)
        throttle_on
        ;;
    --off)
        throttle_off
        ;;
    *)
        echo "Usage: $0 --on | --off"
        exit 1
        ;;
esac
