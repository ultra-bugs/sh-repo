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

         U.B.U.N.T.U  E.A.S.Y  L.A.M.P  S.T.A.C.K

         ';
function setHostName
{
    read -p "Setting up host name for your sever. Please provide a fully qualified domain name : " fqndomain
    if [[ -f /etc/hostname ]]; then
        cp /etc/hostname /etc/hostname-bak
        echo Backed up current hostname : /etc/hostname-bak
    fi
    if [[ -n hostnamectl ]]; then
        hostnamectl set-hostname ${fqndomain};
    else
        echo ${fqndomain} > /etc/hostname
    fi
    if [[ -z $(grep -is $fqndomain /etc/hosts) ]]; then
        echo "127.0.0.1 ${fqndomain} www.${fqndomain}" >> /etc/hosts
        echo "::1 ${fqndomain} www.${fqndomain}" >> /etc/hosts
        echo "Added  127.0.0.1 ${fqndomain} www.${fqndomain} & ::1 ${fqndomain} www.${fqndomain} to /etc/hosts";
    fi
}

function getScriptDir
{
    DIR="${BASH_SOURCE%/*}"
    if [[ ! -d "$DIR" ]]; then
        DIR="$PWD";
    fi
    echo ${DIR};
}

function backportSrcInstall
{
    disId=$(lsb_release -is);
    if [[ "$disId" == "Ubuntu" ]] || [[ "$disId" == "ubuntu" ]]; then
        codeName=$(lsb_release -cs);
        echo "$codeName Detected , install backport src to /etc/apt/backport-src.list";
        echo "deb http://archive.ubuntu.com/ubuntu $codeName-backports main restricted universe multiverse" > /etc/apt/sources.list.d/backport-src.list
        updateSrc
    else
        echo "Not ubuntu. Existing............";
        exit 10;
    fi
}

#UPDATE APT SOURCE
function updateSrc()
{
    echo "UPDATE APT SOURCE"
    apt-get update -y
}

#MARIA-DB DEB SRC
function mariaSrc
{
    echo "Add Src : Maria DB"
    disId=$(lsb_release -is);
    if [[ "$disId" == "Ubuntu" ]] || [[ "$disId" == "Ubuntu" ]]; then
        codeName=$(lsb_release -cs);
        echo "$codeName Detected , install src.........";
        apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
        add-apt-repository "deb [arch=amd64,i386] http://mirrors.dotsrc.org/mariadb/repo/10.2/ubuntu $codeName main";
        #        test add-apt-repository 'deb [arch=amd64,i386] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.2/ubuntu zesty main';
        updateSrc
    else
        echo "Not ubuntu. Existing............";
        exit 10;
    fi
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
    mariaSrc
    read -p "Do u want to run install cmd (including post-install script , u should ignore it if u\'re using LISH shell)\nYes / no ?" runPostInsMaria
    if [[ "$runPostInsMaria" != "n" ]] && [[ "$runPostInsMaria" != "N" ]];
    then
        apt-get install mariadb-server -y
        echo Stopping MYSQL
        service mysql stop
        mkdir /var/run/mysqld/
        chown mysqld /var/run/mysqld/
        service mysql start
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

function ennablePhp5.6
{
    a2dismod php7.1
    a2dismod php7.0
    a2enmod php5.6
    update-alternatives --set php /usr/bin/php5.6
    service apache2 restart
}

#PHP 5.6
function insPhp5
{
    echo "Installing PHP 5.6"
    add-apt-repository ppa:ondrej/php
    updateSrc
    apt-get install php5.6 php5.6-common php5.6-dev php5.6-curl php5.6-imagick php5.6-intl php5.6-json php5.6-mcrypt php5.6-xml php5.6-pear php5.6-dom php5.6-dg php5.6-mbstring php5.6-zip php5.6-soap -y
    apt-get install libapache2-mod-php5.6 -y
    ennablePhp5.6
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
    enablePhp5.6
    udtPhpMyAdmin
    printf "\e[33m PHP-My-Admin : Done ! \e[0m \n "
}

function udtPhpMyAdmin
{
    read -p "Update phpmyadmin ? (Y/n)" isUdtMyadmin
    if [[ "$isUdtMyadmin" != "n" ]] && [[ "$isUdtMyadmin" != "N" ]];
    then
        MyadmVer="4.7.5"
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
    apt-get install php5.6-memcached -y
    phpenmod memcached
    service apache2 restart
}

#Adding packages source list....
setHostName
echo "Checking & Adding packages source list...."
updateSrc
backportSrcInstall
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
