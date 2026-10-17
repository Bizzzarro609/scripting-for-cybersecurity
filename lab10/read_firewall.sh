#!/bin/bash

COUNT_22=0
COUNT_80=0
COUNT_443=0

while read -r ACTION SRC ARROW DST; do

    if [ "$ACTION" = "BLOCK" ]; then
        PORT=${DST##*:}

        echo "$ACTION from $SRC to port $PORT"

        if [ "$PORT" = "22" ]; then
            COUNT_22=$((COUNT_22 + 1))
        elif [ "$PORT" = "80" ]; then
            COUNT_80=$((COUNT_80 + 1))
        elif [ "$PORT" = "443" ]; then
            COUNT_443=$((COUNT_443 + 1))
        fi
    fi

done < case/logs/firewall.log

echo "Blocked connections per port:"
echo "Port 22: $COUNT_22"
echo "Port 80: $COUNT_80"
echo "Port 443: $COUNT_443"
