#!/usr/bin/env bash

# Options:
#		-d "destino"
#		-D "dominio"
#		-s for sogo
#   -m for mail

## FUNCTIONS
usage() {

echo -e "The available options are the following: 
	-d 'virtual mail domain name'
	-D 'backup destination'
	-s for sogo backup
	-m for mail backup \n
An example for backup the Mail and Sogo modules for the domain 'lab.lan' and stores them in '/mnt/externaldrive':
	./zentyal-mail-backup -d lab.lan -D /mnt/externaldrive -m -s"
}


bk_mail() {
	cd /var/vmail/${VDOM}	

	## Creating the tar file for each mailbox
	for usermbox in $(find . -mindepth 1 -maxdepth 1 -type d | cut -d "/" -f2); do
		echo "Backing up the user mailbox: ${usermbox}"
		tar cfz ${DEST}${usermbox}-$(date "+%d-%m-%y").tar.gz ${usermbox}

		## Checking the return code
		if [[ "${?}" -ne 0 ]]; then
			echo "Backup failed for the user: ${usermbox}"
		fi
	done
}


bk_sogo() {
	## Checking if the mysql password is stored
	if [[ ! -f "/var/lib/zentyal/conf/zentyal-mysql.passwd" ]]; then
		echo "The file where the Mysql password is stored is not found."
	  return
	fi

	## Making the database dump
	echo -e "\nBacking up Sogo database."
	mysqldump --single-transaction -u root -p$(cat /var/lib/zentyal/conf/zentyal-mysql.passwd) sogo > ${DEST}sogodb-$(date "+%d-%m-%y").sql 2> ${DEST}sogodb-$(date "+%d-%m-%y").error

	## Checking the return code
	if [[ "${?}" -ne 0 ]]; then
		echo "The dump of the database failed. Check the log file '${DEST}sogodb-$(date "+%d-%m-%y").error'"
	fi
}


## Checking if an argument was set
if [[ ! "${#}" -ge 3 ]] && [[ ! "${#}" -gt 6 ]]; then
	usage
	exit 1
fi

## Setting the variables and calling the functions
while getopts ":d:D:ms" arg; do
	case ${arg} in
		d) 
			VDOM=${OPTARG}

			## Checking if the Virtual Mail directory exists
			if [[ ! -d /var/vmail/${VDOM} ]]; then
				echo "The Virtual Mail Domain '${VDOM}' doesn't exist."
				exit 1
			fi
			;;

		D) 
			DEST=${OPTARG}

			## Checking if the directory where the backup will be stored exist
			if [[ ! -d ${DEST} ]]; then
				echo "The directory doesn't exist. Creating ..."
				mkdir -vp -m 0750 ${DEST}
			fi

			## Checking if the path ends with an forward slash
			if [[ ! $(echo ${DEST} | egrep -o '/$') = '/' ]]; then
				 DEST=$(echo ${DEST} | sed 's#$#/#')
			fi
			;;

		m)
			## Checking if both variables were set and then calling the function
			if [[ -n "${VDOM}" ]] && [[ -n "${DEST}" ]]; then
				bk_mail
			else
				echo -e "You need to set the options '-d' and '-D', both options must be set before '-m' option. \n"
				exit 1
			fi
			;;

		s)
			## Checking if the variable was set and calling the function
			if [[ -n "${DEST}" ]]; then
				bk_sogo
			else
				echo -e "You need to set the options '-D' and must be set before '-s' option. \n"
				exit 1
			fi
			;;
		*)
			usage 
			exit 0
			;;
	esac
done
