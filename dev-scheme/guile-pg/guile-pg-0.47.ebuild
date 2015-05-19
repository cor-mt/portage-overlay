# Copyright 2015 Cor Legemaat
# Distributed under the terms of the GNU General Public License v3
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="Guile-PG is a collection of modules for Guile allowing access to the PostgreSQL RDBMS from Scheme programs"
HOMEPAGE="https://savannah.nongnu.org/projects/guile-www/"
SRC_URI="mirror://nongnu/guile-pg/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-scheme/guile
	dev-db/postgresql"
DEPEND="${RDEPEND}"

src_test() {
	emake VERBOSE=1 check
}

