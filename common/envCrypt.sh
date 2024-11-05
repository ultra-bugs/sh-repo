#!/usr/bin/env bash

#
#          M""""""""`M            dP
#          Mmmmmm   .M            88
#          MMMMP  .MMM  dP    dP  88  .dP   .d8888b.
#          MMP  .MMMMM  88    88  88888"    88'  `88
#          M' .MMMMMMM  88.  .88  88  `8b.  88.  .88
#          M         M  `88888P'  dP   `YP  `88888P'
#          MMMMMMMMMMM    -*-  Created by Zuko  -*-
#
#          * * * * * * * * * * * * * * * * * * * * *
#          * -    - -   F.R.E.E.M.I.N.D   - -    - *
#          * -  Copyright © 2024 (Z) Programing  - *
#          *    -  -  All Rights Reserved  -  -    *
#          * * * * * * * * * * * * * * * * * * * * *
#

# Header and banner
echo ''
echo -e $'
           \e[31mM""""""""`M            dP\e[0m
           \e[31mMmmmmm   .M            88\e[0m
           \e[31mMMMMP  .MMM  dP    dP  88  .dP   .d8888b.\e[0m
           \e[31mMMP  .MMMMM  88    88  88888"    88\'  `88\e[0m
           \e[31mM\' .MMMMMMM  88.  .88  88  `8b.  88.  .88\e[0m
           \e[31mM         M  `88888P\'  dP   `YP  `88888P\'\e[0m
           \e[31mMMMMMMMMMMM    \e[36m-*-\e[0m  \e[4;32mCreated by Zuko\e[0m  \e[36m-*-\e[0m\e[0m
           ';
echo -e $'
           \e[35m* * * * * * * * * * * * * * * * * * * * *\e[0m
           \e[32m* -    - -   F.R.E.E.M.I.N.D   - -    - *\e[0m
           \e[35m* * * * * * * * * * * * * * * * * * * * *\e[0m
           \e[1;33m!  .env file encryption/decryption tool !\e[0m
           '
echo ''
echo ''
echo -e "\e[1;33mSecurity Warning: AES-256-CBC does not provide authenticated encryption and is vulnerable to padding oracle attacks. You should use something like age instead."
echo -e "\e[31mPlease remember your passphrase, it will note stored any where by this script\e[0m"

# Parse arguments
file=""
action=""
env=""

while [[ "$1" != "" ]]; do
    case $1 in
        --file)
            shift
            file="$1"
            ;;
        encrypt | decrypt)
            action="$1"
            ;;
        *)
            env="$1"
            ;;
    esac
    shift
done

# Set default input file if not specified
if [ -z "$file" ]; then
    file=".env"
    [ -n "$env" ] && file=".env.$env"
fi

# Set output file for encryption
outputfile="${file}.encrypt"

# Function to show usage
show_usage() {
    echo "Usage: $0 [--file <path_to_file>] <action> [env]"
    echo "Actions:"
    echo "  encrypt   Encrypt the input file (default: .env or .env.<env>)"
    echo "  decrypt   Decrypt the input file (.env.encrypt or .env.<env>.encrypt)"
    echo "Examples:"
    echo "  $0 encrypt           # Encrypts .env file"
    echo "  $0 encrypt dev       # Encrypts .env.dev file"
    echo "  $0 decrypt           # Decrypts .env.encrypt file"
    echo "  $0 decrypt dev       # Decrypts .env.dev.encrypt file"
    echo "  $0 --file custom.env encrypt   # Encrypts custom.env file"
    echo "  $0 --file custom.env decrypt   # Decrypts custom.env file"
    exit 1
}

# Check action and perform encryption or decryption
if [ "$action" == "encrypt" ]; then
    if [ ! -f "$file" ]; then
        echo "File not found: $file"
        exit 1
    fi
    openssl aes-256-cbc -a -salt -pbkdf2 -in "$file" -out "$outputfile"
    echo "File encrypted: $outputfile"

elif [ "$action" == "decrypt" ]; then
    # Determine output filename by removing ".encrypt" suffix
    decrypt_output="${file%.encrypt}"

    # If target file exists, append ".decrypted" to the filename
    if [ -f "$decrypt_output" ]; then
        decrypt_output="${decrypt_output}.decrypted"
    fi

    if [ ! -f "$file" ]; then
        file="${file}.encrypt"
    fi
    if [ ! -f "$file" ]; then
        echo "File not found: $file"
        exit 1
    fi

    # Perform decryption
    openssl aes-256-cbc -d -a -pbkdf2 -in "$file" -out "$decrypt_output"
    echo "File decrypted: $decrypt_output"

else
    show_usage
fi
