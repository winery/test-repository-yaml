#!/usr/bin/env bash

parse_yaml() {
  local prefix=$2
  local s
  local w
  local fs
  s='[[:space:]]*'
  w='[a-zA-Z0-9_]*'
  fs="$(echo @|tr @ '\034')"
  sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
  awk -F"$fs" '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {
      if (i > indent) {
        delete vname[i]
      }
    }
    if (length($3) > 0) {
      vn=""; 
      for (i=0; i<indent; i++) {
        vn=(vn)(vname[i])("_")
      }
      if ($2 == "targetNamespace") {
        printf("%s\n", $3);
      }
    }
  }' | sed 's/_=/+=/g'
}

rawUrlDecode() {
  local string="${1}"
  local length=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<length ; pos++ )); do
     c=${string:${pos}:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"; o=${o^^};
     esac
     encoded+="${o}"
  done
  echo "${encoded}"
}

cd yaml/
for i in *.yml; do
  [ -f "$i" ] || break
  test=$(parse_yaml "$i");
  dir=serviceTemplates;
  [[ -d ${dir} ]] || mkdir ${dir};
  dir=${dir}/$(rawUrlDecode ${test});
  [[ -d ${dir} ]] || mkdir ${dir};
  mv ${i} ${dir}/${i}
done
cd ../
