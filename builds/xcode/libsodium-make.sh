#! /bin/sh
#
# Build libsodium for the current Xcode environment.
#
# Since it only needs to be rebuilt when something in
# the Sodium project changes, create an installation
# in Em's 'builds' folder where the primary projects
# can find it but where it can't be removed by a "clean."
#
# Production settings include:  
#   CFLAGS -  arch and macosx-version-min
#   LDFLAGS - macosx-version-min
#   INSTALL_DIR - where to install the product,
#     like ../builds/libsodium/macos-<version>-universal2
#   MACOSX_DEPLOYMENT_TARGET - macOS target/min version
#
# See libs/xcode/common_plugin_model.xcconfig for
# consumption settings.
#
sodium_install_dir="$INSTALL_DIR"
sodium_install_parent=$(dirname "$sodium_install_dir")
sodium_header="$sodium_install_dir/include/sodium.h"
sodium_library="$sodium_install_dir/lib/libsodium.a"
# Use configure.ac as the project-level trigger since it
# appears to be touched for each sodium release.
if [[ ! -f $sodium_header || ! -f $sodium_library || "configure.ac" -nt $sodium_library ]]; then
    # NB: The installation location (prefix) is baked
    # into the generated makefile.
    echo "Configuring for macOS $MACOSX_DEPLOYMENT_TARGET..."
    rm -rf "$sodium_install_dir" >/dev/null
    # Ensure install folder's parent folder exists
    # for log generation.
    mkdir -p "$sodium_install_parent"
    # Clone libsodium in the target's temporary
    # folder and build it there so that simultaneous
    # builds won't interfere with each other.
    rm -rf "$TARGET_TEMP_DIR" >/dev/null
    mkdir -p "$TARGET_TEMP_DIR"
    cp -R ./ "$TARGET_TEMP_DIR"
    pushd "$TARGET_TEMP_DIR" >/dev/null
    ./configure --enable-minimal --disable-shared --prefix="$sodium_install_dir" >"$sodium_install_dir.log" 2>&1 || exit 1
    echo "Installing $(basename "$sodium_install_dir")..."
    mkdir -p "$sodium_install_dir" || exit 1
    # Elide ignorable "ranlib" warnings that would
    # show in Xcode as build issues.
    make install 2>&1 | grep -v -e 'has no symbols' -e 'table of contents is empty' -e 'is ignored for' --line-buffered
#    make install 2>&1 >>"$sodium_install_dir.log"
    make distclean >/dev/null 2>&1
    popd >/dev/null
fi
