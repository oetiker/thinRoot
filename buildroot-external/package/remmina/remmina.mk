################################################################################
#
# remmina
#
################################################################################

REMMINA_VERSION = v1.3.10
REMMINA_SITE = https://gitlab.com/Remmina/Remmina/-/archive/$(REMMINA_VERSION)/Remmina-$(REMMINA_VERSION).tar.gz
REMMINA_LICENSE = GPLv2+ with OpenSSL exception
REMMINA_LICENSE_FILES = COPYING LICENSE LICENSE.OpenSSL

REMMINA_CONF_OPTS = \
	-DWITH_SSE2=ON \
	-DWITH_ICON_CACHE=ON \
	-DWITH_CUPS=OFF \
	-DWITH_SPICE=OFF \
	-DWITH_WAYLAND=OFF \
	-DWITH_PULSE=ON \
	-DWITH_AVAHI=OFF \
	-DWITH_APPINDICATOR=OFF \
	-DWITH_GNOMEKEYRING=OFF \
	-DWITH_TELEPATHY=OFF \
	-DWITH_GCRYPT=OFF \
	-DWITH_LIBSSH=OFF \
	-DWITH_VTE=OFF

REMMINA_DEPENDENCIES = \
	libgtk3 libvncserver freerdp \
	xlib_libX11 xlib_libXext xlib_libxkbfile

ifeq ($(BR2_NEEDS_GETTEXT),y)
REMMINA_DEPENDENCIES += gettext

define REMMINA_POST_PATCH_FIXINTL
	$(SED) 's/$${GTK_LIBRARIES}/$${GTK_LIBRARIES} -lintl/' \
		$(@D)/remmina/CMakeLists.txt
endef

REMMINA_POST_PATCH_HOOKS += REMMINA_POST_PATCH_FIXINTL
endif

$(eval $(cmake-package))