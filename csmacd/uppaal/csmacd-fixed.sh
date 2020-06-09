#!/bin/bash
SIZE=2
L=808
S=26

if [ "$#" -eq 1 ]; then
    SIZE=$1
elif [ "$#" -eq 3 ]; then
    SIZE=$1
    L=$2
    S=$3
else
    echo "Usage: $0 <size> [<L> <S>]";
    exit 1
fi

cat csmacd-fixed.xml | sed -e s/"N=2"/"N=$SIZE"/g -e s/"L=808"/"L=$L"/g -e s/"S=26"/"S=$S"/g > csmacd-fixed-$SIZE-$L-$S.xml
