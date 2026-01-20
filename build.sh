#!/bin/bash
set -e

UPSTREAM_VERSION="0.9.8"
UPSTREAM_REPO="https://github.com/atar-axis/xpadneo.git"
UPSTREAM_TAG="v${UPSTREAM_VERSION}"

echo "Building xpadneo-dkms package..."
echo "Upstream version: ${UPSTREAM_VERSION}"

# Clone upstream source if not present
if [ ! -d "xpadneo" ]; then
    echo "Cloning upstream repository..."
    git clone "${UPSTREAM_REPO}" xpadneo
fi

cd xpadneo

# Fetch latest tags
echo "Fetching upstream tags..."
git fetch --tags

# Checkout specific version
echo "Checking out ${UPSTREAM_TAG}..."
git checkout "${UPSTREAM_TAG}"

# Copy debian packaging files
echo "Copying debian/ directory..."
rm -rf debian
cp -r ../debian .

# Clean previous build
echo "Cleaning previous build..."
debian/rules clean

# Build package
echo "Building package..."
dpkg-buildpackage -us -uc -b

# Move build artifacts to parent directory
cd ..
echo ""
echo "Build complete! Packages are in: $(pwd)"
ls -lh xpadneo-dkms_*.deb xpadneo-dkms_*.buildinfo xpadneo-dkms_*.changes 2>/dev/null || true
