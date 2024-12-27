#!/usr/bin/bash -x

function delete
{
	# $1 is consider the name of the data file
	# $2 is consider the name of the column
	# $3 is consider the value that we want to remove the record contains it
	awk -F, -v PK=$3 '{if ($1 != PK) print $0}' $1 > tmp
	cat tmp > $1
	rm tmp
}
delete $1 $2 $3
