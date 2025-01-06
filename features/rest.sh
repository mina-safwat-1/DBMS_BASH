#!/usr/bin/bash

shopt -s nullglob
 

list_tables() {
  # validate that you are inside a database befor calling ot from sql (is_connected)
  echo "Tables in the current database:"
  if [[ $(ls | wc -l) -gt 0 ]]; then
    ls -1 *.data | cut -d . -f1 | awk '{print "- " $0}'
  else
    echo "No tables found."
  fi

}

drop_table() {
  # remove meta file and data file
  if [[ -f "$1.meta" ]]; then
    rm "$1.meta" && rm "$1.data" && echo "Table '$1' dropped successfully."
  else
    echo "Error: Table '$1' does not exist."
  fi
}


# we need to check
select_from_table() {
  table_name="$1.data"
  if [[ -f "$table_name" ]]; then
    echo "Contents of table '$table_name':"
      column -t -s ',' "$table_name"
  else
    echo "Error: Table '$table_name' does not exist."
  fi
}