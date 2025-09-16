#!/bin/bash

source config.sh

DB_NAME="$1"
TABLE_PATH="$DB_PATH/$DB_NAME"

create_table() {
  tablename=$(zenity --entry --title="Create Table" --text="Enter table name:")
  if [ -z "$tablename" ]; then
    zenity --error --text="No table name entered."
    return
  elif [ -f "$TABLE_PATH/$tablename" ]; then
    zenity --error --text="Table already exists."
    return
  fi

  cols=$(zenity --entry --title="Columns" --text="Enter column names separated by comma (e.g. id,name,age):")
  types=$(zenity --entry --title="Types" --text="Enter types for each column (e.g. int,string,int):")
  pk=$(zenity --entry --title="Primary Key" --text="Enter name of primary key column:")

  echo "$cols" > "$TABLE_PATH/$tablename"
  echo "$types" >> "$TABLE_PATH/$tablename"
  echo "$pk" >> "$TABLE_PATH/$tablename"

  zenity --info --text="Table '$tablename' created successfully!"
}

list_tables() {
  ls "$TABLE_PATH" > temp.txt
  zenity --text-info --title="Tables in $DB_NAME" --filename=temp.txt
  rm temp.txt
}

drop_table() {
  tablename=$(zenity --entry --title="Drop Table" --text="Enter table name to delete:")
  if [ -f "$TABLE_PATH/$tablename" ]; then
    rm "$TABLE_PATH/$tablename"
    zenity --info --text="Table '$tablename' deleted."
  else
    zenity --error --text="Table not found."
  fi
}

insert_into_table() {
  tablename=$(zenity --entry --title="Insert" --text="Enter table name:")
  if [ ! -f "$TABLE_PATH/$tablename" ]; then
    zenity --error --text="Table not found."
    return
  fi

  IFS=',' read -r -a cols < "$TABLE_PATH/$tablename"
  IFS=',' read -r -a types < <(sed -n '2p' "$TABLE_PATH/$tablename")
  pk=$(sed -n '3p' "$TABLE_PATH/$tablename")

  row=""
  for i in "${!cols[@]}"; do
    value=$(zenity --entry --title="Insert" --text="Enter value for ${cols[i]} (${types[i]}):")
    if [[ "${types[i]}" == "int" && ! "$value" =~ ^[0-9]+$ ]]; then
      zenity --error --text="Invalid integer for ${cols[i]}"
      return
    fi
    if [[ "${cols[i]}" == "$pk" ]]; then
      if grep -q "^$value," "$TABLE_PATH/$tablename"; then
        zenity --error --text="Primary key '$value' already exists."
        return
      fi
    fi
    row+="$value,"
  done
  echo "${row%,}" >> "$TABLE_PATH/$tablename"
  zenity --info --text="Row inserted successfully!"
}

select_from_table() {
  tablename=$(zenity --entry --title="Select" --text="Enter table name:")
  if [ ! -f "$TABLE_PATH/$tablename" ]; then
    zenity --error --text="Table not found."
    return
  fi
  tail -n +4 "$TABLE_PATH/$tablename" > temp.txt
  zenity --text-info --title="Data in $tablename" --filename=temp.txt
  rm temp.txt
}

delete_from_table() {
  tablename=$(zenity --entry --title="Delete" --text="Enter table name:")
  if [ ! -f "$TABLE_PATH/$tablename" ]; then
    zenity --error --text="Table not found."
    return
  fi
  pk=$(sed -n '3p' "$TABLE_PATH/$tablename")
  value=$(zenity --entry --title="Delete" --text="Enter $pk value to delete:")
  grep -v "^$value," "$TABLE_PATH/$tablename" > temp.txt
  head -n 3 "$TABLE_PATH/$tablename" > "$TABLE_PATH/$tablename"
  cat temp.txt >> "$TABLE_PATH/$tablename"
  rm temp.txt
  zenity --info --text="Row with $pk=$value deleted."
}

update_table() {
  tablename=$(zenity --entry --title="Update" --text="Enter table name:")
  if [ ! -f "$TABLE_PATH/$tablename" ]; then
    zenity --error --text="Table not found."
    return
  fi
  pk=$(sed -n '3p' "$TABLE_PATH/$tablename")
  value=$(zenity --entry --title="Update" --text="Enter $pk value to update:")
  new_row=""
  IFS=',' read -r -a cols < "$TABLE_PATH/$tablename"
  IFS=',' read -r -a types < <(sed -n '2p' "$TABLE_PATH/$tablename")

  for i in "${!cols[@]}"; do
    val=$(zenity --entry --title="Update" --text="Enter new value for ${cols[i]} (${types[i]}):")
    if [[ "${types[i]}" == "int" && ! "$val" =~ ^[0-9]+$ ]]; then
      zenity --error --text="Invalid integer for ${cols[i]}"
      return
    fi
    new_row+="$val,"
  done

  head -n 3 "$TABLE_PATH/$tablename" > temp.txt
  grep -v "^$value," "$TABLE_PATH/$tablename" >> temp.txt
  echo "${new_row%,}" >> temp.txt
  mv temp.txt "$TABLE_PATH/$tablename"
  zenity --info --text="Row updated successfully!"
}

while true; do
  choice=$(zenity --list \
    --title="Database: $DB_NAME" \
    --column="Option" \
    "Create Table" \
    "List Tables" \
    "Drop Table" \
    "Insert into Table" \
    "Select From Table" \
    "Delete From Table" \
    "Update Table" \
    "Back to Main Menu")
case $choice in
  "Create Table") create_table ;;
  "List Tables") list_tables ;;
  "Drop Table") drop_table ;;
  "Insert into Table") insert_into_table ;;
  "Select From Table") select_from_table ;;
  "Delete From Table") delete_from_table ;;
  "Update Table") update_table ;;
  "Back to Main Menu") break ;;
esac
done
