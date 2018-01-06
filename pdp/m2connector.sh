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
GITFILE='https://github.com/magebay99/magento2-product-designer-tools/archive/master.zip';
TMPINSTALLDIR='m2connect';
ZipFileName='master.zip';
scrDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
#DIRTOCHECK=( app bin pub var vendor );
read -p "Input Magento Root Directory Full Path : " m2path
cd ${m2path}
#TEST IS M2 DIR
#echo "Testing Current working dir is magento root";
#for i in DIRTOCHECK; do
#    if ! [ -d $(${PWD}/${DIRTOCHECK[i]}) ];
#    then
#        echo Found ${DIRTOCHECK[i]} , Trying next one;
#    else
#        echo ${DIRTOCHECK[i]} Found , NOT in Magento2 root dir. Script will exists !;
#        exit;
#    fi
#done
echo Current Working dir is : ${PWD};
echo \n;
read -p "Please confirm that is exactly the directory containing the index.php of magento (Y/n)" isMagento
if [[ "$isMagento" != "n" ]] && [[ "$isMagento" != "N" ]];
then
    if [ -d ./${TMPINSTALLDIR} ];
    then
        cd ${TMPINSTALLDIR};
    else
        mkdir ${TMPINSTALLDIR};
        cd ${TMPINSTALLDIR};
    fi
    echo "Downloading Module from GIT / Master branch";
    wget ${GITFILE};
    unzip ${ZipFileName};
    # cp -R -b -f -v ./magento2-product-designer-tools-master/skin/ ../skin
    cp -R -b -f -v ./magento2-product-designer-tools-master/app/* ../app
    echo \n;
    echo \n;
    echo \n;
    echo "-------------------------------------------------------------------------------------";
    echo \n;
    echo "Files Copies Completed !!!~";
    echo \n;
    echo \n;
    cd ../
    rm -rf ${TMPINSTALLDIR};
    # read -p "Input Version Surfix : " vzip
    # wget https://jp.zuko.pw/exec/pdp-connector-m2-${vzip}.zip
    # unzip pdp-connector-m2-${vzip}.zip
    cd bin
    php magento module:enable PDP_Integration
    php magento setup:upgrade
    php magento setup:di:compile
    php magento setup:static-content:deploy
    php magento cache:flush
    printf "\e[33m Removing installer script file it-self.........  \e[0m \n "
    rm "${scrDir}/$(basename "${0}")"
    printf "\e[33m Connector enabled successfully !.  \e[0m \n "
    printf "\e[0m \n "
    printf "\e[0m \n "
    printf "\e[33m Please visit admin to config module !.  \e[0m \n "
fi
