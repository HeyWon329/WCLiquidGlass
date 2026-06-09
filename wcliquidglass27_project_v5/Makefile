ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = WeChat
HEADERPAD_HEX ?= 0x40000
THEOS_PACKAGE_SCHEME ?= rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = wcliquidglass27
wcliquidglass27_FILES = Tweak.xm
wcliquidglass27_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-arc-performSelector-leaks
wcliquidglass27_FRAMEWORKS = UIKit Foundation QuartzCore CoreGraphics
wcliquidglass27_LDFLAGS += -Wl,-headerpad,$(HEADERPAD_HEX)

include $(THEOS_MAKE_PATH)/tweak.mk
