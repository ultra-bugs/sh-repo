#!/bin/bash
# Git clean untracked files & reset to newest commit on current branch
# By: Zuko
echo '';
echo '';
echo -e $'
         \e[31mM""""""""`M            dP\e[0m
         \e[31mMmmmmm   .M            88\e[0m
         \e[31mMMMMP  .MMM  dP    dP  88  .dP   .d8888b.\e[0m
         \e[31mMMP  .MMMMM  88    88  88888"    88\'  `88\e[0m
         \e[31mM\' .MMMMMMM  88.  .88  88  `8b.  88.  .88\e[0m
         \e[31mM         M  `88888P\'  dP   `YP  `88888P\'\e[0m
         \e[31mMMMMMMMMMMM    \e[36m-*-\e[0m  \e[4;32mCreated by Zuko\e[0m  \e[36m-*-\e[0m\e[0m
         ';

echo -e $'
         \e[35m* * * * * * * * * * * * * * * * * * * * *\e[0m
         \e[32m* -    - -   F.R.E.E.M.I.N.D   - -    - *\e[0m
         \e[35m* * * * * * * * * * * * * * * * * * * * *\e[0m
         \e[1;33m!  git clean untracked files & reset  !\e[0m
         ';
echo '';
echo '';
echo "Current working directory: ${PWD}"
if [ -d "${PWD}/.git" ]; then
  echo ".git directory exist"
else
  echo ".git directory DOES NOT EXIST. The script quitting..." && exit 1
fi
echo "Begin dry-run clean untracked files"
git clean -n -d
read -rp "Would you like to continue ? (Y/n)" clrun
if [[ "$clrun" != "n" ]] && [[ "$clrun" != "N" ]];
then
    git clean -f -d
else
  echo "Goodbye !"
  exit 0;
fi
echo "Begin reset"
git checkout -f
echo "Reset success. showing git status"
git status
read -rp "Would you like to pull ? (Y/n)" dopull
if [[ "$dopull" != "n" ]] && [[ "$dopull" != "N" ]];
then
    git pull
else
  echo "Goodbye !"
  exit 0;
fi
