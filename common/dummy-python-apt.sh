#!/bin/bash

# Default Python version
DEFAULT_VERSION="3.11"

# Print usage information
usage() {
    echo "Usage: $0 [version]"
    echo
    echo "This script creates and installs dummy packages for Python installed from source."
    echo "These dummy packages help 'apt' recognize specific Python versions as installed."
    echo
    echo "Arguments:"
    echo "  version   The Python version to set in the dummy packages. Default is 3.11 if not provided."
    echo
    echo "Examples:"
    echo "  $0               # Creates dummy packages for Python 3.11"
    echo "  $0 3.9            # Creates dummy packages for Python 3.9"
    exit 1
}

# Check if help is requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    usage
fi

# Check if a version is provided
VERSION=${1:-$DEFAULT_VERSION}

# Define package names based on version
PACKAGE_PYTHON="python$VERSION"
PACKAGE_PYTHON3="python3"
PACKAGE_PYTHON_ALIAS="python$VERSION"

# Create directories for the dummy packages
PACKAGE_DIR=~/python-dummy
DEBIAN_DIR=$PACKAGE_DIR/DEBIAN

# Remove old directories if they exist
rm -rf $PACKAGE_DIR

# Create directory structure
mkdir -p $DEBIAN_DIR

# Create control file for python$VERSION
cat <<EOF > $DEBIAN_DIR/control
Package: $PACKAGE_PYTHON
Version: $VERSION
Architecture: all
Maintainer: Your Name <you@example.com>
Description: Dummy package to indicate that Python $VERSION is installed from source.
EOF

# Create control file for python3
cat <<EOF > $DEBIAN_DIR/control
Package: $PACKAGE_PYTHON3
Version: $VERSION
Architecture: all
Maintainer: Your Name <you@example.com>
Depends: $PACKAGE_PYTHON
Description: Dummy package to alias that Python $VERSION is installed as Python 3.
EOF

# Create control file for python3.version
cat <<EOF > $DEBIAN_DIR/control
Package: $PACKAGE_PYTHON_ALIAS
Version: $VERSION
Architecture: all
Maintainer: Your Name <you@example.com>
Depends: $PACKAGE_PYTHON
Description: Dummy package to indicate that Python $VERSION is installed and aliased as Python 3.$VERSION.
EOF

# Build the dummy package
dpkg-deb --build $PACKAGE_DIR

# Install the dummy package
sudo dpkg -i $PACKAGE_DIR.deb

# Resolve dependency issues
#sudo apt-get -f install

echo "Dummy packages for Python $VERSION created and installed successfully."
