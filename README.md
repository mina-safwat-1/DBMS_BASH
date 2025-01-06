# DBMS Bash Project

## Introduction
This project offers a simple Database Management System (DBMS) implemented using Bash scripts. It provides two main interfaces:
1. **Menu-Based Interface**: Allows users to interact through a series of menus.
2. **SQL-Like Interface**: Offers an SQL-like command line interface for database operations.

## Setup
### Prerequisites
Ensure that Bash is installed on your system. This project is compatible with Unix-like operating systems.

### Running the Project
1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```
2. **Give execute permissions to the scripts**:
   ```bash
   chmod +x *.sh
   chmod +x ./features/*
   chmod +x ./helper/*
   ```
3. **Start the application**:
   ```bash
   ./start.sh
   ```

## Usage

### Start Menu
Upon running `start.sh`, the following menu appears:
```
Start Menu:
1) Menu Based App
2) SQL Based App
3) Exit
```

- **Option 1**: Launches the Menu-Based interface.
- **Option 2**: Launches the SQL-Based interface.
- **Option 3**: Exits the application.

### Menu-Based Interface
The Menu-Based interface offers these options:
1. **Create Database**: Create a new database.
2. **List Databases**: List all available databases.
3. **Connect To Database**: Connect to an existing database.
4. **Drop Database**: Delete an existing database.
5. **Exit**: Return to the Start Menu.

### SQL-Based Interface
In the SQL-Based interface, you can run commands in an SQL-like syntax. Some supported commands include:

- **LIST ALL**: Lists all databases.
- **CREATE DATABASE \<database name\>**: Creates a new database.
- **DROP DATABASE \<database name\>**: Deletes a database.
- **CONNECT \<database name\>**: Connects to a database.
- **CREATE TABLE \<table name\> ( \<col1\> \<type\>, \<col2\> \<type\> pk , ..., \<coln\> \<type\> )**: Creates a new table.
- **INSERT INTO \<table name\> VALUES ( \<value1\>, \<value2\>, ..., \<valuen\> )**: Inserts data into a table.
- **SELECT \<table name\>**: Displays all rows from a table.
- **UPDATE \<table name\> SET \<col\>=\<value\> WHERE \<col\>=\<val\>**: Updates rows in a table.
- **DELETE FROM \<table name\> WHERE \<col\> = \<val\>**: Deletes rows from a table.
- **EXIT**: Exits the SQL interface.

## Features
- **Database Operations**: Create, list, connect to, and drop databases.
- **Table Operations**: Create tables, insert data, select data, update rows, and delete rows.
- **SQL Parsing**: Execute commands in an SQL-like syntax.

## Error Handling
The scripts include error handling to manage invalid inputs and operations, providing a more robust user experience.

