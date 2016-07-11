# Copytight 2015 Cor Legemaat
# Distributed under the term of the GNU General Public License v3

EAPI="5"
PYTHON_COMPAT=( python{3_3,3_4} )

inherit cmake-utils eutils python-single-r1 git-r3

MY_PN="libArcus"
MY_PV="2.1.0"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="A to facilitate the communication between Cura and its backend and similar code."
HOMEPAGE="https://github.com/Ultimaker/${MY_PN}"
EGIT_REPO_URI="https://github.com/Ultimaker/libArcus.git"
EGIT_BRANCH="2.1"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
 
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
DEPEND=""
RDEPEND="
	${PYTHON_DEPS}
	dev-libs/protobuf:0/10b3[${PYTHON_USEDEP}]
"

src_prepare () {
	sed -i -e "s:set(PYTHON_SITE_PACKAGES_DIR\ lib/python3/dist-packages\ CACHE STRING\ \"Directory\ to\ install\ Python\ bindings\ to\"):set(PYTHON_SITE_PACKAGES_DIR\ lib/python3.4/site-packages/\ CACHE STRING \"Directory\ to\ install\ Python\ bindings\ to\"):" CMakeLists.txt || die "Sed faild."
	epatch_user
}
