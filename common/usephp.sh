#!/bin/bash

# Usage: usephp <version>
# Example: usephp 8.2 will switch to PHP 8.2

# Use user ID or username to make directory unique per user
USER_IDENTIFIER="${USER:-$UID}"
SYMLINK_DIR="/tmp/php-bin-links-$USER_IDENTIFIER"

# Check if the user provided a version argument
if [ -z "$1" ]; then
  echo "Error: Please provide a PHP version (e.g., usephp 8.2)"
  exit 1
fi

PHP_VERSION="$1"
PHP_BIN="/usr/bin/php$PHP_VERSION"

# Check if the provided PHP version exists
if [ ! -x "$PHP_BIN" ]; then
  echo "Error: PHP version $PHP_VERSION not found in /usr/bin."
  exit 1
fi

# Create the symlink directory if it doesn't exist
if [ ! -d "$SYMLINK_DIR" ]; then
  mkdir -p "$SYMLINK_DIR"
  echo "Created directory: $SYMLINK_DIR"
fi

# Remove any existing 'php' symlink
if [ -L "$SYMLINK_DIR/php" ]; then
  rm "$SYMLINK_DIR/php"
  echo "Removed previous symlink for php."
fi

# Create the new symlink for the specified PHP version
ln -s "$PHP_BIN" "$SYMLINK_DIR/php"
echo "Created symlink for PHP $PHP_VERSION at $SYMLINK_DIR/php."

# Prepend the symlink directory to PATH if it's not already there
if [[ ":$PATH:" != *":$SYMLINK_DIR:"* ]]; then
  export PATH="$SYMLINK_DIR:$PATH"
  echo "Updated PATH to prioritize $SYMLINK_DIR."
fi

# Confirm the change
echo "PHP version switched to $PHP_VERSION."
php -v
