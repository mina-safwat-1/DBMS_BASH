#!/usr/bin/bash

source ./dbms.sh
source ./sql.sh

while true; do
	clear
	echo "Start Menu:"
	echo "1) Menu Based App"
	echo "2) SQL Based App"
	echo "3) Exit"
	echo
	
	read -p "Choose an option [1-3]: " choice
	case $choice in
		1)
			main_menu
		    ;;
		2)
		    start
		    ;;

	  	5)
		    echo "Exiting..."
		    break
		    ;;
	  	*)
		    echo "Invalid option. Please try again."
	    ;;
	esac
 done 