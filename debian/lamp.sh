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

echo -e $'
         \e[31mM""""""""`M            dP\e[0m
         \e[31mMmmmmm   .M            88\e[0m
         \e[31mMMMMP  .MMM  dP    dP  88  .dP   .d8888b.\e[0m
         \e[31mMMP  .MMMMM  88    88  88888"    88\'  `88\e[0m
         \e[31mM\' .MMMMMMM  88.  .88  88  `8b.  88.  .88\e[0m
         \e[31mM         M  `88888P\'  dP   `YP  `88888P\'\e[0m
         \e[31mMMMMMMMMMMM    \e[36m-*-\e[0m  \e[4;32mCreated by Zuko\e[0m  \e[36m-*-\e[0m\e[0m
         
         \e[35m* * * * * * * * * * * * * * * * * * * * *\e[0m
         D.E.B.I.A.N  \e[32mE.A.S.Y\e[0m  L.A.M.P  \e[36mS.T.A.C.K\e[0m
         \e[35m* * * * * * * * * * * * * * * * * * * * *\e[0m
         \e[1;33m!  Just for running & serving the web  !\e[0m

         SUPPORTED Versions: Debian 8 Wheezy,9 Stretch, 10 Buster
         ';

if [[ "$(whoami)" != "root" ]]; then echo "         ERROR: This script can only work with root. Bye bye !"; exit; fi

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
        elif [[ "$codeName" == "stretch" ]]; then
            echo "Stretch - Debian 9";
            return 0;
        elif [[ "$codeName" == "jessie" ]]; then
            echo "Jessie";
            return 0;
        elif [[ "$codeName" == "buster" ]]; then
            echo "Buster - Debian 10";
            return 0;
        elif [[ "$codeName" == "bullseye" ]]; then
            echo "Bullseye - Debian 11";
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
            echo 'INFO: Wheezy Detected , installing';
            dotDebSrcWheezy
        elif [[ "$codeName" == "jessie" ]]; then
            echo "INFO: Jessie Detected , installing";
            dotDebSrcJessie
        elif [[ "$codeName" == "stretch" ]]; then
            echo "INFO: Stretch Detected , installing";
            if ! grep -q 'stretch' /etc/apt/sources.list.d/backport.list; then
              echo "deb http://ftp.debian.org/debian stretch-backports main contrib non-free
deb-src http://ftp.debian.org/debian stretch-backports main contrib non-free" > /etc/apt/sources.list.d/backport.list ;
            fi
            addSrcSury
            updateSrc
        elif [[ "$codeName" == "buster" ]]; then
            echo "INFO: Buster - Debian 10 Detected , installing";
            if ! grep -q 'buster' /etc/apt/sources.list.d/backport.list; then
              echo "deb http://deb.debian.org/debian buster-backports main contrib non-free
deb-src http://deb.debian.org/debian buster-backports main contrib non-free" > /etc/apt/sources.list.d/backport.list ;
            fi
            addSrcSury
            updateSrc
         elif [[ "$codeName" == "bullseye" ]]; then
            echo "INFO: Buster - Debian 11 Detected , installing";
            if ! grep -q 'bullseye' /etc/apt/sources.list.d/backport.list; then
              echo "deb http://deb.debian.org/debian bullseye-backports main contrib non-free
deb-src http://deb.debian.org/debian bullseye-backports main contrib non-free" > /etc/apt/sources.list.d/backport.list ;
            fi
            addSrcSury
            updateSrc
        else
            #NOT SUPPORTED !
            echo "NOT SUPPORTED OS , STOP !";
            exit;
        fi
    else
        return 10;
    fi
}

function addSrcSury
{
  if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
  fi

  ${SUDO} apt-get -y install apt-transport-https lsb-release ca-certificates
  ${SUDO} wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
  ${SUDO} sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php-sury.list'
}

#DOTDEB PACKAGES
function dotDebSrcWheezy
{
    if ! grep -q 'dotdeb.org' /etc/apt/sources.list.d/dotdeb.list; then
        echo "INFO: Add Src : dotDeb 7"
        echo "deb http://packages.dotdeb.org wheezy all
        deb-src http://packages.dotdeb.org wheezy all
        deb http://packages.dotdeb.org wheezy-php56-zts all
        deb-src http://packages.dotdeb.org wheezy-php56-zts all" > /etc/apt/sources.list.d/dotdeb.list
        echo "INFO: Getting Src key\n"
        wget https://www.dotdeb.org/dotdeb.gpg
        apt-key add dotdeb.gpg
        updateSrc
    fi
}

#DOTDEB PACKAGES
function dotDebSrcJessie
{
    if ! grep -q 'dotdeb.org' /etc/apt/sources.list.d/dotdeb.list; then
        echo "INFO: adding apt source list......."
        echo "deb http://packages.dotdeb.org jessie all
        deb-src http://packages.dotdeb.org jessie all" > /etc/apt/sources.list.d/dotdeb.list
        echo "INFO: Getting Src key"
        wget https://www.dotdeb.org/dotdeb.gpg
        apt-key add dotdeb.gpg
        updateSrc
    fi
}

#UPDATE APT SOURCE
function updateSrc()
{
    echo "INFO: UPDATE APT SOURCE...."
    apt-get update -y
}

#MARIA-DB DEB SRC
function mariaSrcWheezy
{
    echo "INFO: Add Src : Maria DB for Debian Wheezy"
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
    add-apt-repository 'deb [arch=amd64,i386] http://mirror.rackspace.com/mariadb/repo/10.3/debian wheezy main'
    updateSrc
}

function mariaSrcJessie
{
    echo "INFO: Add Src : Maria DB for Debian Jessie"
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
    echo "deb [arch=amd64,i386] http://mirror.rackspace.com/mariadb/repo/10.3/debian jessie main
deb-src http://mirror.rackspace.com/mariadb/repo/10.3/debian jessie main" > /etc/apt/sources.list.d/maria-db.list
    updateSrc
}

function mariaSrcStretch
{
    echo "INFO: Add Src : Maria DB 10.3 for Debian Stretch"
    apt-get install software-properties-common dirmngr -y
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
    add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirror.rackspace.com/mariadb/repo/10.3/debian stretch main'
    updateSrc
}
function mariaSrcDeb10
{
    echo "INFO: Add Src : Maria DB v10.5 for Debian 10 (Mirror Rackspace)"
    apt-get install software-properties-common dirmngr -y
    apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
    add-apt-repository 'deb [arch=amd64] https://mirror.rackspace.com/mariadb/repo/10.5/debian buster main'
    updateSrc
}
function mariaSrcDeb11
{
    echo "INFO: Add Src : Maria DB v10.5 for Debian 11 (Mirror Rackspace)"
    apt-get install software-properties-common dirmngr -y
    apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
    add-apt-repository 'deb [arch=amd64] https://mirror.rackspace.com/mariadb/repo/10.5/debian bullseye main'
    updateSrc
}

#APACHE
function insApache
{
    echo "INFO: Installing Apache 2.4.........."
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
            echo 'INFO: Wheezy Detected , installing src';
            mariaSrcWheezy
        elif [[ "$codeName" == "jessie" ]]; then
            echo "INFO: Jessie Detected , installing src";
            mariaSrcJessie
        elif [[ "$codeName" == "stretch" ]]; then
            echo "INFO: stretch Detected , installing src";
            mariaSrcStretch
        elif [[ "$codeName" == "buster" ]]; then
            echo "INFO: Debian 10 (buster) Detected , installing maria src";
            mariaSrcDeb10
         elif [[ "$codeName" == "bullseye" ]]; then
            echo "INFO: Debian 11 (bullseye) Detected , installing maria src";
            mariaSrcDeb11
        else
            #NOT SUPPORTED !
            echo "NOT SUPPORTED OS , STOP !";
            exit;
        fi
    else
        return 10;
    fi
    read -p "Do u want to run install cmd (including post-install script , u should ignore it if u're using LISH shell). Y/n ?" runPostInsMaria
    if [[ "$runPostInsMaria" != "n" ]] && [[ "$runPostInsMaria" != "N" ]];
    then
        apt-get remove --purge mysql* -y
        apt-get remove --purge mysql -y
        apt-get install mariadb-server -y
        mysql_secure_installation
    fi
    printf "\e[33m MARIA-DB : Done ! \e[0m \n "
}

#NODE JS
function postInsNode
{
    apt-get install -y build-essential
    npm install -g npm
}
function insNode14x
{
    echo "INFO :Start Install NODEJS 14.x .........."
    apt-get install python-software-properties curl -y
    curl -sL https://deb.nodesource.com/setup_14.x | bash -
    apt-get install -y nodejs
    postInsNode
    printf "\e[33m NODEJS 12.x : Done ! \e[0m \n "
}
function insNode12x
{
    echo "INFO :Start Install NODEJS 12.x .........."
    apt-get install python-software-properties curl -y
    curl -sL https://deb.nodesource.com/setup_12.x | bash -
    apt-get install -y nodejs
    postInsNode
    printf "\e[33m NODEJS 12.x : Done ! \e[0m \n "
}

function insNode6x
{
    echo "INFO :Start Install NODEJS.........."
    apt-get install python-software-properties curl -y
    curl -sL https://deb.nodesource.com/setup_6.x | bash -
    apt-get install -y nodejs
    postInsNode
    printf "\e[33m NODEJS 6.x : Done ! \e[0m \n "
}

function insNode
{
    echo "INFO :Preparing install NODEJS.........."
    PS3='Select version to install : '
    options=("NodeJs 6.x" "NodeJs 12.x" "NodeJs 14.x" "Cancel")
    select opt in "${options[@]}"
    do
        case $opt in
            "NodeJs 6.x")
                echo "INFO :Installing....";
                insNode6x;
                break
                ;;
            "NodeJs 12.x")
                echo "INFO :Installing....";
                insNode12x;
                break
                ;;
            "NodeJs 14.x")
                echo "INFO :Installing....";
                insNode14x;
                break
                ;;
            "Cancel")
                echo "INFO :Skipping install Node JS";
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

#GIT
function insGit
{
    echo "INFO :Installing Git.........."
    apt-get install git -y
    printf "\e[33m GIT : Done ! \e[0m \n "
}

function enablePhp70
{
    a2dismod php5
    a2dismod php7.1
    a2enmod php7.0
    update-alternatives --set php /usr/bin/php7.0
    service apache2 restart
}

function enablePhp71
{
    a2dismod php5
    a2dismod php7.0
    a2dismod php7.2
    a2dismod php7.3
    a2enmod php7.1
    a2enmod proxy_fcgi setenvif
    a2enconf php7.1-fpm
    update-alternatives --set php /usr/bin/php7.1
    service apache2 restart
    service php7.1-fpm restart
}

function enablePhp73
{
    echo "INFO :Enabling PHP 7.3 FPM"
    a2dismod php5
    a2dismod php7.0
    a2dismod php7.1
    a2dismod php7.2
#    a2enmod php7.3
    a2enmod proxy_fcgi setenvif
    a2disconf php7.0-fpm
    a2disconf php7.1-fpm
    a2disconf php7.2-fpm
    a2disconf php7.4-fpm
    a2enconf php7.3-fpm
    update-alternatives --set php /usr/bin/php7.3
    service apache2 restart
    service php7.3-fpm restart
}

function enablePhp74
{
    echo "INFO :Enabling PHP 7.3 FPM"
    a2dismod php5
    a2dismod php7.0
    a2dismod php7.1
    a2dismod php7.2
    a2dismod php7.3
#    a2enmod php7.3
    a2enmod proxy_fcgi setenvif
    a2disconf php7.0-fpm
    a2disconf php7.1-fpm
    a2disconf php7.2-fpm
    a2disconf php7.3-fpm
    a2enconf php7.4-fpm
    update-alternatives --set php /usr/bin/php7.3
    service apache2 restart
    service php7.4-fpm restart
}

#PHP 5.6
function insPhp5
{
    echo "INFO :Installing PHP 5.6-ZTS.........."
    apt-get install php5 php5-dev php5-curl php5-imagick php5-intl php5-json php5-mcrypt php5-xsl php-pear -y
    apt-get install libapache2-mod-php5 -y
    a2enmod php5
    service apache2 restart
    printf "\e[33m PHP : Done ! \e[0m \n "
}

function insPhp70
{
    echo "INFO :Installing PHP 7.0"
    apt-get install php7.0 php7.0-common php7.0-dev php7.0-gd php7.0-curl php7.0-imagick php7.0-intl php7.0-json php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-xml php7.0-zip -y
    apt-get install libapache2-mod-php7.0 -y
    enablePhp70
}

function insPhp71
{
    echo "INFO :Installing PHP 7.1 (with FPM) .........."
    apt-get install php7.1 php7.1-fpm php7.1-common php7.1-dev php7.1-gd php7.1-curl php7.1-imagick php7.1-intl php7.1-json php7.1-mbstring php7.1-mcrypt php7.1-mysql php7.1-xml php7.1-zip -y
    apt-get install libapache2-mod-php7.1 -y
    enablePhp71
}

function insPhp73
{
    echo "INFO :Installing PHP 7.3 (with FPM, No Apache Module) .........."
    apt-get install php7.3 php7.3-bcmath php7.3-bz2 php7.3-cli php7.3-common php7.3-curl php7.3-fpm php7.3-gd php7.3-json php7.3-mbstring php7.3-mysql php7.3-opcache php7.3-readline php7.3-xml php7.3-zip -y
    enablePhp73
}

function insPhp74
{
    echo "INFO :Installing PHP 7.4 (with FPM, No Apache Module) .........."
    apt-get install php7.4 php7.4-bcmath php7.4-bz2 php7.4-cli php7.4-common php7.4-curl php7.4-fpm php7.4-gd php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-readline php7.4-xml php7.4-zip -y
    enablePhp74
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

function udtPhpMyAdmin
{
    # MyadmVer="4.7.5"
    # read -p "Update phpMyAdmin to $MyadmVer ? (Y/n)" isUdtMyadmin
    # if [[ "$isUdtMyadmin" != "n" ]] && [[ "$isUdtMyadmin" != "N" ]];
    # then
        # MyadmPath=/usr/share/phpmyadmin
        # cd ${MyadmPath};
        # cp -rvf ${MyadmPath} ${MyadmPath}-backup
        # echo "Downloading phpMyAdmin v$MyadmVer";
        # wget https://files.phpmyadmin.net/phpMyAdmin/${MyadmVer}/phpMyAdmin-${MyadmVer}-all-languages.zip;
        # unzip phpMyAdmin-${MyadmVer}-all-languages
        # cp -rvf phpMyAdmin-${MyadmVer}-all-languages/* ${MyadmPath}
        # printf "\e[33m Update PHP-My-Admin : v$MyadmVer Done ! \e[0m \n "
    # fi
  curl -sL https://raw.githubusercontent.com/zuko-xdev/sh-repo/master/common/update-phpmyadmin.sh | bash -
}

function makeSwap
{
  curl -sL https://raw.githubusercontent.com/zuko-xdev/sh-repo/master/common/mkswap.sh | bash -
}

#PHP-My-Admin
function insPhpMyAdmin
{
    if [ "$(lsb_release -cs)" == "buster" ]; then
        echo "INFO : install php-twig on Debian 10"
        apt-get install -t buster-backports install php-twig -y
    elif [ "$(lsb_release -cs)" == "bullseye" ]; then
        echo "INFO : install php-twig on Debian 11"
        apt-get install -t bullseye-backports install php-twig -y
    fi
    apt-get install phpmyadmin -y
    service apache2 restart
    #udtPhpMyAdmin
    printf "\e[33m PHP-My-Admin : Done ! \e[0m \n "
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
echo "INFO :Checking & Adding packages source list...."
dotDebSrcInstall

# read -p "Make Swap Partion ? (Y/n)" swsp
# if [[ "$swsp" != "n" ]] && [[ "$swsp" != "N" ]]; then
    # makeSwap
# fi

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

read -p "Install PHP ? (Y/n)" php
if [[ "$php" != "n" ]] && [[ "$php" != "N" ]];
then
    PS3='Select version to install : '
    options=("PHP 5.6" "PHP 7.0" "PHP 7.1" "PHP 7.3" "PHP 7.4" "Cancel")
    select opt in "${options[@]}"
    do
        case $opt in
            "PHP 5.6")
                echo "INFO :Installing....";
                insPhp5;
                break
                ;;
            "PHP 7.0")
                echo "INFO :Installing....";
                insPhp70;
                break
                ;;
            "PHP 7.1")
                echo "INFO :Installing....";
                insPhp71;
                break
                ;;
            "PHP 7.3")
                echo "INFO :Installing....";
                insPhp73;
                break
                ;;
            "PHP 7.4")
                echo "INFO :Installing....";
                insPhp74;
                break
                ;;
            "Cancel")
                echo "INFO :Skipping install PHP";
                break
                ;;
            *) echo "INFO :invalid option $REPLY";;
        esac
    done
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
