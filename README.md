# zfs-keep-and-clean

## Script sts23.sh
### Aufruf:
Aufruf: ./sts23.sh <test|echt> <Poolfilter> <Anz. Behalte> [Snapshotfilter]


## Script snpgrpdl.sh (neu)
Snapshots nach Datasets und Muster im Snapshotnamen filtern und ggf. löschen.
Es können alle bis auf die letzten x Snapshots behalten werden (-k keep).
Zu löschende Snapshots werden mit einem '-' gekennzeichnet.

### Aufruf:
```  
root@zfsrasp~# ./snpgrpdl.sh -h

Aufruf: snpgrpdl.sh [-htf] [-k keep] <Datasetfilter> [Snapshotfilter]

        -h Hilfe Anzeigen
        -t Testmodus. Simulation von löschen ohne Nachfragen (benötigt -k)
        -f Echtmodus. Snapshots löschen ohne Nachfragen (benötigt -k)
        -k <Anzahl> Anzahl der letzten Snapshots die behalten werden sollen.
           Rest wird gelöscht. Ohne -t oder -f kommt Abfrage ob gelöscht werden soll.
```
### Beispiele:
Nur Filtern (ohne löschen):
```
root@zfsrasp:~# ./snpgrpdl.sh  backup frequent
# Gefilterte Datasets:
  NAME                USED  AVAIL     REFER  MOUNTPOINT
  backup             3.93M  3.62G       24K  /backup
  backup/smbshr       182K  3.62G     50.5K  /backup/smbshr

# Dataset: backup
# Snapfilter: frequent
# Anzahl Snaps: 4
# Liste Snaps:
  + backup@zfs-auto-snap_frequent-2021-01-01-2030
  + backup@zfs-auto-snap_frequent-2021-01-01-2045
  + backup@zfs-auto-snap_frequent-2021-01-01-2100
  + backup@zfs-auto-snap_frequent-2021-01-01-2115

# Dataset: backup/smbshr
# Snapfilter: frequent
# Anzahl Snaps: 6
# Liste Snaps:
  + backup/smbshr@zfs-auto-snap_frequent-2020-12-28-1145
  + backup/smbshr@zfs-auto-snap_frequent-2020-12-28-1200
  + backup/smbshr@zfs-auto-snap_frequent-2021-01-01-2030
  + backup/smbshr@zfs-auto-snap_frequent-2021-01-01-2045
  + backup/smbshr@zfs-auto-snap_frequent-2021-01-01-2100
  + backup/smbshr@zfs-auto-snap_frequent-2021-01-01-2115

root@zfsrasp:~#
```
Interaktiv - Filtern und alle außer die letzten 10 löschen:
```
root@zfsrasp:~# ./snpgrpdl.sh -k 10 backup$ daily
# Gefilterte Datasets:
  NAME                USED  AVAIL     REFER  MOUNTPOINT
  backup             4.00M  3.62G       24K  /backup

# Dataset: backup
# Snapfilter: daily
# Anzahl Snaps: 12
# Behalte: 10
# Anzahl Del. Snaps: 2
# Liste Snaps:
  - backup@zfs-auto-snap_daily-2020-12-21-0525
  - backup@zfs-auto-snap_daily-2020-12-22-0525
  + backup@zfs-auto-snap_daily-2020-12-23-0525
  + backup@zfs-auto-snap_daily-2020-12-24-0525
  + backup@zfs-auto-snap_daily-2020-12-25-0525
  + backup@zfs-auto-snap_daily-2020-12-26-0525
  + backup@zfs-auto-snap_daily-2020-12-27-0525
  + backup@zfs-auto-snap_daily-2020-12-28-0525
  + backup@zfs-auto-snap_daily-2020-12-29-0525
  + backup@zfs-auto-snap_daily-2020-12-30-0525
  + backup@zfs-auto-snap_daily-2020-12-31-0525
  + backup@zfs-auto-snap_daily-2021-01-01-0525
> Snapshots (2 von 12) mit J löschen (Return = weiter): J
% zfs destroy wird ausgeführt:
  will destroy backup@zfs-auto-snap_daily-2020-12-21-0525
  will reclaim 0B
  will destroy backup@zfs-auto-snap_daily-2020-12-22-0525
  will reclaim 0B
% Liste nach zfs destroy:
  + backup@zfs-auto-snap_daily-2020-12-23-0525
  + backup@zfs-auto-snap_daily-2020-12-24-0525
  + backup@zfs-auto-snap_daily-2020-12-25-0525
  + backup@zfs-auto-snap_daily-2020-12-26-0525
  + backup@zfs-auto-snap_daily-2020-12-27-0525
  + backup@zfs-auto-snap_daily-2020-12-28-0525
  + backup@zfs-auto-snap_daily-2020-12-29-0525
  + backup@zfs-auto-snap_daily-2020-12-30-0525
  + backup@zfs-auto-snap_daily-2020-12-31-0525
  + backup@zfs-auto-snap_daily-2021-01-01-0525

root@zfsrasp:~#
```
Testmodus - löschen nur simulieren (ohne Nachfragen):
```
root@zfsrasp:~# ./snpgrpdl.sh -t -k 5 backup$ daily
# Gefilterte Datasets:
  NAME                USED  AVAIL     REFER  MOUNTPOINT
  backup             3.98M  3.62G       24K  /backup

# Dataset: backup
# Snapfilter: daily
# Anzahl Snaps: 10
# Behalte: 5
# Anzahl Del. Snaps: 5
# Liste Snaps:
  - backup@zfs-auto-snap_daily-2020-12-23-0525
  - backup@zfs-auto-snap_daily-2020-12-24-0525
  - backup@zfs-auto-snap_daily-2020-12-25-0525
  - backup@zfs-auto-snap_daily-2020-12-26-0525
  - backup@zfs-auto-snap_daily-2020-12-27-0525
  + backup@zfs-auto-snap_daily-2020-12-28-0525
  + backup@zfs-auto-snap_daily-2020-12-29-0525
  + backup@zfs-auto-snap_daily-2020-12-30-0525
  + backup@zfs-auto-snap_daily-2020-12-31-0525
  + backup@zfs-auto-snap_daily-2021-01-01-0525
# Testmodus - Für folgende Snapshots würde ein destroy ausgeführt:
  backup@zfs-auto-snap_daily-2020-12-23-0525    creation        Wed Dec 23  6:25 2020            -
  backup@zfs-auto-snap_daily-2020-12-24-0525    creation        Thu Dec 24  6:25 2020            -
  backup@zfs-auto-snap_daily-2020-12-25-0525    creation        Fri Dec 25  6:25 2020            -
  backup@zfs-auto-snap_daily-2020-12-26-0525    creation        Sat Dec 26  6:25 2020            -
  backup@zfs-auto-snap_daily-2020-12-27-0525    creation        Sun Dec 27  6:25 2020            -
root@zfsrasp:~#
```

Forcemodus - löschen ohne Nachfragen:
```
root@zfsrasp:~# ./snpgrpdl.sh -f -k 6 backup frequent
# Gefilterte Datasets:
  NAME                USED  AVAIL     REFER  MOUNTPOINT
  backup             3.98M  3.62G       24K  /backup
  backup/smbshr       182K  3.62G     50.5K  /backup/smbshr

# Dataset: backup
# Snapfilter: frequent
# Anzahl Snaps: 4
# Behalte: 6
# Anzahl Del. Snaps: 0
# Liste Snaps:
  + backup@zfs-auto-snap_frequent-2021-01-01-2000
  + backup@zfs-auto-snap_frequent-2021-01-01-2015
  + backup@zfs-auto-snap_frequent-2021-01-01-2030
  + backup@zfs-auto-snap_frequent-2021-01-01-2045
% Keine Snapshots zum löschen

# Dataset: backup/smbshr
# Snapfilter: frequent
# Anzahl Snaps: 8
# Behalte: 6
# Anzahl Del. Snaps: 2
# Liste Snaps:
  - backup/smbshr@zfs-auto-snap_frequent-2020-12-21-2130
  - backup/smbshr@zfs-auto-snap_frequent-2020-12-21-2145
  + backup/smbshr@zfs-auto-snap_frequent-2020-12-28-1145
  + backup/smbshr@zfs-auto-snap_frequent-2020-12-28-1200
  + backup/smbshr@zfs-auto-snap_frequent-2021-01-01-2000
  + backup/smbshr@zfs-auto-snap_frequent-2021-01-01-2015
  + backup/smbshr@zfs-auto-snap_frequent-2021-01-01-2030
  + backup/smbshr@zfs-auto-snap_frequent-2021-01-01-2045
% zfs destroy wird ausgeführt:
  will destroy backup/smbshr@zfs-auto-snap_frequent-2020-12-21-2130
  will reclaim 0B
  will destroy backup/smbshr@zfs-auto-snap_frequent-2020-12-21-2145
  will reclaim 0B
% Liste nach zfs destroy:
  + backup/smbshr@zfs-auto-snap_frequent-2020-12-28-1145
  + backup/smbshr@zfs-auto-snap_frequent-2020-12-28-1200
  + backup/smbshr@zfs-auto-snap_frequent-2021-01-01-2000
  + backup/smbshr@zfs-auto-snap_frequent-2021-01-01-2015
  + backup/smbshr@zfs-auto-snap_frequent-2021-01-01-2030
  + backup/smbshr@zfs-auto-snap_frequent-2021-01-01-2045

root@zfsrasp:~#
```
