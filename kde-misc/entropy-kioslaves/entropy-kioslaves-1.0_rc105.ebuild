# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
KDE_MINIMAL="4.2"
CMAKE_REQUIRED=never
inherit eutils kde4-base

DESCRIPTION="Entropy Package Manager KDE kioslaves support"
HOMEPAGE="http://www.sabayon.org"
LICENSE="GPL-2"

SLOT="4"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

SRC_URI="mirror://sabayon/sys-apps/entropy-${PV}.tar.bz2"

S="${WORKDIR}/entropy-${PV}"

RDEPEND="app-admin/sulfur"
DEPEND="${RDEPEND}"

src_prepare() {
	einfo "nothing to prepare"
}

src_configure() {
	einfo "nothing to configure"
}

src_compile() {
	einfo "nothing to compile"
}

src_install() {
	einfo "Nothing to install, please drop this pkg"
}

pkg_postinst() {
	kde4-base_pkg_postinst
}

pkg_postrm() {
	kde4-base_pkg_postrm
}
