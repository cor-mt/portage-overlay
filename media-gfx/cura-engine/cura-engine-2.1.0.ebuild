# Copytight 2015 Cor Legemaat
# Distributed under the term of the GNU General Public License v3

EAPI="5"

inherit cmake-utils eutils

MY_PN="CuraEngine"
MY_PV="2.1.0"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="The CuraEngine is a C++ console application for 3D printing GCode generation."
HOMEPAGE="https://github.com/Ultimaker/${MY_PN}"
SRC_URI="https://github.com/Ultimaker/${MY_PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
S="${WORKDIR}/${MY_P}"
 
DEPEND=""
RDEPEND="
	dev-libs/protobuf:0/10b3
	=dev-libs/libarcus-${PV}
"

src_prepare () {
	epatch_user
}
