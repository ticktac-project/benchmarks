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
cat pacemaker_DDD.xml | sed -e s/"N = 3"/"N = $N"/ > pacemaker_DDD_${N}.xml
