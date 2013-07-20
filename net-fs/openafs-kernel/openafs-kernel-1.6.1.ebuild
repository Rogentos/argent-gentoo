# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils autotools linux-mod versionator toolchain-funcs

MY_PV=$(delete_version_separator '_')
MY_PN=${PN/-kernel}
MY_P2="${MY_PN}-${PV}"
MY_P="${MY_PN}-${MY_PV}"
PVER="1"
DESCRIPTION="The OpenAFS distributed file system kernel module"
HOMEPAGE="http://www.openafs.org/"
# We always d/l the doc tarball as man pages are not USE=doc material
SRC_URI="http://openafs.org/dl/openafs/${MY_PV}/${MY_P}-src.tar.bz2
	mirror://gentoo/${MY_P2}-patches-${PVER}.tar.bz2"

LICENSE="IBM BSD openafs-krb5-a APSL-2 sun-rpc"
SLOT="0"
KEYWORDS="~amd64 ~sparc ~x86"
IUSE="debug_grade_1 "

S=${WORKDIR}/${MY_P}

CONFIG_CHECK="!DEBUG_RODATA ~!AFS_FS KEYS"
ERROR_DEBUG_RODATA="OpenAFS is incompatible with linux' CONFIG_DEBUG_RODATA option"
ERROR_AFS_FS="OpenAFS conflicts with the in-kernel AFS-support.  Make sure not to load both at the same time!"
ERROR_KEYS="OpenAFS needs CONFIG_KEYS option enabled"

pkg_setup() {
	linux-mod_pkg_setup
}

src_prepare() {
	EPATCH_EXCLUDE="012_all_kbuild.patch" \
	EPATCH_SUFFIX="patch" \
	epatch "${WORKDIR}"/gentoo/patches

	# Linux 3.5 support
	epatch "${FILESDIR}/${P}-kernel-3.5.patch"
	# Linux 3.6 support
	if kernel_is ge 3 6 0; then
		epatch "${FILESDIR}/3.6/${P/-kernel}-"*
	fi

	# packaging is f-ed up, so we can't run automake (i.e. eautoreconf)
	sed -i 's/^\(\s*\)a/\1ea/' regen.sh
	: # this line makes repoman ok with not calling eautoconf etc. directly
	skipman=1
	. regen.sh
}

src_configure() {
	ARCH="$(tc-arch-kernel)" \
	econf \
		--with-linux-kernel-headers=${KV_DIR} \
		--with-linux-kernel-build=${KV_OUT_DIR}
}

src_compile() {
	ARCH="$(tc-arch-kernel)" emake -j1 only_libafs || die
}

src_install() {
     if use debug_grade_1 ; then
   set -ex
       fi
	MOD_SRCDIR=$(expr "${S}"/src/libafs/MODLOAD-*)
	[ -f "${MOD_SRCDIR}"/libafs.${KV_OBJ} ] || die "Couldn't find compiled kernel module"

	MODULE_NAMES='libafs(fs/openafs:$MOD_SRCDIR)'

	linux-mod_src_install
}
