#!/bin/sh

# This script was tested on Linux and MacOS hosts, where it can be used
# to build native libsecp256k1 binaries.
#
# It can also be used to cross-compile to Windows:
# $ sudo apt-get install mingw-w64
# For a Windows x86 (32-bit) target, run:
# $ GCC_TRIPLET_HOST="i686-w64-mingw32" ./contrib/make_libsecp256k1.sh
# Or for a Windows x86_64 (64-bit) target, run:
# $ GCC_TRIPLET_HOST="x86_64-w64-mingw32" ./contrib/make_libsecp256k1.sh
#
# To cross-compile to Linux x86:
# sudo apt-get install gcc-multilib g++-multilib
# $ AUTOCONF_FLAGS="--host=i686-linux-gnu CFLAGS=-m32 CXXFLAGS=-m32 LDFLAGS=-m32" ./contrib/make_libsecp256k1.sh

LIBSECP_VERSION="1253a27756540d2ca526b2061d98d54868e9177c"

set -e

. $(dirname "$0")/build_tools_util.sh || (echo "Could not source build_tools_util.sh" && exit 1)

here="$(dirname "$(realpath "$0" 2> /dev/null || grealpath "$0")")"
CONTRIB="$here"
PROJECT_ROOT="/usr/local/lib/python3.11/site-packages"

pkgname="secp256k1"
info "Building $pkgname..."

(
    cd "$CONTRIB"
    if [ ! -d secp256k1 ]; then
        git clone https://github.com/bitcoin-core/secp256k1.git
    fi
    cd secp256k1
    if ! $(git cat-file -e ${LIBSECP_VERSION}) ; then
        info "Could not find requested version $LIBSECP_VERSION in local clone; fetching..."
        git fetch --all
    fi
    git reset --hard
    git clean -dfxq
    git checkout "${LIBSECP_VERSION}^{commit}"

    if ! [ -x configure ] ; then
        echo "libsecp256k1_la_LDFLAGS = -no-undefined" >> Makefile.am
        echo "LDFLAGS = -no-undefined" >> Makefile.am
        ./autogen.sh || fail "Could not run autogen for $pkgname. Please make sure you have automake and libtool installed, and try again."
    fi
    if ! [ -r config.status ] ; then
        ./configure \
            $AUTOCONF_FLAGS \
            --prefix="$here/$pkgname/dist" \
            --enable-module-recovery \
            --enable-experimental \
            --enable-module-ecdh \
            --disable-benchmark \
            --disable-tests \
            --disable-exhaustive-tests \
            --disable-static \
            --enable-shared || fail "Could not configure $pkgname. Please make sure you have a C compiler installed and try again."
    fi
    make -j4 || fail "Could not build $pkgname"
    make install || fail "Could not install $pkgname"
    . "$here/$pkgname/dist/lib/libsecp256k1.la"
    host_strip "$here/$pkgname/dist/lib/$dlname"
    cp -fpv "$here/$pkgname/dist/lib/$dlname" "$PROJECT_ROOT/electrum_ltc" || fail "Could not copy the $pkgname binary to its destination"
    info "$dlname has been placed in the inner 'electrum_ltc' folder."
    if [ -n "$DLL_TARGET_DIR" ] ; then
        cp -fpv "$here/$pkgname/dist/lib/$dlname" "$DLL_TARGET_DIR/" || fail "Could not copy the $pkgname binary to DLL_TARGET_DIR"
    fi
)