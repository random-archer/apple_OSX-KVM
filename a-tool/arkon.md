
###  osx-kvm

https://github.com/kholia/OSX-KVM

// ubuntu
sudo apt-get install qemu uml-utilities virt-manager git wget libguestfs-tools p7zip-full -y

// archux
sudo pacman -S qemu
sudo pacman -S virt-manager
sudo pacman -S git
sudo pacman -S wget
sudo pacman -S p7zip
sudo pacman -S libguestfs
aur uml_utilities

git clone https://github.com/kholia/OSX-KVM.git

cd OSX-KVM

python fetch-macOS.py

* setup ok: select " 3    041-91758    10.13.6  2019-10-19  macOS High Sierra"

qemu-img convert BaseSystem.dmg -O raw BaseSystem.img

qemu-img create -f qcow2 mac_hdd_ng.img 128G

./OpenCore-Boot.sh

### usb path through

===

https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF
 
provide /etc/modprobe.d/vfio.conf
```
options vfio-pci ids=8086:8d2d
```




https://github.com/kholia/OSX-KVM/blob/master/notes.md#usb-passthrough-notes

* front panel usb 2.0

lspci -nn|grep USB
00:1a.0 USB controller [0c03]: Intel Corporation C610/X99 series chipset USB Enhanced Host Controller #2 [8086:8d2d] (rev 05)

