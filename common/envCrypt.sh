#!/usr/bin/env bash

#
#
# 			   M""""""""`M            dP
#             Mmmmmm   .M            88
#             MMMMP  .MMM  dP    dP  88  .dP   .d8888b.
#             MMP  .MMMMM  88    88  88888"    88'  `88
#             M' .MMMMMMM  88.  .88  88  `8b.  88.  .88
#             M         M  `88888P'  dP   `YP  `88888P'
#             MMMMMMMMMMM    -*-  Created by Zuko  -*-
#
#
#             * * * * * * * * * * * * * * * * * * * * *
#             * -    - -   F.R.E.E.M.I.N.D   - -    - *
#             * -  Copyright © 2024 (Z) Programing  - *
#             *    -  -  All Rights Reserved  -  -    *
#             * * * * * * * * * * * * * * * * * * * * *
#
#
#
  echo '';
  echo '';
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
           ';
  echo '';
  echo '';

    echo -e "\e[1;33mSecurity Warning: AES-256-CBC does not provide authenticated encryption and is vulnerable to padding oracle attacks. You should use something like age instead."
    echo -e "\e[31mPlease remember your passphrase, it will note stored any where by this script\e[0m"
# Arguments
action=$1
env=${2:-""}

# Set input file
inputfile=".env"
if [ "$env" != "" ]; then
    inputfile="${inputfile}.${env}"
fi

# Set output file
outputname=$(basename "$inputfile").encrypt

# Function to show usage
show_usage() {
    echo "Usage: $0 <action> [env]"
    echo "Actions:"
    echo "  encrypt   Encrypt the input file (.env or .env.<env>) using AES-256-CBC"
    echo "  decrypt   Decrypt the input file (.env.encrypt or .env.<env>.encrypt)"
    echo "Examples:"
    echo "  $0 encrypt           # Encrypts .env file"
    echo "  $0 encrypt dev       # Encrypts .env.dev file"
    echo "  $0 decrypt           # Decrypts .env.encrypt file"
    echo "  $0 decrypt dev       # Decrypts .env.dev.encrypt file"
    exit 1
}

# Encrypt action
if [ "$action" == "encrypt" ]; then
  if [ ! -f "$inputfile" ]; then
        echo "File not found: $inputfile"
        exit 1
  fi
    openssl aes-256-cbc -a -salt -pbkdf2 -in "$inputfile" -out "$outputname"
    echo "File encrypted: $outputname"

# Decrypt action
elif [ "$action" == "decrypt" ]; then
    if [ ! -f "$inputfile" ]; then
      inputfile="${inputfile}.encrypt"
    fi
    if [ ! -f "$inputfile" ]; then
      echo "File not found: $inputfile"
      exit 1
    fi
    if [[ $inputfile == *.*.* ]]; then
      decrypt_output="${inputfile%.*}.new"
    else
      decrypt_output=$inputfile
    fi
    openssl aes-256-cbc -d -a -pbkdf2 -in "$inputfile.encrypt" -out "$decrypt_output"
    echo "File decrypted: $decrypt_output"

# Invalid action or missing args
else
    show_usage
fi
