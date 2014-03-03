# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
PYTHON_DEPEND="2:2.6"
SUPPORT_PYTHON_ABIS="1"

if [[ ${PV} = 9999 ]]; then
	LIVE_ECLASS="bzr"
	EBZR_REPO_URI="lp:${PN}"
else
	SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

inherit eutils ${LIVE_ECLASS} distutils
unset LIVE_ECLASS

DESCRIPTION="A Pandora Radio (pandora.com) player for the GNOME Desktop"
HOMEPAGE="http://kevinmehall.net/p/pithos/"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

DEPEND=">=dev-python/python-distutils-extra-2.10"

RDEPEND="dev-python/pyxdg
	dev-python/pygobject
	dev-python/notify-python
	dev-python/pygtk
	dev-python/gst-python:0.10
	dev-python/dbus-python
	media-libs/gst-plugins-good:0.10
	media-libs/gst-plugins-bad:0.10
	media-plugins/gst-plugins-faad:0.10
	media-plugins/gst-plugins-soup:0.10
	|| ( gnome-base/gnome-settings-daemon
		dev-libs/keybinder )
"

RESTRICT_PYTHON_ABIS="2.[45] 3.*"
DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"

src_prepare() {
	# hacky way to build when DISPLAY not set
	# https://bugs.launchpad.net/pithos/+bug/778522
	epatch "${FILESDIR}"/${P}-fix-build.patch
	distutils_src_prepare

	# bug #216009
	# avoid writing to /root/.gstreamer-0.10/registry.xml
	export GST_REGISTRY="${T}"/registry.xml
}

src_install() {
	distutils_src_install

	dosym  ../icons/hicolor/scalable/apps/${PN}.svg \
		/usr/share/pixmaps/${PN}.svg || die "dosym failed"
}
