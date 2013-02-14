# Copyright 1999-2009 Sabayon linux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EGIT_COMMIT="c81cf5e289919f2f84cc0aacfb45ac5e97aecd59"
[[ "${PV}" = "9999" ]] && EGIT_COMMIT="master"
EGIT_REPO_URI="git://gitorious.org/itsme/${PN}.git"

inherit eutils cmake-utils git

DESCRIPTION="VFS based on FUSE and Tracker to allow access to files according to associated metadata"
HOMEPAGE="http://gitorious.org/itsme/fster"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="
	>=app-misc/tracker-0.8.1
	>=dev-libs/libxml2-2.7.4
	>=sys-fs/fuse-2.8.1"
DEPEND=">=dev-util/cmake-2.8.0 ${RDEPEND}"

src_unpack() {
	git_src_unpack
	cd "${S}"
	epatch "${FILESDIR}/fster-0.1-tracker-0.8.patch"
}
