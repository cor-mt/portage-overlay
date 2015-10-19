# Copytight 2015 Cor Legemaat
# Distributed under the term of the GNU General Public License v3

EAPI="5"
PYTHON_COMPAT=( python{3_3,3_4} )

inherit cmake-utils eutils python-single-r1

MY_PN="libArcus"
MY_PV="15.06.03"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="A to facilitate the communication between Cura and its backend and similar code."
HOMEPAGE="https://github.com/Ultimaker/${MY_PN}"
SRC_URI="https://github.com/Ultimaker/${MY_PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
S="${WORKDIR}/${MY_P}"
 
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
DEPEND=""
RDEPEND="
	${PYTHON_DEPS}
	dev-libs/protobuf:3[${PYTHON_USEDEP}]
"

src_prepare () {
	sed -i -e "s:install(FILES\ python/Arcus/__init__.py\ DESTINATION\ lib/python\${PYTHON_VERSION_MAJOR}/dist-packages/Arcus):install(FILES\ python/Arcus/__init__.py\ DESTINATION\ lib/python\${PYTHON_VERSION_MAJOR}.\${PYTHON_VERSION_MINOR}/site-packages/Arcus):" CMakeLists.txt || die "Sed faild."
	epatch_user
}
