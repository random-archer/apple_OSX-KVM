
### system setup

* ssh: syspref -> remote login -> check
* display: syspref -> screen saver -> start -> never
* hybernate: syspref -> enegry saver -> turn display -> never 
* hybernate: syspref -> enegry saver -> prevent sleep -> check 
* auto-login: syspref -> users gruops -> automatic loggin -> select

### auto sudo

https://apple.stackexchange.com/questions/257813/enable-sudo-without-a-password-on-macos

echo "%admin ALL=(ALL) NOPASSWD: ALL" > /private/etc/sudoers.d/auto-sudo

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
cat ~/.ssh/id_rsa.pub | ssh username@server.dreamhost.com "cat >> ~/.ssh/authorized_keys"
```

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

https://www.macports.org/install.php

sudo port install mc
sudo port install htop

### kivy setup

https://kivy.org/doc/stable/guide/packaging-ios.html

// sudo su

port install autoconf
port install automake
port install libtool
port install pkgconfig

port install python38
port install py38-pip
port install py38-cython

// no sudo

pip install kivy-ios

mkdir -p /tmp/build
cd /tmp/build 
toolchain build kivy
