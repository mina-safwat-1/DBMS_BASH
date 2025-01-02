#! /usr/bin/bash


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
                echo "Valid LIST ALL DATABASES statement."
            elif [[ "${tokens[1]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$  ]]; then
                echo "Valid LIST tables in ${tokens[1]} database, we will pass this name to list_tables function"
            else
                echo "Error: Invalid List Database syntax."
            fi
            ;;

        CONNECT)
            if [[ "${tokens[1]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                echo "connect to ${tokens[1]} database"
            else
                echo "ERROR: Invalid connect statement"
            fi
            ;;

        DROP)
            if [[ "${tokens[1]}" == "TABLE" ]]; then
                if [[ "${tokens[2]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                    echo "Dropped table ${tokens[2]}"
                else
                    echo "invalid table name..."
                fi

            elif [[ "${tokens[1]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                echo "drop ${tokens[1]} database"
            else
                echo "ERROR: Invalid drop statement"
            fi
            ;;


        CREATE)
            if [[ "${tokens[1]}" == "TABLE" ]]; then
                if [[ "${tokens[2]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ && "${tokens[3]}" == "(" && "${tokens[-1]}" == ")" ]]; then
                    echo "Valid CREATE TABLE statement."
                else
                    echo "Error: Invalid CREATE TABLE syntax."
                fi
            elif [[ "${tokens[1]}" == "DATABASE" ]]; then 
               if [[ "${tokens[2]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                    echo "Valid CREATE DATABASE statement. with database name ${tokens[2]} will be passed to create_database function to be validated"
                else
                    echo "Error: Invalid CREATE DATABASE syntax."
                fi
            else
                echo "Invlid Syntax"
            fi
            ;;

        INSERT)
            if [[ "${tokens[1]}" == "INTO" && "${tokens[2]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ && "${tokens[3]}" == "VALUES" && "${tokens[4]}" == "(" && "${tokens[-1]}" == ")" ]]; then
                echo "Valid INSERT INTO statement."
            else
                echo "Error: Invalid INSERT INTO syntax."
            fi
            ;;
        SELECT)
            if [[ "${tokens[2]}" == "FROM" && "${tokens[3]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                echo "Valid SELECT statement."
            else
                echo "Error: Invalid SELECT syntax."
            fi
            ;;
        DELETE)
            if [[ "${tokens[1]}" == "FROM" && "${tokens[2]}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                echo "Valid DELETE FROM statement."
            else
                echo "Error: Invalid DELETE FROM syntax."
            fi
            ;;
        *)
            echo "Error: Unsupported or invalid SQL command."
            ;;
    esac
}

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





# while true; do
#     read -p "SQL> " sql_command
#     if [[ "$sql_command" == "EXIT" || "$sql_command" == "QUIT" ]]; then
#         break
#     fi
#     # sql_command=$(echo "$sql_command" | tr '[:lower:]' '[:upper:]' | tr -s ' ')
#     if [[ "$sql_command" =~ ^(CREATE DATABASE).* ]]; then
#     	echo "Create a DB"
# 	elif [[ "$sql_command" =~ ^USE.* ]]; then
# 		echo "Connecting"
# 	elif [[ "$sql_command" =~ ^DROP.* ]]; then
# 		echo "Dropping"

# 	elif [[ "$sql_command" =~ ^LIST ]]; then
# 		echo "Listting..."

#     elif [[ "$sql_command" =~ ^SELECT.*FROM ]]; then
#         echo "SELECT"
#     elif [[ "$sql_command" =~ ^INSERT.*INTO ]]; then
#         # Extract INSERT parameters
#         # Placeholder for extraction logic
#         sql_insert "employees" "Name, Age, Department" "David 28 HR"
#     elif [[ "$sql_command" =~ ^UPDATE.*SET ]]; then
#         # Extract UPDATE parameters
#         # Placeholder for extraction logic
#         sql_update "employees" "Age=31" "Name='Alice'"
#     elif [[ "$sql_command" =~ ^DELETE.*FROM ]]; then
#         # Extract DELETE parameters
#         # Placeholder for extraction logic
#         sql_delete "employees" "Department='Marketing'"
#     else
#         echo "Invalid SQL command."
#     fi
# done