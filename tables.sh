#!/usr/bin/ksh

user=$1
database=$2


loading()
{
	printf "\nPress Enter to back"
	sleep .2
	printf "."
	sleep .2
	printf "."
	sleep .2
	printf "."
	read
	clear
}


editTable()
{
	clear
	echo "Enter table name"
	read ustable

	f=0
	for t in `awk -F: '{print $1}' $user/$database/meta` ; do
		if [ "$ustable" == "$t" ]; then
			f=1
			break
		fi
	done
	if [[ $f -eq 0 ]]; then
		echo "Table is not found"
	else
		clear
		printf "Loading table $ustable "
		sleep .7
		printf "."
		sleep .7
		printf "."
		sleep .7
		printf "."
		sleep .7
		printf "."

	 	./edit.sh $user $database $ustable
	fi
	loading
}


listTables()
{
	clear
	awk -F: '{print $1}' $user/$database/meta
	loading
}


createTable()
{
	clear
	echo "Enter table name"
	read tname

	f=0
	for t in `awk -F: '{print $1}' $user/$database/meta` ; do
		if [ "$tname" == "$t" ]; then
			f=1
			break
		fi
	done
	if [[ $f -eq 1 ]]; then
		echo "Table is already exists"
	else
	 	touch $user/$database/$tname
		echo "Enter number of columns including ID column:"
		read num
		columns[0]=$tname
		columns[1]=$num

		printf "\nColumn number 1 is ID\n"
		columns[2]="ID,int"
		for (( i = 2; i <= num; i++ )); do
			echo
			echo "Enter column number" $i "name:"
			read cname
			echo "Enter column number" $i "type:"
			select cho in "str" "int"
			do
				case $cho in
					"str" ) ctype=$cho
						break
						;;
					"int" ) ctype=$cho
						break
						;;
					* ) printf $REPLY" is not an option!\n"
						;;
				esac
			done
			columns[(($i+1))]="$cname,$ctype"
		done
		echo ${columns[*]}|sed 's/ /:/g'>>$user/$database/meta
		echo
		echo "Table created succssfuly"
	fi
	loading
}


deleteTable()
{
	clear
	echo "Enter table name"
	read dname

	f=0
	for t in `awk -F: '{print $1}' $user/$database/meta` ; do
		if [ "$dname" == "$t" ]; then
			f=1
			break
		fi
	done
	if [[ $f -eq 0 ]]; then
		echo "Table is not found"
	else
		echo "Are you sure you want to delete this table ? (y/n)"
		read r
		while [ "$r" != "y" ] && [ "$r" != "n" ]; do
			echo "Wrong answer"
			echo "Are you sure you want to delete it ? (y/n)"
			read r
		done
		if [ "$r" == "y" ]; then
			rm $user/$database/$dname
			sed -i '/^'"$dname"'/d' $user/$database/meta
			echo "Table deleted succssfuly"
		elif [ "$r" == "n" ]; then
			echo "We are good"
		fi
	fi

	loading
}


clear
printf "You are using $database database\nChoose what you like to do in it\n\n"

select choice in "Edit table" "List tables" "Create table" "Delete table" "Back"
do
	case $choice in

		"Edit table" ) editTable
				;;

		"List tables" ) listTables
				;;

		"Create table" ) createTable
				;;

		"Delete table" ) deleteTable
				;;

		"Back" ) break
				;;

		* ) printf $REPLY" is not an option!\n"
				;;
	esac
done
