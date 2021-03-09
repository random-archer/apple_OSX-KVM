#!/usr/bin/env bash

set -u -e

# high sierra
version="10.13.6"

base_dir=$( cd $( dirname "$0" )/.. && pwd )
macos_dir=$base_dir/a-work/macos_$version

cd $base_dir

python fetch-macOS.py \
    --version=$version \

mv $base_dir/BaseSystem.dmg $macos_dir/BaseSystem.dmg

qemu-img convert $macos_dir/BaseSystem.dmg -O raw $macos_dir/BaseSystem.img
