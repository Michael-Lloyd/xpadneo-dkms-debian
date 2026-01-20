# xpadneo-dkms Debian Packaging

Debian packaging files for [xpadneo](https://github.com/atar-axis/xpadneo), an advanced Linux driver for Xbox Wireless Controllers.

## Building the Package

### Prerequisites

```bash
sudo apt install debhelper dh-dkms git build-essential
```

### Build

```bash
./build.sh
```

This script will:
1. Clone the upstream xpadneo repository
2. Check out version 0.9.8
3. Copy the debian/ packaging files
4. Build the package

The resulting `.deb` file will be in the current directory.

### Install

```bash
sudo apt install ./xpadneo-dkms_0.9.8-1_all.deb
```

## Links

- **Upstream:** https://github.com/atar-axis/xpadneo
