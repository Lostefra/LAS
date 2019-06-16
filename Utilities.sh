#!/bin/bash
#Utilites per LAS - Lorenzo Amorosa

############################-VARIABILI-########################################

$$ #PID dello script bash corrente
$# #Numero di argomenti da riga di comando
$? #Exit value dell’ultimo comando eseguito command.
$ #PID della shell
$! #PID dell’ultimo comando eseguito in background
$0 #Nome script search.
$n #N-esimo argomento posizionale. Il massimo numero è 9
$*, $@ #Tutti gli argomenti passati.
"$*" #Tutti gli argomenti in un unica stringa "$1 $2 ...". I valori sono separati da $IFS.
"$@" #Tutti gli argomenti, separati individualmente ("$1" "$2"...).

############################-SSH-########################################

#eseguire con ssh un comando remoto
ssh 10.1.1.1 "ip r | egrep '^10\.9\.9\.0\/24 ' | awk '{ print \$3 }'" 
#eseguire con ssh due comandi remoti
ssh 10.1.1.1 "/bin/bash /tmp/regole$$.sh ; rm -f /tmp/regole$$.sh"
#eseguire ssh con ridirezione input e output su client (ssh)
ssh 10.1.1.1 "ls -l" > ~/out  2> ~/err

#Impostare il sistema affinche' i router possano eseguire ssh verso i client
##### generare sui router coppie di chiavi ssh
##### mettere le chiavi pubbliche dei router su ogni client
##### nel file /root/.ssh/authorized_keys

############################-COMMANDS-########################################

#copia file da locale a remoto, inserire nomefile e valore X (1 Client, 2 Router, 3 Server) (-r per dir ricorsive)
scp nomefile las@192.168.56.20X:nomedestinazione
#copia file da remoto a locale, inserire nomefile e valore X (1 Client, 2 Router, 3 Server) (-r per dir ricorsive)
scp las@192.168.56.20X:nomefile nomedestinazione
#numeri da first a last
seq first | first last | first increment last
#leggere ininterrottamente da file
tail --pid=$$ -f /var/log/reqs | while read var1 var2 ; do  echo $var1; done
#elimina la prima riga da output
tail -n +2		
#grep quiet, no output, exit code 0 se trova match
grep -q <pattern> <file>
#grep case insensitive
grep -i <pattern> <file>
#grep inverse match
grep -v <pattern> <file>
#grep only exact word
grep -w <pattern> <file>
#grep print only matching string
grep -o <pattern> <file>
#grep print number of matching lines
grep -c <pattern> <file>
#restituisce i nomi dei file nei quali la riga cercata e' comparsa
grep -l <pattern> file.a file.b file.c
grep -l <pattern> file.*
#restituisce anche il numero di linea matchata
grep -n <pattern> <file>
#Stampa anche le N righe precedenti al match
grep -B <N> <pattern> <file>
#Stampa anche le N righe precedenti al match
grep -A <N> <pattern> <file>
#Stampa senza bufferizzare
grep --line-buffered <pattern> <file>
# Elenca tutti i file che contengono "ciao" analizzando
# ricorsivamente il direttorio corrente .
grep -r "ciao" .
# Per restituire solo i nomi dei file senza le righe
# che fanno match , usare l ’ opzione -l
grep -r -l "ciao" .
# Controllo se la variabile A contiene " ciao "
A=ciaone
if echo $A | grep -q " ciao"; then
	echo A contiene ciao
else
	echo A non contiene ciao
fi
# Restituisci il decimo carattere di ogni riga del file
cut -c10 file.txt
# Restituisci i caratteri dal quinto al decimo
cut -c5-10 file.txt
# Restiuisci i caratteri dall'inizio fino al 20 esimo
cut -c-20 file.txt
# Resituisci i caratteri dal quinto in poi
cut -c5- file.txt
# Estraggo il primo campo , separati da una virgola
cut -d, -f1
# Estraggo il primo ed il terzo campo , separati da uno spazio
cut -d' ' -f1,3
#stampare un solo campo (es. user) di un solo processo
ps -C connect.sh -o user
#selezionare con ps processo con pid specifico (piu' d'uno separati da virgola)
ps -p 583
#stampare solo l'utente ed il programma in esecuzione
#per altro output: man ps, sezione STANDARD FORMAT SPECIFIERS
ps -hao uname,cmd
# Visualizza i processi di las e root, o solo las
ps U "las root"
ps U las
#Visualizza tutti i processi , anche non propri
ps ax
#Mostra gli utenti proprietari del processo
ps u
#Visualizza la riga di comando completa che ha originato il processo
ps w
#Visualizza i rapporti di discendenza tra i processi
ps f
#ordina alfabeticamente
sort <f>
#ordina numericamente
sort -n <f>
#elimina duplicati
sort -u <f>
#inverte ordine
sort -r <f>
#ordina elenco ip address
sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n
# Elimina i duplicati CONTIGUI
uniq
# Indica il numero di occorrenze per ogni duplicato
uniq -c
# Mostra SOLO i duplicati
uniq -d
#-SED
#sed 's/vecchio_pattern/nuovo_valore/' <file>
#inserisce Linea: all'inizio di ogni riga
cat /etc/passwd | sed 's/^/Linea:/'
#Sostuisce a dottore Dott. (case insensitive)
cat personale | sed 's/dottore/Dott./i'
#replace tutte le virgole con punto (ogni occorrenza per linea)
sed 's/,/./g' <file>
#cancella le occorrenze	
sed '/regex/d' <file>
#elimina ultima riga da output
sed \$d	<file>		
#awk, separatore di default e' il blank (spazio)
cat log | awk -F ": " '{ print $2 }'
#awk senza buffering
cat log | awk -W interactive '{ print $1 }'
#xargs
cat /etc/passwd | cut -f1 -d: | xargs mail -s 'l output di cat e cut va in input a mail'
#ss tcp processi e utenti
ss -tpn
#ss udp proc e utenti
ss -upn
#data in timestamp
date +%s
#byte di un file
stat prova.txt -c %s
#aggiungere sulla macchina un ip con maschera e su interfaccia specificata
ip addr add 10.1.1.1/24 dev eth2
#rimuovere sulla macchina un ip con maschera e su interfaccia specificata
ip addr delete 10.1.1.1/24 dev eth2
#aggiungere sulla macchina indicazioni riguardo l'instradamento
ip route add 10.9.9.0/24 via 10.1.1.254
#rimuovere dalla macchina indicazioni riguardo l'instradamento
ip route delete 10.9.9.0/24 via 10.1.1.254
#cambiare sulla macchina ip che svolge l'instradamento
ip route replace default via 10.1.1.254
#abilitare sulla macchina l'instradamento
sysctl -w net.ipv4.ip_forward=1
#tcpdump attende $SOGLIA pacchetti tra i due host
tcpdump -vnl -i eth2 -c $SOGLIA src host $SIP and dst host $DIP and src port $SP and dst port $DP > /dev/null 2>&1
#tcpdump fa loggare inizio e fine connessioni tra le due net
( tcpdump -lnp -i eth2 'tcp[tcpflags] & (tcp-syn|tcp-fin) != 0 and src net 10.1.1.0/24 and dst net 10.9.9.0/24' 2>/dev/null | logger -p local0.info ) &
#tcpdump traccia i pacchetti fin tra le due net
#Output CON -v e CON 2>/dev/null
#tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
#11:39:39.398845 IP (tos 0x10, ttl 64, id 64019, offset 0, flags [DF], proto TCP (6), length 52)
#    10.9.9.1.46286 > 10.1.1.1.22: Flags [F.], cksum 0x9551 (correct), seq 3935713374, ack 2875122919, win 1091, options [nop,nop,TS val 1302060 ecr 4294932668], length 0
tcpdump -vlnp -i eth3 'tcp[tcpflags] & tcp-fin != 0 and src net 10.9.9.0/24 and dst net 10.1.1.0/24' 2>/dev/null
#tcpdump traccia i pacchetti fin tra i due host
#Output SENZA -v e CON 2>/dev/null, port specificata (valido anche per net)
#11:30:38.763502 IP 192.168.56.1.39010 > 192.168.56.202.22: Flags [F.], seq 2819887278, ack 1156069010, win 311, options [nop,nop,TS val 1218725399 ecr 2117893], length 0
tcpdump -vlnp -i eth3 'tcp[tcpflags] & tcp-fin != 0 and src host 192.168.56.1 and dst net 192.168.56.202 and dst port 22'
# Visualizza i PID dei processi che usano un file
fuser /path/to/file
# Visualizza i processi che usano un intero filesystem
fuser -m /var
# Invia un segnale di SIGUSR1 a tutti i processi che usano il file
fuser -k -USR1 /path/to/file
# Visualizza tutti i file aperti dal sistema
lsof
# Visualizza i file aperti da uno specifico user
lsof -u <username>
# Visualizza i file aperti da uno specifico processo
lsof -p <PID>
# Limitare l'output di lsof ad una sola directory
lsof +D /path/to/dir
# Listare tutti i file in base al tipo di connessione ( tcp o udp )
lsof -i tcp
# IMPORTANTE : Visualizza le porte numeriche e non simboliche
lsof -i tcp -P

############################-TRAP-########################################

FILE=/var/log/file.log
function logging(){
	case "$1" in
		start)	receive_messages > "$FILE" & PID=$! ;;
		stop)	test -n "$PID" && kill "$PID" ;;
		restart)logging stop && logging start ;;
	esac
}

trap 'logging restart' USR1
trap 'logging stop' EXIT
logging start
while :
do echo qui si fa qualcosa mentre si aspettano i segnali
done

############################-AT-########################################

#due comandi tra mezz'ora
echo "/root/ldapmod.sh $UTENTE status closed ; /root/ldapmod.sh $UTENTE used 0" | at now + 30 minutes

############################-ROOT-#######################################

comandi di root: iptables, ss (?), tcpdump, adduser, addgroup, passwd, chown
#script da chiamare supposti in /root/

############################-CHECK-######################################

#Controllo parametri
if [[ $# -ne "3" ]]; then 
	echo "Uso: $! ip_client num ip_generico"
	exit 1
else
	#Controllo ch $1 abbia ultimo byte ip tra 1-100
	if ! echo "$1" | egrep -q "^10\.1\.1\.([1-9][0-9]?|100)$" ; then
		echo "$1 non e' un IP valido di client"
		exit 2
	fi
	#Controllo che $2 sia un numero intero, anche ^\d$
	if ! [[ "$2" =~ ^[0-9]+$ ]]; then
		echo "$2 is not a number"
		exit 3
	fi
	#notare che non sono ammessi indirizzi broadcast (non ammesso valore 255) e gli indirizzi del tipo *.*.*.0
	if ! [[ "$3" =~ ^(25[0-4]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-4]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-4]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-4]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]?)$ ]] ; then
		echo "$3 non e' un IP valido"
		exit 4
	fi
	# $1 sia close o open
	if [[ "$1" != close && "$1" != open ]]  ; then
		echo "$1 deve essere close/open"
		exit 5
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
#Aggiungere una entry allo schema ldif su ldap locale
ldapadd -x -h 127.0.0.1 -D "cn=admin,dc=labammsis" -w admin -f entry.ldif
#Eliminare una entry dallo schema ldif su ldap locale
ldapdelete -x -h 127.0.0.1 -D "cn=admin,dc=labammsis" -w admin "user=pippo,dc=labammsis"
#Modificare una entry sullo schema ldif su ldap locale (oppure vedi funzione modldapattr)
ldapmodify -x -h 127.0.0.1 -D "cn=admin,dc=labammsis" -w admin -f differenze.ldif
#Visualizzare solo le entry con un certo valore di un attributo (output NON pulito), da usare in combo con grep (-c)
ldapsearch -x -h 127.0.0.1 -b "dc=labammsis" -s one "status=open"
#Visualizzare solo un attributo di una entry (output NON pulito)
ldapsearch -x -h 127.0.0.1 -b "user=pippo,dc=labammsis" -s one status
#Applicare filtri in AND (per OR sostituire &->|)
ldapsearch -h 127.0.0.1 -x -s one -b "uname=$USER,dc=labammsis" "(&(objectClass=request)(action=*))"
ldapsearch -h 127.0.0.1 -x -b "dc=labammsis" -s sub "(&(objectclass=request)(|(action=get)(action=put)))"

##########################-LDAP-########################################

#esempio di aggiunta di una entry in uno schema ldap
echo -e "dn: user=gatto,dc=labammsis\nobjectClass: data\nuser: topo\nupdate: $(date +%s)\nused: 0\nstatus: closed\nlimit: 200" > /tmp/entry.ldif
ldapadd -x -h 127.0.0.1 -D "cn=admin,dc=labammsis" -w admin -f /tmp/entry.ldif
rm /tmp/entry.ldif

#Aggiunta di entry, con certezza riguardo alla sua univocita'
# $1 = nuovo gateway, $2 = server LDAP da aggiornare, $3 DN, $4 ipclient
function registra_ldap(){
	ldapdelete -c -h $2 -x -D "cn=admin,dc=labammsis" -w admin "$3" 2> /dev/null
	TS=$(/bin/date +%s)
        echo "dn: $3
objectClass: gw
ipclient: $4
iprouter: $1
timestamp: $TS" | ldapadd -x -D "cn=admin,dc=labammsis" -w admin -h $2
}

#rimpiazzo interamente la mia directory ldap e la importo da un altro server
function sostituisci_ldap(){
        #cancello le entry che ci sono...
        ldapsearch -h 127.0.0.1 -x -s sub -b "dc=labammsis" "objectClass=gw" | grep "^dn: " | awk '{ print $2 }' | ldapdelete -D "cn=admin,dc=labammsis" -w "admin" -x
        #le rimpiazzo con le entry dell'altro router
        ldapsearch -x -c -s sub -h 10.1.1.253 -b "dc=labammsis" "objectClass=gw" | ldapadd -x -D "cn=admin,dc=labammsis" -w admin 
}

##########################-LDAP-########################################

# Legge uno specifico attributo di una entry ldap
# ARGOMENTI : $1 Distinguished Name , $2 Nome attributo, $3 ip server ldap
# RETURN : 0 se l'attributo e' stato trovato, 1 altrimenti
function readldapattr() {
	RES=$(ldapsearch -x -h "$3" -b "$1" -s base | egrep "^$2: " | awk -F ": " '{ print $2 }')
	if test -z "$RES" ; then
		return 1
	else
		echo "$RES"
		return 0
	fi
}
# Esempio d'uso :
ATTRVAL=$(readldapattr "user=pippo,dc=labammsis" "status" "127.0.0.1")
echo "RETURN VALUE: $?"
echo "ATTR VALUE: $ATTRVAL"

#leggere piu' attributi con 1 unico ldapsearch (ORDINE ALFABETICO ATTRIBUTI)
ldapsearch -x -h localhost -b "user=pippo,dc=labammsis" -s base | sort | egrep "^used: |^limit: " | awk '{ print $2 }' > /tmp/ldap$$
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

#Schema LDIF piu' articolato, importante non includere spazi
dn: cn=file,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: file
olcAttributeTypes: ( 5000.1.1.1 NAME ( 'uname' )
  DESC 'uname'
  EQUALITY caseExactMatch
  SUBSTR caseExactSubstringsMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )
olcAttributeTypes: ( 5000.1.1.2 NAME ( 'file' )
  DESC 'file'
  EQUALITY caseExactMatch
  SUBSTR caseExactSubstringsMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )
olcAttributeTypes: ( 5000.1.1.3 NAME ( 'action' )
  DESC 'nome dello scipt'
  EQUALITY caseExactMatch
  SUBSTR caseExactSubstringsMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )
olcAttributeTypes: ( 5000.1.1.4 NAME ( 'ts' )
  DESC 'ts'
  EQUALITY integerMatch
  ORDERING integerOrderingMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 )
olcAttributeTypes: ( 5000.1.1.5 NAME ( 'limit' )
  DESC 'limit'
  EQUALITY integerMatch
  ORDERING integerOrderingMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 )
olcAttributeTypes: ( 5000.1.1.6 NAME ( 'byte' )
  DESC 'byte'
  EQUALITY integerMatch
  ORDERING integerOrderingMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 )
olcAttributeTypes: ( 5000.1.1.7 NAME ( 'client' )
  DESC 'client'
  EQUALITY caseExactMatch
  SUBSTR caseExactSubstringsMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )
olcObjectClasses: ( 5000.2.1.1 NAME 'user'
  DESC 'un utente'
  MUST ( uname $ limit )
  STRUCTURAL )
olcObjectClasses: ( 5000.2.1.2 NAME 'request'
  DESC 'richiesta di esecuzione'
  MUST ( ts $ file $ client )
  MAY (action $ byte )
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

# Eliminazione di un attributo
dn: ts=555555,uname=$USER,dc=labammsis
changetype: modify
delete: action

# Aggiunta di un attributo
dn: ts=555555,uname=$USER,dc=labammsis
changetype: modify
add: byte
byte: 30

##########################-LDAP-########################################

# Modifica di uno specifico attributo di una entry ldap
# ARGOMENTI: $1 Distinguished Name, $2 Nome attributo, $3 Nuovo valore, $4 host server ldap
# RETURN: 0 se l'attributo e'stato modificato, 1 altrimenti
function modldapattr() {
	echo -e "dn: $1\nchangetype: modify\nreplace: $2\n$2: $3" | ldapmodify -x -h "$4" -D "cn=admin,dc=labammsis" -w admin
	return $?
}
# Esempio d’uso :
modldapattr "ind=10.9.9.1,ind=10.1.1.1,dc=labammsis" "cnt" "2" "127.0.0.1"
echo "RETURN VALUE: $?"

# Eliminazione di uno specifico attributo di una entry ldap
# ARGOMENTI: $1 Distinguished Name, $2 Nome attributo, $3 host server ldap
# RETURN: 0 se l'attributo e'stato rimosso, 1 altrimenti
function delldapattr() {
	echo -e "dn: $1\nchangetype: modify\delete: $2" | ldapmodify -x -h "$3" -D "cn=admin,dc=labammsis" -w admin
	return $?
}
# Esempio d’uso :
modldapattr "ts=555555,uname=$USER,dc=labammsis" "action" "127.0.0.1"
echo "RETURN VALUE: $?"

# Aggiunta di uno specifico attributo di una entry ldap
# ARGOMENTI: $1 Distinguished Name, $2 Nome attributo, $3 Valore, $4 host server ldap
# RETURN: 0 se l'attributo e'stato aggiunto, 1 altrimenti
function addldapattr() {
	echo -e "dn: $1\nchangetype: modify\nadd: $2\n$2: $3" | ldapmodify -x -h "$4" -D "cn=admin,dc=labammsis" -w admin
	return $?
}
# Esempio d’uso :
modldapattr "ts=555555,uname=$USER,dc=labammsis" "byte" "30" "127.0.0.1"
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

#Usare una funzione per scrivere messaggi di errore sul log
function err() {
	EX=$1
	shift
	echo "$@"
	logger -p local1.info "$@" 
	exit $EX
}
#Esempio d'uso
if [ "$1" != "put" -a "$1" != "get" ] ; then
	err 1 "Bad first argument, need put|get"
fi

if ! echo "$2" | grep -q '^/' ; then
	err 2 "Bad second argument, need a filename"
fi

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
ID=$(snmpwalk -v 1 -c public localhost "UCD-SNMP-MIB::prNames" | grep rsyslogd | awk -F "prNames." '{ print $2 }' | awk -F " = " '{ print $1 }')
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
#Azzera pacchetti passati nelle catena, mostrando valori attuali
iptables -Z -vnL

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

##########################-IPTABLES LOG-#####################################

#Inserisce una regola che logga i pacchetti in transito nella chain specificata con prefisso e livello di log specificati
#I log hanno facility=kernel, --log-level=debug => i log salvati con livello kernel.debug 
iptables -I <chain> <options> -j LOG --log-prefix="___prefisso___" --log-level=<livello_log>
# Logga l'inizio di ogni connessione inoltrata da 10.1.1.1 a 10.9.9.1 con livello debug e prefisso ___NEWCON___
iptables -I FORWARD -i eth2 -s 10.1.1.1 -d 10.9.9.1 -p tcp --tcp-flags SYN SYN -j LOG --log-prefix "___NEWCON___" --log-level=debug
# Logga la fine di ogni connessione inoltrata da 10.1.1.1 a 10.9.9.1 con livello debug e prefisso ___ENDCON___
iptables -I FORWARD -i eth2 -s 10.1.1.1 -d 10.9.9.1 -p tcp --tcp-flags FIN FIN -j LOG --log-prefix "___ENDCON___" --log-level=debug

function imposta_regole(){
	# ... deve essere attivata (evitando duplicazioni) 
	# su entrambi i router una regola di iptables 
	# che permetta di loggare ogni pacchetto da e per tale client (passato come $1)
	#volendo mandare in background imposta_regole: ssh las@192.168.56.202 "ip route" | grep -q "default via 10.0.2.2", se $? diverso da 0 si lanciano script seguenti

	echo "if ! iptables -vnL FORWARD | grep -q 'check_$1' ; then
                iptables -I FORWARD -s $1 -j LOG --log-level debug --log-prefix  ' check_$1 '
                iptables -I FORWARD -d $1 -j LOG --log-level debug --log-prefix  ' check_$1 '
                iptables -I INPUT -s $1 -j LOG --log-level debug --log-prefix  ' check_$1 '
                iptables -I OUTPUT -d $1 -j LOG --log-level debug --log-prefix  ' check_$1 '
              fi" > /tmp/regole$1.sh
	/bin/bash /tmp/regole$1.sh
	#qui inserimento regole su altro router
	scp /tmp/regole$1.sh 10.1.1.253:/tmp
	ssh 10.1.1.253 "/bin/bash /tmp/regole$1.sh ; rm -f /tmp/regole$1.sh"
	#rimuovo file contenente regole
	rm -f /tmp/regole$1.sh
}

#FORMATO DEI LOG CIRCA PER UDP, ICMP, TCP

#Jun 16 15:59:03 Router kernel: [12506.141621] ___UDP___ IN=eth2 OUT= MAC=08:00:27:0b:37:1f:08:00:27:72:c7:c1:08:00 SRC=10.1.1.1 DST=10.1.1.254 LEN=82 TOS=0x00 PREC=0x00 TTL=64 ID=2939 DF PROTO=UDP SPT=51519 DPT=161 LEN=62 

#Jun 16 15:31:40 Router kernel: [10862.759703] ___ICMP___ IN=eth2 OUT= MAC=08:00:27:0b:37:1f:08:00:27:72:c7:c1:08:00 SRC=10.1.1.1 DST=10.1.1.254 LEN=84 TOS=0x00 PREC=0x00 TTL=64 ID=33869 DF PROTO=ICMP TYPE=8 CODE=0 ID=1301 SEQ=1

# Apr 27 12:02:56 router kernel: [10139.999098]  INIZIO IN=eth2 OUT=eth1 MAC=08:00:27:27:a6:e6:08:00:27:24:9b:d5:08:00 SRC=10.1.1.1 DST=10.9.9.1 LEN=60 TOS=0x00 PREC=0x00 TTL=63 ID=23272 DF PROTO=TCP SPT=37668 DPT=22 WINDOW=29200 RES=0x00 SYN URGP=0
# opzioni dei comandi
# tail --pid $$ garantisce che tail termini quando termina il processo principale
# grep --line-buffered e awk -W interactive evitano il buffering, ogni linea 
# prodotta va direttamente in output
#
# notare che awk taglia sulla "]" evitando il problema dovuto al timestamp precedente,
# che potrebbe riempire o non riempire le [] modificando la numerazione dei campi seguenti
tail --pid=$$ -f /var/log/newconn | egrep --line-buffered 'INIZIO|FINE' | awk -W interactive -F ']' '{ print $2 }' | while read EVENTO IN OUT MAC SRC DST LEN TOS PREC TTL ID DF PROTO SPT DPT RESTO ; do
	SOURCEIP=$(echo $SRC | cut -f2 -d=)
	SOURCELASTBYTE=$(echo $SOURCEIP | cut -f4 -d.)
	DESTIP=$(echo $DST | cut -f2 -d=)
	DESTLASTBYTE=$(echo $DESTIP | cut -f4 -d.)
	SOURCEPORT=$(echo $SPT | cut -f2 -d=)
	DESTPORT=$(echo $DPT | cut -f2 -d=)
	CHAIN="CONTA-$SOURCELASTBYTE-$DESTLASTBYTE-$SOURCEPORT-$DESTPORT"

	# uso una custom chain semplicemente per metterci dentro una sola regola
	# salto poi nella custom chain dalla catena FORWARD, sia per i pacchetti
	# in andata che in ritorno: la regola della custom chain quindi somma
	# automaticamente i traffici, semplificando il successivo rilevamento
	#
	# notare che si usa solo l'ultimo byte degli indirizzi, che in questo 
	# specifico caso è suffciente a individuare le macchine, perche' le 
	# catene hanno nomi limitati a 32 caratteri

	case $EVENTO in 
		INIZIO)
			iptables -N $CHAIN
			iptables -I $CHAIN -j RETURN
			forwardjump I $SOURCEIP $DESTIP $SOURCEPORT $DESTPORT $CHAIN
		;;
		FINE)
			forwardjump D $SOURCEIP $DESTIP $SOURCEPORT $DESTPORT $CHAIN
			iptables -F $CHAIN
			iptables -X $CHAIN
		;;
		*)
			echo "evento sconosciuto $EVENTO"
		;;
	esac
done

function forwardjump() {
	iptables -$1 FORWARD -p tcp -s $2 -d $3 --sport $4 --dport $5 -j $6
	iptables -$1 FORWARD -p tcp -d $2 -s $3 --dport $4 --sport $5 -j $6
}

##########################-IPTABLES DEFAULT-#####################################

#data una coppia di indirizzi, un'interfaccia e una porta si abilitano le comunicazioni
#in entrambe le direzioni, entrambi i componenti sono sia server che client
function confTotallyBidir(){
	# confTotallyBidir interface ip1 ip2 port proto
    	# ip2 come server di ip1
	iptables -I INPUT -i $1 -s $2 -d $3 -p $5 --dport $4 -j ACCEPT
    	iptables -I OUTPUT -o $1 -d $2 -s $3 -p $5 --sport $4 -m state --state ESTABLISHED -j ACCEPT
	# ip2 come client di ip1
   	iptables -I INPUT -i $1 -s $2 -d $3 -p $5 --sport $4 -m state --state ESTABLISHED -j ACCEPT
    	iptables -I OUTPUT -o $1 -d $2 -s $3 -p $5 --dport $4 -j ACCEPT
    	# ip1 come server di ip2
  	iptables -I INPUT -i $1 -s $3 -d $2 -p $5 --dport $4 -j ACCEPT
    	iptables -I OUTPUT -o $1 -d $3 -s $2 -p $5 --sport $4 -m state --state ESTABLISHED -j ACCEPT
	# ip1 come client di ip2
   	iptables -I INPUT -i $1 -s $3 -d $2 -p $5 --sport $4 -m state --state ESTABLISHED -j ACCEPT
   	iptables -I OUTPUT -o $1 -d $3 -s $2 -p $5 --dport $4 -j ACCEPT
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

#data una coppia di indirizzi, un'interfaccia, una porta e un protocollo si abilitano le comunicazioni
#rendendo ip2 server di ip1
function confServer(){
	# confServer interface ip1 ip2 port proto
	iptables -I INPUT -i $1 -s $2 -d $3 -p $5 --dport $4 -j ACCEPT
    	iptables -I OUTPUT -o $1 -d $2 -s $3 -p $5 --sport $4 -m state --state ESTABLISHED -j ACCEPT
}

#data una coppia di indirizzi, un'interfaccia, una porta e un protocollo si abilitano le comunicazioni
#rendendo ip2 client di ip1
function confClient(){
	# confClient interface ip1 ip2 port proto
	iptables -I OUTPUT -i $1 -s $2 -d $3 -p $5 --dport $4 -j ACCEPT
    	iptables -I INPUT -o $1 -d $2 -s $3 -p $5 --sport $4 -m state --state ESTABLISHED -j ACCEPT
}

#scarto qualsiasi configurazione precedente
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD
#confTotallyBidir
confTotallyBidir eth1 10.9.9.254 10.9.9.253 22 tcp
confTotallyBidir eth2 10.1.1.254 10.1.1.253 22 tcp
confTotallyBidir eth3 192.168.56.254 192.168.56.253 22 tcp
confTotallyBidir eth3 192.168.56.254 192.168.56.253 389 tcp
# LDAP client-router (router server ldap)
confServer eth2 10.1.1.0/24 10.1.1.250 389 tcp
iptables -I INPUT -i eth2 -p tcp -s 10.1.1.0/24 -d 10.1.1.250 --dport 389 -j ACCEPT
iptables -I OUTPUT -o eth2 -p tcp -d 10.1.1.0/24 -s 10.1.1.250 --sport 389 -m state --state ESTABLISHED -j ACCEPT
# rsyslog client-router (log registrati su router)
confServer eth2 10.1.1.0/24 10.1.1.254 514 udp
iptables -I INPUT -i eth2 -p udp -s 10.1.1.0/24 -d 10.1.1.254 --dport 514 -j ACCEPT
iptables -I OUTPUT -o eth2 -p udp -d 10.1.1.0/24 -s 10.1.1.254 --sport 514 -m state --state ESTABLISHED -j ACCEPT
# SNMP router-client (demone snmp su client)
confClient eth2 10.1.1.254 10.1.1.0/24 161 udp
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

##########################-IPTABLES2 DEFAULT-#####################################

#utile se ho ICMP oppure RANGE-IP

function setipparams() {
	# setta le variabili a seconda che ci sia un ip o un range
	# MOD per caricare eventualmente il modulo iprange
	# IPS e IPD sono sorgente e destinazione con l'opzione giusta
	if echo $1 | grep -q -- '-' ; then
		# se c'è un - è un range
		MOD="-m iprange"
		IPD="--dst-range $1"
		IPS="--src-range $1"
	else
		# se no è un ip singolo
		MOD=""
		IPD="-d $1"
		IPS="-s $1"
	fi
}

function setprotoparams() {
	# setta le variabili a seconda del protocollo (icmp, tcp o udp)
	# PROTO è sempre il protocollo
	# DP e SP sono sorgente e destinazione solo se non è icmp
	# sarebbe opportuno error checking, anche se invocata solo 
	# internamente da questo stesso script
	PROTO="$1"
	if test "$PROTO" = "icmp" ; then
		DP=""
		SP=""
	else
		DP="--dport $2"
		SP="--sport $2"
	fi
}

function client() {
	# imposta regole iptables quando io sono client
	# parametri: server proto porta 
	setipparams $3
	setprotoparams $4 $5
	iptables -I OUTPUT -o $1 $MOD $PROTO -s $2 $DP $IPD -j ACCEPT
	iptables -I INPUT -i $1 $MOD $PROTO -d $2 $SP $IPS --state ESTABLISHED -j ACCEPT
}

function server() {
	# imposta regole iptables quando io sono server
	# parametri: client proto porta 
	setipparams $3
	setprotoparams $4 $5
	iptables -I INPUT -i $1 $MOD $PROTO -d $2 $DP $IPS -j ACCEPT
	iptables -I OUTPUT -o $1 $MOD $PROTO -s $2 $SP $IPD --state ESTABLISHED -j ACCEPT
}

#Esempi d'uso
# sono server LDAP per i client (gw.sh)
server eth2 10.1.1.254 "10.1.1.1-10.1.1.200" tcp 389
# rispondo ai ping dei client (gw.sh)
server eth2 10.1.1.254 "10.1.1.1-10.1.1.200" icmp
# sono client SSH verso i client (check.sh e reset.sh)
client eth2 10.1.1.254 "10.1.1.1-10.1.1.200" tcp 22
# sono client e server SSH per l'altro router (check.sh e reset.sh)
client eth2 10.1.1.254 10.1.1.253 tcp 22
server eth2 10.1.1.254 10.1.1.253 tcp 22
# sono client e server SYSLOG per l'altro router (check.sh)
client eth2 10.1.1.254 10.1.1.253 udp 514
server eth2 10.1.1.254 10.1.1.253 udp 514
# sono client e server LDAP per l'altro router (init.sh)
client eth2 10.1.1.254 10.1.1.253 tcp 389
server eth2 10.1.1.254 10.1.1.253 tcp 389
# sono client i server SNMP per l'altro router (init.sh)
client eth2 10.1.1.254 10.1.1.253 udp 161
server eth2 10.1.1.254 10.1.1.253 udp 161

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
# configuro cron per l'esecuzione, eseguendo i seguenti comandi
/usr/bin/crontab -l > /tmp/traffic.cron.$$
echo "*/5 * * * * /root/traffic.sh" >> /tmp/traffic.cron.$$
/usr/bin/crontab /tmp/traffic.cron.$$
/bin/rm -f /tmp/traffic.cron.$$

if /usr/bin/tty > /dev/null ; then
	# invocato da terminale, controllo parametri
else
	# Invocato da cron
fi

############################-TCPDUMP LOG-###################################################

#logging in background di inizio e fine connessioni tcp
( tcpdump -lnp -i eth2 'tcp[tcpflags] & (tcp-syn|tcp-fin) != 0 and src net 10.1.1.0/24 and dst net 10.9.9.0/24' 2>/dev/null | logger -p local0.info ) &

# log format:
# Mar 28 11:41:17 Router logger: 11:41:17.574430 IP 10.1.1.1.52356 > 10.9.9.1.22: S 3572751694:3572751694(0) win 5840 <mss 1460,sackOK,timestamp 2110393 0,nop,wscale 1>

tail --pid=$$ -f /var/log/newconn | while read M G H HOST PROC TS PROTO SRC DIR DST FLAG OTHER ; do

    case "$FLAG" in
        S)  if test -f /var/run/traffic_monitor_${SRC}_${DST}.pid
            then
                echo connessione $SRC $DST gia monitorata
            else
                SIP=$(echo $SRC | cut -f-4 -d.)
                DIP=$(echo $DST | cut -f-4 -d.)
                SP=$(echo $SRC | cut -f5 -d.)
                DP=$(echo $DST | cut -f5 -d. | sed -e 's/://')
                /root/traffic_monitor.sh $SIP $DIP $SP $DP &
                echo $! > /var/run/traffic_monitor_${SRC}_${DST}.pid
                echo avvio monitoraggio connessione $SRC $DST
            fi
            ;;
        F)  if test -f /var/run/traffic_monitor_${SRC}_${DST}.pid
            then
                echo arresto monitoraggio connessione $SRC $DST
		kill $(cat /var/run/traffic_monitor_${SRC}_${DST}.pid)
                rm -f "/var/run/traffic_monitor_${SRC}_${DST}.pid"
            else
                echo processo di monitoring di $SRC $DST non trovato
            fi
            ;;
        *)  echo "$FLAG" non valido
            ;;
    esac
done

############################-CHIUDI CONNESSIONI SU HOST REMOTO-###################################################

#si collega al client e termina tutti i processi che stanno utilizzando socket di rete

function segnala_client(){
	# l'output di ss può essere di questo tipo:
	# tcp ESTAB 0 0 127.0.0.1:ssh 127.0.0.1:37012 users:(("sshd",pid=10610,fd=3),("sshd",pid=10516,fd=3))
	# prima converto le virgole in a capo, poi seleziono i pid
        ssh root@$1 "ss -ptu | sed -e 's/,/\n/g' | grep pid= | sed -e 's/pid=//' | xargs kill -9"
}

############################-RICONOSCO VERIFICARSI EVENTO 10 VOLTE IN 2 MIN-###################################################

# Questo script esamina continuamente il file /var/log/orphans.log. 
# Per ogni riga che legge, determina se l'IP client in essa contenuto
# è stato osservato più di 10 volte nei due minuti precedenti.

#Jun 16 16:27:43 Router kernel: [14225.975606] check_10.1.1.1 IN=eth2 OUT= MAC=08:00:27:0b:37:1f:08:00:27:72:c7:c1:08:00 SRC=10.1.1.1 DST=10.1.1.254 LEN=84 TOS=0x00 PREC=0x00 TTL=64 ID=3814 DF PROTO=ICMP TYPE=8 CODE=0 ID=990 SEQ=1 
tail -f /var/log/orphans.log | grep --line-buffered " check_" | while read riga ; do
	# check.sh marca le righe con la stringa check_INDIRIZZO, quindi		
        IP=$(echo $riga | awk -F 'check_' '{ print $2 }' | awk '{ print $1 }')

	# ricavo il timestamp e lo converto in secondi dall'1/1/70
	TS=$(echo $riga | awk '{ print $1,$2,$3 }')
	TS=$(date -D "$TS" +%s)

	# implemento su file un buffer circolare nel quale tenere 
	# gli ultimi 10 timestamp relativi all'indirizzo letto:
	# "dimentico" la riga più vecchia e accodo la più recente
	if test -f /tmp/buffer_$IP ; then
		tail -9 /tmp/buffer_$IP > /tmp/new_buffer_$IP
	else
		echo "0" > /tmp/new_buffer_$IP
	fi
	echo $TS >> /tmp/new_buffer_$IP
	mv /tmp/new_buffer_$IP /tmp/buffer_$IP

	# se ci sono almeno 10 righe...
	if $(wc -l /tmp/buffer_$IP | awk '{ print $1 }') -ge 10 ; then
  	   # leggo il timestamp più vecchio, se è entro i 2 minuti
	   # lo sono anche tutti gli altri --> ho superato la soglia
	   FIRSTTS=$(head -1 /tmp/buffer_$IP)
           if test $(( $TS - $FIRSTTS )) -lt 120 ; then
		#esegui operazioni per evento                
		#segnala_client $IP
                #rimuovi_regole $IP INPUT
                #rimuovi_regole $IP FORWARD
                #rimuovi_regole $IP OUTPUT
           fi
	fi
done

############################-ATTENDO UN PING MAX 10 SECONDI-###################################################

count=0
while ! ping -c1 -w1 10.1.1.254 > /dev/null 2>&1
do
        echo "In attesa che RF risponda..."
        if test "$count" -gt 9 
        then
                echo "Il router non risponde"
                exit 5
        fi
        count=$(( "$count" + 1 ))
done

echo "Ha risposto connessione avviata con $1"

############################-ATTENDO UN PING MAX 3 SECONDI-###################################################

#eseguo operazione se falliscono 3 ping consecutivi
FAILPING="0"
while sleep 1 ; do
        if ping -c 1 -W 1 10.1.1.254 > /dev/null 2>&1 ; then
		FAILPING=0
	else		
                FAILPING=$(( $FAILPING + 1 ))
                if test $FAILPING -ge 3 ; then
                        echo qui faccio una operazione
                        FAILPING="0"
                fi
        fi
done

############################-BACKGROUND FOREGROUND-###################################################

# Avvia il comando in background
gedit &
#mandare SIGSTOP a processo (CTRL+Z) per stopparlo
#[1]+  Fermato                 top
#poi bg <job_id> lo si manda in background
# Riporta il processo con il jobid specificato in foreground
fg <job_id>
# Elenca tutti i jobs con il loro stato.
jobs
# Esegue il comando in background e lo
# rende immune alla chiusura della shell
nohup <command> &

############################-UTENTI GRUPPI-###################################################

#contiene il nome dell utente
$USER	
#id utente
$EUID	
#PERMESSI ROOT
# Aggiungi un utente al sistema
adduser <nomeutente>
# Se non esiste gia', bisogna creare il gruppo
addgroup <nomegruppo>
# A questo punto possiamo creare un nuovo utente ed aggiungerlo al gruppo
adduser --ingroup <nomegruppo> <nomeutente>
#Per aggiungere un utente ad un gruppo secondario, si può utilizzare il comando usermod in questo modo:
usermod -a -G <nomegruppo> <nomeutente>
#Cambiare il gruppo primario di un utente
usermod -g <nomegruppo> <nomeutente>
# Visualizzo le info dell ’ utente corrente
id
# Visualizzo le info di un utente specifico
id <nomeutente>
# Elenco i gruppi dell ’ utente corrente
groups
# Elenco i gruppi di un utente specifico
groups <nomeutente>
# Stampa l ’ elenco di tutti i gruppi del sistema
getent group
# Cambia la password dell ’ utente corrente
passwd
# Cambia la password di un utente specifico
# NOTA : Necessari i permessi di root
#Utilizzando rispettivamente le opzioni -l e -u è possibile settare un account in stato di lock o unlock.
Solo root può farlo.
passwd <nomeutente>
# Stampa l ’ username dell ’ utente corrente
whoami
# Elenca gli utenti correntemente collegati alla macchina
who

############################-PERMESSI-###################################################

# Diamo a tutti il permesso di lettura
chmod a=r <nomefile>
# Aggiungiamo il permesso di scrittura ed esecuzione al proprietario
chmod u+wx <nomefile>
# Rimuoviamo i permessi di scrittura al gruppo proprietario
chmod g-w <nomefile>
# E ’ anche possibile utilizzare il formato numerico
chmod 0777 <nomefile>
# Cambia l ’ utente proprietario di un file
chown <username> <nomefile>
# Cambia il gruppo proprietario di un file
# NOTA : Attenzione ad aggiungere :
chown :<group> <nomefile>
# Cambia l ’ utente ed il gruppo proprietario
chown <username>:<group> <nomefile>
# Cambia la proprieta di tutti i file contenuti nella directory
# in maniera RICORSIVA
chown -R <username>: <group> <nomedirectory>
# Visualizza la umask corrente
umask
# Per visualizzare i permessi a default correnti in maniera
# piu ’ comprensibile , si puo ’ usare l ’ opzione -S
umask -S
# Imposta la maschera in modo che i nuovi file abbiano permesso 775
umask 0002
#L’impostazione della umask è valida solo per la sessione di shell corrente. Per fare in modo che l’impostazione sia persistente, bisogna aggiungere il comando umask al file /etc/bash.bashrc








