#!/bin/sh

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

# Check parameters

k=10
K=10

function usage() {
    echo "Usage: $0 N";
    echo "       $0 N k K";
    echo "       N number of processes";
    echo "       k minimum delay for mutex (default: $k)"
    echo "       K maximum delay for mutex (default: $K)"
}

if [ $# -eq 1 ]; then
    N=$1
elif [ $# -eq 3 ]; then
    N=$1
    k=$2
    K=$3
else
    usage
    exit 1
fi

# Model
cat fischer-TY.xml | sed -e s/"N = 3"/"N = $N"/ -e s/"k = 1"/"k = $k"/ -e s/"K = 1"/"K = $K"/ > fischer-TY_${N}_${k}_${K}.xml