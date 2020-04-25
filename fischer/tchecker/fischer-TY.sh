#!/bin/sh

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

# Check parameters

k=10  # Gamma in the paper cited below
K=10  # Delta in the paper cited below

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

echo "#clock:size:name
#int:size:min:max:init:name
#process:name
#event:name
#location:process:name{attributes}
#edge:process:source:target:event:{attributes}
#sync:events
#   where
#   attributes is a colon-separated list of key:value
#   events is a colon-separated list of process@event
"

echo "# Model of Fischer's protocol introduced in:
# Stavros Tripakis and Sergio Yovine, Analysis of Timed Systems using 
# Time-Abstraction Bisimulations, Formal Methods in System Design, 18,
# pp. 25-68, 2001.
#
# NB: this model does not satisfy mutual exclusion
"

echo "system:fischer_TY_${N}_${k}_$K
"

# Events

for pid in `seq 1 $N`; do
    echo "event:try$pid
event:set$pid
event:retry$pid
event:enter$pid
event:exit$pid"
done
echo ""

# Global variables

echo "int:1:0:$N:0:last
"

# Processes

for pid in `seq 1 $N`; do
    echo "# Process $pid
process:P$pid
clock:1:x$pid
location:P$pid:idle{initial:}	
location:P$pid:trying{invariant:x$pid<=$K}
location:P$pid:waiting{}
location:P$pid:critical{labels:cs$pid}
edge:P$pid:idle:trying:try$pid{provided:last==0 : do:x$pid=0}
edge:P$pid:trying:waiting:set$pid{do:x$pid=0;last=$pid}
edge:P$pid:waiting:trying:retry$pid{provided:last!=$pid&&x$pid>$k : do:x$pid=0}
edge:P$pid:waiting:critical:enter$pid{provided:x$pid>${k}&&last==$pid}
edge:P$pid:critical:idle:exit$pid{do:last=0}
"
done
