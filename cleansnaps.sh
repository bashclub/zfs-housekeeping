#! /bin/sh

pr_aufruf() {
cat <<ENDE

Aufruf: $(basename $0) [-htf] [-k keep] <Datasetfilter> [Snapshotfilter]

        -h Hilfe Anzeigen
        -t Testmodus. Simulation von löschen ohne Nachfragen (benötigt -k) 
        -f Echtmodus. Snapshots löschen ohne Nachfragen (benötigt -k) 
        -k <Anzahl> Anzahl der letzten Snapshots die behalten werden sollen.
           Rest wird gelöscht. Ohne -t oder -f kommt Abfrage ob gelöscht werden soll.

ENDE
}

# Defaults:
# Modi: fragen (default), test (-t) oder echt (-f)
MODUS="fragen"

while getopts ":htfk:" opt
do
  case $opt in
    h) pr_aufruf
       exit 0
       ;;
    t) MODUS="test"
       TFLAG="1"	    
       ;;
    f) MODUS="echt"
       FFLAG="1"	    
       ;;
    k) BEHALTE="$OPTARG"
       KFLAG="1"
       ;;
   \?) echo "Unbekannte Option: -$OPTARG" 1>&2;;
    :) echo "Fehler Option: -$OPTARG benötigt ein Argument" 1>&2;;
  esac
done

shift $((OPTIND -1))

# Mit der Filter Variable kannst du die Liste der datasets beschränken 
# Mit der Muster Variable kann man Snapshots nach Muster Filtern
FILTER="$1"
MUSTER="$2"

if [ "$1" = "" -o $# -gt 2 ]
then
  pr_aufruf
  exit 1
fi

if [ "$FFLAG" = "1" -a "$TFLAG" = "1" ]
then
  echo "Option -f oder -t können nicht zusammen verwendet werden."
  pr_aufruf
  exit 1
elif [ "$FFLAG" -o "$TFLAG" ] && [ "$KFLAG" != "1" ]
then
  echo "Option -t oder - f nur zusammen mit -k nutzbar"
  pr_aufruf
  exit 1
fi

# Prüfen das Behalte eine Zahl >= 0 ist
if [ "$KFLAG" = "1" ]
then 
  [ $BEHALTE -ge 0 ] 2>/dev/null
  if [ "$?" != "0" ] 
  then	
    echo "Option -k  keine pos. Zahl"
    pr_aufruf
    exit 1
  fi
fi

ZFSSETLIST=$(zfs list | grep "$FILTER" | awk '{print $1}')

echo "# Gefilterte Datasets:"
zfs list | grep -e "$FILTER" -e NAME | sed 's/^/  /'
echo ""

for DATASET in $ZFSSETLIST
do
  echo "# Dataset: $DATASET"
  echo "# Snapfilter: $MUSTER"

  if [ "$MUSTER" = "" ]
  then
    SNAPS=$(zfs list -r -t snap -H -o name -s creation | grep "${DATASET}@")
  else
    SNAPS=$(zfs list -r -t snap -H -o name -s creation | grep "${DATASET}@" | grep $MUSTER)
  fi
  ANZSNAPS=$(echo "$SNAPS"|grep -v "^$"|wc -l|sed 's, ,,g')

  echo "# Anzahl Snaps: $ANZSNAPS"
  if [ "$KFLAG" = "1" ]
  then
    DELSNAPS=$((ANZSNAPS - BEHALTE))
    echo "# Behalte: $BEHALTE"
    echo "# Anzahl Del. Snaps: $(if [ $DELSNAPS -lt 0 ];\
                                 then echo 0;else echo $DELSNAPS;fi)"
  else
    DELSNAPS="0"
    BEHALTE="$ANZSNAPS"
  fi

  echo "# Liste Snaps:"
  echo "$SNAPS" |sed '/^$/d' | awk -v dellines=$DELSNAPS '{
       if (NR <= dellines){
	  printf("  - %s\n",$0)
       }
       else {
	  printf("  + %s\n",$0)
       }
  }' 

  [ $DELSNAPS -gt 0 -o "$KFLAG" != "1" ] 2>/dev/null
  if [ "$?" != "0" ]
  then
    echo "% Keine Snapshots zum löschen"	  
    echo ""
    continue
  fi

  if [ $DELSNAPS -gt 0 ]
  then
      if [ "$MODUS" = "fragen" ]
      then
        printf "> Snapshots (%d von %d) mit J löschen (Return = weiter): " $DELSNAPS $ANZSNAPS
	read ZDESTROY
      elif [ "$MODUS" = "echt" ]
      then
        ZDESTROY="J"
      else
        ZDESTROY="N"
        echo "# Testmodus - Für folgende Snapshots würde ein destroy ausgeführt:"
        echo "$SNAPS" | head -n $DELSNAPS | xargs -n 1 zfs get -H creation | sed 's/^/  /'  
	echo ""
	continue
      fi      

      if [ "$ZDESTROY" = "J" ]
      then 
        echo "% zfs destroy wird ausgeführt:"
        echo "$SNAPS" | head -n $DELSNAPS | xargs -n 1 zfs destroy -v | sed 's/^/  /'

        echo "% Liste nach zfs destroy:"
        if [ "$MUSTER" = "" ]
        then
          zfs list -r -t snap -o name -s creation | grep "${DATASET}@" | sed 's/^/  + /' 
        else
          zfs list -r -t snap -o name -s creation | grep "${DATASET}@" | grep $MUSTER | sed 's/^/  + /'
        fi
      else
        echo "% Es wurden keine Snapshots gelöscht"
      fi
  fi
  echo ""
done

exit 0
