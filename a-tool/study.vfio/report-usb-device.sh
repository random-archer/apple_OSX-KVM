#!/usr/bin/env bash

set -u -e

usb_device_1="8086:8d2d"

base_dir=$( cd $( dirname "$0" )/.. && pwd )

lspci -nn | grep USB > report-usb-device.txt

echo "-------------------"  >> report-usb-device.txt

lspci -nnk -d $usb_device_1 >> report-usb-device.txt
