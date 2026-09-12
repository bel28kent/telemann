#!/usr/bin/env bash

for i in $(find krn -type f)
do
    KEY=$(echo $i | egrep -o "tele.+[^\.]" | sed 's/\.krn//')
    echo "!!!filename: $KEY" >> $i
done
