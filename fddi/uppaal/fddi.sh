#!/bin/sh

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

# Check parameters

N=10
TTRT=$((50*N))
SA=20
TD=0

function usage() {
    echo "Usage: $0 N";
    echo "       $0 N TTRT SA TD";
    echo "";
    echo "       N number of processes";
    echo "       TTRT target token rotation timer (default: N*50)";
    echo "       SA synchronous allocation (default: 20)";
    echo "       TD token delay (default: 0)"
}

if [ $# -eq 1 ]; then
    N=$1
    TTRT=$((50*N))
elif [ $# -eq 4 ]; then
    N=$1
    TTRT=$2
    SA=$3
    TD=$4
else
    usage
    exit 1
fi

# Model
cat fddi.xml | sed -e s/"N=10"/"N=$N"/ -e s/"TTRT=50\*N"/"TTRT=$TTRT"/ -e s/"SA=20"/"SA=$SA"/ -e s/"TD=0"/"TD=$TD"/ > fddi_${N}_${TTRT}_${SA}_${TD}.xml