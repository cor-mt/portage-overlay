# Copyright 2015 Cor Legemaat
# Distributed under the terms of the GNU General Public License v3
# $Header: Exp $

EAPI=5

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="sqlite"
POSTGRES_COMPAT=( 9.{0,1,2,3,4,5} )

inherit eutils multilib gnome2-utils cmake-utils python-single-r1 subversion versionator

DESCRIPTION="Open Source Radio Planning plug-in for QGIS"
HOMEPAGE="http://www.qrap.org.za/"
#SRC_URI="mirror://sourceforge/${PN}/${PN}.tar.gz"
ESVN_REPO_URI="http://svn.code.sf.net/p/qrap/code/"
ESVN_PROJECT="qrap"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="grass python test"
#S="${WORKDIR}/qraptar"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	sci-geosciences/qgis[postgres]
	dev-qt/qt3support
	dev-qt/qtsql:4[postgres]
	sci-libs/proj
	dev-cpp/eigen:3
	dev-libs/expat
	sci-libs/gdal
	sci-libs/geos
	sci-libs/gsl
	dev-libs/libpqxx
	dev-libs/poco
	x11-libs/qwt:5
	sci-mathematics/fann
	dev-db/postgis
	grass? ( sci-geosciences/grass )
	dev-db/postgresql
"

DEPEND="${RDEPEND}
	sys-devel/bison
	sys-devel/flex"

postgres_check_slot() {
	if ! declare -p POSTGRES_COMPAT &>/dev/null; then
	   die 'POSTGRES_COMPAT not declared.'
	fi

        # Don't die because we can't run postgresql-config during pretend.
        [[ "$EBUILD_PHASE" = "pretend" \
            && -z "$(which postgresql-config 2> /dev/null)" ]] && return 0

   	local res=$(echo ${POSTGRES_COMPAT[@]} \
   	    | grep -c $(postgresql-config show 2> /dev/null) 2> /dev/null)

	if [[ "$res" -eq "0" ]] ; then
		eerror "PostgreSQL slot must be set to one of: "
		eerror "    ${POSTGRES_COMPAT[@]}"
		return 1
	fi

	return 0
}

pkg_setup() {
	postgres_check_slot || die
	export PGSLOT="$(postgresql-config show)"
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}.patch
}

src_configure() {
	local mycmakeargs=(
		"-DQGIS_PLUGIN_DIR=/usr/$(get_libdir)/qgis"
		$(cmake-utils_use_with grass GRASS)
		$(cmake-utils_use_with python BINDINGS)
		$(cmake-utils_use_enable test TESTS)
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	insinto /usr/share/qrap/sql
	doins ${FILESDIR}/db_structure.sql || die "doins faild"
}

pkg_postinst() {	
	elog "To setup a db for Q-Rap, with postgresql running, run"
	elog "\temerge --config =${CATEGORY}/${PF}"
	elog "then start qgis and enable the Q-Rap plugin with the correct password"
}

pkg_config(){
	local postgis_version_range=`equery l dev-db/postgis | grep -o -e \-[0-9]\.[0-9] | grep -o -e [0-9]\.[0-9]`
	source "${EROOT%/}/etc/conf.d/postgresql-${PGSLOT}"
	local postgis_path="${EROOT%/}/usr/share/postgresql-${PGSLOT}/contrib/postgis-${postgis_version_range}"

	einfon "Password for Postgre user (just enter if local is authorized): "
	read -s PGPASSWORD
	export PGPASSWORD
	echo

	einfon "Password for the Q-Rap user (new, enter if local is authorized): "
	read -s QRAPPASSWORD
	export QRAPPASSWORD
	echo

	local retval
	safe_exit() {
		unset PGPASSWORD
		unset QRAPPASSWORD
		eend $retval
		eerror "All actions could not be performed."
		eerror "Read above to see what failed."
		eerror "You will need to manual intervene,"
		eerror "as some things may have succeeded."
		eerror
		die "All actions could not be performed"
	}

	ebegin "Create the qrap user."
	psql -q -U postgres -p ${PGPORT} \
	    -c "CREATE ROLE qrap PASSWORD '$QRAPPASSWORD' NOSUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN;"
	retval=$?
	[[ $retval == 0 ]] && eend 0 || safe_exit

	ebegin "Create the qrap database"
	psql -q -U postgres -p ${PGPORT} \
	    -c "CREATE DATABASE qrap OWNER qrap;"
	retval=$?
	[[ $retval == 0 ]] && eend 0 || safe_exit
			       
	ebegin "Performing CREATE LANGUAGE on qrap"
	createlang -U postgres -p ${PGPORT} plpgsql qrap
	retval=$?
	In this case, only error code 1 is fatal
	[[ $retval == 1 ]] && safe_exit || eend 0

	ebegin "Enabling PostGIS on qrap"
	psql -q -U postgres -p ${PGPORT} -d qrap \
	    -f "${postgis_path}/postgis.sql"
	retval=$?
	[[ $retval == 0 ]] && eend 0 || safe_exit

	ebegin "Adding EPSG to qrap"
	psql -q -U postgres -p ${PGPORT} -d qrap \
	  -f "${postgis_path}/spatial_ref_sys.sql"
	retval=$?
	[[ $retval == 0 ]] && eend 0 || safe_exit

	ebegin "Install the template structure."
	psql -q -U qrap -p ${PGPORT} -d qrap \
	  -f "/usr/share/qrap/sql/db_structure.sql"
	retval=$?
	[[ $retval == 0 ]] && eend 0 || safe_exit

	unset PGPASSWORD
	unset QRAPPASSWORD
	einfo "Q-Rap db installed and password enabled."
}