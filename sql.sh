#! /usr/bin/bash

source ./dbms.sh
source features/rest.sh
source helper/validation
source config
source features/insert.sh
source features/delete_row.sh
source features/create_table_sql.sh
source features/update_table_sql.sh




extract_create_table_input(){

    tokens=("$@")
    table_name=${tokens[2]}

    column_definitions=$(echo "$@" | grep -oP '\(.*\)' | tr -d '()')
        
        # Initialize lists
        local pk_column=""
        local column_list=()
        local datatype_list=()
        
        # Parse column definitions
        IFS=',' read -r -a columns <<< "$column_definitions"
        for column in "${columns[@]}"; do
            column=$(echo "$column" | xargs) # Trim whitespace
            name=$(echo "$column" | cut -d' ' -f1 )
            type=$(echo "$column" | cut -d' ' -f2 )
            
            if [[ "$column" == *"pk"* ]]; then
                pk_column="$name"
            fi
            
            column_list+=("$name")
            datatype_list+=("$type")
        done
        
        # Output the extracted information
        echo "Table Name: $table_name"
        echo "Primary Key Column: $pk_column"
        echo "Column List: ${column_list[*]}"
        echo "Data Type List: ${datatype_list[*]}"


}


extract_insert_into_table_input(){

    tokens=("$@")
    table_name=${tokens[2]}

    column_values=$(echo "$@" | grep -oP '\(.*\)' | tr -d '()' | tr -d " ") 


    insert_into_table_sql $table_name  $column_values
        
}

extract_delete_from_table_input(){

    tokens=("$@")

    table_name=${tokens[2]}

    column_name=$(echo ${tokens[@]:4} | cut -d= -f1 )
    value=$(echo ${tokens[@]:4} | cut -d= -f2 )

    delete_sql $table_name $column_name $value


}

extract_update_table_input(){
    tokens=("$@")

    table_name=${tokens[1]}

    updated_column=$(echo ${tokens[3]} | cut -d= -f1 )
    updated_value=$(echo ${tokens[3]} | cut -d= -f2 )

    selected_column=$(echo ${tokens[5]} | cut -d= -f1 )
    selected_value=$(echo ${tokens[5]} | cut -d= -f2 )

    # echo "updated table name ${table_name}"
    # echo "updated column name ${updated_column}"
    # echo "updated value ${updated_value}"
    # echo "selected column name ${selected_column}"
    # echo "selected value ${selected_value}"

    update_table_sql . $table_name $selected_column $selected_value $updated_column $updated_value
}


tokenize() {
    local input="$1"
    echo "$input" |  tr -s ' ' | tr ' ' '\n'
}

parse() {
    local tokens=("$@")
    local command="${tokens[0]}"

    case "$command" in
        LIST) 
            if [[ "${tokens[1]}" == "ALL" ]]; then
                list_databases

            elif [[ "${tokens[1]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$  ]]; then
                if is_connected ${tokens[1]}; then
                    list_tables
                fi 
            else
                echo "Error: Invalid List Database syntax."
            fi
            ;;

        CONNECT)
            if [[ "${tokens[1]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                echo "connect to ${tokens[1]} database"
                validate_connect_db ${tokens[1]}
            else
                echo "ERROR: Invalid connect statement"
            fi
            ;;

        DROP)
            if [[ "${tokens[1]}" == "TABLE" ]]; then
                if [[ "${tokens[2]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                    # validate if connected to a database, validate table exist, 
                    curr_database=$(pwd | rev | cut -d/ -f1 | rev)
                    if is_connected ${curr_database}; then
                        if table_exits ${tokens[2]}; then
                            drop_table ${tokens[2]}
                        else
                            echo "table ${tokens[2] does not exist...}"
                        fi
                    fi
                    echo "Dropped table ${tokens[2]}"
                else
                    echo "invalid table name..."
                fi

            elif [[ ${tokens[1]} == "DATABASE" ]]; then
                if [[ "${tokens[2]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                    # validate i'm not connected to that database, validate database exist 
                    if is_connected ${tokens[2]}; then 
                        echo "please disconnect from ${tokens[2]} database first... "
                    else
                        if db_exists ${tokens[2]}; then 
                            validate_drop_db ${tokens[2]}
                        else
                            echo "${tokens[2]} database does not exist..."
                        fi 
                    fi
                    echo "drop ${tokens[1]} database"
                else
                    echo "ERROR: Invalid drop statement"
                fi
            fi
            ;;

        CREATE)
            if [[ "${tokens[1]}" == "TABLE" ]]; then
                if [[ "${tokens[2]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ && "${tokens[3]}" == "(" && "${tokens[-1]}" == ")" ]]; then
                    # i need <table name> <pk column> <coulmn list> <datatype list>
                    # validate that i'm connected to a database
                    curr_dir=$(pwd | rev | cut -d/ -f1)
                    if is_connected $curr_dir; then
                        extract_create_table_input ${tokens[@]}
                    fi

                else
                    echo "Error: Invalid CREATE TABLE syntax."
                fi
            elif [[ "${tokens[1]}" == "DATABASE" ]]; then 
                # validate i'm not connected to any db,
               if [[ "${tokens[2]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                    curr_dir=$(pwd | rev | cut -d/ -f1 | rev)
                    pwd
                    echo "$curr_dir"
                    if [[ $curr_dir == "database" || $curr_dir == "DBMS_BASH" ]]; then
                        validate_create_db ${tokens[2]}
                    else
                        echo " please disconnect from $curr_dir database first.."
                    fi

                else
                    echo "Error: Invalid CREATE DATABASE syntax."
                fi
            else
                echo "Invlid Syntax"
            fi
            ;;

        INSERT)
            if [[ "${tokens[1]}" == "INTO" && "${tokens[2]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ && "${tokens[3]}" == "VALUES" && "${tokens[4]}" == "(" && "${tokens[-1]}" == ")" ]]; then
                # validate i'm connected to a database 
                curr_dir=$(pwd | rev | cut -d/ -f1 | rev)
                if is_connected $curr_dir; then
                    extract_insert_into_table_input ${tokens[@]}
                fi

            else
                echo "Error: Invalid INSERT INTO syntax."
            fi
            ;;
        SELECT)
            if [[ "${tokens[1]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                # validate that i'm connected to a database
                curr_dir=$(pwd | rev | cut -d/ -f1 | rev)
                if is_connected $curr_dir; then
                    select_from_table ${tokens[1]}
                fi
            else
                echo "Error: Invalid SELECT syntax."
            fi
            ;;
        DELETE)
            if [[ "${tokens[1]}" == "FROM" && "${tokens[2]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ && ${tokens[3]} == "WHERE" ]]; then
                # validate that connected to database
                 curr_dir=$(pwd | rev | cut -d/ -f1 | rev)
                if is_connected $curr_dir; then
                    extract_delete_from_table_input ${tokens[@]}
                fi

            else
                echo "Error: Invalid DELETE FROM syntax."
            fi
            ;;
        UPDATE)
            if [[ "${tokens[1]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ && ${tokens[2]} == "SET" && ${tokens[4]} == "WHERE" ]]; then
                # validate that connected to database
                 curr_dir=$(pwd | rev | cut -d/ -f1 | rev)
                if is_connected $curr_dir; then
                    extract_update_table_input ${tokens[@]}
                fi

            else
                echo "Error: Invalid UPDATE syntax."
            fi
            ;;           
        *)
            echo "Error: Unsupported or invalid SQL command."
            ;;
    esac
}


start(){
    # Main loop for input
while true; do
    read -p "SQL> " input
    if [[ "$input" == "EXIT" ]]; then
        echo "Exiting SQL. Goodbye!"
        break
    fi

    tokens=($(tokenize "$input"))
    parse "${tokens[@]}"
done
}

# start



