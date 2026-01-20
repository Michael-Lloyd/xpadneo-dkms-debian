#!/bin/bash
set -e

UPSTREAM_VERSION="0.9.8"
UPSTREAM_REPO="https://github.com/atar-axis/xpadneo.git"
UPSTREAM_TAG="v${UPSTREAM_VERSION}"
PACKAGE_NAME="xpadneo-dkms"
BUILD_DIR="../xpadneo-${UPSTREAM_VERSION}"

echo "Building ${PACKAGE_NAME} package..."
echo "Upstream version: ${UPSTREAM_VERSION}"

# Download orig.tar.gz if not present
if [ ! -f "../${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.gz" ]; then
    echo "Downloading upstream source tarball..."
    wget -O "../${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.gz" \
        "https://github.com/atar-axis/xpadneo/archive/refs/tags/${UPSTREAM_TAG}.tar.gz"
fi

# Extract source if not present
if [ ! -d "${BUILD_DIR}" ]; then
    echo "Extracting upstream source..."
    tar -xzf "../${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.gz" -C ..
fi

# Copy debian packaging files
echo "Copying debian/ directory..."
rm -rf "${BUILD_DIR}/debian"
cp -r debian "${BUILD_DIR}/"

# Build package
cd "${BUILD_DIR}"
echo "Cleaning previous build..."
debian/rules clean

echo "Building package..."
dpkg-buildpackage -sa

cd ..
echo ""
echo "Build complete! Packages are in: $(pwd)"
ls -lh ${PACKAGE_NAME}_*.deb ${PACKAGE_NAME}_*.dsc ${PACKAGE_NAME}_*.changes 2>/dev/null || true
