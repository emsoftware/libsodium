#! /bin/sh

# TODO: get this from environment
export PREFIX="$(pwd)/libsodium-macos-universal"

# Adobe InDesign 2020 & 2021 minimum is 10.12.
export MACOS_VERSION_MIN=${MACOS_VERSION_MIN-"10.12"}

if [ -z "$LIBSODIUM_FULL_BUILD" ]; then
  export LIBSODIUM_ENABLE_MINIMAL_FLAG="--enable-minimal"
else
  export LIBSODIUM_ENABLE_MINIMAL_FLAG=""
fi

NPROCESSORS=$(getconf NPROCESSORS_ONLN 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null)
PROCESSORS=${NPROCESSORS:-3}

mkdir -p $PREFIX || exit 1

export CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=${MACOS_VERSION_MIN} -O2 -g"
export LDFLAGS="-mmacosx-version-min=${MACOS_VERSION_MIN}"

make distclean >/dev/null
./configure ${LIBSODIUM_ENABLE_MINIMAL_FLAG} --prefix="$PREFIX" || exit 1
#make -j${PROCESSORS} check && make -j${PROCESSORS} install || exit 1
make -j${PROCESSORS} install || exit 1

# Cleanup
make distclean >/dev/null
