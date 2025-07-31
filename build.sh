#! /bin/bash
set -e

repo_name=$1
target_host=$2
bits=$3

export PATH=/opt/android-ndk-r19b/toolchains/llvm/prebuilt/linux-x86_64/bin:${PATH}
export TARGET_OS=OS_ANDROID_CROSSCOMPILE # leveldb compilation
export HOST=${target_host/v7a/}
export OFFSET_BITS=$bits
export AR=${target_host/v7a/}-ar
export AS=${target_host}21-clang
export CC=${target_host}21-clang
export CXX=${target_host}21-clang++
export LD=${target_host/v7a/}-ld
export STRIP=${target_host/v7a}-strip
export LDFLAGS="-pie -static-libstdc++"
export IOC_LIB_PATH=/ioc_src/depends/${target_host}/lib/
export IOC_INCLUDE_PATH=/ioc_src/depends/${target_host}/include/
# Modern Boost versions don't use -mt suffix
export BOOST_LIB_SUFFIX=
export BDB_LIB_SUFFIX=

num_jobs=4
if [ -f /proc/cpuinfo ]; then
    num_jobs=$(grep ^processor /proc/cpuinfo | wc -l)
fi
cd depends
make -j $num_jobs
cd ../iocoin/src

echo ***********Building iocoind for ${target_host/v7a}
make -j $num_jobs -f makefile.android
tar -zcf /ioc_src/${target_host/v7a/}_${repo_name}.tar.gz iocoind
