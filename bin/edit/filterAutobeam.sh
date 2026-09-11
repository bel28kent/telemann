#!/usr/bin/env bash

FILES=$(find krn -type f)

for i in $FILES
do
    echo "!!!filter: autobeam" >> $i
done
