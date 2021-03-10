#!/usr/bin/env bash

set -u -e

base_dir=$( cd $( dirname "$0" )/.. && pwd )

report_group_for_device() {
    for g in `find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V` ; do
        echo "IOMMU Group ${g##*/}:"
        for d in $g/devices/*; do
            echo -e "\t$(lspci -nns ${d##*/})"
        done
    done
}

report_group_for_controller() {

    for usb_ctrl in /sys/bus/pci/devices/*/usb* ; do 
        pci_path=${usb_ctrl%/*}
        iommu_group=$(readlink $pci_path/iommu_group)
        echo "Bus $(cat $usb_ctrl/busnum) --> ${pci_path##*/} (IOMMU group ${iommu_group##*/})"
        lsusb -s ${usb_ctrl#*/usb}:
        echo
    done
}

#$base_dir/scripts/lsgroup.sh > report-vfio-group.txt

echo "" > report-vfio-group.txt

echo "====================" >> report-vfio-group.txt
report_group_for_device     >> report-vfio-group.txt

echo "====================" >> report-vfio-group.txt
report_group_for_controller >> report-vfio-group.txt

echo "====================" >> report-vfio-group.txt
lspci -nnk -d 10de:13c2     >> report-vfio-group.txt
