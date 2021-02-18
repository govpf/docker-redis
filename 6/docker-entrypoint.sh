#!/bin/bash
set -e

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [[ "${!var:-}" ]] && [[ "${!fileVar:-}" ]]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [[ "${!var:-}" ]]; then
		val="${!var}"
	elif [[ "${!fileVar:-}" ]]; then
		val="$(< "${!fileVar}")"
	fi
    export "$var"="$val"
	unset "$fileVar"
}

file_env REDIS_PASSWORD

if [ ! -z "$REDIS_PASSWORD" ]; then
    REDIS_AUTH=" --requirepass ${REDIS_PASSWORD}"
fi

# first arg is `-f` or `--some-option`
# or first arg is `something.conf`
if [ "${1#-}" != "$1" ] || [ "${1%.conf}" != "$1" ]; then
	set -- redis-server "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'redis-server' -a "$(id -u)" = '0' ]; then
	find . \! -user redis -exec chown redis '{}' +
	exec gosu redis "$0" "$@"
fi

exec "${@}" ${REDIS_AUTH}
