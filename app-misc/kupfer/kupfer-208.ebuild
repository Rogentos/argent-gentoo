# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
PYTHON_DEPEND="2:2.6"
inherit eutils fdo-mime gnome2-utils python waf-utils

DESCRIPTION="Kupfer, a convenient command and access tool"
HOMEPAGE="http://kaizer.se/wiki/kupfer/"

MY_P="${PN}-v${PV}"

SRC_URI="http://kaizer.se/publicfiles/${PN}/${MY_P}.tar.xz"

LICENSE="Apache-2.0 GPL-2 GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug_grade_1 +keybinder doc nautilus"

COMMON_DEPEND="dev-python/pygtk
	dev-python/pyxdg
	dev-python/dbus-python
	dev-python/libwnck-python
	dev-python/pycairo
	dev-python/pygobject:2
	dev-python/libgnome-python"
	# dev-python/gnome-keyring-python doesn't work well with Kupfer
	# dev-python/gnome-keyring-python
DEPEND="${COMMON_DEPEND}
	dev-python/docutils
	doc? ( app-text/gnome-doc-utils )
	dev-util/intltool"
RDEPEND="${COMMON_DEPEND}
	keybinder? ( dev-libs/keybinder[python] )
	nautilus? ( gnome-base/nautilus )"

S=${WORKDIR}/${MY_P}

src_prepare() {
	# don't try to fix them with sed
	# it will cause Kupfer doesn't bother importing gnomekeyring module
	# dev-python/gnome-keyring-python doesn't work well with Kupfer
	# sed -i "s/keyring/gnomekeyring/" wscript || die
	# sed -i "s/import keyring/import gnomekeyring as keyring/" \
	#	kupfer/plugin_support.py || \
	#	die "Error: src_prepare failed!"

	# recognise Xfce terminal installation in Gentoo
	epatch "${FILESDIR}/${PN}-206-xfce4-terminal.patch"
	if ! use doc; then
		sed -i -e 's/bld.env\["XML2PO"\]/False/' help/wscript || die
	fi
}

src_configure() {
	local myopts=""
	use nautilus || myopts="--no-install-nautilus-extension"
	waf-utils_src_configure --no-update-mime --nopyc $myopts || \
		die "Error: configure failed!"
}

src_install() {
     if use debug_grade_1 ; then
   set -ex
       fi
	waf-utils_src_install || die "Error: install failed!"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	python_mod_optimize /usr/share/${PN}
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	python_mod_cleanup /usr/share/${PN}
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}
