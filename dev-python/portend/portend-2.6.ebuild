# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python{2_7,3_{5,6,7,8}} pypy3 )

inherit distutils-r1

DESCRIPTION="TCP port monitoring utilities"
HOMEPAGE="https://pypi.org/project/portend/ https://github.com/jaraco/portend"
SRC_URI="mirror://pypi/p/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND=">=dev-python/tempora-1.8[${PYTHON_USEDEP}]"
BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

distutils_enable_tests pytest

python_prepare_all() {
	# avoid a setuptools_scm dependency
	sed -i "s:use_scm_version=True:version='${PV}':" setup.py || die

	# avoid extra test deps
	sed -i -r 's: --flake8:: ; s: --black:: ; s: --cov::' pytest.ini || die

	distutils-r1_python_prepare_all
}