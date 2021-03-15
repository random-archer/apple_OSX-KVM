
### system config

* name: syspref -> sharing -> computer name 
* ssh: syspref -> sharing -> remote login -> check
* display: syspref -> screen saver -> start -> never
* hybernate: syspref -> enegry saver -> turn display -> never 
* hybernate: syspref -> enegry saver -> prevent sleep -> check 
* auto-login: syspref -> users gruops -> automatic loggin -> select

### ssh key login

https://help.dreamhost.com/hc/en-us/articles/216499537-How-to-configure-passwordless-login-in-Mac-OS-X-and-Linux

on guest
```
mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys
chmod -R go-rwx ~/.ssh
```

on host
```
cat ~/.ssh/id_rsa.pub | ssh user0@xmac "cat >> ~/.ssh/authorized_keys"
```

### auto sudo

https://apple.stackexchange.com/questions/257813/enable-sudo-without-a-password-on-macos


on guest
```
sudo su
echo "%admin ALL=(ALL) NOPASSWD: ALL" > /private/etc/sudoers.d/auto-sudo
```

### xcode setup

use app store


### xcode setup


https://developer.apple.com/download/

download/install Xcode 11.3 command tools
finish setup: xcode-select --install

download/install Xcode 11.3
cd ~/Downloads
xip -x /Volumes/DataDisk/Xcode_11.3.xip
mv ~/Downloads/Xcode.app /Applications/Xcode_11.3.app

finish setup: invoke launcher -> xcode app 

### ports setup

download pkg

https://www.macports.org/install.php

on guest
```
sudo port install mc
sudo port install htop
```

### google chrome

download dmg

### python 3

download pkg
run certificate install script 

https://www.python.org/downloads/release/python-392/

### plan 9 mount

note: ensure same "work" group gid on host and guest

sudo dscl . create /Groups/work gid 2000
sudo dscl . append /Groups/work GroupMembership $USER
echo "HomeWork /private/home_work 9p" | sudo cat > /etc/fstab
sudo mkdir -p /private/home_work
sudo chown $USER:work /private/home_work
sudo mount_9p HomeWork
ls -las /Volumes/HomeWork
