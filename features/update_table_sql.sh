#!/bin/bash

source "helper/validation"

function check_table
{
     ## list all tables in the database and get name of tables
    tables=($(ls "$database_path" | sed -E 's/\.(data|meta)//g' | sort -u))

    if [[ " ${tables[@]} " =~ " ${table} " ]]; then
   
        return 1
    else
        echo "Table not found"
        return 0
        
    fi

}

function check_column
{
    local column="$1"
    meta_table="$database_path/${table}.meta"
    
    columns=($(sed -n '3p' "$meta_table" | cut -d: -f2 | tr ',' ' '))

    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "${column}" ]]; then
            return $((i + 1))
        fi
    done
    echo "Column not found"
    return 0
    
}



function check_search_value
{   
    ## get data file of the selected table and get columns datatypes
    data_table="$database_path/${table}.data"
        
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
        return 1
    else
        echo "The value '$search_value' is not in the table no row will be updated."
       
        return 0
    fi  
}



## to insert value to be updated
function check_updated_value
{   
    columns_datatypes=($(sed -n '4p' "$meta_table" | cut -d: -f2 | tr ',' ' '))

    data_type="${columns_datatypes[${column_index}-1]}"

    ## check if the new value is valid
    if [[ $data_type  == "int" ]]; then

        if ! [[ "$new_value" =~ ^[-+]?[0-9]+$ ]]; then
            echo "Invalid input. Please enter a valid number."
            return 0
        fi
    else 
        if ! check_empty_string "$new_value";then
            echo "Invalid text input."
            return 0
        fi
    fi
    
    ## check if we are updating the primary key column

    if [[ $pk_column_index -eq $column_index ]]; then

        columns_value=($(cat $data_table | cut -d, -f"${column_index}"))
        
        ## check if the new value already exists in the column

        for value in "${columns_value[@]}"; do
            if [[ "$value" == "$new_value" ]]; then
            echo "The value '$new_value' already exists in the column. Please enter a unique value."
            return 0
            fi
        done
        
        ## check if the new value will update more than one row
        length=${#rows_indices[@]}
        
        if [[ $length -gt 1 ]]; then
            echo "Error!! you will update pk_column in more than one row by the same value"
            return 0
        fi
    
    fi
    ## update the table
    return 1

}


## main functon to update the table
function update_table_sql
{   
    
    database_path="$1";
    table="$2"
    column_identifier="$3"
    search_value="$4"
    column_updated="$5"
    new_value="$6"

    check_table

    if [[ $? -eq 0 ]]; then

               return 0

    fi
    check_column "$column_identifier"
    
        column_index=$?
    
    if [[ $column_index -eq 0 ]]; then
               return 0
    fi
    
    check_search_value
    
    if [[ $? -eq 0 ]]; then
               return 0

    fi

    check_column "$column_updated"
    
     column_index=$?
    
    if [[ $column_index -eq 0 ]]; then
               return 0
    fi

    pk_column_index=($(sed -n '5p' "$meta_table" | cut -d: -f2))
    
    check_updated_value

    if [[ $? -eq 0 ]]; then

               return 0

    fi
    awk -F, -v var1="${rows_indices[*]}" -v var2="$column_index" -v var3="$new_value" 'BEGIN {OFS=","; split(var1, rows, " ")} {for (i in rows) {if (NR == rows[i]) { $var2 = var3 }}; print}' "$data_table" > temp && mv temp "$data_table"
    echo "table updated"

}
##
# $1 path
# $2 tablename
# $3 column_identifier
# $4 value_identifier
# $5 column_updated
# $6 newvalue 
#update_table_sql . iti id 1 age 80