#!/bin/bash
if [ "$(whoami)" != 'root' ]; then
    echo $"You have no permission to run $0 as non-root user. Use sudo"
    exit 1;
fi
swapsize=1GB
swapname=swap
function getSwapSize {
    echo "Enter Swapfile size in GB unit :"
    read -r size
	if [[ -z "${size//([0-9]+)(\.[0-9]+)?}" ]]; then echo fi 1; fi
	if [[ -n "$size" ]];then echo fi 2; fi
	if [[ "$size" -gt 0 ]];then 
		swapsize=${size}GB;
		makeSwap;
	fi
    if [[ -z "${size//([0-9]+)(\.[0-9]+)?}" ]] && [[ -n "$size" ]]; then
        swapsize=${size}GB;
        return 0;
    else getSwapSize; fi
}
function makeSwap
{
	echo "Creating fallocate file : /${swapname} with size : ${swapsize}"
	fallocate -l ${swapsize} /${swapname}
	echo chmod 600 /${swapname}
	chmod 600 /${swapname}
	echo makeSwap
	mkswap /${swapname}
	echo Verify Swap details
	swapon -s
	if grep -Fq swap /etc/fstab
	then
		echo "/etc/fstab have swap config already. skip"
	else
		echo "/$swapname   none    swap    sw    0   0" >> /etc/fstab
		echo "Added swap config to /etc/fstab"
		echo "File contents : "
		cat /etc/fstab
	fi

	if grep -Fq "vm.swappiness" /etc/sysctl.conf
	then
		echo "vm.swappiness already exist in /etc/sysctl.conf";
		echo "current value :"
		grep -F "vm.swappiness" /etc/sysctl.conf;
		echo "You need to modify it manually!";
	else
		echo "Adding vm.swappiness to system config ctl ......."
		echo "
		vm.swappiness=10" >> /etc/sysctl.conf;
		echo "Added contents : ";
		grep -F vm.swappiness /etc/sysctl.conf;
	fi

	if grep -Fq "vm.vfs_cache_pressure" /etc/sysctl.conf
	then
		echo "vm.vfs_cache_pressure already exist in /etc/sysctl.conf";
		echo "current value :"
		grep -F "vm.vfs_cache_pressure" /etc/sysctl.conf;
		echo "You need to modify it manually!";
	else
		echo "Adding vfs_cache_pressure to system config ctl ......."
		echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf;
		echo "Added contents : ";
		grep -F "vm.vfs_cache_pressure" /etc/sysctl.conf;
	fi
	echo "Make swap complete !"
	exit 0
}
getSwapSize
