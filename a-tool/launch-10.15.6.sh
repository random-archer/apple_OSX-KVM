#!/usr/bin/env bash

set -u -e

version="10.15.6"

base_dir=$( cd $( dirname "$0" )/.. && pwd )
macos_dir="$base_dir/a-work/macos_$version"

# loader storage
install_media="$macos_dir/BaseSystem.img"

# system storage
main_disk="/dev/disk/by-id/ata-ST9500420AS_5VJD5TJD"

# xcode download storage 
data_disk="/dev/disk/by-id/ata-ST9500420AS_5VJBYL2P"

cd $base_dir


#
# pass thru for ehci-pci usb 2.0 controller
#   lspci | grep -i usb
# 00:1a.0 USB controller [0c03]: Intel Corporation C610/X99 series chipset USB Enhanced Host Controller #2 [8086:8d2d] (rev 05)
#
usb_ctrl_addr="00:1a.0"

# vfio driver switch support
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

# switch driver to guest
driver_expose() {
    manage_driver $usb_ctrl_addr ehci-pci unbind
    manage_driver $usb_ctrl_addr vfio-pci bind
}


# switch driver to host
driver_restore() {
    manage_driver $usb_ctrl_addr vfio-pci unbind
    manage_driver $usb_ctrl_addr ehci-pci bind
}

trap driver_restore EXIT
driver_expose

# verify vfio device access by kvm group
ls -las /dev/vfio/

#
#
#

# Special thanks to:
# https://github.com/Leoyzen/KVM-Opencore
# https://github.com/thenickdude/KVM-Opencore/
# https://github.com/qemu/qemu/blob/master/docs/usb2.txt
#
# qemu-img create -f qcow2 mac_hdd_ng.img 128G
#
# echo 1 > /sys/module/kvm/parameters/ignore_msrs (this is required)

# This script works for Big Sur, Catalina, Mojave, and High Sierra. Tested with
# macOS 10.15.6, macOS 10.14.6, and macOS 10.13.6

ALLOCATED_RAM="8196" # MiB
CPU_SOCKETS="1"
CPU_CORES="4"
CPU_THREADS="8"

CPU_OPTS="+pcid,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"

REPO_PATH="$base_dir"
OVMF_DIR="$macos_dir"

# This causes high cpu usage on the *host* side
# qemu-system-x86_64 -enable-kvm -m 3072 -cpu Penryn,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,hypervisor=off,vmx=on,kvm=off,$CPU_OPTS\

# shellcheck disable=SC2054
args=(

  -enable-kvm 
  -m "$ALLOCATED_RAM" 
  -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,$CPU_OPTS
  -smp "$CPU_THREADS",cores="$CPU_CORES",sockets="$CPU_SOCKETS"
  -machine q35,accel=kvm
  
  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
  -drive if=pflash,format=raw,readonly,file="$OVMF_DIR/OVMF_CODE.fd"
  -drive if=pflash,format=raw,file="$OVMF_DIR/OVMF_VARS-1024x768.fd"
  -smbios type=2
  
  -device ich9-intel-hda -device hda-duplex
  -device ich9-ahci,id=sata
  
  -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$REPO_PATH/OpenCore-Catalina/OpenCore-nopicker.qcow2"
  #-drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$REPO_PATH/OpenCore-Catalina/OpenCore.qcow2"
  -device ide-hd,bus=sata.2,drive=OpenCoreBoot
  
  # skip: enabe only during reinstall
  #-device ide-hd,bus=sata.3,drive=InstallMedia
  #-drive id=InstallMedia,if=none,file="$install_media",format=raw
  
  # provides configured system
  -drive id=MainDisk,if=none,file="$main_disk",format=raw
  -device ide-hd,bus=sata.4,drive=MainDisk
  
  # provides development storage
  -drive id=DataDisk,if=none,file="$data_disk",format=raw
  -device ide-hd,bus=sata.5,drive=DataDisk
  
  # skip: interferes with usb pass thru
  #-usb 
  #-device usb-kbd
  #-device usb-tablet
  
  # provides usb 2.0 support
  -device usb-ehci,id=ehci
  -device usb-kbd,bus=ehci.0
  -device usb-tablet,bus=ehci.0

  # enable pass thru support for usb 2.0
  -device vfio-pci,bus=pcie.0,host=$usb_ctrl_addr
 
  # skip: no host access for ssh
  #-netdev tap,id=net0,ifname=tap0,script=no,downscript=no -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c9:18:27
  #-netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c8:18:28
  
  # provides full network bridge with host access via ssh
  -netdev bridge,id=br0,br=virbr0,helper=/usr/lib/qemu/qemu-bridge-helper
  -device vmxnet3,netdev=br0,id=net0,mac=52:54:00:c8:18:28
  
  # skip: bugs with resolution
  #-device VGA,vgamem_mb=128

  # provides display rescale on demand
  -device virtio-vga
  
  # provides shared folder via 9p 
  # https://wiki.qemu.org/Documentation/9psetup
  # https://www.kraxel.org/blog/2019/06/macos-qemu-guest
  #-fsdev local,id=home_work,path=/home/work,security_model=mapped,dmode=0775,fmode=0664
  -fsdev local,id=home_work,path=/home/work,security_model=none
  -device virtio-9p-pci,fsdev=home_work,mount_tag=HomeWork

  -monitor stdio
  
)

qemu-system-x86_64 "${args[@]}"
