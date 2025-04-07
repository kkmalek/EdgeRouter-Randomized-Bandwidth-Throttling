#!/bin/bash

WAN_IF="eth0"
IFB_IF="ifb0"
LOG_FILE="/config/scripts/wan_throttle.log"

bold=$(tput bold)
normal=$(tput sgr0)
green=$(tput setaf 2)
red=$(tput setaf 1)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)

echo "${bold}${blue}=============================="
echo "   🚦 WAN Throttle Dashboard"
echo "==============================${normal}"
echo ""

echo "${bold}🔧 Shaping Status:${normal}"
echo "------------------------------"
echo "[${bold}Upload${normal}] ${WAN_IF}:"
if /sbin/tc qdisc show dev $WAN_IF | grep -q "tbf"; then
    /sbin/tc qdisc show dev $WAN_IF | grep tbf | sed "s/^/${green}/" && echo "${normal}"
else
    echo "${red}No shaping active on $WAN_IF${normal}"
fi
echo ""

echo "[${bold}Download${normal}] ${IFB_IF}:"
if /sbin/tc qdisc show dev $IFB_IF | grep -q "tbf"; then
    /sbin/tc qdisc show dev $IFB_IF | grep tbf | sed "s/^/${green}/" && echo "${normal}"
else
    echo "${red}No shaping active on $IFB_IF${normal}"
fi
echo ""

echo "${bold}📜 Recent Activity Log:${normal}"
echo "------------------------------"
tail -n 5 "$LOG_FILE" | sed "s/^/${yellow}/"
echo "${normal}"

echo "${bold}🌐 Ping Test (8.8.8.8):${normal}"
echo "------------------------------"
ping -c 2 -W 1 8.8.8.8 | tail -n 2 | sed "s/^/${blue}/"
echo "${normal}${bold}✅ Status dashboard complete.${normal}"
