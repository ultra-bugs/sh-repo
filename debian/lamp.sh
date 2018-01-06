#!/bin/bash

: << 'END'
         M""""""""`M            dP
         Mmmmmm   .M            88
         MMMMP  .MMM  dP    dP  88  .dP   .d8888b.
         MMP  .MMMMM  88    88  88888"    88'  `88
         M' .MMMMMMM  88.  .88  88  `8b.  88.  .88
         M         M  `88888P'  dP   `YP  `88888P'
         MMMMMMMMMMM    -*-  Created by Zuko  -*-

         * * * * * * * * * * * * * * * * * * * * *
         * -    - -     S.Y.M.L.I.E     - -    - *
         * -  Copyright © 2017 (Z) Programing  - *
         *    -  -  All Rights Reserved  -  -    *
         * * * * * * * * * * * * * * * * * * * * *
END
echo $'
         M""""""""`M            dP
         Mmmmmm   .M            88
         MMMMP  .MMM  dP    dP  88  .dP   .d8888b.
         MMP  .MMMMM  88    88  88888"    88\'  `88
         M\' .MMMMMMM  88.  .88  88  `8b.  88.  .88
         M         M  `88888P\'  dP   `YP  `88888P\'
         MMMMMMMMMMM    -*-  Created by Zuko  -*-

         * * * * * * * * * * * * * * * * * * * * *

         D.E.B.I.A.N  E.A.S.Y  L.A.M.P  S.T.A.C.K

         ';
function getScriptDir
{
    DIR="${BASH_SOURCE%/*}"
    if [[ ! -d "$DIR" ]]; then
        DIR="$PWD";
    fi
    echo ${DIR};
}

function checkDebVersion
{
    disId=$(lsb_release -is);
    if [[ "$disId" == "Debian" ]] || [[ "$disId" == "debian" ]]; then
        codeName=$(lsb_release -cs);
        if [[ "$codeName" == "wheezy" ]]; then
            echo 'Wheezy';
            return 0;
        elif [[ "$codeName" == "jessie" ]]; then
            echo "Jessie";
            return 0;
        else
            #NOT SUPPORTED !
            return 11;
        fi
    else
        return 10;
    fi
}

function dotDebSrcInstall
{
    echo "TODO : Build Update Src Func";
    disId=$(lsb_release -is);
    if [[ "$disId" == "Debian" ]] || [[ "$disId" == "debian" ]]; then
        codeName=$(lsb_release -cs);
        if [[ "$codeName" == "wheezy" ]]; then
            echo 'Wheezy Detected , installing';
            dotDebSrcWheezy
        elif [[ "$codeName" == "jessie" ]]; then
            echo "Jessie Detected , installing";
            dotDebSrcJessie
        else
            #NOT SUPPORTED !
            echo "NOT SUPPORTED OS , STOP !";
            exit;
        fi
    else
        return 10;
    fi
}

#DOTDEB PACKAGES
function dotDebSrcWheezy
{
    if ! grep -q 'dotdeb.org' /etc/apt/sources.list.d/dotdeb.list; then
        echo "Add Src : dotDeb 7"
        echo "deb http://packages.dotdeb.org wheezy all
        deb-src http://packages.dotdeb.org wheezy all
        deb http://packages.dotdeb.org wheezy-php56-zts all
        deb-src http://packages.dotdeb.org wheezy-php56-zts all" > /etc/apt/sources.list.d/dotdeb.list
        echo "Getting Src key\n"
        wget https://www.dotdeb.org/dotdeb.gpg
        apt-key add dotdeb.gpg
        updateSrc
    fi
}

#DOTDEB PACKAGES
function dotDebSrcJessie
{
    if ! grep -q 'dotdeb.org' /etc/apt/sources.list.d/dotdeb.list; then
        echo "adding apt source list......."
        echo "deb http://packages.dotdeb.org jessie all
        deb-src http://packages.dotdeb.org jessie all" > /etc/apt/sources.list.d/dotdeb.list
        echo "Getting Src key"
        wget https://www.dotdeb.org/dotdeb.gpg
        apt-key add dotdeb.gpg
        updateSrc
    fi
}

#UPDATE APT SOURCE
function updateSrc()
{
    echo "UPDATE APT SOURCE"
    apt-get update -y
}

#MARIA-DB DEB SRC
function mariaSrcWheezy
{
    echo "Add Src : Maria DB for Debian Wheezy"
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
    add-apt-repository 'deb [arch=amd64,i386] http://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/repo/10.1/debian wheezy main'
    updateSrc
}

function mariaSrcJessie
{
    echo "Add Src : Maria DB for Debian Jessie"
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
    echo "deb [arch=amd64,i386] http://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/repo/10.1/debian jessie main
deb-src http://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/repo/10.1/debian jessie main" > /etc/apt/sources.list.d/maria-db.list
    updateSrc
}

#APACHE
function insApache
{
    echo "Installing Apache 2.4.........."
    apt-get install zip unzip gcc curl -y
    apt-get install -y apache2
    a2enmod rewrite headers proxy ssl
    printf "\e[33m APACHE : Done ! \e[0m \n "
}

#MARIA-DB
function insMariaDB
{
    apt-get install python-software-properties -y
    disId=$(lsb_release -is);
    if [[ "$disId" == "Debian" ]] || [[ "$disId" == "debian" ]]; then
        codeName=$(lsb_release -cs);
        if [[ "$codeName" == "wheezy" ]]; then
            echo 'Wheezy Detected , installing src';
            mariaSrcWheezy
        elif [[ "$codeName" == "jessie" ]]; then
            echo "Jessie Detected , installing src";
            mariaSrcJessie
        else
            #NOT SUPPORTED !
            echo "NOT SUPPORTED OS , STOP !";
            exit;
        fi
    else
        return 10;
    fi
    read -p "Do u want to run install cmd (including post-install script , u should ignore it if u\'re using LISH shell)\nYes / no ?" runPostInsMaria
    if [[ "$runPostInsMaria" != "n" ]] && [[ "$runPostInsMaria" != "N" ]];
    then
        apt-get install mariadb-server -y
    fi
    printf "\e[33m MARIA-DB : Done ! \e[0m \n "
}

#NODE JS
function insNode
{
    echo "Installing NODEJS.........."
    apt-get install python-software-properties curl -y
    curl -sL https://deb.nodesource.com/setup_6.x | bash -
    apt-get install -y nodejs
    apt-get install -y build-essential
    npm install -g npm gulp bower
    printf "\e[33m NODEJS : Done ! \e[0m \n "
}

#GIT
function insGit
{
    echo "Installing Git.........."
    apt-get install git -y
    printf "\e[33m GIT : Done ! \e[0m \n "
}

#PHP 5.6
function insPhp5
{
    echo "Installing PHP 5.6-ZTS.........."
    apt-get install php5 php5-dev php5-curl php5-imagick php5-intl php5-json php5-mcrypt php5-xsl php-pear -y
    apt-get install libapache2-mod-php5 -y
    a2enmod php5
    service apache2 restart
    printf "\e[33m PHP : Done ! \e[0m \n "
}

# COMPOSER
function insComposer
{
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    mv composer.phar /usr/bin/composer
    chmod u+x /usr/bin/composer
    printf "\e[33m COMPOSER : Done ! \e[0m \n "
}

#PHP-My-Admin
function insPhpMyAdmin
{
    apt-get install phpmyadmin -y
    service apache2 restart
    udtPhpMyAdmin
    printf "\e[33m PHP-My-Admin : Done ! \e[0m \n "
}

function udtPhpMyAdmin
{
    MyadmVer="4.7.5"
    read -p "Update phpMyAdmin to $MyadmVer ? (Y/n)" isUdtMyadmin
    if [[ "$isUdtMyadmin" != "n" ]] && [[ "$isUdtMyadmin" != "N" ]];
    then
        MyadmPath=/usr/share/phpmyadmin
        cd ${MyadmPath};
        cp -rvf ${MyadmPath} ${MyadmPath}-backup
        echo "Downloading phpMyAdmin v$MyadmVer";
        wget https://files.phpmyadmin.net/phpMyAdmin/${MyadmVer}/phpMyAdmin-${MyadmVer}-all-languages.zip;
        unzip phpMyAdmin-${MyadmVer}-all-languages
        cp -rvf phpMyAdmin-${MyadmVer}-all-languages/* ${MyadmPath}
        printf "\e[33m Update PHP-My-Admin : v$MyadmVer Done ! \e[0m \n "
    fi
}


# MemCached
function insMemcached
{
    apt-get install memcached -y
    service memcached start
    apt-get install php5-memcached -y
    php5enmod memcached
    service apache2 restart
}

#Let Encrypt (SSL Cert Signed)
function insLetEncrypt
{
    cd ~
    apt-get install python-certbot-apache -t jessie-backports
    certbot --apache
}

#Adding packages source list....
echo "Checking & Adding packages source list...."
dotDebSrcInstall
read -p "Install Apache ? (Y/n)" apa
if [[ "$apa" != "n" ]] && [[ "$apa" != "N" ]];
then
    insApache
fi

read -p "Install MARIA-DB ? (Y/n)" maria
if [[ "$maria" != "n" ]] && [[ "$maria" != "N" ]];
then
    insMariaDB
fi

read -p "Install PHP 5.6-ZTS ? (Y/n)" php
if [[ "$php" != "n" ]] && [[ "$php" != "N" ]];
then
    insPhp5
fi

read -p "Install Php MyAdmin ? (Y/n)" myadmin
if [[ "$myadmin" != "n" ]] && [[ "$myadmin" != "N" ]];
then
    insPhpMyAdmin
fi

read -p "Install Composer ? (Y/n)" composer
if [[ "$composer" != "n" ]] && [[ "$composer" != "N" ]];
then
    insComposer
fi

read -p "Install Node Js ? (Y/n)" node
if [[ "$node" != "n" ]] && [[ "$node" != "N" ]];
then
    insNode
fi

read -p "Install Git ? (Y/n)" git
if [[ "$git" != "n" ]] && [[ "$git" != "N" ]];
then
    insGit
fi

read -p "Install Memcached Deamon & PHP Extension ? (Y/n)" memca
if [[ "$memca" != "n" ]] && [[ "$memca" != "N" ]];
then
    insMemcached
fi

printf "\e[33m All opeation done ! \e[0m \n "
exit 0;