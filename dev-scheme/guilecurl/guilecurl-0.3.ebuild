# Copyright 2015 Cor Legemaat
# Distributed under the terms of the GNU General Public License v3
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="guile curl is a project that has procedures that allow Guile to do client-side URL transfers, like requesting documents from http or ftp servers"
HOMEPAGE="http://www.lonelycactus.com/guile-curl.html"
SRC_URI="http://www.lonelycactus.com/tarball/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-scheme/guile
	net-misc/curl
"
DEPEND="${RDEPEND}"

src_configure() {
    econf --with-guilesitedir=/usr/share/guile/site --with-guileextensiondir=/usr/lib64
}

