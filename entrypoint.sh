#!/bin/bash
set -e

setup() {
	urbackupclientctl wait-for-backend
	urbackupclientctl set-settings \
		-k internet_mode_enabled -v true \
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
