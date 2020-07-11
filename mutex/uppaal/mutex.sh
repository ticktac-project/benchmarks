#!/bin/bash

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

# Check parameters

CYCLE=1
MUTEX_DELAY=2

function usage() {
    echo "Usage: $0 N";
    echo "       $0 N CYCLE MUTEX_DELAY";
    echo "       N number of processes";
    echo "       CYCLE time of a CYCLE in a node"
    echo "       MUTEX_DELAY delay of a mutex control"
}

if [ $# -eq 1 ]; then
    N=$1
elif [ $# -eq 3 ]; then
    N=$1
    CYCLE=$2
    MUTEX_DELAY=$3
else
    usage
    exit 1
fi

# Model
cat mutex.xml | sed -e s/"N = 2"/"N = $N"/ -e s/"CYCLE = 1"/"CYCLE = $CYCLE"/ -e s/"MUTEX_DELAY = 2"/"MUTEX_DELAY = $MUTEX_DELAY"/ > mutex_${N}_${CYCLE}_${MUTEX_DELAY}.xml
