# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/openafs-kernel/openafs-kernel-1.6.2_pre3.ebuild,v 1.1 2013/01/26 17:37:57 vapier Exp $

EAPI="4"

inherit eutils autotools multilib linux-mod versionator toolchain-funcs

MY_PV=$(delete_version_separator '_')
MY_PN=${PN/-kernel}
MY_P2="${MY_PN}-${PV}_pre3"
MY_P="${MY_PN}-${MY_PV}"
PVER="1"
DESCRIPTION="The OpenAFS distributed file system kernel module"
HOMEPAGE="http://www.openafs.org/"
# We always d/l the doc tarball as man pages are not USE=doc material
SRC_URI="http://openafs.org/dl/${MY_PV}/${MY_P}-src.tar.bz2
	mirror://gentoo/${MY_P2}-patches-${PVER}.tar.bz2"

LICENSE="IBM BSD openafs-krb5-a APSL-2"
SLOT="0"
KEYWORDS="~amd64 ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

S=${WORKDIR}/${MY_P}

CONFIG_CHECK="~!AFS_FS KEYS"
ERROR_AFS_FS="OpenAFS conflicts with the in-kernel AFS-support.  Make sure not to load both at the same time!"
ERROR_KEYS="OpenAFS needs CONFIG_KEYS option enabled"

QA_TEXTRELS_x86_fbsd="/boot/modules/libafs.ko"
QA_TEXTRELS_amd64_fbsd="/boot/modules/libafs.ko"

pkg_setup() {
	if use kernel_linux; then
		linux-mod_pkg_setup
	fi
}

src_prepare() {
	EPATCH_EXCLUDE="012_all_kbuild.patch" \
	EPATCH_SUFFIX="patch" \
	epatch "${WORKDIR}"/gentoo/patches

	# Linux 3.8 support
	epatch "${FILESDIR}/${P}-linux-3.8-1.patch"
	epatch "${FILESDIR}/${P}-linux-3.8-2.patch"

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
	if use kernel_linux; then
		local srcdir=$(expr "${S}"/src/libafs/MODLOAD-*)
		[[ -f ${srcdir}/libafs.${KV_OBJ} ]] || die "Couldn't find compiled kernel module"

		MODULE_NAMES="libafs(fs/openafs:${srcdir})"

		linux-mod_src_install
	elif use kernel_FreeBSD; then
		insinto /boot/modules
		doins "${S}"/src/libafs/MODLOAD/libafs.ko
	fi
}

pkg_postinst() {
	# Update linker.hints file
	use kernel_FreeBSD && /usr/sbin/kldxref "${EPREFIX}/boot/modules"
	use linux_kernel && linux-mod_pkg_postinst
}

pkg_postrm() {
	# Update linker.hints file
	use kernel_FreeBSD && /usr/sbin/kldxref "${EPREFIX}/boot/modules"
	use linux_kernel && linux-mod_pkg_postrm
}
