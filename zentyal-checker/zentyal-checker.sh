#!/usr/bin/env bash

### FUNCTIONS

function system_check () {

echo "##################"
echo "# GENERAL CHECKS #"
echo "##################"

echo -e "\n#####\n## Checking the partition space:\n"

for partitions in $(df -h -x tmpfs  | awk '{if(NR>1)print}' | egrep -v '^udev' | awk '{print $6}'); do

		PARTCHECK=$(df -h ${partitions} | awk '{print $5}' | sed 's/%//' | tail -1)
    if [[ ${PARTCKECK} -gt 80 ]]; then
			echo "Your partition '$partitions' has less than 20 percent available. Check it."
		else
			echo "Your partition '$partitions' is ok."
		fi

done


echo -e "\n#####\n## Checking the state of the system packages:\n"

BNPKG=$(dpkg -l |egrep -v '^ii|rc' | awk '{if(NR>5)print}' | wc -l)
if [[ $BNPKG -gt 0 ]]; then
		echo "You have '${BNPKG}' broken packages."
else
		echo "You don't have any broken packages."
fi


echo -e "\n#####\n## Checking if there are any package for update:\n"

sudo apt-get update > /dev/null

PKGAV=$(apt list --upgradable 2> /dev/null | wc -l)
if [[ ${PKGAV} -gt 0 ]]; then
		echo "You have '${PKGAV}' packages available for update."
else
		echo "Your system are up-to-date."
fi


echo -e "\n#####\n## Checking the mails for the local root user:\n"

if [[ -f /var/mail/root ]] && [[ $(wc -l /var/mail/root | awk '{print $1}') -gt 1 ]]; then
        echo "You have mails for the local root user, you can check the mails by running 'cat /var/mail/root' command."
else
		echo "You don't have any mail for the local root account."
fi


echo -e "\n#####\n## Checking the state of the Mysql databases:\n"
mysqlcheck -u root -p$(cat /var/lib/zentyal/conf/zentyal-mysql.passwd) --all-databases 2> /dev/null
#if [[ $? -eq 0 ]]; then
#		echo "All the databases are ok."
#else
#		echo "There are errors on the databases. Please, check it by running the command: 'mysqlcheck -u root -p$(cat /var/lib/zentyal/conf/zentyal-mysql.passwd) --all-databases'."
#fi

}


function log_files () {

echo "######################"
echo "# ZENTYAL LOG FILE  #"
echo "#######################"

declare -r zentyal_log="/var/log/zentyal/zentyal.log"
declare -A modulosError
declare -A modulosWarning

errormodules=([network]=0 [logs]=0 [mysql]=0 [firewall]=0 [ntp]=0 [dhcp]=0 [dns]=0 [samba]=0 [mail]=0 [sogo]=0 [ca]=0 [openvpn]=0 [ipsec]=0 [squid]=0 [ejabber]=0)
warningmodules=([network]=0 [logs]=0 [mysql]=0 [firewall]=0 [ntp]=0 [dhcp]=0 [dns]=0 [samba]=0 [mail]=0 [sogo]=0 [ca]=0 [openvpn]=0 [ipsec]=0 [squid]=0 [ejabber]=0)

while IFS='' read -r line; do

	for i in "${!errormodules[@]}"; do
		if [[ ${line,,} =~ ${i} && ( ${line} =~ "ERROR>" ) ]]; then
			((errormodules[$i]+=1))
    elif [[ ${line,,} =~ ${i} && ( ${line} =~ "WARN>" ) ]]; then
    	((warningmodules[$i]+=1))
    fi
   done
        
done < "${zentyal_log}"

echo -e "\n## Checking the log file '/var/log/zentyal/zentyal.log':\n"
echo -e "The number of errors found: ${errormodules[@]}"
echo -e "The number of warnings found: ${warningmodules[@]} \n"

}


# Running system_check function
system_check

echo -e "\n"

# Running log_files function
log_files
