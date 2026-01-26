#!/bin/bash
set -e

UPSTREAM_VERSION="0.9.8"
UPSTREAM_REPO="https://github.com/atar-axis/xpadneo.git"
UPSTREAM_TAG="v${UPSTREAM_VERSION}"
PACKAGE_NAME="xpadneo-dkms"
BUILD_DIR="../xpadneo-${UPSTREAM_VERSION}"
DIST="${DIST:-unstable}"
ARCH="$(dpkg --print-architecture)"
CHROOT_TARBALL="$HOME/.cache/sbuild/${DIST}-${ARCH}.tar.zst"

echo "Building ${PACKAGE_NAME} package..."
echo "Upstream version: ${UPSTREAM_VERSION}"
echo "Distribution: ${DIST}"
echo "Architecture: ${ARCH}"

command -v sbuild >/dev/null 2>&1 || { echo "Error: sbuild not installed"; exit 1; }
command -v mmdebstrap >/dev/null 2>&1 || { echo "Error: mmdebstrap not installed"; exit 1; }
command -v wget >/dev/null 2>&1 || { echo "Error: wget not installed"; exit 1; }
command -v debsign >/dev/null 2>&1 || { echo "Error: debsign not installed"; exit 1; }

if [ ! -f "${CHROOT_TARBALL}" ]; then
    echo ""
    echo "Chroot tarball not found: ${CHROOT_TARBALL}"
    echo "Creating it now..."
    mkdir -p "$(dirname "${CHROOT_TARBALL}")" || exit 1
    mmdebstrap --include=ca-certificates --skip=output/dev --variant=buildd \
        "${DIST}" "${CHROOT_TARBALL}" https://deb.debian.org/debian || exit 1
fi

if [ ! -f "../${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.gz" ]; then
    wget -O "../${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.gz" \
        "https://github.com/atar-axis/xpadneo/archive/refs/tags/${UPSTREAM_TAG}.tar.gz" || exit 1
fi

# Extract source if not present
if [ ! -d "${BUILD_DIR}" ]; then
    echo "Extracting upstream source..."
    tar -xzf "../${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.gz" -C .. || exit 1
fi

# Copy across debian packaging files
rm -rf "${BUILD_DIR}/debian" || exit 1
cp -r debian "${BUILD_DIR}/" || exit 1

# Build package with sbuild
cd "${BUILD_DIR}" || exit 1
sbuild -d "${DIST}" --no-clean-source || exit 1

# Sign the package
cd ..
debsign ${PACKAGE_NAME}_${UPSTREAM_VERSION}-1_*.changes || exit 1

cd ..
echo ""
echo "Build complete! Packages are in: $(pwd)"
ls -lh ${PACKAGE_NAME}_*.deb ${PACKAGE_NAME}_*.dsc ${PACKAGE_NAME}_*.changes 2>/dev/null || true
