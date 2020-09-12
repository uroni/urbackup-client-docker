#!/bin/bash
set -e

if [[ "$URBACKUP_SERVER_NAME" == "" ]]
then
	echo "Please specify UrBackup server DNS name/IP via environment variable URBACKUP_SERVER_NAME"
	exit 1
fi

if [[ "$URBACKUP_CLIENT_NAME" == "" ]]
then
	echo "Please specify UrBackup client name via environment variable URBACKUP_CLIENT_NAME"
	exit 1
fi

if [[ "$URBACKUP_CLIENT_AUTHKEY" == "" ]]
then
	echo "Please specify UrBackup client authentication key via environment variable URBACKUP_CLIENT_AUTHKEY"
	exit 1
fi

if [[ "$URBACKUP_INTERNET_MODE" == "" ]]
then
	echo "Please specify UrBackup client mode (Internet/LAN) via environment variable URBACKUP_INTERNET_MODE (true/false)"
	exit 1
fi

setup() {
	urbackupclientctl wait-for-backend
	
	IFS=':'
	for dir in $URBACKUP_BACKUP_VOLUMES
	do
		echo "Backing up volume $dir"
		urbackupclientctl add -d "$dir"
	done
	unset IFS
	
	urbackupclientctl set-settings \
		-k internet_mode_enabled -v "$URBACKUP_INTERNET_MODE" \
		-k internet_server -v "$URBACKUP_SERVER_NAME" \
		-k internet_server_port -v "$URBACKUP_SERVER_PORT" \
		-k computername -v "$URBACKUP_CLIENT_NAME" \
		-k internet_authkey -v "$URBACKUP_CLIENT_AUTHKEY"
		
	if [[ "$URBACKUP_SERVER_PROXY" != "" ]]
	then
		urbackupclientctl set-settings \
			-k internet_server_proxy -v "$URBACKUP_SERVER_PROXY"
	fi
	
	if [[ "$URBACKUP_CLIENT_MYSQL_BACKUP" == "1" ]]
	then
		cat << EOF > /usr/local/etc/urbackup/mariadbdump.conf
#Enable MariaDB dump backup
MARIADB_DUMP_ENABLED=1

#Backup user account
MARIADB_BACKUP_USER=$MYSQL_USER

#Backup user password
MARIADB_BACKUP_PASSWORD=$MYSQL_PASSWORD

MARIADB_DUMP="mysqldump --host=$MYSQL_HOST"
EOF
	fi
}

setup &
exec /usr/local/sbin/urbackupclientbackend "$@"
