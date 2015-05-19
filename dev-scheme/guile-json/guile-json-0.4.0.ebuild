# Copyright 2015 Cor Legemaat
# Distributed under the terms of the GNU General Public License v3
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="guile-json is a JSON module for Guile"
HOMEPAGE="https://savannah.nongnu.org/projects/guile-json/"
SRC_URI="mirror://nongnu/guile-json/${P}.tar.gz"

LICENSE="LGPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-scheme/guile"
DEPEND="${RDEPEND}"

