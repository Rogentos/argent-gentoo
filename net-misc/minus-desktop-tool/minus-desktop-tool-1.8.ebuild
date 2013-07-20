# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit unpacker

DESCRIPTION="Allows to drag-n-drop documents into the taskbar and upload onto Minus"
HOMEPAGE="https://minus.com/pages/tools"
SRC_URI="http://blog.minus.com/updates/${PN}_${ARCH}.deb -> ${P}_${ARCH}.deb"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug_grade_1 "

RDEPEND="x11-libs/qt-core
	dev-libs/qjson
	"
DEPEND=""

S="${WORKDIR}"

src_install() {
     if use debug_grade_1 ; then
   set -ex
       fi

	dobin "${S}/usr/bin/minus"
}
