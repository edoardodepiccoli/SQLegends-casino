#!/bin/bash

clear

set -e

DB_NAME="sqlegends-casino"
USER=$(whoami)
SQL_FILE="schema.sql"

echo "------ dropping database ---------"
dropdb -U "$USER" "$DB_NAME"

echo "------ creating database ---------"
createdb -U "$USER" "$DB_NAME"

echo "------ syncing database ---------"
psql -U "$USER" -d "$DB_NAME" -f "$SQL_FILE"

echo "------ database synced ---------"
