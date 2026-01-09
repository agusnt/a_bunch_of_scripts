#/usr/bin/env bash
#
# Easy way to export virtual machines from libvirt
#
# @author: Navarro Torres, Agustín
# @date: 2026-01-09
# @version: 0.0.1
#

[ "$#" -ne 2 ] && echo "$0 <vm name> <out dir>" && exit
[ "$EUID" -ne 0 ]  && echo "I think that I should be root to perform this operation" && exit

VM_NAME=$1
OUT_DIR=$2
EXPORT_PATH=$OUT_DIR/${VM_NAME}_export_$(date +%Y%m%d_%H%M)

STATE=$(LC_ALL=C virsh dominfo "$VM_NAME")

if [ -z "$STATE" ]; then
  echo "Virtual machine ($VM_NAME) doesn't exists, try on of this:" 
  echo ""
  virsh list --all
  exit 1
fi

mkdir -p "$EXPORT_PATH"

[ -z "$(echo "$STATE" | grep 'shut off')" ] && echo "Stop $VM_NAME before export it with: virsh shutdown $VM_NAME. It will take a while, be patient" && exit

echo "[1/2] exporting XML configuration"
virsh dumpxml "$VM_NAME" > "$EXPORT_PATH/$VM_NAME.xml"

echo "[2/2] exporting disk configuration"
echo "  This will take a while..."
for disk in $(LC_ALL=C virsh domblklist "$VM_NAME" | sed '1d' | awk '{print $2}'); do
  echo -n -e "\r  Exporting $disk"
  cp --sparse=always "$disk" "$EXPORT_PATH/"
done
echo -e "\rEverhing should be exported in $EXPORT_PATH"

