#!/bin/bash

source "helper/validation"


function check_table_name
{
    local table_name=$1
    if ! check_empty_string  "$table_name"; then
		return 0
	fi

    if ! check_starting_string "$table_name"; then
		return 0
	fi
    
    if [ -f "${table_name}.data" ]; then
		echo "Error: Table name already exists."
		return 0
	fi
    
    return 1
}

function get_columns_number
{
   
    local size_column_names=${#column_names[@]}
    local size_column_datatypes=${#column_datatypes[@]}


    if [ "$size_column_names" -ne "$size_column_datatypes" ]; then
        echo "Error: The number of column names and column datatypes must be equal."
        return 0
    fi
    return "$size_column_names"

}

function check_column_name
{
    local column_name=$1
    
    if ! check_empty_string  "$column_name"; then
        return 0
    fi

    
    if ! check_starting_string "$column_name"; then
        return 0
    fi

    
    if [[ " ${column_names_checker[@]} " =~ " $column_name " ]]; then
        echo "Error: Column name '$column_name' already exists more than once."
        return 0
    fi
    
    return 1
	

}

function check_column_datatype
{   
    local column_datatype=$1
    if [[ "$column_datatype" != "string" && "$column_datatype" != "int" ]]; then
        echo "error! datatype is int or string only "
        return 0
    fi
    return 1
	
}

function get_pk_column
{


    index=0
    for column in "${column_names[@]}"; do
        index=$((index+1))
        if [ "$column" == "$pk_column" ]; then
            return "$index"
        fi
    done
    echo "Error: Primary key column does not exist."
    return 0

}



function create_table_sql
{
    database_path=$1
    table_name=$2
    column_names=("${!3}")  # Correct way to pass an array as a parameter
    column_datatypes=("${!4}")  # Correct way to pass an array as a parameter
    pk_column=$5
    column_names_checker=()



    check_table_name "$table_name"
    result_table_name=$?

    get_columns_number 
    columns_number=$?

    if [ "$columns_number" -gt 0 ]; then
        

            for ((i=0; i<$columns_number; i++)); do

                check_column_name "${column_names[i]}"
                result_column_name=$?
                if [ "$result_column_name" -eq 0 ]; then
                    break
                fi
                
                check_column_datatype "${column_datatypes[i]}"
                result_column_datatype=$?
                if [ "$result_column_datatype" -eq 0 ]; then
                    break
                fi
                column_names_checker[i]="${column_names[i]}"
    		
	done

    fi
    get_pk_column
    
    pk_column=$?

    if [[ "$result_table_name" -ne 0 && "$columns_number" -ne 0 && "$result_column_name" -ne 0 && "$result_column_datatype" -ne 0 && "$pk_column" -ne 0 ]]; then
       
        ## create data and meta files
        path=${database_path}/${table_name}

        
        touch "${path}".data
        
        echo "table_name:$table_name">"${path}".meta
        
        echo "columns_number:$columns_number">>"${path}".meta
        
        columns_name_string=$(IFS=,; echo "${column_names[*]}")
        
        echo "columns_name:$columns_name_string">>"${path}".meta
        
        columns_datatype_string=$(IFS=,; echo "${column_datatypes[*]}")
        
        echo "columns_datatypes:$columns_datatype_string">>"${path}".meta
        
        echo "pk_column_number:$pk_column">>"${path}".meta
        
        echo "Table created successfully."    

    else
    
        echo "Error in SQL syntax"
    
    fi

}
# Correct function call
##my_array_column_names=("id" "city" "phone")
##my_array_datatypes=("int" "string" "string")


#create_table_sql . "league" my_array_columns[@] my_array_datatypes[@] "id"
