#!/usr/bin/env bash

replace()
{
    for i in $(find . -type f -and -name '*temp*' -print)
    do
        FILENAME=$(awk ' /filename/ { print $2; exit } ' $i)

        git rm $FILENAME.krn
        git mv $i $FILENAME.krn
    done
}

cd krn/fantasias/flute
replace
cd ..

cd gamba
replace
cd ..

cd violin
replace
cd ../../

cd essercizii
replace
cd ..

cd metodiche
replace
