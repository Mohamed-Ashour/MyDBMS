#!/usr/bin/ksh

user=$1 


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


useDatabase()
{
	clear
	echo "Database name: "
	read usname

	f=0
	for d in `cat $user/dbslist` ; do
		if [ "$usname" == "$d" ]; then
			f=1
			break
		fi
	done
	if [[ $f -eq 0 ]]; then
		echo "Database is not found"
	else
		clear
		printf "Using $usname database "
		sleep .7
		printf "."
		sleep .7
		printf "."
		sleep .7
		printf "."
		sleep .7
		printf "."
	 	./tables.sh $user $usname
	fi
	loading
}


listDatabases()
{
	clear
	cat $user/dbslist
	loading
}


createDatabase()
{
	clear
	echo "Database name: "
	read cname

	f=0
	for d in `cat $user/dbslist` ; do
		if [ "$cname" == "$d" ]; then
			f=1
			break
		fi
	done
	if [[ $f -eq 0 ]]; then
		mkdir $user/$cname
		touch $user/$cname/meta
		echo $cname >> $user/dbslist
		echo "Database created succssfuly"
	else
	 	echo "Database is already exists"
	fi
	
	loading
}


deleteDatabase()
{
	clear
	echo "Database name: "
	read dname
	f=0
	for d in `cat $user/dbslist` ; do
		if [ "$dname" == "$d" ]; then
			f=1
			break
		fi
	done
	if [[ $f -eq 0 ]]; then
		echo "Database is not found"
	else
	 	echo "Are you sure you want to delete this database ? (y/n)"
		read r
		while [ "$r" != "y" ] && [ "$r" != "n" ]; do
			echo "Wrong answer"	
			echo "Are you sure you want to delete it ? (y/n)"
			read r
		done
		if [ "$r" == "y" ]; then
			rm -r $user/$dname
			sed -i '/^'"$dname"'$/d' $user/dbslist			 
			echo "Database deleted succssfuly"
		elif [ "$r" == "n" ]; then
			echo "We are good"
		fi
	fi
	loading
}


clear
printf "Hi $user!\nWhat would you like to do?\n\n"

select choice in "Use database" "List databases" "Create database" "Delete databases" "Back"
do
	case $choice in
		"Use database" ) useDatabase
			;;

		"List databases" ) listDatabases	
			;;

		"Create database" ) createDatabase
			;;

		"Delete databases" ) deleteDatabase
			;;

		"Back" ) break
			;;

		* ) printf $REPLY" is not an option!\n"
			;;
	esac
done
