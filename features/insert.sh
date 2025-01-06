#!/bin/bash

source "helper/validation"
source "helper/meta_helper"


# table name , 6
# check number of columns
# check data type of each element
# check pk is unique
# insert into table

# insert into table tablename
# values (2,megz,10)


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

function insert_into_table_sql()
{

    # $1 table_name without any extension
    # $2 list of values comma seprated  values="1,mina,hh"

    table_name=$1

	# validate table name if exists
	if ! table_exits "$table_name.meta"; then
		echo "table not exist"
		return 1
	fi


    table_meta="$table_name.meta"

    dt_columns=$(get_meta_dt_columns $table_meta)



    # replace comma with space
    values=$(echo $2 | tr [","] [" "])
    dt_names=$(echo $dt_columns | tr [","] [" "])

    # Convert the strings into arrays
    values_array=($values)
    dt_array=($dt_names)

    # check the lenght of each array
    num_values=${#values_array[@]}
    num_dt=${#dt_array[@]}


    # check the number of inputs equal number of cols
    if [ $num_values -ne $num_dt ]
    then
        echo "invalid number of values"
        return 1
    fi


    # validation
    for((i=0; i < $num_values; i++));
    do
        if [ ${dt_array[i]} = "int" ]
        then
            if ! check_int ${values_array[i]}; then
                return 1
            fi
        else
            if ! check_starting_string "${values_array[i]}"; then
                return 1
            fi

        fi
    done

    echo $2 >> "$1.data"
}

