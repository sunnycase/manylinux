#!/bin/bash
# Top-level build script called from Dockerfile

# Stop at any error, show all commands
set -exuo pipefail

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

# Get build utilities
source $MY_DIR/build_utils.sh

GCC_VERSION=gcc-10.3.0

# Build gcc
apt update
apt install -y wget xz-utils bzip2 make autoconf gcc-multilib g++-multilib
wget https://ftp.wrz.de/pub/gnu/gcc/$GCC_VERSION/$GCC_VERSION.tar.xz
tar xf $GCC_VERSION.tar.xz
cd $GCC_VERSION
contrib/download_prerequisites
cd ..
mkdir build
cd build
../$GCC_VERSION/configure  -v --with-pkgversion='Debian 10.3.0-1+deb9u1' --enable-languages=c,c++ --prefix=/usr --program-suffix=-10 --enable-shared --enable-linker-build-id --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --libdir=/usr/lib --enable-nls --with-sysroot=/ --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=new --enable-gnu-unique-object --disable-vtable-verify --enable-libmpx --enable-plugin --enable-default-pie --with-system-zlib --disable-browser-plugin --with-target-system-zlib --enable-multiarch --with-arch-32=i686 --with-abi=m64 --with-multilib-list=m32,m64,mx32 --enable-multilib --with-tune=generic --enable-checking=release --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu
make -j4
make install DESTDIR=/manylinux-rootfs
cd ..
rm -rf $GCC_VERSION
rm -rf build
rm $GCC_VERSION.tar.xz
apt clean

# Strip what we can
strip_ /manylinux-rootfs

# Install
cp -rlf /manylinux-rootfs/* /

gcc-10 --version
