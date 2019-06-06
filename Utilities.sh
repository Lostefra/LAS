#!/bin/bash
#Utilites per LAS - Lorenzo Amorosa

############################ SCP ########################################

#copia file remota, inserire nomefile e valore X (1 Client, 2 Router, 3 Server)
scp nomefile las@192.168.56.20X:

############################ ROOT #######################################

comandi di root: iptables, ss, tcpdump

############################ CHECK ######################################

#Controllo parametri
if [[ $# -ne "3" ]]; then 
	echo "Uso: $! ip_client num ip_generico"
	exit 1
else
	# $1 ultimo byte ip tra 1-100
	if ! echo "$1" | egrep '^10.1.1.([1-9][0-9]?|100)$' ; then
		echo "$1 non e' un IP valido di client"
		exit 2
	fi
	#Controllo che $2 sia un numero intero
	if [[ "$2" == *[!0-9]* ]]; then
		echo "$2 is not a number"
		exit 3
	fi
	if [[ ! "$3" =~ ^(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$ ]] ; then
		echo "$3 non e' un IP valido"
		exit 4
	fi
fi

########################## LDAP ########################################

#avvio demone ldap
sudo systemctl restart slapd
#aggiungere uno schema ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f nomefile.ldif
#Visualizzare l'entry e tutti i figli a partire da "dc=labammsis" su ldap locale
ldapsearch -x -h 127.0.0.1 -b "dc=labammsis"
#Visualizzare solo i figli di primo livello di "fn=home,dc=labammsis" su ldap locale
ldapsearch -x -h 127.0.0.1 -b "fn=home,dc=labammsis" -s one
#Visualizzare solo l'entry "fn=home,dc=labammsis" su ldap locale
ldapsearch -x -h 127.0.0.1 -b "fn=home,dc=labammsis" -s base
#Aggiungere una entry allo schema ldif
ldapadd -x -D "cn=admin,dc=labammsis" -w admin -f entry.ldif
#Eliminare una entry dallo schema ldif
ldapdelete -x -D "cn=admin,dc=labammsis" -w admin "user=pippo,dc=labammsis"
#Modificare una entry sullo schema ldif su ldap locale (oppure vedi funzione modldapattr)
ldapmodify -x -h 127.0.0.1 -D "cn=admin,dc=labammsis" -w admin -f differenze.ldif
#Visualizzare solo le entry con un certo valore di un attributo (output NON pulito)
ldapsearch -x -h 127.0.0.1 -b "dc=labammsis" -s one 'status=open'
#Visualizzare solo un attributo di una entry (output NON pulito)
ldapsearch -x -h 127.0.0.1 -b "user=pippo,dc=labammsis" -s one status

########################## LDAP ########################################

# Legge uno specifico attributo di una entry ldap
# ARGOMENTI : $1 Distinguished Name , $2 Nome attributo, $3 ip server ldap
# RETURN : 0 se l ’ attributo e ’ stato trovato , 1 altrimenti
function readldapattr() {
	RES=$(ldapsearch -x -h "$3" -b "$1" -s base | egrep "^$2 :" | awk -F ": " '{ print $2 }')
	if test -z "$RES" ; then
		return 1
	else
		echo "$RES"
		return 0
	fi
}
# Esempio d ’ uso :
ATTRVAL=$(readldapattr "ind=10.9.9.1,ind=10.1.1.1,dc=labammsis" "cnt" "127.0.0.1")
echo "RETURN VALUE: $?"
echo "ATTR VALUE: $ATTRVAL"

########################## LDIF ########################################

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

########################## LDIF ########################################

# Definizione di una entry per lo schema data (file entry.ldif)
dn: user=pippo,dc=labammsis
objectClass: data
user: pippo
update: 1234567890
used: 0
status: closed
limit: 200

########################## LDIF ########################################

# File differenze.ldif che modifica l’attributo used dell’entry
# definita in precedenza con dn: user=pippo,dc=labammsis
dn: user=pippo,dc=labammsis
changetype: modify
replace: used
used: 50

########################## LDAP ########################################

# Modifica uno specifico attributo di una entry ldap
# ARGOMENTI : $1 Distinguished Name , $2 Nome attributo , $3 Nuovo valore, $4 host server ldap
# RETURN : 0 se l ’ attributo e ’ stato modificato , 1 altrimenti
function modldapattr() {
	echo -e "dn: $1\nchangetype: modify\nreplace: $2\n$2: $3" | ldapmodify -x -h "$4" -D "cn=admin,dc=labammsis" -w admin
	return $?
}
# Esempio d’uso :
modldapattr "ind=10.9.9.1,ind=10.1.1.1,dc=labammsis" "cnt" "2" "127.0.0.1"
echo "RETURN VALUE: $?"

########################## LOG #########################################

#Scrivere un messaggio al logger
logger -p local4.info "___$(hostname -I | egrep -o '10\.1\.1\.')___$(whoami)___"

########################## LOG #########################################

#Come configurare rsyslog
#/etc/rsyslog.d/esame.conf
# -- su C: local1.=info	@10.1.1.253
#          local1.=info	@10.1.1.254
# -- su R: local1.=info /var/log/reqs
#Decommentare le seguenti linee in /etc/rsyslog.conf
#       $ModLoad imudp
#	$UDPServerRun 514
#Eseguire il comando
#sudo systemtctl restart rsyslog

########################## SNMP #########################################

#snmpget esame
snmpget -v 1 -c public 10.1.1.1 'NET-SNMP-EXTEND-MIB::nsExtendOutputFull."esame"' | awk -F ' = STRING: ' '{ print $2 }'

#Configurare il demone snmp su client commentando nel file /etc/snmp/snmp.conf la riga "mibs:" per avere i nomi simbolici
#Inoltre nel file /etc/snmp/snmpd.conf svolgere le seguenti operazioni:
#attivare ricezione udp con la riga "agentAddress udp:161" 
#Definire una vista che includa tutto il MIB con "view all included .1"
#Abilitare le community ad operare su quella vista con "rocommunity public default -V all" e "rwcommunity supercom default -V all"
#Inserire inoltre la riga "extend-sh esame ps -C connect.sh -o user | grep -v USER"
#Infine eseguire il comando "sudo systemtctl restart snmpd"

#Per prova inserisci "view systemonly included .1"

#Visualizza tutti gli oggetti del server 10.9.9.1
snmpwalk -v 1 -c public 10.9.9.1 .1 | less
#Visualizza tutti gli oggetti del server 10.9.9.1 mostrando OID
snmpwalk -On -v 1 -c public 10.9.9.1 .1 | less
# Visualizza il valore di una specifica entry del server 10.9.9.1 'SNMPv2-MIB::sysName.0'
snmpget -v 1 -c public 10.9.9.1 'SNMPv2-MIB::sysName.0'

#Per fare in modo che SNMP possa essere esteso per eseguire un comando di root sono necessari alcuni passaggi:
#Per far eseguire a SNMP comandi di root serve editare il file di configurazione /etc/snmp/snmpd.conf per includere la nuova regola:
# Restituisce le connessioni correntemente attive
#extend activeconn /usr/bin/sudo /bin/ss -ntp
# editare il file /etc/sudoers con: sudo visudo
# Permette all'utente snmp di eseguire il comando ss senza digitare la password
#snmp ALL=NOPASSWD:/bin/ss

# Aggiungere al file: /etc/snmp/snmpd.conf (segue esempio)
proc <nome_processo> <max_numero> <min_numero>
#proc rsyslogd 10 1
#Elenco dei processi monitorati da snmp su localhost
snmpwalk -v 1 -c public localhost "UCD-SNMP-MIB::prNames"
# Visualizza tutti i valori di UDC - SNMP - MIB
snmpwalk -v 1 -c public localhost .1 | grep "UCD-SNMP-MIB"

# Ottengo l'id del processo "rsyslogd" su localhost e lo salvo in ID
ID=$(snmpwalk -v 1 -c public localhost "UCD-SNMP-MIB::prNames" | grep mountd | awk -F "prNames." '{ print $2 }' | awk -F " = " '{ print $1 }')
# Utilizzo l'id per ottenere il conteggio, verifico cosi' se il processo e' in esecuzione su localhost
snmpget -v 1 -c public localhost "UCD-SNMP-MIB::prCount.$ID" | awk -F "INTEGER: " '{ print $2 }'

########################## SNMP #########################################

# Ottiene il numero di istanze di un processo registrato tramite SNMP
# ARGOMENTI : $1 nome processo , $2 indirizzo macchina
function getProcessCount{
	ID=$(snmpwalk -v 1 -c public "$2" "UCD-SNMP-MIB::prNames" | grep "$1" | awk -F "prNames." '{ print $2 }' | awk -F " = " '{ print $1 }')
	NUM=$(snmpget -v 1 -c public "$2" "UCD-SNMP-MIB::prCount.$ID" | awk -F "INTEGER: " '{ print $2 }')
	echo $NUM
}

# Esempio d'utilizzo:
NUMERO=$(getProcessCount "rsyslogd" "10.9.9.1" )
echo $NUMERO

########################## IPTABLES #########################################

#Le regole iptables vengono resettate allo spegnimento della macchina, se si vogliono rendere persistenti
#è quindi importante aggiungerle al file .bashrc
# Visualizza le configurazioni di iptables (tabella filter)
iptables -vnL
# Visualizza una singola chain
iptables -L <chain>
#Policy:
#DROP: Scarta il pacchetto
#REJECT: Scarta il pacchetto ed invia un pacchetto ICMP per segnalare l’errore al mittente.
#ACCEPT: Accetta il pacchetto.
#chain: INPUT, OUTPUT, FORWARD
# Aggiungo una regola in coda ( APPEND ) alla chain FORWARD
iptables -A FORWARD <options> -j <policy>
# Aggiungo una regola all'inizio della coda ( INSERT ) alla chain FORWARD
iptables -I FORWARD <options> -j <policy>
# Rimuovo una regola ( DELETE ) dalla chain FORWARD 
iptables -D FORWARD <options> -j <policy>
# Elimina la regola numero 2 della chain INPUT
iptables -D INPUT 2
#Eliminare tutte le regole (di ogni chain o di quella specificata)
iptables -F <chain>
iptables -F

#options:
-i eth3 # Solo pacchetti in ingresso dall'interfaccia eth3
-o eth3 # Solo pacchetti in uscita dall'interfaccia eth3
-s <ip>[/<netmask>] # Pacchetti che provengono dall'ip specificato
-d <ip>[/<netmask>] # Pacchetti destinati all'ip specificato
-p tcp # Solo pacchetti TCP
-p udp # Solo pacchetti UDP [anche icmp]
#Si puo' specificare il negato di un'opzione
-s ! <address>[/<netmask>]
# Specificando il protocollo tcp o udp , si possono selezionare le porte:
--dport <prt> # Pacchetti con porta di destinazione == <prt>
--sport <prt> # Pacchetti con porta di partenza == <prt>
# Nel caso del protocollo TCP , anche lo stato della connessione:
-m state --state NEW,ESTABLISHED
-m state --state ESTABLISHED

#ARGOMENTI: $1 A oppure D per aggiungere o togliere la regola, $2 indirizzo sorgente, ma da settare a seconda dei casi
function gestisciRegola() {
	iptables -"$1" INPUT -s "$2" -j ACCEPT
}

# Esempio d'uso
# Aggiungo la regola
gestisciRegola A 10.1.1.1
# Elimino la regola
gestisciRegola D 10.1.1.1

########################## IPTABLES #########################################

# Accetta tutti i pacchetti dell'interfaccia di loopback
iptables -I INPUT -i lo -s 127.0.0.0/8 -j ACCEPT
iptables -I OUTPUT -o lo -d 127.0.0.0/8 -j ACCEPT
# Consenti le connessioni SSH ( in questo caso verso router )
iptables -I INPUT -i eth3 -s 192.168.56.1 -d 192.168.56.202 -p tcp --dport 22 -j ACCEPT
iptables -I OUTPUT -o eth3 -d 192.168.56.1 -s 192.168.56.202 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
# Imposto policy di default
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

########################## IPTABLES NAT #########################################

# Visualizza le configurazioni di iptables (tabella nat)
iptables -t nat -vnL
# Visualizza una singola chain
iptables -t nat -L <chain>
#chain: POSTROUTING, PREROUTING, OUTPUT
#Policy:
#MASQUERADE: conversione implicita nell’indirizzo IP assegnato all’interfaccia di uscita.
#ACCEPT: No conversione.
#SNAT --to-source <addr> (chain POSTROUTING) 
#DNAT --to-destination <addr> (chain PREROUTING) 
#con <addr>=<address>|<address>:<port>
#<options> uguali a tabella filter
# Aggiungo una regola in coda ( APPEND ) 
iptables -t nat -A <chain> <options> -j <policy>
# Aggiungo una regola all'inizio della coda ( INSERT )
iptables -t nat -I <chain> <options> -j <policy>
# Rimuovo una regola ( DELETE )
iptables -t nat -D <chain> <options> -j <policy>


















