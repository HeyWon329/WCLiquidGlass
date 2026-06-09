ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = WeChat
HEADERPAD_HEX ?= 0x40000

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = wclg27cleaner
wclg27cleaner_FILES = Tweak.xm
wclg27cleaner_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-arc-performSelector-leaks
wclg27cleaner_FRAMEWORKS = UIKit Foundation QuartzCore
wclg27cleaner_LDFLAGS += -Wl,-headerpad,$(HEADERPAD_HEX)

include $(THEOS_MAKE_PATH)/tweak.mk
