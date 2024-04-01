#!/bin/bash

# read argument given besides bash execution
INPUT=$1

# check if input is null
if [ -z $INPUT ]
then
	echo "Please provide an element as an argument."
	exit
fi

# connection to the database and queries
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

#VERIFY IF THE INPUT IS NUMBER OR NOT
IS_NUM(){
  num='^[0-9]+([.][0-9]+)?$'
  if [[ $1 =~ $num ]]; then
     return 0
  else
     return 1
  fi
 }

# verifies if argument exist in the database and call another method, if not, close the program and ask to give a valid argument
INFO(){
 if IS_NUM $INPUT;
 then
	ELEMENT=$($PSQL "SELECT name FROM elements WHERE atomic_number = $INPUT")
	if [[ -z $ELEMENT ]]
	then
		echo  I could not find that element in the database. 
	else
		IF_ELEMENT_EXIST
	fi
 else
	ELEMENT=$($PSQL "SELECT name FROM elements WHERE name = '$INPUT' OR symbol ='$INPUT' ")
	if [[ -z $ELEMENT ]]
	then 
		echo I could not find that element in the database.
	else
		IF_ELEMENT_EXIST	
	fi
 fi
}

# If element exist, gives all the info requiered by the user
IF_ELEMENT_EXIST(){

if IS_NUM $INPUT;
 then
        ELEMENT=$($PSQL "SELECT name FROM elements WHERE atomic_number = $INPUT ")
        SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $INPUT")
        MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $INPUT ")
        BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $INPUT ")
        SORT=$($PSQL "SELECT sort FROM properties WHERE atomic_number = $INPUT ")
        ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $INPUT ")
        echo "The element with atomic number $INPUT is $ELEMENT ($SYMBOL). It's a $SORT, with a mass of $ATOMIC_MASS amu. $ELEMENT has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
 else
        ELEMENT=$($PSQL "SELECT name FROM elements WHERE symbol = '$INPUT' OR name = '$INPUT' ")
        SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name = '$INPUT' OR symbol = '$INPUT' ")
        MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties INNER JOIN elements USING(atomic_number)  WHERE name = '$INPUT' OR symbol = '$INPUT' ")
        BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties INNER JOIN elements USING(atomic_number)  WHERE name = '$INPUT' OR symbol = '$INPUT' ")
        SORT=$($PSQL "SELECT sort FROM properties INNER JOIN elements USING(atomic_number) WHERE name = '$INPUT' OR symbol = '$INPUT' ")
        ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties INNER JOIN elements USING(atomic_number) WHERE name = '$INPUT' OR symbol = '$INPUT' ")
        ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$INPUT' OR symbol = '$INPUT' ")
        echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT ($SYMBOL). It's a $SORT, with a mass of $ATOMIC_MASS amu. $ELEMENT has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
 fi
}

# calls method INFO to verify input
INFO
