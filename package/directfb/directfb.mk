#############################################################
#
# directfb
#
#############################################################
DIRECTFB_VERSION_MAJOR = 1.4
DIRECTFB_VERSION = $(DIRECTFB_VERSION_MAJOR).16
DIRECTFB_SITE = http://www.directfb.org/downloads/Core/DirectFB-$(DIRECTFB_VERSION_MAJOR)
DIRECTFB_SOURCE = DirectFB-$(DIRECTFB_VERSION).tar.gz
DIRECTFB_AUTORECONF = YES
DIRECTFB_INSTALL_STAGING = YES
DIRECTFB_CONF_OPT = \
	--localstatedir=/var \
	--disable-explicit-deps \
	--enable-zlib \
	--enable-freetype \
	--enable-fbdev \
	--disable-sysfs \
	--disable-sdl \
	--disable-vnc \
	--disable-osx \
	--disable-video4linux \
	--disable-video4linux2 \
	--without-tools

DIRECTFB_DEPENDENCIES = freetype zlib

ifeq ($(BR2_PACKAGE_DIRECTFB_MULTI),y)
DIRECTFB_CONF_OPT += --enable-multi --enable-fusion
DIRECTFB_DEPENDENCIES += linux-fusion
endif

ifeq ($(BR2_PACKAGE_DIRECTFB_DEBUG),y)
DIRECTFB_CONF_OPT += --enable-debug
endif

ifeq ($(BR2_PACKAGE_DIRECTFB_TRACE),y)
DIRECTFB_CONF_OPT += --enable-trace
endif

ifeq ($(BR2_PACKAGE_XSERVER),y)
DIRECTFB_CONF_OPT += --enable-x11
else
DIRECTFB_CONF_OPT += -disable-x11
endif

ifeq ($(BR2_PACKAGE_DIRECTFB_UNIQUE),y)
DIRECTFB_CONF_OPT += --enable-unique
else
DIRECTFB_CONF_OPT += --disable-unique
endif

DIRECTFB_GFX := \
	$(if $(BR2_PACKAGE_DIRECTFB_ATI128),ati128) \
	$(if $(BR2_PACKAGE_DIRECTFB_CLE266),cle266) \
	$(if $(BR2_PACKAGE_DIRECTFB_CYBER5K),cyber5k) \
	$(if $(BR2_PACKAGE_DIRECTFB_MATROX),matrox) \
	$(if $(BR2_PACKAGE_DIRECTFB_PXA3XX),pxa3xx) \
	$(if $(BR2_PACKAGE_DIRECTFB_UNICHROME),unichrome) \
	$(if $(BR2_PACKAGE_DIRECTFB_I830),i830)	\
	$(if $(BR2_PACKAGE_DIRECTFB_EP9X),ep9x) \
	$(if $(BR2_PACKAGE_DIRECTFB_DAVINCI),davinci)

ifeq ($(strip $(DIRECTFB_GFX)),)
DIRECTFB_GFX:=none
else
DIRECTFB_GFX:=$(subst $(space),$(comma),$(strip $(DIRECTFB_GFX)))
endif

DIRECTFB_CONF_OPT += --with-gfxdrivers=$(DIRECTFB_GFX)

DIRECTFB_INPUT := \
	$(if $(BR2_PACKAGE_DIRECTFB_LINUXINPUT),linuxinput) \
	$(if $(BR2_PACKAGE_DIRECTFB_KEYBOARD),keyboard) \
	$(if $(BR2_PACKAGE_DIRECTFB_PS2MOUSE),ps2mouse) \
	$(if $(BR2_PACKAGE_DIRECTFB_SERIALMOUSE),serialmouse) \
	$(if $(BR2_PACKAGE_DIRECTFB_TSLIB),tslib)

ifeq ($(BR2_PACKAGE_DIRECTFB_TSLIB),y)
DIRECTFB_DEPENDENCIES += tslib
endif

ifeq ($(strip $(DIRECTFB_INPUT)),)
DIRECTFB_INPUT:=none
else
DIRECTFB_INPUT:=$(subst $(space),$(comma),$(strip $(DIRECTFB_INPUT)))
endif

DIRECTFB_CONF_OPT += --with-inputdrivers=$(DIRECTFB_INPUT)

ifeq ($(BR2_PACKAGE_DIRECTFB_GIF),y)
DIRECTFB_CONF_OPT += --enable-gif
else
DIRECTFB_CONF_OPT += --disable-gif
endif

ifeq ($(BR2_PACKAGE_DIRECTFB_PNG),y)
DIRECTFB_CONF_OPT += --enable-png
DIRECTFB_DEPENDENCIES += libpng
DIRECTFB_CONF_ENV += ac_cv_path_LIBPNG_CONFIG=$(STAGING_DIR)/usr/bin/libpng-config
else
DIRECTFB_CONF_OPT += --disable-png
endif

ifeq ($(BR2_PACKAGE_DIRECTFB_JPEG),y)
DIRECTFB_CONF_OPT += --enable-jpeg
DIRECTFB_DEPENDENCIES += jpeg
else
DIRECTFB_CONF_OPT += --disable-jpeg
endif

ifeq ($(BR2_PACKAGE_DIRECTB_DITHER_RGB16),y)
DIRECTFB_CONF_OPT += --with-dither-rgb16=advanced
else
DIRECTFB_CONF_OPT += --with-dither-rgb16=none
endif

ifeq ($(BR2_PACKAGE_DIRECTB_TESTS),y)
DIRECTFB_CONF_OPT += --with-tests
endif

HOST_DIRECTFB_DEPENDENCIES = host-pkg-config host-libpng
HOST_DIRECTFB_CONF_OPT = \
		--disable-debug \
		--disable-multi \
		--enable-png \
		--with-gfxdrivers=none \
		--with-inputdrivers=none

HOST_DIRECTFB_BUILD_CMDS = \
	$(MAKE) -C $(@D)/tools directfb-csource

HOST_DIRECTFB_INSTALL_CMDS = \
	$(INSTALL) -m 0755 $(@D)/tools/directfb-csource $(HOST_DIR)/usr/bin

define DIRECTFB_STAGING_CONFIG_FIXUP
	$(SED) "s,^prefix=.*,prefix=\'$(STAGING_DIR)/usr\',g" \
		-e "s,^exec_prefix=.*,exec_prefix=\'$(STAGING_DIR)/usr\',g" \
		$(STAGING_DIR)/usr/bin/directfb-config
endef

DIRECTFB_POST_INSTALL_STAGING_HOOKS += DIRECTFB_STAGING_CONFIG_FIXUP

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))

# directfb-csource for the host
DIRECTFB_HOST_BINARY:=$(HOST_DIR)/usr/bin/directfb-csource
