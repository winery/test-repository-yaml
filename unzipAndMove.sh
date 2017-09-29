#!/usr/bin/env bash

dir=yaml
[[ -d ${dir} ]] || mkdir ${dir};

for i in csars/*.csar; do
  [ -f "$i" ] || break
  unzip -o ${i} -d ${dir}
  ./move.sh
done
