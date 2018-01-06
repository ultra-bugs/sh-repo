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
GITFILE='https://github.com/magebay99/magento-product-designer-tools/archive/master.zip';
TMPINSTALLDIR='m1connect';
ZipFileName='master.zip';
scrDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
echo "Wellcome to PDP Shell installer script";
read -p "Input Magento Root Directory Full Path : " m2path
cd ${m2path};
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
    wget ${GITFILE};
    unzip ${ZipFileName};
    cp -R -b -f -v ./magento-product-designer-tools-master/skin/* ../skin
    cp -R -b -f -v ./magento-product-designer-tools-master/app/* ../app
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
    printf "\e[33m Removing installer script file it-self.........  \e[0m \n "
    rm "${scrDir}/$(basename "${0}")"
    echo "Clean completed , Head to magento backend to config the connector !;";
fi