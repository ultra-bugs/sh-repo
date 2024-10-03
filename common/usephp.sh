#!/bin/bash

# Usage
if [ -z "$1" ]; then
  echo "Usage: usephp <version>"
  exit 1
fi

# param is version of PHP, Ex: 7.4, 8.2
PHP_VERSION=$1
PHP_BIN="/usr/bin/php$PHP_VERSION"

# Check that exists in /usr/bin or not
if [ -x "$PHP_BIN" ]; then
  # Prepend PHP binary to PATH env
  export PATH="/usr/bin/php$PHP_VERSION:$PATH"
  echo "Using PHP version $PHP_VERSION"
else
  echo "PHP version $PHP_VERSION not found in /usr/bin"
  exit 1
fi
