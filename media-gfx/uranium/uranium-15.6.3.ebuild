# Copytight 2015 Cor Legemaat
# Distributed under the term of the GNU General Public License v3

EAPI="5"
PYTHON_COMPAT=( python3_4 )

inherit cmake-utils eutils python-single-r1

MY_PN="Uranium"
MY_PV="15.06.03"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="A Python framework for building Desktop applications."
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
	dev-qt/qtquickcontrols:5
	<dev-python/PyQt5-5.5[${PYTHON_USEDEP},declarative,network,gui,gles2]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	dev-libs/protobuf:0/10[${PYTHON_USEDEP}]
	=dev-libs/libarcus-${PV}[${PYTHON_USEDEP}]
"

pkg_setup () {
	python-single-r1_pkg_setup
}

src_prepare () {
	sed -i -e "s:install(DIRECTORY\ UM\ DESTINATION\ lib/python\${PYTHON_VERSION_MAJOR}/dist-packages):install(DIRECTORY\ UM\ DESTINATION\ lib/python\${PYTHON_VERSION_MAJOR}.\${PYTHON_VERSION_MINOR}/site-packages):" CMakeLists.txt || die "Sed faild."
	epatch_user
}
