# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils

DESCRIPTION="Main Memory Relational Database Management System"
HOMEPAGE="http://www.garret.ru/fastdb.html"
# SRC_URI="http://www.garret.ru/${P}.tar.gz"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

DEPEND="sys-devel/bison
	sys-devel/flex
"
RDEPEND=""

S="${WORKDIR}/${PN}"

src_prepare() {
	edos2unix "${S}/configure"
}

src_install() {
	emake DESTDIR="${D}" install || die

	mv "${ED}"usr/bin/subsql "${ED}"usr/bin/subsql-fdb || die "mv failed"
	sed -i '/^#include "acconfig.h"/d' "${ED}"usr/include/${PN}/config.h \
		|| die "sed failed"
	#insinto /usr/include/${PN}
	#doins inc/acconfig.h
	dodoc CHANGES AUTHORS
	dohtml FastDB.htm
}

pkg_postinst() {
	elog "The subsql binary has been renamed to subsql-fdb,"
	elog "to avoid a name clash with the GigaBase version of subsql"
}
