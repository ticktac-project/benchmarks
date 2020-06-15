#!/bin/sh

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

usage() {
    echo "Usage: $0 N";
    echo "       N number of processes";
}

if [ $# -eq 1 ]; then
    N=$1
else
    usage
    exit 1
fi

# Model
cat fig1-Morbe_et_al-CAV2011.xml | sed -e s/"N = 3"/"N = $N"/ > fig1-Morbe_et_al-CAV2011_${N}.xml
