# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PLOCALES="ar cs de es et fr hr hu it ja nl pl pt pt_BR ru sk sv uk"

inherit eutils fdo-mime gnome2-utils l10n multilib qt4-r2

DESCRIPTION="A Qt based map editor for the openstreetmap.org project"
HOMEPAGE="http://www.merkaartor.be https://github.com/openstreetmap/merkaartor"
SRC_URI="https://github.com/openstreetmap/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug exif gps libproxy qrcode +qt4 qt5 spatialite"

REQUIRED_USE="
	^^ ( qt4 qt5 )
	qt5? ( !spatialite )
"

RDEPEND="
	qt4? (
	     dev-qt/qtcore:4
	     dev-qt/qtgui:4
	     dev-qt/qtsvg:4
	     dev-qt/qtwebkit:4
	     >=dev-qt/qtsingleapplication-2.6.1[X,qt4(+)]
	)
	qt5? (
	     dev-qt/qtcore:5
	     dev-qt/qtgui:5
             dev-qt/qtsvg:5
             dev-qt/qtwebkit:5[printsupport]
	     dev-qt/qtxml:5
	     dev-qt/qtconcurrent:5
             >=dev-qt/qtsingleapplication-2.6.1[X,qt5(+)]
	)
	>=sci-libs/gdal-2.0.0
	>=sci-libs/proj-4.6
	sys-libs/zlib
	spatialite? ( >=dev-db/spatialite-4.1.0 )
	exif? ( 
	      media-gfx/exiv2:=
	)
	gps? ( 
	     >=sci-geosciences/gpsd-2.92[cxx]
	     <=sci-geosciences/gpsd-3.11[cxx] 
	)
	libproxy? ( net-libs/libproxy )
	qrcode? ( media-gfx/zbar[qt4] )
"
DEPEND="${RDEPEND}
	>=dev-libs/boost-1.46
	virtual/pkgconfig
"

DOCS=( AUTHORS CHANGELOG HACKING )

src_prepare() {
	my_rm_loc() {
		sed -i -e "s:../translations/${PN}_${1}.\(ts\|qm\)::" src/src.pro || die
		rm "translations/${PN}_${1}.ts" || die
	}

	l10n_find_plocales_changes 'translations' "${PN}_" '.ts'

	if [[ -n "$(l10n_get_locales)" ]]; then
		l10n_for_each_disabled_locale_do my_rm_loc
		$(qt4_get_bindir)/lrelease src/src.pro || die
	fi

	epatch "${FILESDIR}"/${P}-geoimage.patch
	epatch "${FILESDIR}"/${P}-gdal2.patch

	if use qt5; then
	   sed -i -e "s/DEFINES\ +=\ USE_ZBAR/DEFINES\ +=\ USE_ZBAR\ QT_DISABLE_DEPRECATED_BEFORE=0x040900/" \
	   plugins/background/MWalkingPapersBackground/MWalkingPapersBackground.pro || die "Sed faild!"
	fi
	epatch_user
}

src_configure() {
	# TRANSDIR_SYSTEM is for bug #385671
	if use qt4; then
	       eqmake4 \
	       	       PREFIX="${EPREFIX}/usr" \
		       LIBDIR="${EPREFIX}/usr/$(get_libdir)" \
		       TRANSDIR_MERKAARTOR="${EPREFIX}/usr/share/${PN}/translations" \
		       TRANSDIR_SYSTEM="${EPREFIX}/usr/share/qt4/translations" \
		       SYSTEM_QTSA=1 \
		       RELEASE=1 \
		       NODEBUG="$(usex debug '0' '1')" \
		       GEOIMAGE="$(usex exif '1' '0')" \
		       GPSDLIB="$(usex gps '1' '0')" \
		       LIBPROXY="$(usex libproxy '1' '0')" \
		       SPATIALITE="$(usex spatialite '1' '0')" \
		       ZBAR="$(usex qrcode '1' '0')" \
		       Merkaartor.pro
	fi

	if use qt5; then
	       eqmake5 \
	               PREFIX="${EPREFIX}/usr" \
	               LIBDIR="${EPREFIX}/usr/$(get_libdir)" \
                       TRANSDIR_MERKAARTOR="${EPREFIX}/usr/share/${PN}/translations" \
                       TRANSDIR_SYSTEM="${EPREFIX}/usr/share/qt4/translations" \
                       SYSTEM_QTSA=1 \
                       RELEASE=1 \
                       NODEBUG="$(usex debug '0' '1')" \
                       GEOIMAGE="$(usex exif '1' '0')" \
                       GPSDLIB="$(usex gps '1' '0')" \
                       LIBPROXY="$(usex libproxy '1' '0')" \
                       SPATIALITE="$(usex spatialite '1' '0')" \
                       ZBAR="$(usex qrcode '1' '0')" \
                       Merkaartor.pro
	fi
																																									
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
