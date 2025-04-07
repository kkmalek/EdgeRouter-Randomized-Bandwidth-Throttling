#!/bin/bash

LOG_FILE="/config/scripts/wan_throttle.log"
SCRIPT_PATH="/config/scripts/wan_throttle.sh"
END_HOUR=6

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

echo "$(timestamp): [INFO] Random shaper started" >> $LOG_FILE

while true; do
    HOUR=$(date +%H)
    if [ "$HOUR" -ge "$END_HOUR" ]; then
        echo "$(timestamp): [INFO] Time reached $END_HOUR:00, disabling throttle and exiting." >> $LOG_FILE
        $SCRIPT_PATH --off
        exit 0
    fi

    ON_MIN=$((RANDOM % 76 + 15))
    echo "$(timestamp): [RANDOM] Turning ON for $ON_MIN minutes" >> $LOG_FILE
    $SCRIPT_PATH --on
    sleep "${ON_MIN}m"

    HOUR=$(date +%H)
    if [ "$HOUR" -ge "$END_HOUR" ]; then
        echo "$(timestamp): [INFO] Time reached $END_HOUR:00 during sleep, exiting." >> $LOG_FILE
        $SCRIPT_PATH --off
        exit 0
    fi

    OFF_MIN=$((RANDOM % 8 + 3))
    echo "$(timestamp): [RANDOM] Turning OFF for $OFF_MIN minutes" >> $LOG_FILE
    $SCRIPT_PATH --off
    sleep "${OFF_MIN}m"
done
