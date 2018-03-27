#!/bin/bash

set -ex

MY_DIR=$(dirname "${BASH_SOURCE[0]}")
source $MY_DIR/utils.sh

#
# Function 'do_openssl_build' and 'build_openssl'
# copied from https://github.com/pypa/manylinux/tree/master/docker/build_scripts
#

OPENSSL_ROOT=openssl-1.0.2n
# Hash from https://www.openssl.org/source/openssl-1.0.2n.tar.gz.sha256
# Matches hash at https://github.com/Homebrew/homebrew-core/blob/99b8ea3594d1f1f78b0fff1fd8ca7d782aa07e13/Formula/openssl.rb#L11
OPENSSL_HASH=370babb75f278c39e0c50e8c4e7493bc0f18db6867478341a832a982fd15a8fe

# XXX: the official https server at www.openssl.org cannot be reached
# with the old versions of openssl and curl in Centos 5.11 hence the fallback
# to the ftp mirror:
OPENSSL_DOWNLOAD_URL=ftp://ftp.openssl.org/source

function do_openssl_build {
    ./config no-ssl2 no-shared -fPIC --prefix=/usr/local/ssl > /dev/null
    make > /dev/null
    make install_sw > /dev/null
}

function build_openssl {
    local openssl_fname=$1
    check_var ${openssl_fname}
    local openssl_sha256=$2
    check_var ${openssl_sha256}
    check_var ${OPENSSL_DOWNLOAD_URL}
    # Can't use curl here because we don't have it yet
    wget -q ${OPENSSL_DOWNLOAD_URL}/${openssl_fname}.tar.gz
    check_sha256sum ${openssl_fname}.tar.gz ${openssl_sha256}
    tar -xzf ${openssl_fname}.tar.gz
    (cd ${openssl_fname} && do_openssl_build)
    rm -rf ${openssl_fname} ${openssl_fname}.tar.gz
}

cd /usr/src
build_openssl $OPENSSL_ROOT $OPENSSL_HASH