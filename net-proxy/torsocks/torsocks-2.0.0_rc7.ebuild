# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit autotools eutils multilib versionator

MY_PV="$(replace_version_separator 3 -)"
MY_PF="${PN}-${MY_PV}"
S="${WORKDIR}/${MY_PF}"

DESCRIPTION="Use most socks-friendly applications with Tor."
HOMEPAGE="http://github.com/dgoulet/torsocks"
SRC_URI="https://github.com/dgoulet/torsocks/archive/v${MY_PV}.tar.gz -> ${MY_PF}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs"

# We do not depend on tor which might be running on a different box
DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf $(use_enable static-libs static)
}

src_install() {
	default

	dodoc ChangeLog TODO doc/notes/DEBUG doc/socks/{SOCKS5,socks-extensions.txt}

	#Remove libtool .la files
	cd "${D}"/usr/$(get_libdir)/torsocks
	rm -f *.la
}
