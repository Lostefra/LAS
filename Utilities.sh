#!/bin/bash
#Utilites per LAS - Lorenzo Amorosa

############################-COMMANDS-########################################

#copia file remota, inserire nomefile e valore X (1 Client, 2 Router, 3 Server)
scp nomefile las@192.168.56.20X:
seq first | first last | first increment last

############################-AT-########################################

#due comandi tra mezz'ora
echo "/root/ldapmod.sh $UTENTE status closed ; /root/ldapmod.sh $UTENTE used 0" | at now + 30 minutes

############################-ROOT-#######################################

comandi di root: iptables, ss, tcpdump
#script da chiamare supposti in /root/

############################-CHECK-######################################

#Controllo parametri
if [[ $# -ne "3" ]]; then 
	echo "Uso: $! ip_client num ip_generico"
	exit 1
else
	# $1 ultimo byte ip tra 1-100
	if ! echo "$1" | egrep "^10\.1\.1\.([1-9][0-9]?|100)$" ; then
		echo "$1 non e' un IP valido di client"
		exit 2
	fi
	#Controllo che $2 sia un numero intero
	if ! [[ "$2" =~ ^[0-9]+$ ]]; then
		echo "$2 is not a number"
		exit 3
	fi
	#notare che non sono ammessi indirizzi broadcast (non ammesso valore 255)
	#occhio agli indirizzi che terminano per 0, basta spostare il '?' dopo [0-9]
	if ! [[ "$3" =~ ^(25[0-4]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-4]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-4]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-4]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$ ]] ; then
		echo "$3 non e' un IP valido"
		exit 4
	fi
fi

##########################-LDAP-########################################

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

##########################-LDAP-########################################

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
ATTRVAL=$(readldapattr "user=pippo,dc=labammsis" "status" "127.0.0.1")
echo "RETURN VALUE: $?"
echo "ATTR VALUE: $ATTRVAL"

#leggere piu' attributi con 1 unico ldapsearch (ORDINE ALFABETICO ATTRIBUTI)
ldapsearch -x -h localhost -b "user=pippo,dc=labammsis" -s base | sort | egrep "^used :|^limit :" | awk '{ print $2 }' > /tmp/ldap$$
LIM=$(head -1 /tmp/ldap$$)
USE=$(tail -1 /tmp/ldap$$)

##########################-LDIF-########################################

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

##########################-LDIF-########################################

# Definizione di una entry per lo schema data (file entry.ldif)
dn: user=pippo,dc=labammsis
objectClass: data
user: pippo
update: 1234567890
used: 0
status: closed
limit: 200

##########################-LDIF-########################################

# File differenze.ldif che modifica l’attributo used dell’entry
# definita in precedenza con dn: user=pippo,dc=labammsis
dn: user=pippo,dc=labammsis
changetype: modify
replace: used
used: 50

##########################-LDAP-########################################

# Modifica uno specifico attributo di una entry ldap
# ARGOMENTI: $1 Distinguished Name, $2 Nome attributo, $3 Nuovo valore, $4 host server ldap
# RETURN: 0 se l'attributo e'stato modificato, 1 altrimenti
function modldapattr() {
	echo -e "dn: $1\nchangetype: modify\nreplace: $2\n$2: $3" | ldapmodify -x -h "$4" -D "cn=admin,dc=labammsis" -w admin
	return $?
}
# Esempio d’uso :
modldapattr "ind=10.9.9.1,ind=10.1.1.1,dc=labammsis" "cnt" "2" "127.0.0.1"
echo "RETURN VALUE: $?"

##########################-LOG-#########################################

#Scrivere un messaggio al logger
logger -p local4.info ___$(hostname -I | egrep -o "10\.1\.1\.([1-9][0-9]?|100)")___$(whoami)___
#formato:
#Jun  7 14:29:40 Router las: ___prova1___ciao___
#facility: auth, ftp, news, authpriv, kern, syslog, cron, lpr, user, daemon, mail, uucp, local0 .. local7
#priority: emerg, alert, crit, err, warning, notice, info, debug

#leggere da /var/log/reqs righe con formato
#Jun  7 14:29:40 Router las: ___prova1___ciao___
tail --pid=$$ -f /var/log/reqs | while read mm gg hh host user msg ; do
	IP=$(echo $msg | awk -F '___' '{ print $2 }')
	UTENTE=$(echo $msg | awk -F '___' '{ print $3 }')
	echo $IP
	echo $UTENTE
done

##########################-LOG-#########################################

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

##########################-SNMP-#########################################

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

##########################-SNMP-#########################################

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

##########################-IPTABLES-#########################################

#Le regole iptables vengono resettate allo spegnimento della macchina, se si vogliono rendere persistenti
#è quindi importante aggiungerle al file .bashrc
# Visualizza le configurazioni di iptables (tabella filter), -x per valori numerici esatti
iptables -vnxL
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
! -s <address>[/<netmask>]
# Specificando il protocollo tcp o udp , si possono selezionare le porte:
--dport <prt> # Pacchetti con porta di destinazione == <prt>
--sport <prt> # Pacchetti con porta di partenza == <prt>
# Nel caso del protocollo TCP , anche lo stato della connessione:
-m state --state NEW,ESTABLISHED
-m state --state ESTABLISHED

#ARGOMENTI: $1 A oppure D per aggiungere o togliere la regola, $2 indirizzo sorgente, ma da settare a seconda dei casi
function gestisciRegola() {
	iptables -"$1" INPUT -s "$2" -j ACCEPT
	#iptables -"$1" FORWARD -i eth2 -o eth1 -s "$2" ! -d 10.1.1.0/24 -j ACCEPT
	#iptables -"$1" FORWARD -i eth1 -o eth2 ! -s 10.1.1.0/24 -d "$2" -j ACCEPT -m state --state ESTABLISHED
	#iptables -t nat -"$1" POSTROUTING -i eth2 -o eth1 -s "$2" ! -d 10.1.1.0/24 -j SNAT --to-source 10.9.9.250
}

# Esempio d'uso
# Aggiungo la regola
gestisciRegola A 10.1.1.1
# Elimino la regola
gestisciRegola D 10.1.1.1

#Inserisce una regola che logga i pacchetti in transito nella chain specificata con prefisso e livello di log specificati
#I log hanno facility=kernel, --log-level=debug => i log salvati con livello kernel.debug 
iptables -I <chain> <options> -j LOG --log-prefix="___prefisso___" --log-level=<livello_log>
# Logga l'inizio di ogni connessione inoltrata da 10.1.1.1 a 10.9.9.1 con livello debug e prefisso ___NEWCON___
iptables -I FORWARD -i eth2 -s 10.1.1.1 -d 10.9.9.1 -p tcp --tcp-flags SYN SYN -j LOG --log-prefix "___NEWCON___" --log-level=debug
# Logga la fine di ogni connessione inoltrata da 10.1.1.1 a 10.9.9.1 con livello debug e prefisso ___ENDCON___
iptables -I FORWARD -i eth2 -s 10.1.1.1 -d 10.9.9.1 -p tcp --tcp-flags FIN FIN -j LOG --log-prefix "___ENDCON___" --log-level=debug

##########################-IPTABLES DEFAULT-#####################################

#data una coppia di indirizzi, un'interfaccia e una porta si abilitano le comunicazioni
#in entrambe le direzioni, entrambi i componenti sono sia server che client
function confTotallyBidir(){
	# confTotallyBidir interface ip1 ip2 port
    	# ip2 come server di ip1
	iptables -I INPUT -i $1 -s $2 -d $3 -p tcp --dport $4 -j ACCEPT
    	iptables -I OUTPUT -o $1 -d $2 -s $3 -p tcp --sport $4 -m state --state ESTABLISHED -j ACCEPT
	# ip2 come client di ip1
   	iptables -I INPUT -i $1 -s $2 -d $3 -p tcp --sport $4 -m state --state ESTABLISHED -j ACCEPT
    	iptables -I OUTPUT -o $1 -d $2 -s $3 -p tcp --dport $4 -j ACCEPT
    	# ip1 come server di ip2
  	iptables -I INPUT -i $1 -s $3 -d $2 -p tcp --dport $4 -j ACCEPT
    	iptables -I OUTPUT -o $1 -d $3 -s $2 -p tcp --sport $4 -m state --state ESTABLISHED -j ACCEPT
	# ip1 come client di ip2
   	iptables -I INPUT -i $1 -s $3 -d $2 -p tcp --sport $4 -m state --state ESTABLISHED -j ACCEPT
   	iptables -I OUTPUT -o $1 -d $3 -s $2 -p tcp --dport $4 -j ACCEPT
}

#data una coppia di indirizzi, un'interfaccia e una porta si abilitano le comunicazioni
#rendendo ip1 client di ip2, ip2 server di ip1
function confTotallyMono(){
	# confConnMono interface ip1 ip2 port
    	# ip2 come server di ip1
	iptables -I INPUT -i $1 -s $2 -d $3 -p tcp --dport $4 -j ACCEPT
    	iptables -I OUTPUT -o $1 -d $2 -s $3 -p tcp --sport $4 -m state --state ESTABLISHED -j ACCEPT
	# ip1 come client di ip2
   	iptables -I INPUT -i $1 -s $3 -d $2 -p tcp --sport $4 -m state --state ESTABLISHED -j ACCEPT
   	iptables -I OUTPUT -o $1 -d $3 -s $2 -p tcp --dport $4 -j ACCEPT
}

#data una coppia di indirizzi, un'interfaccia e una porta si abilitano le comunicazioni
#rendendo ip2 server di ip1
function confMono(){
	# confMono interface ip1 ip2 port proto
	iptables -I INPUT -i $1 -s $2 -d $3 -p $5 --dport $4 -j ACCEPT
    	iptables -I OUTPUT -o $1 -d $2 -s $3 -p $5 --sport $4 -m state --state ESTABLISHED -j ACCEPT
}

#scarto qualsiasi configurazione precedente
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD
#confTotallyBidir
confTotallyBidir eth1 10.9.9.254 10.9.9.253 22
confTotallyBidir eth2 10.1.1.254 10.1.1.253 22
confTotallyBidir eth3 192.168.56.254 192.168.56.253 22
confTotallyBidir eth3 192.168.56.254 192.168.56.253 389
# LDAP client-router (router server ldap)
confMono eth2 10.1.1.0/24 10.1.1.250 389 tcp
iptables -I INPUT -i eth2 -p tcp -s 10.1.1.0/24 -d 10.1.1.250 --dport 389 -j ACCEPT
iptables -I OUTPUT -o eth2 -p tcp -d 10.1.1.0/24 -s 10.1.1.250 --sport 389 -m state --state ESTABLISHED -j ACCEPT
# rsyslog client-router (log registrati su router)
confMono eth2 10.1.1.0/24 10.1.1.254 514 udp
iptables -I INPUT -i eth2 -p udp -s 10.1.1.0/24 -d 10.1.1.254 --dport 514 -j ACCEPT
iptables -I OUTPUT -o eth2 -p udp -d 10.1.1.0/24 -s 10.1.1.254 --sport 514 -m state --state ESTABLISHED -j ACCEPT
# SNMP router-client (demone snmp su client)
confMono eth2 10.1.1.254 10.1.1.0/24 161 udp
iptables -I OUTPUT -o eth2 -p udp -d 10.1.1.0/24 -s 10.1.1.254 --dport 161 -j ACCEPT
iptables -I INPUT -i eth2 -p udp -s 10.1.1.0/24 -d 10.1.1.254 --sport 161 -m state --state ESTABLISHED -j ACCEPT
# Accetta tutti i pacchetti dell'interfaccia di loopback
iptables -I INPUT -i lo -s 127.0.0.0/8 -j ACCEPT
iptables -I OUTPUT -o lo -d 127.0.0.0/8 -j ACCEPT
# Imposto policy di default
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Consenti le connessioni SSH ( in questo caso verso router ) PER DEBUG
iptables -I INPUT -i eth3 -s 192.168.56.1 -d 192.168.56.202 -p tcp --dport 22 -j ACCEPT
iptables -I OUTPUT -o eth3 -d 192.168.56.1 -s 192.168.56.202 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

##########################-IPTABLES NAT-#########################################

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

#Esempi:
# Intercetta le connessioni SSH da Client a Router e le ridirige a Server
iptables -t nat -A PREROUTING -i eth2 -s 10.1.1.1 -d 10.1.1.254 -p tcp --dport 22 -j DNAT --to-dest 10.9.9.1
# Espone le connessioni dal Client al Server come se venissero dal Router stesso
iptables -t nat -A POSTROUTING -o eth1 -s 10.1.1.1 -d 10.9.9.1 -j SNAT --to-source 10.9.9.254

##########################-IPTABLES CHAIN/STORE-#####################################

# Crea la chain PIPPO
iptables -N PIPPO
# Inserisco una regola all'interno di PIPPO che faccia direttamente il RETURN (ovvero ritorni alla chain che l'ha invocata)
iptables -I PIPPO -j RETURN
# Elimino tutte le regole all'interno di PIPPO ( FLUSH )
iptables -F PIPPO
# Elimino la chain PIPPO
iptables -X PIPPO

# Salva la configurazione corrente sul file
iptables-save > /tmp/output
# Ripristina la configurazione salvata
iptables-restore < /tmp/output

############################-CRON-###################################################

#Esegue il comando ogni 5 minuti
# */5 * * * * /root/traffic.sh
#Esegue il comando da lun a ven alle 22
# 00 22 * * 1-5 /root/traffic.sh
# configuro cron per l'esecuzione
/usr/bin/crontab -l > /tmp/traffic.cron.$$
echo "*/5 * * * * /root/traffic.sh" >> /tmp/traffic.cron.$$
/usr/bin/crontab /tmp/traffic.cron.$$
/bin/rm -f /tmp/traffic.cron.$$

if /usr/bin/tty > /dev/null ; then
	# invocato da terminale, controllo parametri
else
	# Invocato da cron
fi













