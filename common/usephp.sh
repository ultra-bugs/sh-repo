#!/bin/bash

# Check if the user provided a version argument
if [ -z "$1" ]; then
  echo "Usage: usephp <version>"
  echo "Switch the active PHP version in the current session."
  echo "Example:"
  echo "  usephp 8.2    # Switch to PHP 8.2"
  echo "  usephp 7.4    # Switch to PHP 7.4"
  exit 1
fi

# Argument is the PHP version, e.g., 7.4, 8.2
PHP_VERSION=$1
PHP_BIN="/usr/bin/php$PHP_VERSION"

# Check if the specified PHP binary exists in /usr/bin
if [ -x "$PHP_BIN" ]; then
  # Prepend the specified PHP version path to the beginning of the PATH
  export PATH="/usr/bin/php$PHP_VERSION:$PATH"
  echo "Switched to PHP version $PHP_VERSION"
else
  # If the binary does not exist, print an error message
  echo "PHP version $PHP_VERSION not found in /usr/bin"
  exit 1
fi
