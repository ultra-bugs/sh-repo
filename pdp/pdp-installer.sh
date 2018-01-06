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

         * * * * * * * * * * * * * * * * * * * * *';
scrDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
if [ -d "${scrDir}/designer" ];
then
    cd "${scrDir}/designer";
    echo DEBUG : cd into ${scrDir}/designer;
else
    mkdir "${scrDir}/designer";
    cd "${scrDir}/designer";
    echo DEBUG: Make dir : "${scrDir}/designer" then cd into it.
fi
echo "Wellcome to PDP Shell installer script"
printf "\n"
printf "\e[34mFirstly : Please make sure you ran this script from \e[31mfolder which PDP directory will be live in\e[34m .\n Ex : magento root folder , and PDP is sub-directory in it\e[0m \n"
read -p "Please input version (numberic only , can containt dot) : " pdpVer
wget https://jp.zuko.pw/exec/pdp2016-${pdpVer}.zip
wget https://jp.zuko.pw/exec/vendor-${pdpVer}.zip
if [ ! -f pdp2016-$pdpVer.zip ];
then
    printf "\e[36mCant find pdp2016-$pdpVer.zip. Installer Exist !\e[0m \n";
    exit 10;
fi
if [ ! -f vendor-$pdpVer.zip ];
then
    printf "\e[36mCant find pdp2016-$pdpVer.zip. Installer Exist !\e[0m \n";
    exit 10;
fi
unzip -o pdp2016-${pdpVer}
unzip -o vendor-${pdpVer}
rm pdp2016-${pdpVer}.zip
rm vendor-${pdpVer}.zip
chmod -R 777 ./config && chmod -R 777 ./data && chmod -R 777 ./module/Pdp/config && chmod -R 777 ./module/Restful/config
read -p "Input MySql Host : " mhost
#read -p "Input MySql Port : " mport
read -p "Input MySql User : " musr
read -p "Input MySql Pwd : " mpwd
read -p "Input MySql DB Name : " mdbname
if [ ! -d ../backup-install-pdp ];
then
    mkdir ../backup-install-pdp
fi
mysqldump -h ${mhost} -u ${musr} -p${mpwd} ${mdbname} > ../backup-install-pdp/db-magento.sql
printf "\e[33m SQL Backup file : ../backup-install-pdp/db-magento.sql ! \e[0m \n "
printf "\e[33m Please visit PDP install page and do a basic installation.  \e[0m \n "
read -p "Press any key when u finished basic installation stage" isInstalled
read -p "Install sample data package ? Type : N to cancel ." sampleIns
if [ $sampleIns = "n" ] || [ $sampleIns = "N" ]
then
    printf "\e[33m PDP had installed successfully !.  \e[0m \n ";
    exit 0;
fi

printf "\e[33m Downloading sample data package.....  \e[0m \n "
wget https://jp.zuko.pw/exec/sample-data-pdp.sql
wget https://jp.zuko.pw/exec/data1.zip
unzip -o data1
rm data1.zip
mysql -h ${mhost} -u ${musr} -p${mpwd} ${mdbname} < ./sample-data-pdp.sql
rm sample-data-pdp.sql
printf "\e[33m Sample data install successfully !.  \e[0m \n "
printf "\e[0m \n "
printf "\e[0m \n "
printf "\e[33m Removing installer script file it-self.........  \e[0m \n "
rm "${scrDir}/$(basename "${0}")"
printf "\e[33m PDP had installed successfully !.  \e[0m \n "
exit 0;