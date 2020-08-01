#!/bin/bash
set -euo pipefail

IMG_FILE=$1
ROOTFS_DIR=$2
BOOTFS_DIR=$3

# Find a free loop device to use.
LOOP_DEV=$(losetup --find)
# If the device file does not exist then use `mknod` to create it.
if [ ! -e $LOOP_DEV ]; then
    mknod -m 0660 $LOOP_DEV b 7 0
fi
# Mount the image as a loop device.
LOOP_DEV=$(losetup --show --partscan $LOOP_DEV $IMG_FILE)

# Wait a second or mount may fail.
sleep 1

# Get a list of partitions in the image.
PARTITIONS=$(lsblk --raw --output "MAJ:MIN" --noheadings ${LOOP_DEV} | tail -n +2)

# Manually use `mknod` to create nodes for partitions on the loop device.
COUNTER=1
for i in $PARTITIONS; do
    MAJ=$(echo $i | cut -d: -f1)
    MIN=$(echo $i | cut -d: -f2)
    if [ ! -e "${LOOP_DEV}p${COUNTER}" ]; then mknod ${LOOP_DEV}p${COUNTER} b $MAJ $MIN; fi
    COUNTER=$((COUNTER + 1))
done

mount -o rw ${LOOP_DEV}p2 $ROOTFS_DIR
mount -o rw ${LOOP_DEV}p1 ${BOOTFS_DIR}
