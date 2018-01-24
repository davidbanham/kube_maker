#!/bin/bash
read -p "Are you sure? (yes)" choice
case "$choice" in 
  yes ) echo "yes";;
  * ) echo nope && exit 1
esac
