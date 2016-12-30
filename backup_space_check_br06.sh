#!/bin/bash                                                                                                                                                                                                                                                              

DEBUG=1
debug() {
    if [ $1 = 1 ]; then
        echo $2
    fi
}
 
DU=$(which du)
LS=$(which ls)
EXPR=$(which expr)
TAIL=$(which tail)
RM=$(which rm)

BackupMaxSize_bytes=483183820800
 
# backup space check log
CKSPSTART_LOG="Backup Space Check Start"
CKSPEND_LOG="Backup Space Check Done"
FREEUP_LOG="Free up the backup sapce..."
SUFFICIENT_LOG="Has sufficent free backup sapce"
NOBAKFILES="There is no backup files"
G_BYTES=`echo '1024^3' | bc`
BAKMAXSIZE_LOG="$(echo "$BackupMaxSize_bytes / $G_BYTES" | bc -l)G"
BAKSP_GB_LOG="`$DU -hs $BackupLocal | cut -f1`"
# backup space files size
BAKLOCALFILE_EARLIEST="$BackupLocal/`$LS -t $BackupLocal | $TAIL -1`"
BAKSP_BYTES="`$DU -hsb $BackupLocal | cut -f1`"
# free the backup space
remove_bakcup_files() {
    until [ $BAKSP_BYTES -lt $BackupMaxSize_bytes ]
    do 
        if [ $BAKLOCALFILE_EARLIEST = $BackupLocal"/" ] || [ ! -d $BackupLocal ]; then
            echo $NOBAKFILES
            break
        fi
        debug $DEBUG "Remove the earliest backup file: $BAKLOCALFILE_EARLIEST"
        $RM -rf $BAKLOCALFILE_EARLIEST
        BAKLOCALFILE_EARLIEST="$BackupLocal/`$LS -t $BackupLocal | $TAIL -1`"
        BAKSP_BYTES="`$DU -hsb $BackupLocal | cut -f1`"
    done
}
# backup space check start
echo "$CKSPSTART_LOG"
debug $DEBUG "$BackupLocal $BAKSP_BYTES bytes = $BAKSP_GB_LOG"
 
if [ $BAKSP_BYTES -ge $BackupMaxSize_bytes ]; then
    debug $DEBUG "[The size of $BackupLocal: $BAKSP_GB_LOG] is over than [max backup space: $BAKMAXSIZE_LOG]"
    echo $FREEUP_LOG
    remove_bakcup_files
else
    echo $SUFFICIENT_LOG
fi

echo $CKSPEND_LOG
# backup space check end
