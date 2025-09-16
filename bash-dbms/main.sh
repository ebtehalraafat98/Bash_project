#!/bin/bash

source config.sh
source functions.sh

mkdir -p "$DB_PATH"

while true; do
  choice=$(zenity --list \
    --title="Main Menu" \
    --column="Option" \
    "Create Database" \
    "List Databases" \
    "Connect to Database" \
    "Drop Database" \
    "Exit")

  case $choice in
    "Create Database") create_database ;;
    "List Databases") list_databases ;;
    "Connect to Database") connect_to_database ;;
    "Drop Database") drop_database ;;
    "Exit") break ;;
  esac
done

