#!/usr/bin/env bash

set -u -e

group_num="39"

base_dir=$( cd $( dirname "$0" )/.. && pwd )

$base_dir/scripts/vfio-group.sh $group_num > update-vfio-group.txt
