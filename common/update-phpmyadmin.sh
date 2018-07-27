#!/usr/bin/env bash

# Work on Debian & based Debian OS (Ubuntu) only

function udtPhpMyAdmin
{
	function checkJq()
	{
		if ! type -t jq; then
			apt-get update;
			apt-get install jq -y;
		fi
	}

	function main {
		versionUrl='https://www.phpmyadmin.net/home_page/version.json';
		MyadmVer=$(curl $versionUrl -s | jq --raw-output '.version');
        MyadmPath=/usr/share/phpmyadmin		
		read -p "Update phpmyadmin to version :  $MyadmVer ? (Y/n)" isUdtMyadmin
		if [[ "$isUdtMyadmin" != "n" ]] && [[ "$isUdtMyadmin" != "N" ]];
		then
			
			cd ${MyadmPath};
			cp -rf ${MyadmPath} ${MyadmPath}-backup
			echo "Downloading phpMyAdmin v$MyadmVer";
			wget https://files.phpmyadmin.net/phpMyAdmin/${MyadmVer}/phpMyAdmin-${MyadmVer}-all-languages.zip;
			unzip phpMyAdmin-${MyadmVer}-all-languages
			cp -rf phpMyAdmin-${MyadmVer}-all-languages/* ${MyadmPath}
			printf "\e[33m Update PHP-My-Admin : v$MyadmVer Done ! \e[0m \n "
		fi
	}
	checkJq;
	main;
}
udtPhpMyAdmin;
