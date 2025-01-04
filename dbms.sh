#!/usr/bin/bash 

source config
source features/create_table.sh
source features/insert.sh
source features/rest.sh
source features/delete_row.sh

validate_db_name() {
  if [[ $1 =~ ^[a-z][a-z0-9_]*$ ]]; then
    return 0 # Valid name
  else
    return 1 # Invalid name
  fi
}

db_exists() {
  if [[ -d $db_path/"$1" ]]; then
    return 0 # Exists
  else
    return 1 # Does not exist
  fi
}

not_inside_db() {
  if [[ $(pwd) != $db_path/"$1" ]]; then
    return 0 # Not inside
  else
    return 1 # Inside
  fi
}

create_database() {
  read -p "Please enter Database name: " db_name
  if validate_db_name "$db_name"; then
    if ! db_exists "$db_name"; then
      mkdir -p $db_path/"$db_name" && echo "Database '$db_name' created successfully."
    else
      echo "Error: Database '$db_name' already exists."
    fi
  else
    echo "Error: Invalid database name. Must start with a lowercase letter and contain only lowercase letters, digits and _."
  fi
}

list_databases() {
  if [[ -d $db_path ]]; then
    echo "Available Databases:"
    ls $db_path | awk '{print "+ " $0}' 
  else
    echo "No databases found. $db_path directory does not exist."
  fi
}

connect_to_database() {

# validate empty line
  read -p "Please enter Database name: " db_name
  if db_exists "$db_name"; then
    cd $db_path/"$db_name" || echo "Error: Could not connect to database '$db_name'."
    table_menu
  else
    echo "Error: Database '$db_name' does not exist."
  fi
}


drop_database() {
  read -p "Please enter Database name: " db_name
  if db_exists "$db_name"; then
    if not_inside_db; then
      rm -r $db_path/"$db_name" && echo "Database '$db_name' dropped successfully."
    else
      echo "Error: Cannot drop the database while inside it."
    fi
  else
    echo "Error: Database '$db_name' does not exist."
  fi
}

main_menu(){
	while true; do
	clear
	echo "Main Menu:"
	echo "1) Create Database"
	echo "2) List Databases"
	echo "3) Connect To Database"
	echo "4) Drop Database"
	echo "5) Exit"
	echo
	read -p "Choose an option [1-5]: " choice

	case $choice in
		1)
			create_database
		    ;;
		2)
		    list_databases
		    ;;
	  	3)
		    connect_to_database
		    ;;
	  	4)
		    drop_database
		    ;;
	  	5)
		    echo "Exiting..."
		    break
		    ;;
	  	*)
		    echo "Invalid option. Please try again."
		    ;;
	esac
    read -p "Press Enter to return to the menu..."
 done 
}

#________________________________________________________________________#


table_menu() {
	while true; do 
	clear
	echo "Table Menu:"
	echo "1) Create Table"
	echo "2) List Tables"
	echo "3) Drop Table"
	echo "4) Insert into Table"
	echo "5) Select From Table"
	echo "6) Delete From Table"
	echo "7) Update Row"
	echo "8) Exit"
	echo
	read -p "Choose an option [1-8]: " choice

	case $choice in
	  1)
	    create_table .
	    ;;
	  2)
	    list_tables
	    ;;
	  3)
	    drop_table
	    ;;
	  4)
	    insert_into_table
	    ;;
	  5)
	    select_from_table
	    ;;
	  6)
	    delete_flow
	    ;;
	  7)
	    update_row
	    ;;
	  8)
	    echo "Returning to Main Menu..."
	    break
	    ;;
	  *)
	    echo "Invalid option. Please try again."
	    ;;
	esac
    read -p "Press Enter to return to the menu..."
done
}


delete_from_table() {
	echo "delete functionality Not implemented Yet :("
}

update_row() {
	echo "update functionality Not implemented Yet :("
}

main_menu