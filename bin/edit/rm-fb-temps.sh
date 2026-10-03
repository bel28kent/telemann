#!/usr/bin/env bash

for i in $(find krn -type f -and -name '*temp*' -print)
do
    FILENAME=$(awk ' /filename/ { print $2 } ' $i)
    MAYBE_SOLO=$(echo $FILENAME | grep 'Sol')

    if [[ -z $MAYBE_SOLO ]]
    then
        git rm krn/metodiche/$FILENAME.krn
        git mv $i krn/metodiche/$FILENAME.krn
    else
        git rm krn/essercizii/$FILENAME.krn
        git mv $i krn/essercizii/$FILENAME.krn
    fi
done
