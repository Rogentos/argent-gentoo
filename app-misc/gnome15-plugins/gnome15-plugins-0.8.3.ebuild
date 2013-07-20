EAPI="3"
SUPPORT_PYTHON_ABIS="1"

DESCRIPTION="Provides a collection of GNOME specific plugins for Gnome15."
HOMEPAGE="http://www.gnome15.org/"
SRC_URI="http://www.gnome15.org/downloads/Gnome15/Optional/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="debug_grade_1 "

RDEPEND="app-misc/gnome15-core
		 dev-python/vobject
		 dev-python/evolution-python
		 dev-python/gnome-keyring-python"
DEPEND="${RDEPEND}"


src_install() {
     if use debug_grade_1 ; then
   set -ex
       fi
	emake DESTDIR="${D}" install || die "emake install failed"
}



