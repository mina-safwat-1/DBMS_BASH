#!/bin/bash

source "helper/validation"
source "helper/meta_helper"


function delete
{
	# $1 is consider the name of the data file
	# $2 is consider the index of the column
	# convert column to index
	# $3 is consider the value that we want to remove the record contains it
	awk -F, -v val=$3 -v col=$2 '{if ($col != val) print $0}' $1 > tmp
	mv tmp $1
}


# update - delete
# 1 - select database done
# 2 - select Update Row done
# 3 - select table (selection) (ls ) 
# 4 - select index of column (selection)
# 5 - get the data type from meta
# 6 - user enter value (validate empty line + validate data type)



function delete_flow
{

	table_name=""

	# validate table name if exists
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

    dt_columns=$(get_meta_dt_columns $table_meta)

    # pk_index=$(get_meta_pk_index $table_meta)


	echo "select index"
	for ((i=1; i <= $n_columns; i++)); do
		echo "$i $(echo $names_columns | cut -d , -f $i) $(echo $dt_columns | cut -d , -f $i)"
	done
	
	read -p "select index (int) : " index

	if ! check_int $index; then
		echo "invalid choice"
		return
	fi

	if [ $index -gt $n_columns ]; then

		echo "invalid choice"
		return
	fi

	read -p "enter the value of record you want to delete : " val



	delete "$table_name.data" $index $val


}



function delete_sql
{

	# $1 is consider the name of the data file without any extension 
	# $2 is consider the name of column
	# $3 is consider the value that we want to remove the record contains it

	table_name=$1

	# validate table name if exists
	if ! table_exits "$table_name.meta"; then
		echo "table not exist"
		return 1
	fi

    table_meta="$table_name.meta"

	column_index=$(get_column_index $table_meta $2)

	if [ $column_index -eq -1 ]; then

		echo "column not found"
		return 1
	fi

	column_value=$3

	delete "$table_name.data" $column_index $column_value

}
