#!/usr/bin/bash

list_tables() {
  echo "Tables in the current database:"
  if [[ $(ls | wc -l) -gt 0 ]]; then
    ls -1 *.data | cut -d . -f1 | awk '{print "- " $0}'
  else
    echo "No tables found."
  fi
}


drop_table() {
  read -p "Enter the table name to drop: " table_name

  # remove meta file and data file
  if [[ -f "$table_name.meta" ]]; then
    rm "$table_name.meta" && rm "$table_name.data" && echo "Table '$table_name' dropped successfully."
  else
    echo "Error: Table '$table_name' does not exist."
  fi
}


select_from_table() {
  read -p "Enter the table name: " table_name
  if [[ -f "$table_name" ]]; then
    echo "Contents of table '$table_name':"
      column -t -s ',' "$table_name"
  else
    echo "Error: Table '$table_name' does not exist."
  fi
}