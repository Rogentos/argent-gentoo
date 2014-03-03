# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

KDE_HANDBOOK="never"
inherit kde4-base

DESCRIPTION="KDE library for mathematical features"
KEYWORDS=" ~amd64 ~arm ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux"
IUSE="debug readline"

DEPEND="
	readline? ( sys-libs/readline )
"
RDEPEND="${DEPEND}"

RESTRICT=test
# bug 443746

add_blocker kalgebra 4.7.50

PATCHES=(
	# See https://git.reviewboard.kde.org/r/111121/
	"${FILESDIR}/analitza-4.10-fix-compilation-armhf.patch"
)

src_configure() {
	mycmakeargs=(
		$(cmake-utils_use_with readline)
	)

	kde4-base_src_configure
}
