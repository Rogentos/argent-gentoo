# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit kde4-base

DESCRIPTION="MTP KIO-Client for KDE"
HOMEPAGE="https://projects.kde.org/projects/playground/base/kio-mtp"

LICENSE="GPL-2"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE="debug_grade_1 debug"

DEPEND="
	>=media-libs/libmtp-1.1.3
"
RDEPEND="
	${DEPEND}
"
