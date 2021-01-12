#! /bin/sh

AUFRUF=$(echo "Aufruf: $0 <test|echt> <Poolfilter> <Anz. Behalte> [Snapshotfilter]")

if [ "$3" = "" ]
then
  echo $AUFRUF
  exit 0
fi

TESTECHT="$1"

#Mit der Filter Variable kannst du die Liste der datasets beschränken für die die Snaps gelöscht werden sollen.
FILTER="$2"

# Wieviele behalten 
BEHALTE="$3"

[ $BEHALTE -ge 0 ] 2>/dev/null
if [ "$?" != "0" ] 
then
 echo "Parameter 3 keine pos. Zahl"
 echo "$AUFRUF"
 exit 0
fi

# Snapshots nach Muster Filtern
MUSTER="$4"

PruneZFSList=$(zfs list -o name -H| grep $FILTER)

echo "# Gegrepte Datasets"
zfs list | grep -e $FILTER -e NAME
echo ""

for DATASET in $PruneZFSList
do
  echo "# Dataset: $DATASET"
  echo "# Muster: $MUSTER"

  if [ "$MUSTER" = "" ]
  then
    SNAPS=$(zfs list -r -t snap -H -o name -s creation|grep "${DATASET}@")
  else
    SNAPS=$(zfs list -r -t snap -H -o name -s creation|grep "${DATASET}@"|grep $MUSTER)
  fi
  ANZSNAPS=$(echo $SNAPS|wc -w)

  echo "# Anzahl Snaps: $ANZSNAPS"
  echo "# Behalte: $BEHALTE"
  echo "# Liste Snaps:"
  echo "$SNAPS" 

  DELSNAPS=$((ANZSNAPS - BEHALTE))
  [ $DELSNAPS -gt 0 ] 2>/dev/null
  if [ "$?" != "0" ]
  then
    echo "Keine Snapshots zum löschen"	  
    echo ""
    continue
  fi

  echo "# Anzahl Del. Snaps: $DELSNAPS"
  echo "# Liste Del. Snaps:"
  echo "$SNAPS" | head -n $DELSNAPS 

  echo "# Behalte Snaps:" 
  echo "$SNAPS" | tail -n $BEHALTE 

  if [ $DELSNAPS -gt 0 ]
  then
      if [ "$TESTECHT" = "echt" ]
      then
        echo "# zfs destroy wird ausgeführt"
        echo "$SNAPS" | head -n $DELSNAPS | xargs -n 1 zfs destroy -v

        echo "# Liste nach zfs destroy"
        if [ "$MUSTER" = "" ]
        then
          zfs list -r -t snap -o name -s creation|grep "${DATASET}@"
        else
          zfs list -r -t snap -o name -s creation|grep "${DATASET}@"|grep $MUSTER
        fi
      else
        echo "# Test - folgende zfs destroys würden ausgführt"
        echo "$SNAPS" | head -n $DELSNAPS | xargs -n 1 zfs get -H creation 
        echo "$SNAPS" | head -n $DELSNAPS | xargs -n 1 echo ">>" zfs destroy -v 
      fi
  fi
  echo ""
done

