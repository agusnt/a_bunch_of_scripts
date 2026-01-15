#/usr/bin/env bash
#
# Easy way to import virtual machines from libvirt
#
# @author: Navarro Torres, Agustín
# @date: 2026-01-09
# @version: 0.0.1
#

[ "$#" -ne 1 ] && echo "$0 <import dir>" && exit
[ "$EUID" -ne 0 ]  && echo "I think that I should be root to perform this operation" && exit

IMPORT_PATH=$1
# Standard dir
TARGET_DIR="/var/lib/libvirt/images"

echo "========================================================"
echo "THIS ONLY WORK IF THE EXPORT MACHINE DISK IS $TARGET_DIR"
echo "========================================================"

XML_FILE=$(ls "$IMPORT_PATH"/*.xml 2>/dev/null | head -n 1)

if [ -z "$XML_FILE" ]; then
    echo "Error: there is no .xml file in $IMPORT_PATH"
    exit 1
fi

echo "[1/2] Importing disks"

for disk in "$IMPORT_PATH/"*.{qcow2,img,raw}; do
  if [ -f "$disk" ]; then
    echo -n -e "\r    Importing $disk"
    cp --sparse=always "$disk" "$TARGET_DIR/"
    chown libvirt-qemu:libvirt-qemu "$TARGET_DIR/$(basename "$disk")"
  fi
done
echo -n -e "\r"

echo "[2/2] Registering the virtual machine"

if sudo virsh define "$XML_FILE"; then
  echo "Finish!"
else
  echo "Something goes wrong!"
fi
