#!/bin/bash
function echo.LightGreen
{
    echo -e "\033[92m$*\033[m"
}
echo $'
         M""""""""`M            dP                     
         Mmmmmm   .M            88                     
         MMMMP  .MMM  dP    dP  88  .dP   .d8888b.     
         MMP  .MMMMM  88    88  88888"    88\'  `88
         M\' .MMMMMMM  88.  .88  88  `8b.  88.  .88
         M         M  `88888P\'  dP   `YP  `88888P\'
         MMMMMMMMMMM    -*-  Created by Zuko  -*-      

         * * * * * * * * * * * * * * * * * * * * *';
GITFILE=https://github.com/magebay99/magento2-product-designer-tools/archive;
useM22xBranch=0;
TMPINSTALLDIR=p2m-connect;
ZipFileName=pdpm2connector.zip;
scrDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
DIRTOCHECK=(app bin pub var vendor);
isMagento="Y";
read -p "Input Magento Root Directory Full Path : " m2path
cd ${m2path}
#TEST IS M2 DIR
echo "Testing Current working dir is magento root";
for i in DIRTOCHECK; do
    if [ -e ./${DIRTOCHECK[i]} ];
    then
        echo "Found ${DIRTOCHECK[i]} , Trying next one";
        echo -e "\n";
    else
        echo "${DIRTOCHECK[i]} NOT Found , NOT in Magento2 root dir. Script will exists !";
        isMagento="n";
        exit 2;
    fi
done
echo Current Working dir is : ${PWD};
echo -e "\n";
#read -p "Please confirm that is exactly the directory containing the index.php of magento (Y/n)" isMagento
if [[ "$isMagento" != "n" ]] && [[ "$isMagento" != "N" ]];
then
    if [ -d ./${TMPINSTALLDIR} ];
    then
        cd ${TMPINSTALLDIR};
    else
        mkdir ${TMPINSTALLDIR};
        cd ${TMPINSTALLDIR};
    fi
    echo.LightGreen "Selecting version to deploy depend your magento version."
    echo "-------------------------------------------------------------------------------------";
    echo "Magento 2.0.x, 2.1x will download Module from master branch."
    echo "Otherwise. Anwser Y will downloading from branch was developed for m2.2x"
    echo "If Your Magento is older than 2.2.0. Press Enter";
    echo -e "\n";
    read -p "Is Your Magento version is 2.2.x or higher (N/y) ? " useM22xBranch
    if [[ "$useM22xBranch" != "y" ]] && [[ "$useM22xBranch" != "Y" ]]; then
        dwnlBranch="master";
    else
        dwnlBranch="magento2.2.x";
    fi
    echo -e "\n";
    if [ -e ./${ZipFileName} ]; then
        rm -f ./${ZipFileName};
    fi
    echo "Downloading Module from GIT / ${dwnlBranch} branch";
    wget -O ${ZipFileName} -nv ${GITFILE}/${dwnlBranch}.zip ;
    unzip ${ZipFileName};
    echo -e "\n";
    echo -e "\n";
    cp -R -b -f -v ./magento2-product-designer-tools-${dwnlBranch}/app/* ../app
    echo -e "\n";
    echo "-------------------------------------------------------------------------------------";
    echo -e "\n";
    echo "Files Copies Completed !!!~";
    echo -e "\n";
    echo -e "\n";
    cd ../
    rm -rf ${TMPINSTALLDIR};
    cd bin
    php magento module:enable PDP_Integration
    php magento setup:upgrade
    php magento setup:di:compile
    php magento setup:static-content:deploy
    php magento cache:flush
    printf "\e[33mRemoving installer script file it-self.........  \e[0m \n"
    rm -f "${scrDir}/$(basename "${0}")"
    printf "\e[33mConnector enabled successfully !.  \e[0m \n"
    printf "\e[0m\n"
    printf "\e[0m\n"
    printf "\e[33mPlease visit admin to config module !.  \e[0m \n"
    exit 0;
fi
