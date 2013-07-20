# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils multilib python

DESCRIPTION="Disper is an on-the-fly display switch utility"
HOMEPAGE="http://willem.engen.nl/projects/disper/"
SRC_URI="http://ppa.launchpad.net/wvengen/ppa/ubuntu/pool/main/d/${PN}/${PN}_${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug_grade_1 "

DEPEND="dev-lang/python"
RDEPEND="${DEPEND}"

S="${WORKDIR}/trunk"

src_install() {
     if use debug_grade_1 ; then
   set -ex
       fi
	emake DESTDIR="${D}" install || die "make install failed."
	doman "${PN}.1"
	dodoc README
}

