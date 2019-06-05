#!/bin/bash
#Utilites per LAS - Lorenzo Amorosa

# Legge uno specifico attributo di una entry ldap
# ARGOMENTI : $1 Distinguished Name , $2 Nome attributo
# RETURN : 0 se l ’ attributo e ’ stato trovato , 1 altrimenti
function readldapattr () {
	RES=$(ldapsearch -x -b "$1" -s base | egrep "^$2" | awk -F ": " '{ print $2 }')
	if test -z "$RES" ; then
		return 1
	else
		echo "$RES"
		return 0
	fi
}
# Esempio d ’ uso :
ATTRVAL=$(readldapattr "ind=10.9.9.1,ind=10.1.1.1,dc=labammsis" "cnt")
echo "RETURN VALUE: $?"
echo "ATTR VALUE: $ATTRVAL"
