# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python{2_7,3_{5,6,7,8}} pypy{,3} )

inherit distutils-r1

DESCRIPTION="Rapid multi-Python deployment"
HOMEPAGE="http://codespeak.net/execnet/ https://pypi.org/project/execnet/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="doc"

RDEPEND=">=dev-python/apipkg-1.4[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( $(python_gen_any_dep '
			dev-python/sphinx[${PYTHON_USEDEP}]
		')
	)"

PATCHES=(
	"${FILESDIR}/execnet-1.7.1-tests.patch"
)

distutils_enable_tests pytest

python_check_deps() {
	use doc || return 0
	has_version "dev-python/sphinx[${PYTHON_USEDEP}]"
}

python_prepare_all() {
	# Remove doctest that access an i'net site
	rm doc/example/test_info.rst || die

	sed -i -r 's:(,[[:space:]]*|)"eventlet":: ; s:(,[[:space:]]*|)"gevent"(,|)::' \
		testing/conftest.py || die

	# get rid of setuptools_scm dep
	sed -i -r "s:use_scm_version=.+,:version='${PV}',: ; s:\"setuptools_scm\"::" \
		setup.py || die

	printf -- '__version__ = "%s"\nversion = "%s"\n' "${PV}" "${PV}" > \
		execnet/_version.py || die

	distutils-r1_python_prepare_all
}

python_compile_all() {
	if use doc; then
		sed -i -e 's:^intersphinx_mapping:disabled_&:' \
			doc/conf.py || die

		sphinx-build -b html -d doc/_build/doctrees doc \
			doc/_build/html || die

		HTML_DOCS+=( "doc/_build/html/." )
	fi
}