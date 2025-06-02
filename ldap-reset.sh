#!/bin/bash
set -e

docker compose down -v
echo "Borrando volúmenes LDAP locales..."
rm -rf ./ldap/data/*
rm -rf ./ldap/config/*
echo "Reconstruyendo imágenes sin caché..."
docker compose build --no-cache
echo "Levantando contenedores..."
docker compose up -d