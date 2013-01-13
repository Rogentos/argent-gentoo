# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/subtitlecomposer/subtitlecomposer-0.5.3.ebuild,v 1.6 2011/02/02 05:22:33 tampakrap Exp $

EAPI=3

KDE_LINGUAS="bg cs de el es fr pl pt_BR sr"
inherit kde4-base

DESCRIPTION="Text-based subtitles editor."
HOMEPAGE="http://www.sourceforge.net/projects/subcomposer/"
SRC_URI="mirror://sourceforge/subcomposer/${P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="amd64 x86"
SLOT="4"
IUSE="debug gstreamer xine"

RDEPEND="
	gstreamer? ( media-libs/gstreamer )
	xine? ( media-libs/xine-lib )
"
DEPEND="${RDEPEND}
	sys-devel/gettext
"

src_prepare() {
	kde4-base_src_prepare

	# linkage issue
	epatch "${FILESDIR}/${PN}-linkage-patch.patch"
	epatch "${FILESDIR}/${P}-lX11.patch"
	epatch "${FILESDIR}"/${P}-gcc45.patch

	sed -e '/ADD_SUBDIRECTORY( api )/s/^/# DISABLED/' \
		-i src/main/scripting/examples/CMakeLists.txt \
		|| die "failed to disable installation of scripting API"
}

src_configure() {
	mycmakeargs=(
		$(cmake-utils_use_with gstreamer GStreamer)
		$(cmake-utils_use_with xine)
	)
	kde4-base_src_configure
}

pkg_postinst() {
	kde4-base_pkg_postinst

	echo
	elog "Some example scripts provided by ${PV} require dev-lang/ruby"
	elog "or dev-lang/python to be installed."
	echo
}
