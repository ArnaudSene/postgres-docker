#!/bin/bash
# ----------------------------------------------
# DEVOPS --
# Script to deploy a postgres container through
# docker-compose
# ----------------------------------------------
# Required from .env
DATABASE_PASSWORD=$(grep POSTGRES_PASSWORD .env|cut -d"=" -f2)
PGADMIN_DEFAULT_PASSWORD=$(grep PGADMIN_DEFAULT_PASSWORD .env|cut -d"=" -f2)
PGADMIN_DEFAULT_EMAIL=$(grep PGADMIN_DEFAULT_EMAIL .env|cut -d"=" -f2)
POSTGRES_USER=$(grep POSTGRES_USER .env|cut -d"=" -f2)
POSTGRES_USER_EXIST=$(grep "${POSTGRES_USER}" /etc/passwd)

# Required directory and UID:GUID
POSTGRES_DIR="db-data"
PGADMIN_DIR="pgadmin-data"
PGADMIN_PERM=5050

if [ -z "$DATABASE_PASSWORD" ] || [[ "$DATABASE_PASSWORD" =~ "password" ]]
then
    echo "DATABASE_PASSWORD is not set"
    exit 0
fi
# Required PGADMIN_DEFAULT_PASSWORD
if [ -z "$PGADMIN_DEFAULT_PASSWORD" ] || [[ "$PGADMIN_DEFAULT_PASSWORD" =~ "password" ]]
then
    echo "PGADMIN_DEFAULT_PASSWORD is not set"
    exit 0
fi

# Required PGADMIN_DEFAULT_EMAIL
if [ -z "$PGADMIN_DEFAULT_EMAIL" ] || [[ ! "$PGADMIN_DEFAULT_EMAIL" =~ "@" ]]
then
    echo "PGADMIN_DEFAULT_EMAIL is not set"
    exit 0
fi

# Required POSTGRES_USER
if [ -z "$POSTGRES_USER_EXIST" ]
then
    echo "$POSTGRES_USER_EXIST is not set"
    echo "sudo adduser --uid ${PGADMIN_PERM} --disabled-password --gecos '' ${POSTGRES_USER}"
    sudo adduser --uid "${PGADMIN_PERM}" --disabled-password --gecos '' "${POSTGRES_USER}"
fi

PG_HOME=$(grep postgres /etc/passwd|cut -d":" -f6)
## Check directory for POSTGRES_DIR
echo "Check directory ${PG_HOME}/${POSTGRES_DIR}"
if [ ! -d "${PG_HOME}/${POSTGRES_DIR}" ]
then
    echo "Create directory ${PG_HOME}/${POSTGRES_DIR}"
    echo "sudo -u ${POSTGRES_USER} mkdir ${PG_HOME}/${POSTGRES_DIR}"
    sudo -u "${POSTGRES_USER}" mkdir "${PG_HOME}/${POSTGRES_DIR}"
fi

# Check directory on pgadmin
echo "Check directory ${PG_HOME}/${PGADMIN_DIR}"
if [ ! -d "${PG_HOME}/${PGADMIN_DIR}" ]
then
    echo "Create directory ${PG_HOME}/${PGADMIN_DIR}"
    echo "sudo -u ${POSTGRES_USER} mkdir ${PG_HOME}/${PGADMIN_DIR}"
    sudo -u "${POSTGRES_USER}" mkdir "${PG_HOME}/${PGADMIN_DIR}"
fi

# Start Container
/usr/bin/docker compose up