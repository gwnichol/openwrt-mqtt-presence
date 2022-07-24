# OepnWRT MQTT Device Tracker

This package allows the reporting device presence to be used in presence tracking by Home Assistant.

The purpose of this package is to allow device tracking without storing root credentials of the OpenWRT router in Home Assistant.

## Configuration

All configuration is to be done with uci

For instance, to track two devices on a specified MQTT broker:
```
config broker broker
    option host 127.0.0.1
    option port 1883
    option id openwrt_presence
    option interval 30

config presence person1
    option mac "6c:94:45:42:34:d3"
    option topic "presence/openwrt/person1"

config presence person2
    option mac "6c:94:45:42:34:04"
    option topic "presence/openwrt/person2"
```

A home assistant configuration for the same setup:
```
device_tracker:
  - platform: mqtt
    devices:
     person1: "presence/openwrt/person1"
     person2: "presence/openwrt/person2"
```

## Method

The list of connected wireless connections is obtained using `iwinfo` from the example at: https://openwrt.org/faq/how_to_get_a_list_of_connected_clients

