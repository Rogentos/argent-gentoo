# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
PYTHON_DEPEND="2"
inherit eutils python bash-completion-r1

DESCRIPTION="Entropy Package Manager server-side tools"
HOMEPAGE="http://www.sabayon.org"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="debug_grade_1 "

SRC_URI="mirror://sabayon/sys-apps/entropy-${PV}.tar.bz2"

S="${WORKDIR}/entropy-${PV}/server"

RDEPEND="~sys-apps/entropy-${PV}"
DEPEND="app-text/asciidoc"

src_compile() {
	emake || die "make failed"
}

src_install() {
     if use debug_grade_1 ; then
   set -ex
       fi
	emake DESTDIR="${D}" install || die "make install failed"
	newbashcomp "${S}/eit-completion.bash" eit
}

pkg_postinst() {
	python_mod_optimize "/usr/lib/entropy/server"
}

pkg_postrm() {
	python_mod_cleanup "/usr/lib/entropy/server"
}
