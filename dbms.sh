#!/usr/bin/bash 

source config
source features/create_table.sh
source features/insert.sh
source features/rest.sh
source features/delete_row.sh
source features/update_table.sh

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

validate_create_db(){

  if validate_db_name "$1"; then
    if ! db_exists "$1"; then
    	create_database "$1"
    else
      echo "Error: Database '$1' already exists."
    fi
  else
    echo "Error: Invalid database name. Must start with a lowercase letter and contain only lowercase letters, digits and _."
  fi
}


create_database() {
	# $1 --> databse name
  mkdir -p $db_path/"$1" && echo "Database '$1' created successfully."
}

list_databases() {
  if [[ -d $db_path ]]; then
    echo "Available Databases:"
    ls $db_path | awk '{print "+ " $0}' 
  else
    echo "No databases found. $db_path directory does not exist."
  fi
}


validate_connect_db(){
	# validate empty line
  if db_exists "$1"; then
    connect_to_database "$1"
    return 0
  else
    echo "Error: Database '$1' does not exist."
    return 1
  fi


}
connect_to_database() {
	echo "connect to $1"
  cd $db_path/"$1" || echo "Error: Could not connect to database '$1'."
}

validate_drop_db(){
	if db_exists "$1"; then
    if not_inside_db; then
      drop_database "$1"
    else
      echo "Error: Cannot drop the database while inside it."
    fi
  else
    echo "Error: Database '$1' does not exist."
  fi

}

drop_database() {
  rm -r $db_path/"$1" && echo "Database '$1' dropped successfully."
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
			read -p "Please enter Database name: " db_name
			validate_create_db "$db_name"
		    ;;
		2)
		    list_databases
		    ;;
  	3)
			read -p "Please enter Database name: " db_name
			if validate_connect_db "$db_name"; then 
				table_menu
			fi

	    ;;
  	4)
			read -p "Please enter Database name: " db_name
	    validate_drop_db "$db_name"
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



is_connected(){
	current_path=$(pwd | rev | cut -d/ -f1,2 | rev)
  if [[ $current_path == "database/$1" ]]; then
  	return 0
  else
  	echo "please connect to $1 database first..."
  	return 1
  fi
}

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
			read -p "Enter the table name to drop: " table_name
	    drop_table "$table_name"
	    ;;
	  4)
	    insert_into_table
	    ;;
	  5)
			read -p "Enter the table name: " table_name
	    select_from_table "$table_name"
	    ;;
	  6)
	    delete_flow
	    ;;
	  7)
	    update_table .
	    ;;
	  8)
			cd ../..
			pwd
	    echo "Returning to Main Menu..."
	    break
	    ;;
	  *)
	    echo "Invalid option. Please try again."
	    ;;
	esac
done
}


delete_from_table(){
	echo "delete functionality Not implemented Yet :("
}

update_row(){
	echo "update functionality Not implemented Yet :("
}

