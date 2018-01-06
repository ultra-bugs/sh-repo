#!/bin/bash

installDir=/usr/local/im7
echo Installing GCC Compiler & Lib RSVG ( For SVG Support in Imagick ) ...........
apt-get update -y
apt-get install gcc -y
apt-get install librsvg2-dev -y
wget https://www.imagemagick.org/download/ImageMagick.tar.gz -o ImageMagick.tar.gz
tar xvzf ImageMagick.tar.gz
srcDir=$(ls | grep ImageMagick-)
if [ -d $srcDir ]; then
    cd $srcDir
    ./configure --prefix=${installDir} --with-gslib --with-rsvg
    echo Running MAKE ...........
    make
    echo Running INSTALL ...........
    make install
    echo Cleanup .............
    make clean
else
    echo Khong tim thay ImageMagick Source. Exit !;
fi