#!/bin/bash

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

# Check parameters

L=808  # lambda
S=26   # sigma

function usage() {
    echo "Usage: $0 N";
    echo "       $0 N L S";
    echo "       N number of processes";
    echo "       L (lambda) delay for full communication";
    echo "       S (sigma) delay for collision detection";
}

if [ $# -eq 1 ]; then
    N=$1
elif [ $# -eq 3 ]; then
    N=$1
    L=$2
    S=$3
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

echo "# Model of the CSMA/CD protocol, inspired from Stavros Tripakis, Sergio 
# Yovine: Analysis of Timed Systems Using Time-Abstracting Bisimulations. 
# Formal Methods Syst. Des. 18(1): 25-68 (2001)
#
# The Retry -busy-> Retry loop in the station processes was missing in the
# publication above. Without the busy loop, communications cannot be fully
# achieved once a collision occured (the end event cannot occur anymore once
# a cd occured).
#
# This model implements collision as a global transition that synchronizes all
# the processes, as in the publication above.
"

echo "system:csmacd_${N}_${L}_$S
"

# Events
echo "event:tau
event:begin
event:busy
event:end
event:cd"

echo ""

# Bus process
echo "# Bus
process:Bus
int:1:1:$(($N+1)):1:j
clock:1:y
location:Bus:Idle{initial:}
location:Bus:Active{}
location:Bus:Collision{invariant:y<$S}
edge:Bus:Idle:Active:begin{do:y=0}
edge:Bus:Active:Collision:begin{provided:y<$S : do:y=0}
edge:Bus:Active:Active:busy{provided:y>=$S}
edge:Bus:Active:Idle:end{do:y=0}
edge:Bus:Collision:Idle:cd{provided:y<$S : do:y:=0}
"

# Station processes
for pid in `seq 1 $N`; do
    echo "# Station $pid
process:Station$pid
clock:1:x$pid
location:Station$pid:Wait{initial:}
location:Station$pid:Start{invariant:x$pid<=$L}
location:Station$pid:Retry{invariant:x$pid<2*$S}
edge:Station$pid:Wait:Start:begin{do:x$pid=0}
edge:Station$pid:Wait:Retry:busy{do:x$pid=0}
edge:Station$pid:Wait:Wait:cd{do:x$pid=0}
edge:Station$pid:Wait:Retry:cd{do:x$pid=0}
edge:Station$pid:Start:Wait:end{provided:x$pid==$L : do:x$pid=0}
edge:Station$pid:Start:Retry:cd{provided:x$pid<$S : do:x$pid=0}
edge:Station$pid:Retry:Start:begin{provided:x$pid<2*$S : do:x$pid=0}
edge:Station$pid:Retry:Retry:busy{provided:x$pid<2*$S : do:x$pid=0}
edge:Station$pid:Retry:Retry:cd{provided:x$pid<2*$S : do:x$pid=0}
"
done

# Synchronizations
for pid in `seq 1 $N`; do
    echo "sync:Bus@begin:Station$pid@begin
sync:Bus@busy:Station$pid@busy
sync:Bus@end:Station$pid@end"
done

echo -n "sync:Bus@cd"
for pid in `seq 1 $N`; do
    echo -n ":Station$pid@cd"
done
echo ""
