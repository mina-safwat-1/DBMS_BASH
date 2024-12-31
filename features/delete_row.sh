#!/usr/bin/bash -x

function delete
{
	# $1 is consider the name of the data file
	# $2 is consider the name of the column
	# $3 is consider the value that we want to remove the record contains it
	awk -F, -v PK=$3 '{if ($1 != PK) print $0}' $1 > tmp
	mv tmp $1
}
delete $1 $2 $3



# update - delete
# 1 - select database
# 2 - select Update Row
# 3 - select table (selection) (ls )
# 4 - select index of column (selection)
# 5 - get the data type from meta
# 6 - user enter value (validate empty line + validate data type)


# # insert
# 1 - select database
# 2 - select insert data
# 3 - select table (selection) (ls)
# 	# loop
# 	4.1 - show each column in table with data type
# 	4.2 - insert column by column (validate empyt line + validate data type)
