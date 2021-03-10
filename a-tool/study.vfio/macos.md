
### guest 9p support

https://www.kraxel.org/blog/2019/06/macos-qemu-guest/

kextstat | grep -i virt
```
   64    0 0xffffff7f8296c000 0x1c000    0x1c000    com.apple.driver.AppleVirtIO (2.1.3) 12648254-1B34-3C29-A5F4-A3FA7ED2CAAF <63 27 13 6 5 3 1>
```

ls -las /System/Library/Extensions/AppleVirtIO.kext/Contents
```
total 16
0 drwxr-xr-x  6 root  wheel   192 Mar 12  2019 .
0 drwxr-xr-x@ 3 root  wheel    96 Mar 12  2019 ..
8 -rw-r--r--  1 root  wheel  3571 Mar 12  2019 Info.plist
0 drwxr-xr-x  3 root  wheel    96 Mar 15  2019 MacOS
0 drwxr-xr-x  3 root  wheel    96 Mar 12  2019 _CodeSignature
8 -rw-r--r--  1 root  wheel   517 Mar 12  2019 version.plist
```

cat /System/Library/Extensions/AppleVirtIO.kext/Contents/Info.plist

### host 9p setup

https://wiki.qemu.org/Documentation/9psetup

qemu options
```
  -fsdev local,id=home_work,path=/home/work,security_model=none
  -device virtio-9p-pci,fsdev=home_work,mount_tag=HomeWork
```
