#!/bin/sh
action=$1
mt="$(pwd)/../.."
ins="$(pwd)"
alias pgsql="$mt/dependencies/postgresql-8.2/part/bin/pg_ctl -D $ins/var/pgsql -l $ins/logfile $action"
alias psql="$mt/dependencies/postgresql-8.2/part/bin/psql"



