#!/bin/bash

source "helper/validation"
source "helper/meta_helper"

# # insert
# 1 - select database done
# 2 - select insert data  done 
# 3 - select table (selection) (ls)
# 	# loop
# 	4.1 - show each column in table with data type
# 	4.2 - insert column by column (validate empyt line + validate data type)


function insert_into_table {
    # $1 table_name

    # refactor later

    table_name=""

    # validate column name if exists
	while true
	do
        read -p "Enter Table Name : " table_name 
        if ! table_exits "$table_name.meta"; then
            continue
        fi
        break
    done


    table_meta="$table_name.meta"


    n_columns=$(get_meta_n_columns $table_meta)

    names_columns=$(get_meta_names_columns $table_meta)

    echo $names_columns

    dt_columns=$(get_meta_dt_columns $table_meta)

    pk_index=$(get_meta_pk_index $table_meta)


    record=""

    for ((i=1; i<=$n_columns; i++))
    do

        column_name=$(echo $names_columns | cut -d , -f $i)
        column_dt=$(echo $dt_columns | cut -d , -f $i)


        val=""


        # validate unique primary key

        while true
            do
                if ! table_exits "$table_name.meta"; then
                    continue
                fi
                break
            done
        # validate entry data type
        while true
            do
                # validate datatype int or string
                read -p "enter $column_name has datatype $column_dt : " val

                    # $1 is index of column
                    # $2 file path
                    # $3 input of user

                # if i == pk  then check unique
                if [ $i -eq $pk_index ]; then
                    if ! check_unique_data $pk_index "$table_name.data" $val; then
                        continue
                    fi
                fi


                if [ $column_dt = "int" ]; then

                    if ! check_int $val ; then
                        continue
                    fi

                else

                    if ! check_starting_string $val ; then
                        continue
                    fi
                fi

                break
            done

        record="$record,$val"
    done

    # remove first comma
    record="${record:1}"

    echo $record >> $table_name.data

}

