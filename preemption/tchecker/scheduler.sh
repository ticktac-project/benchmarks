#!/bin/bash

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

# Check parameters

N=2
CORE=1
WCET=1
EXEC=1

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

if [ "$N" -lt 1 ]; then
    echo "Number of threads should be >= 1"
    exit 1
fi

if [ "$CORE" -lt 1 ]; then
    echo "Number of cores should be >= 1"
    exit 1
fi

if [ "$WCET" -le 0 ]; then
    echo "Worst-case execution time of the scheduler should be >= 0"
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

echo "# Model for schedulability analysis of real-time programs
# inspired from the model introduced in Section 3 of:
# Thomas Bøgholm, Henrik Kragh-Hansen, Petur Olsen, Bent Thomsen, Kim Guldstrand Larsen:
# Model-based schedulability analysis of safety critical hard real-time Java programs.
# JTRES 2008: 106-114
"

echo "
# Schedulabily of the processes can be verified by checking that no process is
# in its location Not_Schedulable.
# Priority is encoded in the process identifiers. Processes with a small 
# indentifier have priority over processes with a bigger identifier.
"

echo "system:scheduler_${N}_${CORE}_$WCET
"

# Events
echo "event:tau
event:go
event:done"
for pid in `seq 1 $N`; do
    echo "event:run$pid
event:ready$pid
event:invoke_code$pid
event:return_code$pid"
done

# Processes
for pid in `seq 1 $N`; do
    OFFSET=0
    DEADLINE=$(($N*6+$pid))
    PERIOD=$(($DEADLINE+2))
    echo "
# Process PeriodicThread$pid
process:PeriodicThread$pid
clock:1:released_time$pid
location:PeriodicThread$pid:initial{initial: : urgent:}
location:PeriodicThread$pid:Release{urgent:}
location:PeriodicThread$pid:Scheduled{urgent:}
location:PeriodicThread$pid:Terminated{urgent:}
location:PeriodicThread$pid:CheckForOffset{invariant:released_time$pid<=$OFFSET}
location:PeriodicThread$pid:Schedulable
location:PeriodicThread$pid:Not_Schedulable
location:PeriodicThread$pid:Running
location:PeriodicThread$pid:Done{invariant:released_time$pid<=$PERIOD}
edge:PeriodicThread$pid:initial:CheckForOffset:go{do:released_time$pid=0}
edge:PeriodicThread$pid:CheckForOffset:Release:tau{provided:released_time$pid==$OFFSET}
edge:PeriodicThread$pid:Release:Schedulable:ready$pid{do:released_time$pid=0}
edge:PeriodicThread$pid:Schedulable:Scheduled:run$pid
edge:PeriodicThread$pid:Schedulable:Not_Schedulable:tau{provided:released_time$pid>$DEADLINE}
edge:PeriodicThread$pid:Scheduled:Running:invoke_code$pid
edge:PeriodicThread$pid:Running:Not_Schedulable:tau{provided:released_time$pid>$DEADLINE}
edge:PeriodicThread$pid:Not_Schedulable:Not_Schedulable:tau
edge:PeriodicThread$pid:Running:Terminated:return_code$pid{provided:released_time$pid<=$DEADLINE}
edge:PeriodicThread$pid:Terminated:Done:done
edge:PeriodicThread$pid:Done:Release:tau{provided:released_time$pid==$PERIOD}"
done

for pid in `seq 1 $N`; do
    echo "
# Process Execution$pid
process:Execution$pid
clock:1:execution_time$pid
location:Execution$pid:WaitingForRelease{initial:}
location:Execution$pid:Ready{invariant:execution_time$pid<=$EXEC}
location:Execution$pid:If{invariant:execution_time$pid<=$EXEC}
location:Execution$pid:IfThen{invariant:execution_time$pid<=$EXEC}
location:Execution$pid:IfElse{invariant:execution_time$pid<=$EXEC}
location:Execution$pid:IfEnd{invariant:execution_time$pid<=$EXEC}
location:Execution$pid:Return{invariant:execution_time$pid<=$EXEC}
location:Execution$pid:End{invariant:execution_time$pid<=$EXEC}
edge:Execution$pid:WaitingForRelease:Ready:invoke_code$pid{do:execution_time$pid=0}
edge:Execution$pid:Ready:If:tau{provided:execution_time$pid==$EXEC : do:execution_time$pid=0}
edge:Execution$pid:If:IfElse:tau{provided:execution_time$pid==$EXEC : do:execution_time$pid=0}
edge:Execution$pid:If:IfThen:tau{provided:execution_time$pid==$EXEC : do:execution_time$pid=0}
edge:Execution$pid:IfThen:IfEnd:tau{provided:execution_time$pid==$EXEC : do:execution_time$pid=0}
edge:Execution$pid:IfElse:IfEnd:tau{provided:execution_time$pid==$EXEC : do:execution_time$pid=0}
edge:Execution$pid:IfEnd:Return:tau{provided:execution_time$pid==$EXEC : do:execution_time$pid=0}
edge:Execution$pid:Return:End:tau{provided:execution_time$pid==$EXEC : do:execution_time$pid=0}
edge:Execution$pid:End:WaitingForRelease:return_code$pid{provided:execution_time$pid==$EXEC : do:execution_time$pid=0}"
done

    echo "
# Process Scheduler
process:Scheduler
clock:1:execution_time
int:1:1:$N:1:pid
int:$(($N+1)):0:1:0:schedulable
int:1:0:$CORE:$CORE:core
location:Scheduler:initial{initial: : urgent:}
location:Scheduler:Idle{urgent:}
location:Scheduler:Wait
location:Scheduler:Running{invariant:execution_time<=$WCET}
location:Scheduler:Schedule{urgent:}
edge:Scheduler:initial:Idle:go
edge:Scheduler:Running:Schedule:tau{provided:execution_time==$WCET : do:pid=1}
edge:Scheduler:Schedule:Schedule:tau{provided:schedulable[pid]==0 : do:pid=pid%$N+1}
edge:Scheduler:Running:Running:done{do:core=core+1}
edge:Scheduler:Schedule:Schedule:done{do:core=core+1}
edge:Scheduler:Idle:Idle:done{do:core=core+1}"
for i in `seq 1 $N`; do
    echo "edge:Scheduler:Schedule:Idle:run$i{provided:schedulable[pid]==1&&pid==$i : do:schedulable[pid]=0;core=core-1}
edge:Scheduler:Idle:Running:tau{provided:schedulable[$i]==1&&core>0 : do:execution_time=0}
edge:Scheduler:Wait:Idle:ready$i{do:schedulable[$i]=1;execution_time=0}
edge:Scheduler:Running:Running:ready$i{do:schedulable[$i]=1}
edge:Scheduler:Schedule:Schedule:ready$i{do:schedulable[$i]=1}
edge:Scheduler:Idle:Idle:ready$i{do:schedulable[$i]=1}"
done
TMP="schedulable[1]==0"
if [ "$N" -ge 2 ]; then
    for i in `seq 2 $N`; do
        TMP="${TMP} && schedulable[$i]==0"
    done
fi
echo "edge:Scheduler:Idle:Wait:tau{provided:$TMP}
edge:Scheduler:Wait:Idle:done{do:core=core+1}
edge:Scheduler:Idle:Wait:tau{provided:core==0}
"

TMP="sync:Scheduler@go"
for pid in `seq 1 $N`; do
    TMP="${TMP}:PeriodicThread$pid@go?"
done
echo "$TMP"
for pid in `seq 1 $N`; do
    echo "sync:Scheduler@run$pid:PeriodicThread$pid@run$pid
sync:PeriodicThread$pid@invoke_code$pid:Execution$pid@invoke_code$pid
sync:PeriodicThread$pid@ready$pid:Scheduler@ready$pid
sync:PeriodicThread$pid@done:Scheduler@done
sync:Execution$pid@return_code$pid:PeriodicThread$pid@return_code$pid"
done
