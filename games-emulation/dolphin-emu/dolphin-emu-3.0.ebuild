# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="3"

WX_GTK_VER="2.8"

inherit cmake-utils eutils flag-o-matic games git pax-utils wxwidgets

DESCRIPTION="Free. open source emulator for Nintendo GameCube and Wii"
HOMEPAGE="http://www.dolphin-emu.com/"
SRC_URI=""
EGIT_REPO_URI="https://code.google.com/p/dolphin-emu/"
EGIT_PROJECT="dolphin-emu"
EGIT_COMMIT="${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="alsa ao bluetooth doc -encode +lzo openal opengl portaudio pulseaudio +wxwidgets +xrandr"
RESTRICT=""

RDEPEND=">=media-libs/glew-1.5
	>=media-libs/libsdl-1.2[joystick]
	sys-libs/readline
	x11-libs/libXext
	ao? ( media-libs/libao )
	alsa? ( media-libs/alsa-lib )
	bluetooth? ( net-wireless/bluez )
	encode? ( virtual/ffmpeg[encode] )
	lzo? ( dev-libs/lzo )
	openal? ( media-libs/openal )
	opengl? ( virtual/opengl )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	wxwidgets? ( x11-libs/wxGTK:2.8 )
	xrandr? ( x11-libs/libXrandr )"
DEPEND="${RDEPEND}
	dev-util/cmake
	dev-util/pkgconfig
	media-gfx/nvidia-cg-toolkit"

src_prepare() {
	sed -i 	-e "s:check_lib(SFML:\#check_lib(SFML:" CMakeLists.txt || die "sed failed"
}

src_configure() {
	LDFLAGS=-L/opt/nvidia-cg-toolkit/lib
	# filter problematic compiler flags
	filter-flags -flto -fwhole-program
	append-flags -fno-pie

	mycmakeargs="
		-DDOLPHIN_WC_REVISION=${MY_PV}
		-DCMAKE_INSTALL_PREFIX=${GAMES_PREFIX}
		-Dprefix=${GAMES_PREFIX}
		-Ddatadir=${GAMES_DATADIR}/${PN}
		-Dplugindir=$(games_get_libdir)/${PN}
		-DCMAKE_INCLUDE_PATH=/opt/nvidia-cg-toolkit/include
		-DCMAKE_LIBRARY_PATH=/opt/nvidia-cg-toolkit/lib
		$(cmake-utils_use !wxwidgets DISABLE_WX)
		$(cmake-utils_use encode ENCODE_FRAMEDUMPS)"
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_make
}

src_install() {
	# copy files to target installation directory
	cmake-utils_src_install

	# set binary name
	local binary="${PN}"
	use wxwidgets || binary+="-nogui"

	# install documentation as appropriate
	cd "${S}"
	dodoc Readme.txt
	if use doc; then
		doins -r docs
	fi

	# create menu entry for GUI builds
	if use wxwidgets; then
		doicon Source/Core/DolphinWX/resources/Dolphin.xpm || die
		make_desktop_entry "${binary}" "Dolphin" "Dolphin" "Game;Emulator"
	fi

	prepgamesdirs
}

pkg_postinst() {
	# hardened fix
	pax-mark -m "${EPREFIX}/usr/games/bin/${PN}"

	echo
	if ! use portaudio; then
		ewarn "If you need to use your microphone for a game, rebuild with USE=portaudio"
		echo
	fi
	if ! use wxwidgets; then
		ewarn "Note: It is not currently possible to configure Dolphin without the GUI."
		ewarn "Rebuild with USE=wxwidgets to enable the GUI if needed."
		echo
	fi

	games_pkg_postinst
}
