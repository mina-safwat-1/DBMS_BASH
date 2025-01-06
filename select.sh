#!/usr/bin/bash


select_from_table() {
  read -p "Enter the table name: " table_name
  if [[ -f "$table_name" ]]; then
    echo "Contents of table '$table_name':"
    if [[ -s "$table_name" ]]; then
      # Read the table into an array of lines
      mapfile -t table < "$table_name"
      IFS=',' read -r -a headers <<< "${table[0]}"
      num_columns=${#headers[@]}
      column_widths=()

      # Calculate maximum column widths
      for ((i = 0; i < num_columns; i++)); do
        column_widths[i]=${#headers[i]}
      done

      for line in "${table[@]:1}"; do
        IFS=',' read -r -a row <<< "$line"
        for ((i = 0; i < num_columns; i++)); do
          if [[ ${#row[i]} -gt ${column_widths[i]} ]]; then
            column_widths[i]=${#row[i]}
          fi
        done
      done

      # Print header row
      for ((i = 0; i < num_columns; i++)); do
        printf "| %-*s " "${column_widths[i]}" "${headers[i]}"
      done
      echo "|"

      # Print separator
      for ((i = 0; i < num_columns; i++)); do
        printf "|%s" "$(printf '%-*s' "${column_widths[i]}" '' | tr ' ' '-')"
      done
      echo "|"

      # Print data rows
      for line in "${table[@]:1}"; do
        IFS=',' read -r -a row <<< "$line"
        for ((i = 0; i < num_columns; i++)); do
          printf "| %-*s " "${column_widths[i]}" "${row[i]}"
        done
        echo "|"
      done
    else
      echo "The table is empty."
    fi
  else
    echo "Error: Table '$table_name' does not exist."
  fi
}