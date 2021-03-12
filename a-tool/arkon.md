
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


### fetch

./a-tool/fetch-10.15.6.sh

### launch

./a-tool/launch-10.15.6.sh

### 9p setup

#### issue on host:

make qemu user member of group work with gid 2000 

#### issue on guest:

make login user member of group work with gid 2000 
```
sudo dscl . create /Groups/work gid 2000
sudo dscl . append /Groups/work GroupMembership $USER
```

provision special mount point for 9p share

```
mkdir -p /private/home_work
chown root:work /private/home_work
mount -t 9p HomeWork /private/home_work
ls -las /Volumes/HomeWork
```

ensure mount 9p on boot, see: 
* host.root/etc/fstab
* host.root/etc/rc.server
