#!/bin/bash

create_database() {
  dbname=$(zenity --entry --title="Create Database" --text="Enter database name:")
  if [ -z "$dbname" ]; then
    zenity --error --text="No name entered."
  elif [ -d "$DB_PATH/$dbname" ]; then
    zenity --error --text="Database already exists."
  else
    mkdir "$DB_PATH/$dbname"
    zenity --info --text="Database '$dbname' created successfully!"
  fi
}

list_databases() {
  ls "$DB_PATH" > temp.txt
  zenity --text-info --title="Databases" --filename=temp.txt
  rm temp.txt
}

connect_to_database() {
  dbname=$(zenity --entry --title="Connect" --text="Enter database name:")
  if [ -d "$DB_PATH/$dbname" ]; then
    zenity --info --text="Connected to '$dbname'"
    bash db_menu.sh "$dbname"
  else
    zenity --error --text="Database not found."
  fi
}

drop_database() {
  dbname=$(zenity --entry --title="Drop" --text="Enter database name to delete:")
  if [ -d "$DB_PATH/$dbname" ]; then
    rm -r "$DB_PATH/$dbname"
    zenity --info --text="Database '$dbname' deleted."
  else
    zenity --error --text="Database not found."
  fi
}

