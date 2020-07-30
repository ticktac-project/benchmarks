#!/bin/bash

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

# Check parameters

N=2
CORE=1
WCET=1

function usage() {
    echo "Usage: $0 N";
    echo "       $0 N CORE";
    echo "       $0 N CORE WCET";
    echo "       N number of threads";
    echo "       CORE number of cores"
    echo "       WCET worse case execution time of the scheduler"
}

if [ $# -eq 1 ]; then
    N=$1
elif [ $# -eq 2 ]; then
    N=$1
    CORE=$2
elif [ $# -eq 3 ]; then
    N=$1
    CORE=$2
    WCET=$3
else
    usage
    exit 1
fi

# Model
cat scheduler.xml | sed -e s/"N = 2"/"N = $N"/ -e s/"CORE = 1"/"CORE = $CORE"/ -e s/"WCET = 1"/"WCET = $WCET"/ > scheduler_${N}_${CORE}_${WCET}.xml
