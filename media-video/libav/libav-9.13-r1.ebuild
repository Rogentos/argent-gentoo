# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

if [[ ${PV} == *9999 ]] ; then
	SCM="git-2"
	EGIT_REPO_URI="git://git.libav.org/libav.git"
	[[ ${PV%9999} != "" ]] && EGIT_BRANCH="release/${PV%.9999}"
fi

inherit eutils flag-o-matic multilib toolchain-funcs ${SCM} multilib-minimal

DESCRIPTION="Complete solution to record, convert and stream audio and video."
HOMEPAGE="http://libav.org/"
if [[ ${PV} == *9999 ]] ; then
	SRC_URI=""
elif [[ ${PV%_p*} != ${PV} ]] ; then # Gentoo snapshot
	SRC_URI="http://dev.gentoo.org/~lu_zero/libav/${P}.tar.xz"
else # Official release
	SRC_URI="http://${PN}.org/releases/${P}.tar.xz"
fi

LICENSE="LGPL-2.1  gpl? ( GPL-3 )"
SLOT="0/9"

# Don't move KEYWORDS on the previous line or ekeyword won't work # 399061
[[ ${PV} == *9999 ]] || \
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"

IUSE="aac alsa amr bindist +bzip2 cdio cpudetection custom-cflags debug doc
	+encode faac fdk frei0r +gpl gsm +hardcoded-tables ieee1394 jack jpeg2k mp3
	network openssl opus oss pic pulseaudio rtmp schroedinger sdl speex ssl
	static-libs theora threads tools truetype v4l vaapi vdpau vorbis vpx X
	x264 xvid +zlib"

# String for CPU features in the useflag[:configure_option] form
# if :configure_option isn't set, it will use 'useflag' as configure option
CPU_FEATURES="3dnow:amd3dnow 3dnowext:amd3dnowext altivec avx mmx mmxext neon ssse3 vis"
for i in ${CPU_FEATURES} ; do
	IUSE+=" ${i%:*}"
done

TOOLS="aviocat graph2dot ismindex pktdumper qt-faststart trasher"

RDEPEND="
	!media-video/ffmpeg:0
	alsa? ( media-libs/alsa-lib[${MULTILIB_USEDEP}] )
	amr? ( media-libs/opencore-amr[${MULTILIB_USEDEP}] )
	bzip2? ( app-arch/bzip2[${MULTILIB_USEDEP}] )
	cdio? (
		|| (
			dev-libs/libcdio-paranoia[${MULTILIB_USEDEP}]
			<dev-libs/libcdio-0.90[-minimal,${MULTILIB_USEDEP}]
		)
	)
	encode? (
		aac? ( media-libs/vo-aacenc[${MULTILIB_USEDEP}] )
		amr? ( media-libs/vo-amrwbenc[${MULTILIB_USEDEP}] )
		faac? ( media-libs/faac[${MULTILIB_USEDEP}] )
		fdk? ( media-libs/fdk-aac[${MULTILIB_USEDEP}] )
		mp3? ( >=media-sound/lame-3.98.3[${MULTILIB_USEDEP}] )
		theora? (
			>=media-libs/libtheora-1.1.1[encode,${MULTILIB_USEDEP}]
			media-libs/libogg[${MULTILIB_USEDEP}]
		)
		vorbis? (
			media-libs/libvorbis[${MULTILIB_USEDEP}]
			media-libs/libogg[${MULTILIB_USEDEP}]
		)
		x264? ( >=media-libs/x264-0.0.20111017:=[${MULTILIB_USEDEP}] )
		xvid? ( >=media-libs/xvid-1.1.0[${MULTILIB_USEDEP}] )
	)
	frei0r? ( media-plugins/frei0r-plugins[${MULTILIB_USEDEP}] )
	gsm? ( >=media-sound/gsm-1.0.12-r1[${MULTILIB_USEDEP}] )
	ieee1394? (
		media-libs/libdc1394[${MULTILIB_USEDEP}]
		sys-libs/libraw1394[${MULTILIB_USEDEP}]
	)
	jack? ( media-sound/jack-audio-connection-kit[${MULTILIB_USEDEP}] )
	jpeg2k? ( >=media-libs/openjpeg-1.3-r2:0[${MULTILIB_USEDEP}] )
	opus? ( media-libs/opus[${MULTILIB_USEDEP}] )
	pulseaudio? ( media-sound/pulseaudio[${MULTILIB_USEDEP}] )
	rtmp? ( >=media-video/rtmpdump-2.2f[${MULTILIB_USEDEP}] )
	ssl? (
		openssl? ( dev-libs/openssl[${MULTILIB_USEDEP}] )
		!openssl? ( net-libs/gnutls[${MULTILIB_USEDEP}] )
	)
	sdl? ( >=media-libs/libsdl-1.2.13-r1[sound,video,${MULTILIB_USEDEP}] )
	schroedinger? ( media-libs/schroedinger[${MULTILIB_USEDEP}] )
	speex? ( >=media-libs/speex-1.2_beta3[${MULTILIB_USEDEP}] )
	truetype? ( media-libs/freetype:2[${MULTILIB_USEDEP}] )
	vaapi? ( x11-libs/libva[${MULTILIB_USEDEP}] )
	vdpau? ( x11-libs/libvdpau[${MULTILIB_USEDEP}] )
	vpx? ( >=media-libs/libvpx-0.9.6[${MULTILIB_USEDEP}] )
	X? (
		x11-libs/libX11[${MULTILIB_USEDEP}]
		x11-libs/libXext[${MULTILIB_USEDEP}]
		x11-libs/libXfixes[${MULTILIB_USEDEP}]
	)
	zlib? ( sys-libs/zlib[${MULTILIB_USEDEP}] )
	abi_x86_32? (
		!<=app-emulation/emul-linux-x86-medialibs-20130224-r11
		!app-emulation/emul-linux-x86-medialibs[-abi_x86_32(-)]
	)"

DEPEND="${RDEPEND}
	>=sys-devel/make-3.81
	doc? ( app-text/texi2html )
	ieee1394? ( virtual/pkgconfig )
	mmx? ( dev-lang/yasm )
	rtmp? ( virtual/pkgconfig )
	schroedinger? ( virtual/pkgconfig )
	ssl? ( virtual/pkgconfig )
	truetype? ( virtual/pkgconfig )
	v4l? ( sys-kernel/linux-headers )
"

# faac can't be binary distributed
# openssl support marked as nonfree
# faac and aac are concurent implementations
# amr and aac require at least lgpl3
# x264 requires gpl2
REQUIRED_USE="bindist? ( !faac !openssl !fdk )
	rtmp? ( network )
	amr? ( gpl ) aac? ( gpl ) x264? ( gpl ) X? ( gpl ) cdio? ( gpl )
"

src_prepare() {
	# if we have snapshot then we need to hardcode the version
	if [[ ${PV%_p*} != ${PV} ]]; then
		sed -i -e "s/UNKNOWN/DATE-${PV#*_pre}/" "${S}/version.sh" || die
	fi
}

multilib_src_configure() {
	local myconf="${EXTRA_LIBAV_CONF}"
	local uses i

	use zlib && TOOLS+=" cws2fws"

	myconf+="
		$(use_enable gpl)
		$(use_enable gpl version3)
		--enable-avfilter
	"

	# enabled by default
	uses="debug doc network zlib"
	for i in ${uses}; do
		use ${i} || myconf+=" --disable-${i}"
	done
	use bzip2 || myconf+=" --disable-bzlib"
	use sdl || myconf+=" --disable-avplay"

	if use ssl; then
		use openssl && myconf+=" --enable-openssl --enable-nonfree" \
			|| myconf+=" --enable-gnutls"
	fi

	use custom-cflags && myconf+=" --disable-optimizations"
	use cpudetection && myconf+=" --enable-runtime-cpudetect"

	use vdpau || myconf+=" --disable-vdpau"

	use vaapi && myconf+=" --enable-vaapi"

	# Encoders
	if use encode; then
		use faac && myconf+=" --enable-nonfree"
		use fdk && myconf+=" --enable-nonfree --enable-libfdk-aac"
		use mp3 && myconf+=" --enable-libmp3lame"
		use amr && myconf+=" --enable-libvo-amrwbenc"
		use aac && myconf+=" --enable-libvo-aacenc"
		uses="faac theora vorbis x264 xvid"
		for i in ${uses}; do
			use ${i} && myconf+=" --enable-lib${i}"
		done
	else
		myconf+=" --disable-encoders"
	fi

	# libavdevice options
	use cdio && myconf+=" --enable-libcdio"
	use ieee1394 && myconf+=" --enable-libdc1394"
	use pulseaudio && myconf+=" --enable-libpulse"

	# Indevs
	# v4l1 is gone since linux-headers-2.6.38
	myconf+=" --disable-indev=v4l"
	use v4l || myconf+=" --disable-indev=v4l2"
	for i in alsa oss jack; do
		use ${i} || myconf+=" --disable-indev=${i}"
	done
	use X && myconf+=" --enable-x11grab"
	# Outdevs
	for i in alsa oss ; do
		use ${i} || myconf+=" --disable-outdev=${i}"
	done
	# libavfilter options
	use frei0r && myconf+=" --enable-frei0r"
	use truetype &&  myconf+=" --enable-libfreetype"

	# Threads; we only support pthread for now
	use threads && myconf+=" --enable-pthreads"

	# Decoders
	use amr && myconf+=" --enable-libopencore-amrwb --enable-libopencore-amrnb"
	uses="gsm opus rtmp schroedinger speex vpx"
	for i in ${uses}; do
		use ${i} && myconf+=" --enable-lib${i}"
	done
	use jpeg2k && myconf+=" --enable-libopenjpeg"

	# CPU features
	for i in ${CPU_FEATURES}; do
		use ${i%:*} || myconf+=" --disable-${i#*:}"
	done

	# pass the right -mfpu as extra
	use neon && myconf+=" --extra-cflags=-mfpu=neon"

	# disable mmx accelerated code if PIC is required
	# as the provided asm decidedly is not PIC for x86.
	# also disable asm for x32.
	case ${ABI} in
	x86*)
		use pic && myconf+=" --disable-mmx --disable-mmxext"
	;;
	x32)
		myconf+=" --disable-asm"
	;;
	esac

	# Option to force building pic
	use pic && myconf+=" --enable-pic"

	# cross compile support
	if tc-is-cross-compiler ; then
		myconf+=" --enable-cross-compile --arch=$(tc-arch-kernel) --cross-prefix=${CHOST}-"
		case ${CHOST} in
			*freebsd*)
				myconf+=" --target-os=freebsd"
				;;
			mingw32*)
				myconf+=" --target-os=mingw32"
				;;
			*linux*)
				myconf+=" --target-os=linux"
				;;
		esac
	fi

	# Misc stuff
	use hardcoded-tables && myconf+=" --enable-hardcoded-tables"

	# Specific workarounds for too-few-registers arch...
	if [[ $(tc-arch) == "x86" ]]; then
		filter-flags -fforce-addr -momit-leaf-frame-pointer
		append-flags -fomit-frame-pointer
		is-flag -O? || append-flags -O2
		if use debug; then
			# no need to warn about debug if not using debug flag
			ewarn ""
			ewarn "Debug information will be almost useless as the frame pointer is omitted."
			ewarn "This makes debugging harder, so crashes that has no fixed behavior are"
			ewarn "difficult to fix. Please have that in mind."
			ewarn ""
		fi
	fi

	"${S}"/configure \
		--prefix="${EPREFIX}"/usr \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--shlibdir="${EPREFIX}"/usr/$(get_libdir) \
		--mandir="${EPREFIX}"/usr/share/man \
		--enable-shared \
		--cc="$(tc-getCC)" \
		--ar="$(tc-getAR)" \
		--optflags="${CFLAGS}" \
		--extra-cflags="${CFLAGS}" \
		$(use_enable static-libs static) \
		${myconf} || die

	MAKEOPTS+=" V=1"
}

multilib_src_compile() {
	local i

	emake

	if use tools && multilib_build_binaries; then
		tc-export CC

		for i in ${TOOLS}; do
			emake tools/${i}
		done
	fi
}

multilib_src_install() {
	local i

	emake DESTDIR="${D}" install-libs install-headers
	if multilib_build_binaries; then
		emake DESTDIR="${D}" install install-man
		cd "${S}"
		dodoc Changelog README INSTALL
		dodoc doc/*.txt
		use doc && dodoc doc/*.html

		if use tools; then
			for i in ${TOOLS}; do
				dobin tools/${i}
			done
		fi
	fi
}
