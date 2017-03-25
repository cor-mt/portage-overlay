# Copyright 2017 Cor Legemaat
# Distributed under the terms of the GNU General Public License v3
# $Header: $

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit eutils python-single-r1

DESCRIPTION="Proximity detector for your mobile phone via bluetooth"
HOMEPAGE="https://github.com/Thor77/Blueproximity/"
SRC_URI="https://github.com/Thor77/Blueproximity/archive/${PV}.tar.gz -> ${P}.tar.gz"

IUSE=""

AVAILABLE_LANGUAGES="de en es fa fr hu it nl ru sv th"
for lang in ${AVAILABLE_LANGUAGES}; do
    IUSE+=" l10n_${lang}"
done

SLOT="0"

LICENSE="GPL-2"

KEYWORDS="~x86 ~amd64"

DEPEND=""
RDEPEND="dev-python/pygobject[${PYTHON_USEDEP}]
	dev-python/configobj[${PYTHON_USEDEP}]
	dev-python/pybluez[${PYTHON_USEDEP}]
	>=dev-python/pygtk-2.0[${PYTHON_USEDEP}]"

S="${WORKDIR}/Blueproximity-${PV}"
DOCS="COPYING ChangeLog README"
HTML_DOCS="docs"

src_install() {
	sed -i -r "s:\`dirname \\\$PRG\`:/usr/lib/${PN}:" start_proximity.sh
	sed -i "s#python #${PYTHON} #" start_proximity.sh
	newbin start_proximity.sh blueproximity
	insinto "/usr/lib/${PN}"
	doins blueproximity*
	doins proximity*
	einstalldocs
	insinto /usr/share/applications
	doins debian-addons/blueproximity.desktop
	insinto /usr/share/pixmaps
	doins debian-addons/blueproximity.xpm
	for l in ${L10N};
	do
		dodir "/usr/lib/${PN}/po/${l}"
		cp -r "${S}/po/${l}.po" "${D}/usr/lib/${PN}/po/"
	done
}
