#!/bin/bash
# ----------------------------------------------
# DEVOPS --
# Script to deploy a postgres container with
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

# Certificates
CERT_DIR="certs"
CERT_CRT_FILE="pgadmin_server.crt"
CERT_KEY_FILE="pgadmin_server.key"

if [ -z "$DATABASE_PASSWORD" ] || [[ "$DATABASE_PASSWORD" =~ "password" ]]
then
    echo "DATABASE_PASSWORD is not set"
    exit 1
fi
# Required PGADMIN_DEFAULT_PASSWORD
if [ -z "$PGADMIN_DEFAULT_PASSWORD" ] || [[ "$PGADMIN_DEFAULT_PASSWORD" =~ "password" ]]
then
    echo "PGADMIN_DEFAULT_PASSWORD is not set"
    exit 1
fi

# Required PGADMIN_DEFAULT_EMAIL
if [ -z "$PGADMIN_DEFAULT_EMAIL" ] || [[ ! "$PGADMIN_DEFAULT_EMAIL" =~ "@" ]]
then
    echo "PGADMIN_DEFAULT_EMAIL is not set"
    exit 1
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
if [ ! -d "${PG_HOME}/${POSTGRES_DIR}" ]
then
    echo "Create directory ${PG_HOME}/${POSTGRES_DIR}"
    echo "sudo -u ${POSTGRES_USER} mkdir ${PG_HOME}/${POSTGRES_DIR}"
    sudo -u "${POSTGRES_USER}" mkdir "${PG_HOME}/${POSTGRES_DIR}"
fi

# Check directory for pgadmin
if [ ! -d "${PG_HOME}/${PGADMIN_DIR}" ]
then
    echo "Create directory ${PG_HOME}/${PGADMIN_DIR}"
    echo "sudo -u ${POSTGRES_USER} mkdir ${PG_HOME}/${PGADMIN_DIR}"
    sudo -u "${POSTGRES_USER}" mkdir "${PG_HOME}/${PGADMIN_DIR}"
fi

# Check directory for certs
if [ ! -d "${PG_HOME}/${CERT_DIR}" ]
then
    echo "Create directory ${PG_HOME}/${CERT_DIR}"
    echo "sudo -u ${POSTGRES_USER} mkdir ${PG_HOME}/${CERT_DIR}"
    sudo -u "${POSTGRES_USER}" mkdir "${PG_HOME}/${CERT_DIR}"
fi


# Check certificates, and copy to tmp dir
CERT_CRT=$(ls ${CERT_DIR}/${CERT_CRT_FILE})
CERT_KEY=$(ls ${CERT_DIR}/${CERT_KEY_FILE})

if [ -z "${CERT_CRT}" ] || [ -z "${CERT_KEY}" ]
then
  echo "Certificate missing"
  exit 1
fi


if [ ! -f "${PG_HOME}/${CERT_DIR}/${CERT_CRT_FILE}" ] || [ ! -f "${PG_HOME}/${CERT_DIR}/${CERT_KEY_FILE}" ]
then
  echo "sudo cp ${CERT_DIR}/pgadmin_server.* ${PG_HOME}/${CERT_DIR}/"
        sudo cp ${CERT_DIR}/pgadmin_server.* "${PG_HOME}/${CERT_DIR}/"

  echo "sudo chown -R ${POSTGRES_USER}:${POSTGRES_USER} ${PG_HOME}/${CERT_DIR}"
        sudo chown -R "${POSTGRES_USER}":"${POSTGRES_USER}" "${PG_HOME}/${CERT_DIR}"

  echo "sudo chmod 400 ${PG_HOME}/${CERT_DIR}/${CERT_KEY_FILE}"
        sudo chmod 400 "${PG_HOME}/${CERT_DIR}/${CERT_KEY_FILE}"
fi

# Start Container
/usr/bin/docker compose up -d
