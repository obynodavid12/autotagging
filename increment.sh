#!/bin/bash

next() {
  local l="$1"
  local a="$2"
  local l1 l2 l3 a1 a2 a3

  IFS="." read l1 l2 l3 <<< "$l"
  IFS="." read a1 a2 a3 <<< "$a"
  
  echo "$(($l1+a1)).$(($l2+a2)).$(($l3+a3))"
}

last="1.0.1"
add="0.0.1"

new=$(next "$last" "$add")
echo "$new"
