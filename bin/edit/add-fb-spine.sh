#!/usr/bin/env bash

for i in $(find krn -type f -and -name '*tele-41*' -print)
do
    FILENAME=$(awk ' /filename/ { print $2 } ' $i)
    MAYBE_SOLO=$(echo $FILENAME | grep 'Sol')

    if [[ -z $MAYBE_SOLO ]]
    then
        addSpine -p $i -e "**fb" | extractx -s 1,3,2 > krn/metodiche/temp-$FILENAME.krn
    else
        addSpine -p $i -e "**fb" | extractx -s 1,3,2 > krn/essercizii/temp-$FILENAME.krn
    fi
done
