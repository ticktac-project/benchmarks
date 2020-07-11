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
# Henning Dierks:
# Comparing model checking and logical reasoning for real-time systems. Formal Asp.
# Comput. 16(2): 104-120 (2004)
"

echo "
# Mutual exclusion between 2 processes can be checked by verifying that both processes
# can't be in their state unsafe at the same time.
"

echo "system:mutex_${N}_${CYCLE}_$MUTEX_DELAY
"

# Events
echo "event:tau"
for pid in `seq 1 $N`; do
    echo "event:set_g$pid
event:set_not_g$pid
event:set_safe$pid
event:set_unsafe$pid
event:poll_g$pid
event:poll_not_g$pid
event:poll_safe$pid
event:poll_unsafe$pid"
done

# Processes

echo "
# Process InOut
process:InOut
clock:1:x"
for pid in `seq 1 $N`; do
    echo "int:1:0:1:0:g$pid
int:1:0:1:0:safe$pid"
done
echo "location:InOut:init{initial:}"
for pid in `seq 1 $N`; do
    echo "edge:InOut:init:init:set_not_g$pid{do:g$pid=0;x=0}
edge:InOut:init:init:set_safe$pid{do:safe$pid=1;x=0}
edge:InOut:init:init:set_unsafe$pid{do:safe$pid=0;x=0}
edge:InOut:init:init:poll_g$pid{provided:g$pid==1&&x>0}
edge:InOut:init:init:poll_not_g$pid{provided:g$pid==0&&x>0}
edge:InOut:init:init:poll_unsafe$pid{provided:safe$pid==0&&x>0}
edge:InOut:init:init:poll_safe$pid{provided:safe$pid==1&&x>0}
edge:InOut:init:init:set_g$pid{do:g$pid=1;x=0}"
done

for pid in `seq 1 $N`; do
    echo "
# Process A$pid
process:A$pid
clock:1:y$pid
clock:1:z$pid
int:1:0:1:1:polled_g$pid
int:1:0:3:0:pc$pid
location:A$pid:init{initial: : committed:}
location:A$pid:Safe{invariant:z$pid<=$CYCLE}
location:A$pid:Unsafe{invariant:z$pid<=$CYCLE}
edge:A$pid:init:Safe:set_safe$pid
edge:A$pid:Safe:Safe:poll_g$pid{provided:pc$pid==0&&z$pid>0 : do:pc$pid=1;polled_g$pid=1}
edge:A$pid:Safe:Safe:poll_not_g$pid{provided:pc$pid==0&&z$pid>0 : do:pc$pid=1;polled_g$pid=0}
edge:A$pid:Safe:Safe:tau{provided:pc$pid==1 : do:pc$pid=3}
edge:A$pid:Safe:Safe:tau{provided:pc$pid==3&&polled_g$pid==0 : do:pc$pid=0;z$pid=0}
edge:A$pid:Safe:Unsafe:set_unsafe$pid{provided:pc$pid==3&&polled_g$pid==1 : do:pc$pid=0;y$pid=0;z$pid=0}
edge:A$pid:Unsafe:Unsafe:tau{provided:pc$pid==1 : do:pc$pid=3}
edge:A$pid:Unsafe:Unsafe:tau{provided:pc$pid==3 : do:pc$pid=0;z$pid=0}
edge:A$pid:Unsafe:Unsafe:poll_not_g$pid{provided:pc$pid==0&&z$pid>0 : do:pc$pid=1;polled_g$pid=0}
edge:A$pid:Unsafe:Unsafe:poll_g$pid{provided:pc$pid==0&&z$pid>0 : do:pc$pid=1;polled_g$pid=1}
edge:A$pid:Unsafe:Safe:set_safe$pid{provided:pc$pid==3 : do:pc$pid=0;y$pid=0;z$pid=0}"
done

echo "
# Process Ctrl
process:Ctrl
clock:1:y
clock:1:z
int:1:0:1:1:polled_safe
int:1:0:3:0:pc
location:Ctrl:init{initial: : committed:}"
for pid in `seq 1 $N`; do
echo "location:Ctrl:W$pid{invariant:z<=$CYCLE}
location:Ctrl:C$pid{invariant:z<=$CYCLE}
location:Ctrl:G$pid{invariant:z<=$CYCLE}"
done
echo "edge:Ctrl:init:W$pid:set_not_g1"
for pid in `seq 1 $N`; do
    echo "edge:Ctrl:W$pid:W$pid:tau{provided:pc==3&&polled_safe==0 : do:pc=0;z=0}
edge:Ctrl:W$pid:W$pid:tau{provided:pc==1 : do:pc=3}
edge:Ctrl:W$pid:W$pid:poll_safe$pid{provided:pc==0&&z>0 : do:pc=1;polled_safe=1}
edge:Ctrl:W$pid:W$pid:poll_unsafe$pid{provided:pc==0&&z>0 : do:pc=1;polled_safe=0}
edge:Ctrl:W$pid:C$pid:tau{provided:pc==3&&polled_safe==1 : do:pc=0;y=0;z=0}
edge:Ctrl:C$pid:W$pid:tau{provided:pc==3&&polled_safe==0 : do:pc=0;y=0;z=0}
edge:Ctrl:C$pid:C$pid:poll_safe$pid{provided:pc==0&&z>0 : do:pc=1;polled_safe=1}
edge:Ctrl:C$pid:C$pid:poll_unsafe$pid{provided:pc==0&&z>0 : do:pc=1;polled_safe=0}
edge:Ctrl:C$pid:C$pid:tau{provided:pc==1&&y<=$MUTEX_DELAY&&polled_safe==1 : do:pc=2}
edge:Ctrl:C$pid:C$pid:tau{provided:pc==1&&y>$MUTEX_DELAY&&polled_safe==1 : do:pc=3}
edge:Ctrl:C$pid:C$pid:tau{provided:pc==1&&polled_safe==0 : do:pc=3}
edge:Ctrl:C$pid:C$pid:tau{provided:pc==2 : do:pc=0;z=0}
edge:Ctrl:G$pid:W$pid:set_not_g$pid{provided:pc==3&&polled_safe==0 : do:pc=0;y=0;z=0}
edge:Ctrl:G$pid:G$pid:tau{provided:pc==3&&polled_safe==1 : do:pc=0;z=0}
edge:Ctrl:G$pid:G$pid:tau{provided:pc==1 : do:pc=3}
edge:Ctrl:G$pid:G$pid:poll_unsafe$pid{provided:pc==0&&z>0 : do:pc=1;polled_safe=0}
edge:Ctrl:G$pid:G$pid:poll_safe$pid{provided:pc==0&&z>0 : do:pc=1;polled_safe=1}
edge:Ctrl:C$pid:G$((($pid%$N)+1)):set_g$((($pid%$N)+1)){provided:pc==3&&polled_safe==1 : do:pc=0;y=0;z=0}"
done

echo "
"

# Synchros
for pid in `seq 1 $N`; do
    echo "sync:Ctrl@set_g$pid:InOut@set_g$pid
sync:Ctrl@set_not_g$pid:InOut@set_not_g$pid
sync:Ctrl@poll_safe$pid:InOut@poll_safe$pid
sync:Ctrl@poll_unsafe$pid:InOut@poll_unsafe$pid
sync:A$pid@set_safe$pid:InOut@set_safe$pid
sync:A$pid@set_unsafe$pid:InOut@set_unsafe$pid
sync:A$pid@poll_g$pid:InOut@poll_g$pid
sync:A$pid@poll_not_g$pid:InOut@poll_not_g$pid"
done
