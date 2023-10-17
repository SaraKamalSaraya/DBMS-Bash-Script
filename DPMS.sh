#!/bin/bash
shopt -s extglob

#********************************** Main Menu ********************************** 
function main_Menu {
	echo "------------------------ Welcome To Main Menu ------------------------"
	echo $'Choose an option:'
	select choice in "Create Database" "List Databases" "Connect To Databases" "Drop Database" "Exit"; do
		case $REPLY in
		1) create_DataBase ;;
		2) list_Databases ;;
		3) connect_To_Database ;;
		4) drop_Database ;;
		5) exit ;;
		*) echo "Invalid input, Please try again" ;;
		esac
	done
}

function backToMainMenu {
	echo "Please wait a second .."
	sleep 1
	echo "Back to Main Menu"
	main_Menu
}

#------------------------ Main Menu Functions ------------------------
#---------------- Create Database ----------------
function create_DataBase {
	read -p "Enter Database name: " name
	if [[ -d ./myDB/$name ]]; then # -d check if thier is a directory with that name
		echo "${name} Already exist!"
		backToMainMenu
	elif [[ $name =~ ^[a-zA-Z]+[a-zA-Z_0-9] ]]; then # check if name start with letter + more than 1 char
		mkdir -p ./myDB/$name
		echo "${name} Database created successfuly!!!"
		backToMainMenu
	else
		echo "Invalid name for database"
		create_DataBase
	fi
}

#---------------- Drop Database ----------------
function drop_Database {
	read -p "Enter database name that you want to delete: " name
	if ! [[ -d ./myDB/$name ]]; then
		echo "${name} is not exist!"
		backToMainMenu
	else
		rm -d ./myDB/$name
		echo "Done. ${name} has been removed successfuly!!!"
		backToMainMenu
	fi
}

#---------------- List Database ----------------
function list_Databases {
	echo "This is list of all databases you have"
	ls ./myDB
	backToMainMenu
}

#---------------- Connect To Database ----------------
function connect_To_Database {
	read -p "Which database you want to connect to? " name
	if [[ -d ./myDB/$name ]]; then
		cd ./myDB/$name
		echo "Done. You are now connected to ${name} database successfuly!!!"
		table_Menu
	else
		read -p "No database with name ${name}, Do you want to create it? [y/n]: " answer
		case $answer in
		"y") create_DataBase ;;
		"n") connect_To_Database ;;
		*)
			echo "Invalid input!"
			backToMainMenu
			;;
		esac
	fi
}

#********************************** Table Menu ********************************** 
function table_Menu {
	echo "------------------------ Welcome To Table Menu ------------------------"
	echo $'Choose an option:'
	select choice in "Create Table" "List Tables" "Drop Table" "Insert Into Table" "Select From Table" "Delete From Table" "Update Table" "Back to Main Menu" "Exit"; do
		case $REPLY in
		1) create_Table ;;
		2) list_Tables ;;
		3) drop_Table ;;
		4) insert_Into_Table ;;
		5) select_From_Table ;;
		6) delete_From_Table ;;
		7) update_Table ;;
		8) 	cd ../..
			backToMainMenu ;;
		9) exit ;;
		*) echo "Invalid input, Please try again" 
			table_Menu ;;
		esac
	done
}

function backToTableMenu {
	echo "Please wait a second .."
	sleep 1
	echo "Back to Table Menu"
	table_Menu
}

#------------------------ Table Menu Functions ------------------------
#---------------- Create Table ----------------
function create_Table {
	read -p $'Please enter table name to create it: ' tableName
	if [[ -f $tableName ]]; 			# -f check if thier is a file with that name
	then
		echo "table already exists!"
		backToTableMenu
	elif ! [[ $tableName =~ ^[a-zA-Z]+[a-zA-Z_0-9] ]] 	# check if name start with letter + more than 1 char
	then
		echo "Invalid name for Table"
		create_Table
	else
		touch $tableName
		echo "${tableName} Table created succesfully"
		read -p "Please enter Number of fields: " fields 	# take Number of columns
		if ! [[ $fields =~ [0-9] ]]; 						# Number of columns validation
		then
			echo "Invalid input!"
			rm $tableName
			backToTableMenu
		else
			flag="true"			# Primary Key 
			for ((i = 1; i <= $fields; i++)); 				# Data about the column
			do
				read -p "Please enter name for field number $i: " colname
				while [[ `head -1 $tableName` == *$colname* ]]
                do        
                    echo -e $"The Column Already Exist, Try Again!!"
                    read -p "Please enter name for field number $i Again: " colname
                done
				while [ $flag == "true" ]; 
				do
					read -p "Is this a PK? [Y/N] " answer
					if [[ $answer == "y" ]]; 
					then
						flag="false"
						echo -n "(PK)" >>$tableName
					else
						break
					fi
				done
				while true; 		# Data Type:::
				do
					read -p "Choose data type from (int , string): " datatype
					case $datatype in
					int)
						echo -n $colname"($datatype);" >>$tableName ;;
					string)
						echo -n $colname"($datatype);" >>$tableName ;;
					*)
						echo "Invalid input!"
						continue ;;
					esac
					break
				done
			done
			echo $'\n' >>$tableName
			echo "Your table $tableName is created successfuly!!!"
			backToTableMenu
		fi
	fi
}
#---------------- Drop Table ----------------
function drop_Table {
	read -p "Enter Table name that you want to delete: " name
	if ! [[ -f $name ]]; then
		echo "${name} is not exist!"
		drop_Table
	else
		rm $name
		echo "Done. ${name} has been removed successfuly!!!"
		backToTableMenu
	fi
}

#---------------- List Tables ----------------
function list_Tables {
	echo "This is list of all Tables you have"
	ls
	backToTableMenu
}

#---------------- Insert Column Into Table ----------------
function insert_Into_Table {
	read -p "Enter table name to insert data to: " tableName
	if ! [[ -f $tableName ]]; then
		echo "Table doesn't exist"
		read -p "Do you want to create it? [y/n] " answer
		case $answer in
		y) create_Table ;;
		n) insert_Into_Table ;;
		*) echo "Invlid input!" 
			backToTableMenu ;;
		esac
	else
		numberOfCol=$(grep 'PK' $tableName | grep -o ";" | wc -l) # number of columns
		for ((i = 1; i <= $numberOfCol; i++)); do
			colName=$(grep PK $tableName | cut -f$i -d";")
			read -p $"Enter data for [$colName]: " data
			checkType $i $data
			if [[ $? != 0 ]]; then
				((i = $i - 1))
			else
				echo -n $data";" >>$tableName
			fi
		done
		echo $'\n' >>$tableName #end of record
		echo "insert done into $tableName successfuly!!!"
		backToTableMenu
	fi
}

#---------------- Select From Table ----------------
function select_From_Table {
	read -p "Please enter table name to select data: " tableName
	if ! [[ -f $tableName ]]; then
		echo "Table doesn't exist"
		read -p "Do you want to create it? [y/n]: " answer
		case $answer in
		y) create_Table ;;
		n) select_From_Table ;;
		*)
			echo $'Invalid input!'
			backToTableMenu
			;;
		esac
	else
		read -p $'Would you like to print all records? [y/n]: ' printall
		if [[ $printall == "y" ]]; then
			read -p $'Would you like to print a specific field? [y/n]: ' cut1
			if [[ $cut1 == "y" ]]; then
				read -p $'Please specify field number: ' fieldno
				echo "-----------------------------"
				awk $'{print $0\n}' $tableName | cut -f$fieldno -d";" # Print all rows of column x
				echo "-----------------------------"
			else
				echo "-----------------------------"
				column -t -s ';' $tableName # Print Full Table
				echo "-----------------------------"
			fi
		else
			read -p $'Please enter a search value to select record(s): ' value
			read -p $'Would you like to print a specific field? [y/n]: ' cut
			NumberOfColumnsInTable=`awk -F';' '{if(NR==1) print NF}' $tableName`
			if [[ $cut == "y" ]]; then
				read -p $'Please specify field number: ' field
				if [[ $field == "" ]]
				then
					echo "Invalid input!"
					echo "Try again!"
					select_From_Table
				elif (( $field > $NumberOfColumnsInTable-1 | $field == 0 ))
				then
					echo "Invalid input!"
					select_From_Table
				else
					# find the pattern in records |> for that specific field
					echo "-----------------------------"
					awk -v pat=$value $'$0~pat{print $0\n}' $tableName | cut -f$field -d";"
					echo "-----------------------------"
				fi
			else
				# find the pattern in records |> for all fields |> as a table display
				echo "-----------------------------"
				awk -v pat=$value '$0~pat{print $0}' $tableName | column -t -s ';'
				echo "-----------------------------"
			fi
		fi
		read -p $'Would you like to make another query? [y/n]: ' answer
		if [[ $answer == "y" ]]; then
			select_From_Table
		elif [[ $answer == "n" ]]; then
			backToTableMenu
		else
			echo "Invalid input!"
			backToTableMenu
		fi
	fi
}

#---------------- Delete From Table ----------------
function delete_From_Table {
	while [ true ]; do
		read -p "Enter Table You want to Delete from: " tableName
		if ! [[ -f $tableName ]]; then
			echo "This table doesn't Exsit! Please enter another name."
			delete_From_Table
		else
			while [ true ]; do
				read -p "Do you want to delete all data in this table? [y/n]: " answer
				if ! [[ $answer == "y" || $answer == "n" ]]; then
					echo "Invalid input!"
				elif [[ $answer == "y" ]]; then
					sed -i '2,$d' $tableName			# Delete all data inside table but not the head
					echo "Done. Table is empty now succesfully!!!"
					backToTableMenu
				else
					read -p "Enter ID (PK) value to Delete Row by it: " PK
					checkPKExist=`cat $tableName | cut -f1 -d";" | grep $PK`
					if ! [[ $checkPKExist ]]
					then
						echo "Invalid ID! Try again!"
						delete_From_Table
					else
						row=$(sed -n "/^${PK}/p" ${tableName})
						echo $row
						read -p "Is this the row you want to delete? [y/n]: " answer
						if ! [[ $answer == 'y' ]]; then
							echo "Try again!"
							delete_From_Table
						else
							record_num=$( (awk -F';' '{if($1=='${PK}'){print NR}}' ${tableName}))
							if [ $record_num ]; then
								sed -i ''$record_num'd' "$tableName" 		# Delete specific row
								echo "Record deleted successfuly!!!"
								backToTableMenu
							else
								echo "You Entered ID not Found! please Enter valid ID"
								delete_From_Table
							fi
						fi
					fi
					
				fi
			done
		fi
	done
}

#---------------- Update Table ----------------
function update_Table {
	read -p "Enter Table Name you want to update: " tableName
	if ! [[ -f $tableName ]]; then
		echo "This table doesn't Exsit !!, Please enter another name."
		update_Table
	else
		echo "This is your Table:"
		echo "-----------------------------"
		column -t -s ';' $tableName  			# Print The table
		echo "-----------------------------"
		NumberOfColumnsInTable=`awk -F';' '{if(NR==1) print NF}' $tableName`
		read -p "Enter column number you want to update: " colNumber
		if [[ $colNumber == "" ]]
		then
			echo "Invalid input!"
			echo "Try again!"
			update_Table
		elif (( $colNumber > $NumberOfColumnsInTable-1 | $colNumber == 0 ))
		then
			echo "Invalid input!"
			update_Table
		else
			read -p "Enter value you want to change: " oldValue
			value=`awk -v pat=$oldValue $'$0~pat{print $0\n}' $tableName | cut -f$colNumber -d";"`
			if [[ $value == "" ]]
			then
				echo "Not Found!"
				update_Table
				backToTableMenu
			else
				read -p "Enter your new value: " newValue
				checkType $colNumber $newValue
				if [[ $? == 0 ]]; then				# if exit status from last command == 0 kml el code 3ady
					sed -i "s/$oldValue/$newValue/g" $tableName		# Replace old value with new one
					echo "Done. Table updated successfully!!!"
					backToTableMenu
				else
					echo "Not The same datatype .. !"
					echo "Try again!"
					update_Table
				fi				
			fi
		fi
	fi
}


#------------------------ Validations ------------------------
#---------------- Check Data Type ----------------
function checkType {
	datatype=$(grep PK $tableName | cut -f$1 -d";") 
	if [[ "$datatype" == *"int"* ]]; then
		num='^[0-9]+$'
		if ! [[ $2 =~ $num ]]; then
			echo "Invalid input!"
			return 1
		else
			checkPK $1 $2
		fi
	elif [[ "$datatype" == *"string"* ]]; then
		str='^[a-zA-Z]+$'
		if ! [[ $2 =~ $str ]]; then
			echo "Invalid input!"
			return 1
		else
			checkPK $1 $2
		fi
	fi
}

#---------------- Check if PK is existed ot not ----------------
function checkPK {
	header=$(grep PK $tableName | cut -f$1 -d";") # grep PK
	if [[ "$header" == *"PK"* ]]; then
		if [[ $(cut -f$1 -d";" $tableName | grep -w $2) ]]; then # grep PK values and compare them with new ones
			echo $'Invalid input! This PK is already in the table'
			return 1
		fi
	fi
}
main_Menu

