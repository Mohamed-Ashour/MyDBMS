#!/usr/bin/ksh

user=$1
database=$2
table=$3

theTypes()
{
	if echo $1 | egrep -q '^[0-9]+$'; then
	    echo "int"
	else
	    echo "str"
	fi
}


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


displayTable()
{
	clear
	cnum=$(grep $table $user/$database/meta|cut -d":" -f2)
	for (( c = 0; c <= cnum; c++ )); do
		part=$(($c+3))
		col=$(grep $table $user/$database/meta|cut -d":" -f $part|cut -d"," -f1)
		columns[c]=$col
	done
	echo ${columns[*]}|sed 's/ /'"\t"'/g'
	echo "________________________________________________________________________________"
	awk -F: '{print $0}' $user/$database/$table|tr ':' '\t'
	loading
}


addColumn(){
	clear
	echo "Enter column name"
	read cname
	echo "Enter column name"
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
	col="$cname,$ctype"

	awk -F: -v co=$col -v t=$table '{
		if($1==t){
			$2=$2+1
			print $0":"co
		}
		else{
			print
		}
	}' $user/$database/meta|sed 's/ /:/g' > $user/$database/temp
	cat $user/$database/temp > $user/$database/meta
	rm $user/$database/temp

	sed -i s/$/:/g $user/$database/$table
	echo
	echo "Colnum added succssfuly"
	loading
}

deleteColumn()
{
	clear
	echo "Enter column name"
	read cname
	f=0
	for c in `awk -F: -v table=$table '{if($1==table){for(i=3;i<=NF;i++){print $i} } }' $user/$database/meta` ; do
		col=$(echo $c|cut -d"," -f1)
		if [[ "$cname" == "$col" ]]; then
			f=1
			break
		fi
	done
	if [[ $f -eq 0 ]]; then
		echo "Column is not found"
	else
		echo "Are you sure you want to delete this table ? (y/n)"
		read r
		while [ "$r" != "y" ] && [ "$r" != "n" ]; do
			echo "Wrong answer"
			echo "Are you sure you want to delete it ? (y/n)"
			read r
		done
		if [ "$r" == "y" ]; then
			colnum=$(awk -F: -v col1="$cname,int" -v t=$table -v col2="$cname,str" '{
				if($1==t){
					for(i=3; i<NF+2; i++){
						if($i==col1 || $i==col2){
							print i-2
							break
						}
					}
				}
			} ' $user/$database/meta)

			awk -F: -v col1="$cname,int" -v t=$table -v col2="$cname,str" '{
				if($1==t){
					for(i=3; i<NF+2; i++){
						if($i==col1 || $i==col2){
							break
						}
					}
					$i=""
					$2=$2-1
					print $0
				}
				else{
					print $0
				}

			} ' $user/$database/meta|sed 's/'" "'$//'|tr -s ' ' ':' > $user/$database/temp
			cat $user/$database/temp > $user/$database/meta

			awk -F: -v c=$colnum '{
				$c=""
				print $0
			}' $user/$database/$table|sed 's/^'" "'//'|sed 's/'" "'$//'|tr -s '  ' ':' > $user/$database/temp
			cat $user/$database/temp > $user/$database/$table
			rm $user/$database/temp
			echo
			echo "Colnum deleted succssfuly"
		elif [ "$r" == "n" ]; then
			echo "We are good"
		fi
	fi
	loading
}

insertRow()
{
	clear
	cnum=$(grep $table $user/$database/meta|cut -d":" -f2)
	for (( c = 0; c < cnum; c++ )); do
		part=$(($c+3))
		typee=$(grep $table $user/$database/meta|cut -d":" -f $part|cut -d"," -f2)
		colName=$(grep $table $user/$database/meta|cut -d":" -f $part|cut -d"," -f1)

		printf "Enter value for $colName"
		printf '('"$typee"')'"\n"
		read val
		#Validate ID
		isThere=0
		if [[ "$colName"=="ID" ]]; then
			isThere=$(awk -F: -v id=$val '{if($1 == id){print 1}}' $user/$database/$table)
			while [[ isThere -eq 1 ]] || [[ "$typee" != `theTypes $val` ]]; do
				echo "ID already exists or wrong type"
				read val
				isThere=$(awk -F: -v id=$val '{if($1 == id){print 1}}' $user/$database/$table)
			done
		fi

		#Validate type
		while [[ "$typee" != `theTypes $val` ]]; do
			echo "wrong type! enter again"
			read val
		done
		values[$c]=$val
	done

	echo ${values[*]}|sed 's/ /:/g'>>$user/$database/$table
	echo
	echo "Row inserted succssfuly"
	loading
}


updateRow()
{
	clear
	echo "Enter ID of the row you want to update"
	read id

	cnum=$(grep $table $user/$database/meta|cut -d":" -f2)
	for (( c = 0; c < cnum; c++ )); do
		part=$(($c+3))
		typee=$(grep $table $user/$database/meta|cut -d":" -f $part|cut -d"," -f2)
		colName=$(grep $table $user/$database/meta|cut -d":" -f $part|cut -d"," -f1)

		printf "Enter value for $colName"
		printf '('"$typee"')'"\n"
		read val
		#Validate ID
		isThere=0
		if [[ "$colName"=="ID" ]]; then
			isThere=$(awk -F: -v myid=$val -v sid=$id '{if($1 == myid && $1 != sid){print 1}}' $user/$database/$table)
			while [[ isThere -eq 1 ]]; do
				echo "ID already exists try another one"
				read val
				isThere=$(awk -F: -v myid=$val '{if($1 == myid && $1 != sid){print 1}}' $user/$database/$table)
			done
		fi

		#Validate type
		while [[ "$typee" != `theTypes $val` ]]; do
			echo "wrong type! enter again"
			read val
		done

		values[$c]=$val
	done
	newline=$(echo ${values[*]}|sed 's/ /:/g')

	line=$(awk -F: -v id=$id '{if($1 == id){print $0}}' $user/$database/$table)
	sed -i 's/'"$line"'/'"$newline"'/' $user/$database/$table
	echo
	echo "Row updated succssfuly"
	loading
}


deleteRow()
{
	clear
	echo "Enter ID of the row you want to delete"
	read id
	line=$(awk -F: -v id=$id '{if($1 == id){print $0}}' $user/$database/$table)
	sed -i '/'"$line"'/d' $user/$database/$table
	echo
	echo "Row deleted succssfuly"
	loading
}



clear
printf "You are editing $table table in $database database\nChoose what you like to do in it\n\n"

select choice in "Display table's rows" "Insert row" "Update row" "Delete row" "Add column" "Delete column" "Back"
do
	case $choice in

		"Display table's rows" ) displayTable
				;;

		"Insert row" ) insertRow
				;;

		"Update row" ) updateRow
				;;

		"Delete row" ) deleteRow
				;;

		"Add column" ) addColumn
		;;

		"Delete column" ) deleteColumn
				;;

		"Back" ) break
				;;

		* ) printf $REPLY" is not an option\n"
				;;
	esac
done
