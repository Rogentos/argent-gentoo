# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit cmake-utils

DESCRIPTION="Qt4-based download/upload manager"
HOMEPAGE="http://fatrat.dolezel.info/"
SRC_URI="http://www.dolezel.info/download/data/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug_grade_1 bittorrent +curl -debug doc jabber nls webinterface"

RDEPEND="x11-libs/qt-gui:4[dbus]
	x11-libs/qt-svg:4
	bittorrent? ( >=net-libs/rb_libtorrent-0.14.1
				>=dev-cpp/asio-1.1.0
				x11-libs/qt-webkit:4 )
	curl? ( >=net-misc/curl-7.18.2 )
	doc? ( x11-libs/qt-assistant:4 )
	jabber? ( net-libs/gloox )
	webinterface? ( x11-libs/qt-script:4 )"
DEPEND=">=dev-util/cmake-2.6.0
		${RDEPEND}"

RESTRICT="mirror"

pkg_setup() {
	# this is a completely optional and NOT automagic dep
	# (it is dynamically loaded)
	if ! has_version dev-libs/geoip; then
		einfo "If you want the GeoIP support, then emerge dev-libs/geoip."
	fi
}

src_prepare() {
	sed -i -e 's/Proxy::Proxy Proxy::getProxy/Proxy Proxy::getProxy/' \
		src/Proxy.cpp || die
	sed -i -e "s/${PN}.png/${PN}/" -e "s/Application;//" \
		data/${PN}.desktop || die
}

src_configure() {
	use debug && CMAKE_BUILD_TYPE=Debug
	mycmakeargs=(
		$(cmake-utils_use_with bittorrent BITTORRENT)
		$(cmake-utils_use_with curl CURL)
		$(cmake-utils_use_with doc DOCUMENTATION)
		$(cmake-utils_use_with jabber JABBER)
		$(cmake-utils_use_with nls NLS)
		$(cmake-utils_use_with webinterface WEBINTERFACE)
	)
	cmake-utils_src_configure
}

src_install() {
     if use debug_grade_1 ; then
   set -ex
       fi
	use bittorrent \
		&& echo "MimeType=application/x-bittorrent;" \
		>> "${S}"/data/${PN}.desktop
	cmake-utils_src_install
}
