#!/bin/sh
# Copyright 2022 Grant Nichol

get_connected_list() {
    for interface in $(iwinfo | grep ESSID | cut -f 1 -s -d" ")
    do
        iwinfo $interface assoclist | grep dBm | cut -f 1 -s -d" "
    done
}

presence_list=
broker_host=
broker_port=
broker_id=
broker_interval=

add_presence() {
    name="$1"
    topic="$2"
    mac="$3"

    mac="$( echo "$mac" | tr [:lower:] [:upper:])"

    presence_list="${presence_list} ${name}"
    eval "PRESENCE_${name}_topic=\"${topic}\""
    eval "PRESENCE_${name}_mac=\"${mac}\""
}

process_presence() {
    name="$1"
    connected_list="$2"

    eval "mac=\"\$PRESENCE_${name}_mac\""
    eval "topic=\"\$PRESENCE_${name}_topic\""

    for connected in $connected_list; do
        if [ $connected = $mac ]; then
            mosquitto_pub -i "$broker_id" -h "$broker_host" -p "$broker_port" -t "$topic" -m "home"
            return 0
        fi
    done

    mosquitto_pub -i "$broker_id" -h "$broker_host" -p "$broker_port" -t "$topic" -m "not_home"
    return 1
}

main () {
    config_file="$1"
    if [ ! -r "$config_file" ]; then
        echo "Unable to read from ${config_file}!" >&2
        exit 1
    fi

    . ./"$config_file"

    if [ -z "$broker_host" ] || [ -z "$broker_port" ] || [ -z "$broker_id" ] || [ -z "$broker_interval" ]; then
        echo "Error: Config missing one of \"broker_host\", \"broker_port\", \"broker_id\", or \"broker_interval\"" >&2
        exit 1
    fi

    if [ -z "$presence_list" ]; then
        echo "Warning: There are no devices configured for presence detection" >&2
    fi

    while true; do
        connected_macs="$(get_connected_list)"

        for presence in $presence_list; do
            process_presence "$presence" "$connected_macs"
        done

        sleep "$broker_interval"
    done
}

main $@

