# Copyright (C) 2022 Grant Nichol

include $(TOPDIR)/rules.mk

PKG_NAME:=openwrt-mqtt-presence
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_MAINTAINER:=Grant Nichol <me@grantnichol.com>

include $(INCLUDE_DIR)/package.mk

define Package/openwrt-mqtt-presence
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=MQTT Presence Anouncements
	DEPENDS:=+mosquitto-client
endef

define Package/openwrt-mqtt-presence/description
 An OpenWRT presence announcer over MQTT for use in Home Assistant
endef

define Build/Compile
	true
endef

define Package/openwrt-mqtt-presence/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) mqtt_presence.sh	$(1)/usr/bin/mqtt_presence
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) init_mqtt_presence $(1)/etc/init.d/init_mqtt_presence
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) example_config.txt $(1)/etc/config/mqtt_presence
endef

$(eval $(call BuildPackage,openwrt-mqtt-presence))

