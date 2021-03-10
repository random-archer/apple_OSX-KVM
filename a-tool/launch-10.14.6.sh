#!/usr/bin/env bash

set -u -e

version="10.14.6"

base_dir=$( cd $( dirname "$0" )/.. && pwd )
macos_dir="$base_dir/a-work/macos_$version"
install_media="$macos_dir/BaseSystem.img"

main_disk="/dev/disk/by-id/ata-ST9500420AS_5VJD6FV1"
data_disk="/dev/disk/by-id/ata-ST9500420AS_5VJBYL2P"

cd $base_dir

# Special thanks to:
# https://github.com/Leoyzen/KVM-Opencore
# https://github.com/thenickdude/KVM-Opencore/
# https://github.com/qemu/qemu/blob/master/docs/usb2.txt
#
# qemu-img create -f qcow2 mac_hdd_ng.img 128G
#
# echo 1 > /sys/module/kvm/parameters/ignore_msrs (this is required)

############################################################################
# NOTE: Tweak the "MY_OPTIONS" line in case you are having booting problems!
############################################################################

#
# 00:1a.0 USB controller [0c03]: Intel Corporation C610/X99 series chipset USB Enhanced Host Controller #2 [8086:8d2d] (rev 05)
#
usb_ctrl_addr="00:1a.0"

manage_driver() {
    local addr="0000:$1"
    local name="$2"
    local mode="$3"
    local base_path="/sys/bus/pci/drivers/$name"
    local term_list=$(ls $base_path)
    case $mode in
        bind)
            if [[ $term_list == *"$addr"* ]]; then
                echo device $addr present @ $base_path
            else
                sudo bash -c "echo $addr > $base_path/bind"
            fi
            ;;
        unbind)
            if [[ $term_list == *"$addr"* ]]; then
                sudo bash -c "echo $addr > $base_path/unbind"
            else
                echo device $addr missing @ $base_path
            fi
            ;;
    esac
}

device_expose() {
    manage_driver $usb_ctrl_addr ehci-pci unbind
    manage_driver $usb_ctrl_addr vfio-pci bind
}


device_restore() {
    manage_driver $usb_ctrl_addr vfio-pci unbind
    manage_driver $usb_ctrl_addr ehci-pci bind
}

#trap device_restore EXIT
#device_expose

ls -las /dev/vfio/

#
#
#

MY_OPTIONS="+pcid,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"

# This script works for Big Sur, Catalina, Mojave, and High Sierra. Tested with
# macOS 10.15.6, macOS 10.14.6, and macOS 10.13.6

ALLOCATED_RAM="8196" # MiB
CPU_SOCKETS="1"
CPU_CORES="4"
CPU_THREADS="8"

REPO_PATH="$base_dir"
OVMF_DIR="$macos_dir"

# This causes high cpu usage on the *host* side
# qemu-system-x86_64 -enable-kvm -m 3072 -cpu Penryn,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,hypervisor=off,vmx=on,kvm=off,$MY_OPTIONS\

# shellcheck disable=SC2054
args=(

  -enable-kvm -m "$ALLOCATED_RAM" -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,"$MY_OPTIONS"

  -smp "$CPU_THREADS",cores="$CPU_CORES",sockets="$CPU_SOCKETS"
  -machine q35
  
  -usb -device usb-kbd -device usb-tablet
  -device usb-ehci,id=ehci
  # -device usb-kbd,bus=ehci.0
  # -device usb-mouse,bus=ehci.0
  # -device nec-usb-xhci,id=xhci
  
  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
  -drive if=pflash,format=raw,readonly,file="$OVMF_DIR/OVMF_CODE.fd"
  -drive if=pflash,format=raw,file="$OVMF_DIR/OVMF_VARS-1024x768.fd"
  -smbios type=2
  
  -device ich9-intel-hda -device hda-duplex
  -device ich9-ahci,id=sata
  
  # pass thru
  #     00:1a.0 USB controller [0c03]: Intel Corporation C610/X99 series chipset USB Enhanced Host Controller #2 [8086:8d2d] (rev 05)
  #-device vfio-pci,host=$usb_ctrl_addr
  
  #-drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$REPO_PATH/OpenCore-Catalina/OpenCore-nopicker.qcow2"
  -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$REPO_PATH/OpenCore-Catalina/OpenCore.qcow2"
  -device ide-hd,bus=sata.2,drive=OpenCoreBoot
  
  #-device ide-hd,bus=sata.3,drive=InstallMedia
  #-drive id=InstallMedia,if=none,file="$install_media",format=raw
  
  -drive id=MainDisk,if=none,file="$main_disk",format=raw
  -device ide-hd,bus=sata.4,drive=MainDisk
  
  -drive id=DataDisk,if=none,file="$data_disk",format=raw
  -device ide-hd,bus=sata.5,drive=DataDisk
  
  # -netdev tap,id=net0,ifname=tap0,script=no,downscript=no -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c9:18:27
  -netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c8:18:28
  
  #-device VGA,vgamem_mb=128
  
  -device virtio-vga
  
  #-device virtio-vga,virgl=on
  #-display gtk,gl=on

  -monitor stdio
  
)

qemu-system-x86_64 "${args[@]}"

