# Distributed under the terms of the GNU General Public License v3

EAPI=5
inherit linux-info xorg-2 eutils

DESCRIPTION="Generic Linux input driver"
KEYWORDS="~amd64 ~x86"
IUSE="debounce"

RDEPEND=">=x11-base/xorg-server-1.12[udev]
	dev-libs/libevdev
	sys-libs/mtdev"
DEPEND="${RDEPEND}
	>=x11-proto/inputproto-2.1.99.3
	>=sys-kernel/linux-headers-2.6"

#Patch from https://aur.archlinux.org/packages/xf86-input-evdev-debounce/
src_prepare() {
	if use debounce ; then
	   epatch "${FILESDIR}"/${P}-debounce.patch
	fi

	xorg-2_src_prepare
}

pkg_pretend() {
	if use kernel_linux ; then
		CONFIG_CHECK="~INPUT_EVDEV"
	fi
	check_extra_config
}

src_install() {
	# Install the debounce config.
	if use debounce ; then
	   insinto /etc/X11/xorg.conf.d/
	   newins "${FILESDIR}/debounce.conf" 11-evdev-mouse-debounce.conf
	fi

	xorg-2_src_install
}

pkg_postinst() {
	if use debounce ; then
	   elog "Edit /etc/X11/xorg.conf.d/11-evdev-mouse-debounce.conf for"
	   elog "the required debounce delay or rever to "
	   elog "http://lists.x.org/archives/xorg-devel/2012-August/033225.html"
	   elog "for details."
	fi

	xorg-2_pkg_postinst
}
