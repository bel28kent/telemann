#!/usr/bin/env bash

FILES=$(find krn -type f)

for i in $FILES
do
    BEAT=$(beat $i)

    if [[ $? == 0 ]]; then
        echo "pass: " $i
    else
        echo "fail: " $i
    fi
done
