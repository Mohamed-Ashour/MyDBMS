#!/usr/bin/ksh

clear
touch users

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

loginF()
{
	clear
	echo "User name:"
	read user
	f=0

	for u in `cat users` ; do
		if [ "$user" == "$u" ]; then
			f=1
			break
		fi
	done
	if [[ $f -eq 1 ]]; then
		clear
		printf "Logging as $user "
		sleep .7
		printf "."
		sleep .7
		printf "."
		sleep .7
		printf "."
		sleep .7
		printf "."
		./databases.sh $user
	else
		echo "User is not found"
	fi
	loading
}


createUser()
{
	clear
	echo "User name:"
	read user
	for u in `cat users` ; do
		if [ "$user" == "$u" ]; then
			f=1
			break
		fi
	done
	if [[ $f -eq 1 ]]; then
		echo "User already exists"
	else
		mkdir $user
		touch $user/dbslist
		echo $user >> users
		echo "User is created succssfuly"
	fi
	loading
}

deleteUser()
{
	clear
	echo "User name:"
	read user
	f=0
	for u in `cat users` ; do
		if [ "$user" == "$u" ]; then
			f=1
			break
		fi
	done
	if [[ $f -eq 0 ]]; then
		echo "User is not found"
	else
	 	echo "Are you sure you want to delete this user ? (y/n)"
		read r
		while [ "$r" != "y" ] && [ "$r" != "n" ]; do
			echo "Wrong answer"
			echo "Are you sure you want to delete it ? (y/n)"
			read r
		done
		if [ "$r" == "y" ]; then
			rm -r $user
			sed -i '/^'"$user"'/d' users
			echo "User deleted succssfuly"

		elif [ "$r" == "n" ]; then
			echo "We are good"
		fi
	fi
	loading
}


printf "Hello!\n\n"
select choice in "Login" "Create user" "Delete user" "Exit"
do

	case $choice in

		"Login" ) loginF
			;;

		"Create user" ) createUser
			;;

		"Delete user" ) deleteUser
			;;

		"Exit" ) break
			;;

		* ) printf $REPLY" is not an option!\n"
			;;
	esac
done

printf "\nGoodbye"
sleep .5
printf "."
sleep .5
printf "."
sleep .5
printf ".\n\n"
