# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Rebootless Linux kernel security updates"
HOMEPAGE="http://www.ksplice.com/"
SRC_URI="http://www.ksplice.com/dist/${P}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug_grade_1 "

DEPEND="dev-lang/perl"
RDEPEND="${DEPEND}"

src_install() {
     if use debug_grade_1 ; then
   set -ex
       fi
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ChangeLog || die "dodoc failed"
}
