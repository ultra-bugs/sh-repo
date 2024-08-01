#!/bin/bash

echo "This script will download, build, and install (or altinstall) Python 3.11 on your system."

read -p "Would you like to proceed? (Y/n) " isok

if [ "$isok" == "Y" ] || [ "$isok" == "y" ] || [ -z "$isok" ]; then
    # Ensure necessary build tools are installed
    sudo apt update
    sudo apt install -y build-essential checkinstall zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev curl libbz2-dev
    
    # Create directory for Python source
    mkdir -p ~/py311
    cd ~/py311

    # Download Python source
    wget https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tgz -O source.tar.gz

    if [ $? -ne 0 ]; then
        echo "Failed to download Python 3.11. Exiting."
        exit 1
    fi

    # Extract source
    tar -xzf source.tar.gz
    cd Python-3.11.0

    # Configure and build Python
    ./configure --enable-optimizations
    make -j$(nproc)

    if [ $? -ne 0 ]; then
        echo "Build failed. Exiting."
        exit 1
    fi

    # Ask user for install choice
    read -p "Would you like to use 'make install' or 'make altinstall'? (install/altinstall) " install_type

    # Default to altinstall if no input
    install_type=${install_type:-altinstall}

    case $install_type in
        install)
            sudo make install
            ;;
        altinstall)
            sudo make altinstall
            ;;
        *)
            echo "Invalid option. Defaulting to 'altinstall'."
            sudo make altinstall
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo "Python 3.11 installation completed successfully."
    else
        echo "Installation failed."
        exit 1
    fi
else
    echo "Installation aborted."
    exit 1
fi
