#!/bin/bash

source "helper/validation"


## function read table name 


function get_table_name
{

check=0
while [ $check -eq 0 ]	
	do
		echo "Enter table name:"
		read table_name
		

		if ! check_empty_string  "$table_name"; then
			continue
		fi


		if ! check_starting_string "$table_name"; then
			continue
		fi
		

		if [ -f "${table_name}.data" ]; then
			echo "Error: Table name already exists."
			check=0
			continue
		fi

		check=1
	done

}


## function read columns count
function get_columns_number
{
check=0
while [ $check -eq 0 ]	
	do

		echo "Enter number of columns:"
		read columns_number
		
		if ! check_positive "$columns_number"; then
			continue
		fi
	
		check=1
	done

}

## function read columns name

function get_column_name
{
	check=0
	
	while [ $check -eq 0 ]
	do
		echo "Enter name of column:"
		read column_name
		

		if ! check_empty_string  "$column_name"; then
			continue
		fi

		if ! check_starting_string "$column_name"; then
			continue
		fi
		

		if [[ " ${column_names[@]} " =~ " $column_name " ]]; then
					echo "Error: Column name '$column_name' already exists"
					check=0
					continue
			fi
		
		check=1
	done

}


function get_column_datatype {
    check=0
    
    while [ $check -eq 0 ]; do
        echo "Select column data type:"
        select column_datatype in "string" "int"; do
            if [[ -n "$column_datatype" ]]; then
                check=1
                break
            else
                echo "Invalid selection. Please choose either 'text' or 'int'."
            fi
        done
    done

    echo "You selected: $column_datatype"
}

## function read order of pk column

function get_pk_column
{

	check=0
	
	while [ $check -eq 0 ]
	do
	
	echo "Enter number of pk column"
	read pk_column
	
	
	if ! check_positive "$pk_column"; then
		continue
	fi
	
	# if ! [[ "$pk_column" -ge 1 && "$pk_column" -le "$columns_number" ]]; then
		
	# 	echo "Invalid input. Please enter a number between 1 and $columns_number."
	# 	check=0	
	# fi

	if ! check_range "$pk_column" "$columns_number"; then
		continue
	fi
	
	#

		check=1

	done


}


# main function
function create_table
{	
	database_path=$1
 	column_names=()
 	column_datatypes=()
	
	#get table name and number of columns
	get_table_name
	get_columns_number
	
	#set columns name and datatypes
	for ((i=0; i<$columns_number; i++)); do
    		get_column_name
    		get_column_datatype
    		column_names[i]=$column_name
    		column_datatypes[i]=$column_datatype
	done
	
	## get primary column
	get_pk_column
	
	path=${database_path}/${table_name}
	
	## create data and meta files
	
	touch ${path}.data
	
	echo "table_name:$table_name">${path}.meta
	
	echo "columns_number:$columns_number">>${path}.meta
	
	columns_name_string=$(IFS=,; echo "${column_names[*]}")
	
	echo "columns_name:$columns_name_string">>${path}.meta
	
	columns_datatype_string=$(IFS=,; echo "${column_datatypes[*]}")
	
	echo "columns_datatypes:$columns_datatype_string">>${path}.meta
	
	echo "pk_column_number:$pk_column">>${path}.meta
	

}

# only need path of database directory
create_table $1
