#!/bin/bash
#Utilites per LAS - Lorenzo Amorosa

#copia file remota
scp nomefile las@192.168.56.20X:

#########################################################################

#avvio demone ldap
sudo systemctl restart slapd
#aggiungere uno schema ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f nomefile.ldif
#Visualizzare l'entry e tutti i figli a partire da "dc=labammsis" su ldap locale
ldapsearch -x -h 127.0.0.1 -b "dc=labammsis"
#Visualizzare solo i figli di primo livello di "fn=home,dc=labammsis"su ldap locale
ldapsearch -x -h 127.0.0.1 -b "fn=home,dc=labammsis" -s one
#Visualizzare solo l'entry "fn=home,dc=labammsis" su ldap locale
ldapsearch -x -h 127.0.0.1 -b "fn=home,dc=labammsis" -s base
#Aggiungere una entry allo schema ldif
ldapadd -x -D "cn=admin,dc=labammsis" -w admin -f entry.ldif
#Eliminare una entry dallo schema ldif
ldapdelete -x -D "cn=admin,dc=labammsis" -w admin "user=pippo,dc=labammsis"

#########################################################################

# Legge uno specifico attributo di una entry ldap
# ARGOMENTI : $1 Distinguished Name , $2 Nome attributo, $3 ip server ldap
# RETURN : 0 se l ’ attributo e ’ stato trovato , 1 altrimenti
function readldapattr () {
	RES=$(ldapsearch -x -h "$3" -b "$1" -s base | egrep "^$2 :" | awk -F ": " '{ print $2 }')
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

#########################################################################

#Schema ldif, importante non prendere gli spazi
dn: cn=data,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: data
olcAttributeTypes: ( 1000.1.1.1 NAME 'user'
  DESC 'nome dello user'
  EQUALITY caseExactMatch
  SUBSTR caseExactSubstringsMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )
olcAttributeTypes: ( 1000.1.1.2 NAME 'limit'
  DESC 'MB trasferibili max'
  EQUALITY integerMatch
  ORDERING integerOrderingMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 )
olcAttributeTypes: ( 1000.1.1.3 NAME 'used'
  DESC 'MB trasferiti'
  EQUALITY integerMatch
  ORDERING integerOrderingMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 )
olcAttributeTypes: ( 1000.1.1.4 NAME 'status'
  DESC 'valore dello status'
  EQUALITY caseExactMatch
  SUBSTR caseExactSubstringsMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )
olcAttributeTypes: ( 1000.1.1.5 NAME 'update'
  DESC 'ultimo update'
  EQUALITY integerMatch
  ORDERING integerOrderingMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 )
olcObjectClasses: ( 1000.2.1.1 NAME 'data'
  DESC 'data'
  MUST ( user $ limit $ used $ status $ update )
  STRUCTURAL )

#########################################################################

# Definizione di una entry per lo schema data
dn: user=pippo,dc=labammsis
objectClass: data
user: pippo
update: 1234567890
used: 0
status: closed
limit: 200

#########################################################################










#########################################################################

#Scrivere un messaggio al logger
logger -p local4.info "___$(hostname -I | egrep -o '10\.1\.1\.')___$(whoami)___"

#########################################################################



