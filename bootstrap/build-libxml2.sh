#!/bin/bash -e

LIBXML2_VERSION=2.9.1

BUILD_DIR=libxml2
SCRIPT_DIR=../engine
: ${PREFIX:=~/.openwebrtc}

export PATH=$PREFIX/bin:$PATH

check_preconditions() {
    $SCRIPT_DIR/test_internet_connection.sh || die "Internet connection is broken."
}

local_clean_source() {
    echo "build-libxml2.sh cleaning $BUILD_DIR"
    rm -fr $BUILD_DIR
}

install_sources() {
    mkdir -p $BUILD_DIR
    pushd $BUILD_DIR > /dev/null

    # get libxml2
    curl -f -O ftp://xmlsoft.org/libxml2//libxml2-$LIBXML2_VERSION.tar.gz
    gunzip -c libxml2-$LIBXML2_VERSION.tar.gz | tar xv

    popd > /dev/null
}

build() {
    local arch=$1
    local target_triple=$2

    mkdir -p $PREFIX/bin
    mkdir -p $PREFIX/lib

    (cd $BUILD_DIR && git checkout $target_triple)

    pushd $BUILD_DIR > /dev/null

    export PATH=$PREFIX/bin:$PATH:/Applications/Xcode.app/Contents/Developer/usr/bin
    export DYLD_LIBRARY_PATH=$PREFIX/lib
    export LD_LIBRARY_PATH=$PREFIX/lib
    export JHBUILD_PREFIX=$PREFIX
    export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
    export PKG_CONFIG=$PREFIX/bin/pkg-config
    export PYTHON=`which python2.7`
    export PYTHONPATH=$PREFIX/lib/python2.7/site-packages

    export CFLAGS=$PLATFORM_CFLAGS
    export CPPFLAGS=$PLATFORM_CFLAGS

    # build libxml2
    pushd libxml2-$LIBXML2_VERSION
    ./configure --prefix=$PREFIX --without-python && make && make install || die "$0 -- Could not build libxml2."
    popd > /dev/null

    popd > /dev/null
}


# drive
. $SCRIPT_DIR/engine.sh
