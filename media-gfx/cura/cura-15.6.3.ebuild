# Copytight 2015 Cor Legemaat
# Distributed under the term of the GNU General Public License v3

EAPI="5"
PYTHON_COMPAT=( python3_4 )

inherit cmake-utils eutils python-single-r1

MY_PN="Cura"
MY_PV="15.06.03"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="This is the new, shiny frontend for Cura."
HOMEPAGE="https://github.com/Ultimaker/${PY_PN}"
SRC_URI="https://github.com/Ultimaker/${MY_PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz https://github.com/Ultimaker/Uranium/archive/${MY_PV}.tar.gz -> uranium-${PV}.tar.gz"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="serial"
S="${WORKDIR}/${MY_P}"
 
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
DEPEND="dev-qt/linguist-tools:5"
RDEPEND="
	${PYTHON_DEPS}
	dev-libs/protobuf:0/10[${PYTHON_USEDEP}]
	dev-qt/qtwidgets:5
	dev-python/PyQt5[${PYTHON_USEDEP},widgets,gui]
	serial? ( dev-python/pyserial[${PYTHON_USEDEP}] )
	=media-gfx/uranium-${PV}
	=dev-libs/libarcus-${PV}[${PYTHON_USEDEP}]
"

src_prepare () {
	sed -i -e "s:set(URANIUM_SCRIPTS_DIR\ \"\${CMAKE_SOURCE_DIR}/../uranium/scripts\"\ CACHE\ DIRECTORY\ \"The\ location\ of\ the\ scripts\ directory\ of\ the\ Uranium\ repository\"):set(URANIUM_SCRIPTS_DIR\ \"\${CMAKE_SOURCE_DIR}/../Uranium-${MY_PV}/scripts\"\ CACHE\ DIRECTORY\ \"The\ location\ of\ the\ scripts\ directory\ of\ the\ Uranium\ repository\"):" CMakeLists.txt || die "Sed faild."
	sed -i -e "s:install(DIRECTORY\ cura\ DESTINATION\ lib/python\${PYTHON_VERSION_MAJOR}/dist-packages):install(DIRECTORY\ cura\ DESTINATION\ lib/python\${PYTHON_VERSION_MAJOR}.\${PYTHON_VERSION_MINOR}/site-packages):" CMakeLists.txt || die "Sed faild."
	sed -i -e "s:#\!/usr/bin/env\ python3:#\!/usr/bin/env\ python3.4:" \
		cura_app.py || die "Sed faild."
	epatch_user
}
