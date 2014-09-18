# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
PYTHON_DEPEND="2:2.5"

inherit eutils python

DESCRIPTION="Parental control tool"
HOMEPAGE="http://projects.gnome.org/nanny/"
SRC_URI="http://ftp.gnome.org/pub/GNOME/sources/nanny/2.31/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="
	>=gnome-base/gnome-desktop-2.26.0
	gnome-base/libglade
	dev-python/gconf-python
	dev-python/hachoir-regex
	dev-python/libgtop-python
	dev-python/pycairo
	dev-python/pygtk
	dev-python/twisted-core
	dev-python/twisted-web
	media-libs/alsa-lib
	virtual/python-imaging"

DEPEND="${CDEPEND}
	app-text/gnome-doc-utils
	app-text/rarian
	virtual/pkgconfig"
RDEPEND="${CDEPEND}
	x11-libs/libgksu"

src_prepare() {
	epatch "${FILESDIR}/${P}-PIL.patch"
	sed -i 's/^Exec=/Exec=gksu /' \
		client/gnome/admin/data/nanny-admin-console.desktop.in \
		|| die "sed failed"
}

src_configure() {
	econf --with-init-scripts=None
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	newinitd "${FILESDIR}"/nanny.initd nanny || die "doinitd failed"
	doicon client/common/icons/48x48/nanny.png || die "doicon failed"
}

pkg_postinst() {
	echo
	elog "If you want this app to start automatically on boot, add it to the runlevel:"
	elog "# rc-update add nanny default"
	echo
	ewarn "This is development version, so not everything"
	ewarn "may work. Good luck."
}
