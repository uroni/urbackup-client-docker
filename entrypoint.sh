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
}

setup &
exec /usr/local/sbin/urbackupclientbackend "$@"
