#!/usr/bin/env bash

### Only worked on Debian & Ubuntu
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
			checkJq;
			cd ${MyadmPath};
			if [ -e "${MyadmPath}-backup" ]; then rm -rf "${MyadmPath}-backup"; fi
			echo "--- Backing-up your old phpMyAdmin directory ! ---";
			cp -rf ${MyadmPath} ${MyadmPath}-backup
			echo "--- Downloading phpMyAdmin v$MyadmVer ---";
			wget https://files.phpmyadmin.net/phpMyAdmin/${MyadmVer}/phpMyAdmin-${MyadmVer}-all-languages.zip -o "${MyadmPath}/phpMyAdmin-${MyadmVer}-all-languages.zip";
			unzip -o phpMyAdmin-${MyadmVer}-all-languages.zip
			cp -rf phpMyAdmin-${MyadmVer}-all-languages/* ${MyadmPath}
			printf "\e[33m Update PHP-My-Admin : v$MyadmVer Done ! \e[0m \n "
		fi
	}
	
	function removeUnzipedFiles()
	{
		toRm=$(find ${MyadmPath} -iname "*all-languages");
		echo $toRm;
		for f in $toRm; do
			echo Removing: $f;
			rm -rf $f;
		done
	}
	main;
	removeUnzipedFiles;
}
udtPhpMyAdmin;
