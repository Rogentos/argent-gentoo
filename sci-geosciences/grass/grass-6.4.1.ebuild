# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-geosciences/grass/grass-6.4.1.ebuild,v 1.9 2011/11/15 04:05:27 nerdboy Exp $

EAPI=3

PYTHON_DEPEND="python? 2"

inherit eutils gnome2 multilib python versionator wxwidgets base

MY_PM=${PN}$(get_version_component_range 1-2 ${PV})
MY_PM=${MY_PM/.}
MY_P=${P/_rc/RC}

DESCRIPTION="A free GIS with raster and vector functionality, as well as 3D vizualization"
HOMEPAGE="http://grass.osgeo.org/"
SRC_URI="http://grass.osgeo.org/${MY_PM}/source/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="6"
KEYWORDS="amd64 ppc ~ppc64 x86"
IUSE="X cairo cxx ffmpeg fftw gmath jpeg motif mysql nls odbc opengl png postgres python readline sqlite tiff truetype wxwidgets"

TCL_DEPS="
	>=dev-lang/tcl-8.5
	>=dev-lang/tk-8.5"

RDEPEND="
	>=app-admin/eselect-1.2
	sci-libs/gdal
	sci-libs/proj
	sys-libs/gdbm
	sys-libs/ncurses
	sys-libs/zlib
	cairo? ( x11-libs/cairo[X?,opengl?] )
	ffmpeg? ( virtual/ffmpeg )
	fftw? ( sci-libs/fftw:3.0 )
	gmath? (
		virtual/blas
		virtual/lapack
	)
	jpeg? ( virtual/jpeg )
	mysql? ( virtual/mysql )
	odbc? ( dev-db/unixODBC )
	png? ( media-libs/libpng )
	postgres? ( >=dev-db/postgresql-base-8.4 )
	readline? ( sys-libs/readline )
	sqlite? ( dev-db/sqlite:3 )
	tiff? ( media-libs/tiff )
	truetype? ( media-libs/freetype:2 )
	X? (
		x11-libs/libICE
		x11-libs/libSM
		x11-libs/libX11
		x11-libs/libXaw
		x11-libs/libXext
		x11-libs/libXmu
		x11-libs/libXp
		x11-libs/libXpm
		x11-libs/libXt
		motif? (
			>=x11-libs/openmotif-2.3:0
			opengl? ( media-libs/mesa[motif] )
		)
		opengl? (
			virtual/opengl
			${TCL_DEPS}
		)
		python? ( wxwidgets? ( >=dev-python/wxpython-2.8.10.1[cairo,opengl?] ) )
		!python? ( ${TCL_DEPS} )
		!wxwidgets? ( ${TCL_DEPS} )
	)"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/flex
	sys-devel/gettext
	sys-devel/bison
	X? (
		x11-proto/xextproto
		x11-proto/xproto
		python? ( wxwidgets? ( dev-lang/swig ) )
	)"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}"/${PN}-pkgconf.patch
	"${FILESDIR}"/${P}-libpng15.patch
	"${FILESDIR}"/${P}-nopycompile.patch
	"${FILESDIR}"/${P}-timer_flags.patch
	"${FILESDIR}"/${P}-libav.patch
)

pkg_setup() {
	local myblas

	# check correct gmath profiles (this must sadly die)
	if use gmath; then
		for d in $(eselect lapack show); do myblas=${d}; done
		if [[ -z "${myblas/reference/}" ]] && [[ -z "${myblas/atlas/}" ]]; then
			ewarn "You need to set lapack to atlas or reference. Do:"
			ewarn "   eselect lapack set <impl>"
			ewarn "where <impl> is atlas, threaded-atlas or reference"
			die "setup failed"
		fi
		for d in $(eselect blas show); do myblas=${d}; done
		if [[ -z "${myblas/reference/}" ]] && [[ -z "${myblas/atlas/}" ]]; then
			ewarn "You need to set blas to atlas or reference. Do:"
			ewarn "   eselect blas set <impl>"
			ewarn "where <impl> is atlas, threaded-atlas or reference"
			die "setup failed"
		fi
	fi

	# check useflag nesting.
	use motif && ! use X && ewarn "For motif support X useflag must be enabled"
	use opengl && ! use X && ewarn "For opengl support X useflag must be enabled"
	use wxwidgets && ! use X && ewarn "For wxwidgets support X useflag must be enabled"
	use wxwidgets && ! use python && ewarn "For wxwidgets support python useflag must be enabled"

	if use python; then
		# only py2 is supported
		python_set_active_version 2
	fi
}

src_prepare() {
	use opengl || epatch "${FILESDIR}"/${PN}-6.4.0-html-nonviz.patch
	base_src_prepare
}

src_configure() {
	local myconf TCL_LIBDIR

	if use X; then
		TCL_LIBDIR="/usr/$(get_libdir)/tcl8.5"
		myconf+="
			--with-tcltk-libs=${TCL_LIBDIR}
			$(use_with motif)
			$(use_with opengl)
			--with-x
			"

		if use python && use wxwidgets; then
			WX_BUILD=yes
			WX_GTK_VER=2.8
			need-wxwidgets unicode
			myconf+="
				--without-tcltk
				--with-wxwidgets=${WX_CONFIG}
			"
		else
			WX_BUILD=no
			# use tcl gui if wxwidgets are disabled
			myconf+="
				--with-tcltk
				--without-wxwidgets
			"
		fi

		use opengl && myconf+=" --with-tcltk"
		use motif && use opengl && myconf+=" --with-glw"
		use motif || myconf+=" --without-glw"
	else
		myconf+="
			--without-opengl
			--without-glw
			--without-tcltk
			--without-wxwidgets
			--without-x
		"
	fi

	econf \
		--with-gdal=$(type -P gdal-config) \
		--with-curses \
		--with-proj \
		--with-proj-share="/usr/share/proj/" \
		--without-glw \
		--enable-shared \
		$(use_enable amd64 64bit) \
		$(use_enable ppc64 64bit) \
		$(use_with cairo) \
		$(use_with cxx) \
		$(use_with fftw) \
		$(use_with ffmpeg) \
		--with-ffmpeg-includes="/usr/include/libavcodec /usr/include/libavdevice /usr/include/libavfilter /usr/include/libavformat /usr/include/libavutil /usr/include/libpostproc /usr/include/libswscale" \
		$(use_with gmath blas) \
		$(use_with gmath lapack) \
		$(use_with jpeg) \
		$(use_with mysql) \
		--with-mysql-includes=/usr/include/mysql \
		--with-mysql-libs=/usr/$(get_libdir)/mysql \
		$(use_with nls) \
		$(use_with odbc) \
		$(use_with png) \
		$(use_with postgres) \
		$(use_with python) \
		$(use_with readline) \
		$(use_with sqlite) \
		$(use_with tiff) \
		$(use_with truetype freetype) \
		--with-freetype-includes="/usr/include/freetype2/" \
		--enable-largefile \
		${myconf}
}

src_compile() {
	# we don't want to link against embeded mysql lib
	base_src_compile MYSQLDLIB=""
}

src_install() {
	emake DESTDIR="${D}" \
		INST_DIR="${D}"/usr/${MY_PM} \
		prefix="${D}"/usr BINDIR="${D}"/usr/bin \
		PREFIX="${D}"/usr/ \
		install || die

	pushd "${D}"/usr/${MY_PM} &> /dev/null

	# fix docs
	dodoc AUTHORS CHANGES || die
	dohtml -r docs/html/* || die
	rm -rf docs/ || die
	rm -rf {AUTHORS,CHANGES,COPYING,GPL.TXT,REQUIREMENTS.html} || die

	# manuals
	dodir /usr/share/man/man1 || die
	mv man/man1/* "${D}"/usr/share/man/man1/ || die
	rm -rf man/ || die

	# translations
	if use nls; then
		dodir /usr/share/locale/ || die
		mv locale/* "${D}"/usr/share/locale/ || die
		rm -rf locale/ || die
		# pt_BR is broken
		mv "${D}"/usr/share/locale/pt_br "${D}"/usr/share/locale/pt_BR || die
	fi

	popd &> /dev/null

	# place libraries where they belong
	mv "${D}"/usr/${MY_PM}/lib/ "${D}"/usr/$(get_libdir)/ || die

	# place header files where they belong
	mv "${D}"/usr/${MY_PM}/include/ "${D}"/usr/include/ || die
	# make rules are not required on installed system
	rm -rf "${D}"/usr/include/Make || die

	# mv remaining gisbase stuff to libdir
	mv "${D}"/usr/${MY_PM} "${D}"/usr/$(get_libdir) || die

	# set proper default window renderer
	if [[ ${WX_BUILD} == yes ]]; then
		sed -i \
			-e "1,\$s:^DEFAULT_GUI.*:DEFAULT_GUI=\"wxpython\":" \
			"${D}"/usr/$(get_libdir)/${MY_PM}/etc/Init.sh || die
	fi

	# get proper folder for grass path in script
	sed -i \
		-e "1,\$s:^GISBASE.*:GISBASE=/usr/$(get_libdir)/${MY_PM}:" \
		"${D}"usr/bin/${MY_PM} || die

	# get proper fonts path for fontcap
	sed -i \
		-e "s|${D}/usr/${MY_PM}|/usr/$(get_libdir)/${MY_PM}|" \
		"${D}"/usr/$(get_libdir)/${MY_PM}/etc/fontcap || die

	if use X; then
		generate_files
		doicon gui/icons/${PN}-48x48.png || die
		domenu ${MY_PM}-grass.desktop || die
	fi

	# install .pc file so other apps know where to look for grass
	insinto /usr/$(get_libdir)/pkgconfig/
	doins grass.pc || die

	# fix weird +x on tcl scripts
	find "${D}" -name "*.tcl" -exec chmod +r-x '{}' \;
}

pkg_postinst() {
	if use X; then
		fdo-mime_desktop_database_update
		gnome2_icon_cache_update
	fi
}

pkg_postrm() {
	if use X; then
		fdo-mime_desktop_database_update
		gnome2_icon_cache_update
	fi
}

generate_files() {
	local GUI="-gui"
	[[ ${WX_BUILD} == yes ]] && GUI="-wxpython"

	cat <<-EOF > ${MY_PM}-grass.desktop
	[Desktop Entry]
	Encoding=UTF-8
	Version=1.0
	Name=Grass ${PV}
	Type=Application
	Comment=GRASS (Geographic Resources Analysis Support System), the original GIS.
	Exec=${TERM} -T Grass -e /usr/bin/${MY_PM} ${GUI}
	Path=
	Icon=${PN}-48x48.png
	Categories=Science;Education;
	Terminal=false
EOF
}
