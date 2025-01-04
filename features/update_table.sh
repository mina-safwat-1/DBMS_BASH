#!/bin/bash
source "helper/validation"

## to select table from database directory
function select_table
{   
    ## list all tables in the database and get name of tables
    tables=($(ls "$database_path" | sed -E 's/\.(data|meta)//g' | sort -u))

    if [[ ${#tables} -eq 0 ]]; then
        echo "No tables found in the database"
    
    else
        echo "Select a table to update"
        tables+=("Quit")
        select table in "${tables[@]}"; do
            if [[ -z $table ]]; then
                # -Z means empty
                echo "Invalid selection"
            elif [[ $table == "Quit" ]]; then
                echo "Exiting..."
                return 0
            else
                return 1
            fi
        done
    fi
}

## to select column from the selected table to search for rows to be updated and to select column to be updated

function select_column
{   
    ## get meta file of the selected table and get columns names

    meta_table="$database_path/${table}.meta"
    
    columns=($(sed -n '3p' "$meta_table" | cut -d: -f2 | tr ',' ' '))

    
    select column in "${columns[@]}"; do
        if [[ -z $column ]]; then
            echo "Invalid selection"
        else
            ## index start from 1
            column_index=$((${REPLY}))
            break
        fi
    done   
}

## to insert value to search for rows to be updated
function insert_search_value
{   
    ## get data file of the selected table and get columns datatypes
    data_table="$database_path/${table}.data"
    
    columns_datatypes=($(sed -n '4p' "$meta_table" | cut -d: -f2 | tr ',' ' '))

    echo "Please insert a value with a datatype ${columns_datatypes[${column_index}-1]} to search for rows to be updated"
    
    read search_value

    columns_value=($(cat $data_table | cut -d, -f"${column_index}"))

    ## count the number of times the value occurs in the column
    count=0
    ## rows to be updated
    rows_indices=()

    
    ## save the indices of the rows to be updated
    for i in "${!columns_value[@]}"; do
        if [[ "${columns_value[$i]}" == "$search_value" ]]; then
            ((count++))  
            rows_indices+=($((i+1)))
        fi
    done

    ## show the number of times the value occurs in the column
    if [[ $count -gt 0 ]]; then
        echo "The value '$search_value' is in the table and occurs $count times."
        printf "%s \n" "${rows_indices[1]}"
    else
        echo "The value '$search_value' is not in the table no row will be updated."
        ## fix this must remove exit it colse the program
        return 0
    fi  
    return 1  
}

## to insert value to be updated
function insert_updated_value
{
    data_type="${columns_datatypes[${column_index}-1]}"
    echo "insert new value with a datatype $data_type "
    read new_value

    ## check if the new value is valid
    if [[ $data_type  == "int" ]]; then

        if ! [[ "$new_value" =~ ^[-+]?[0-9]+$ ]]; then
            echo "Invalid input. Please enter a valid number."
            insert_updated_value
            return
        fi
    else 
        if ! check_empty_string "$new_value";then
            echo "Invalid text input."
            insert_updated_value
            return
        fi
    fi
    
    ## check if we are updating the primary key column

    if [[ $pk_column_index -eq $column_index ]]; then

        columns_value=($(cat $data_table | cut -d, -f"${column_index}"))
        
        ## check if the new value already exists in the column

        for value in "${columns_value[@]}"; do
            if [[ "$value" == "$new_value" ]]; then
            echo "The value '$new_value' already exists in the column. Please enter a unique value."
            insert_updated_value
            return
            fi
        done
        
        ## check if the new value will update more than one row
        length=${#rows_indices[@]}
        
        if [[ $length -gt 1 ]]; then
            echo "Error!! you will update pk_column in more than one row by the same value"
            return
        fi
    
    fi
    ## update the table
    awk -F, -v var1="${rows_indices[*]}" -v var2="$column_index" -v var3="$new_value" 'BEGIN {OFS=","; split(var1, rows, " ")} {for (i in rows) {if (NR == rows[i]) { $var2 = var3 }}; print}' "$data_table" > temp && mv temp "$data_table"

}

## main functon to update the table
function update_table
{   
    
    database_path="$1";
    select_table;
    if [[ $? -eq 1 ]]; then

    echo "Selected table: $table"
    
    
    echo "Select a column to identify rows to be updated"
    select_column
    echo "Selected column: $column"
    
    insert_search_value
    
    
    if [[ $? -eq 1 ]]; then
        
    echo "Select a column to be updated"
    select_column
    echo "Selected column to be updated: $column"

    ## get the primary key column index
    pk_column_index=($(sed -n '5p' "$meta_table" | cut -d: -f2))
    
    insert_updated_value
    fi
    fi




}
## only need to pass the database path
update_table "$1"