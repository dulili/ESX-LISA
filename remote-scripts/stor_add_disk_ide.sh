#!/bin/bash

###############################################################################
##
## Description:
##   add IDE disk and check wheather it works
##
###############################################################################
##
## Revision:
## v1.0.0 - ruqin - 7/11/2018 - Build the script
##
###############################################################################

dos2unix utils.sh

# Source utils.sh
. utils.sh || {
    echo "Error: unable to source utils.sh!"
    exit 1
}

# Source constants file and initialize most common variables

. constants.sh || {
    echo "Error: unable to source constants.sh!"
    exit 1
}

UtilsInit

###############################################################################
##
## Put your test script here
## NOTES:
## 1. Please use LogMsg to output log to terminal.
## 2. Please use UpdateSummary to output log to summary.log file.
## 3. Please use SetTestStateFailed, SetTestStateAborted, SetTestStateCompleted,
##    and SetTestStateRunning to mark test status.
##
###############################################################################

GetDistro

LogMsg $DISTRO

# Find out current system partition
system_part=`df -h | grep /boot | awk 'NR==1' | awk '{print $1}'| grep a`

if [ ! $system_part ]; then
#   The IDE disk should be sdb
    disk_name="sda"
else
#   The IDE disk should be sda
    disk_name="sdb"
fi

LogMsg "disk_name is $disk_name"

# if [ "$DISTRO" == "redhat_6" ]; then
#     disk_name="sda"
# else
#     disk_name="sdb"
# fi

# Do Partition for /dev/sdb

fdisk /dev/"$disk_name" <<EOF
n
p
1


w
EOF

# Get new partition

kpartx /dev/"$disk_name"

# Wait a while

sleep 6

# Format ext4

mkfs.ext4 /dev/"$disk_name"1

if [ ! "$?" -eq 0 ]
then
    LogMsg "Format Failed"
    SetTestStateFailed
    exit 1
fi

mount /dev/"$disk_name"1 /mnt

if [ ! "$?" -eq 0 ]
then
    LogMsg "Mount Failed"
    SetTestStateFailed
    exit 1
fi

cd /mnt
touch test

if [ ! "$?" -eq 0 ]
then
    LogMsg "Create New File Failed"
    SetTestStateFailed
    exit 1
fi

file="/mnt/test"

if [ ! -f "$file" ]; then
    LogMsg "Create New File Failed"
    SetTestStateFailed
    exit 1
fi

SetTestStateCompleted
exit 0