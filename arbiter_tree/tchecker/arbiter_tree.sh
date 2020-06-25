#!/bin/bash

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

# Check parameters
usage() {
    echo "Usage: $0 N";
    echo "       N depth of the tree";
    echo "       Default: N=3";
}

if [ $# -eq 1 ]; then
    N=$((2**$1-1))
elif [ $# -ge 1 ]; then
  usage
  exit 1
else
    N=3
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

echo "# Inspired from UPPAAL model introduced in Section 5 in:
#Martin Wehrle, Sebastian Kupferschmid:
#Mcta: Heuristics and Search for Timed Systems. FORMATS 2012: 252-266
"

echo "system:arbiter_tree_$N
"

# Events

echo "event:tau
"
for i in `seq 0 $(($N*2))`; do
    echo "event:req_$i
event:gr_$i
event:rel_$i
"
done

# Processes

echo "# Process Loop
process:Loop
location:Loop:wait{initial:}
location:Loop:request
location:Loop:release
edge:Loop:wait:request:req_0
edge:Loop:request:release:gr_0
edge:Loop:release:wait:rel_0
"

for i in `seq 0 $(($N-1))`; do
    echo "# Process Arbiter_$i
process:Arbiter_$i
location:Arbiter_$i:wait{initial:}
location:Arbiter_$i:req_left1
location:Arbiter_$i:req_right1
location:Arbiter_$i:req_left3
location:Arbiter_$i:req_left2
location:Arbiter_$i:req_right2
location:Arbiter_$i:release
location:Arbiter_$i:granted
location:Arbiter_$i:req_right3
location:Arbiter_$i:req_second
location:Arbiter_$i:release_up
edge:Arbiter_$i:wait:req_left1:req_$(($i*2+1))
edge:Arbiter_$i:wait:req_right1:req_$((($i+1)*2))
edge:Arbiter_$i:req_left1:req_left2:req_$i
edge:Arbiter_$i:req_left2:req_left3:gr_$i
edge:Arbiter_$i:req_left3:granted:gr_$(($i*2+1))
edge:Arbiter_$i:granted:release:rel_$(($i*2+1))
edge:Arbiter_$i:granted:release:rel_$(($i*2+2))
edge:Arbiter_$i:release:wait:rel_$i
edge:Arbiter_$i:req_right3:granted:gr_$((($i+1)*2))
edge:Arbiter_$i:req_right1:req_right2:req_$i
edge:Arbiter_$i:req_right2:req_right3:gr_$i
edge:Arbiter_$i:req_second:req_left3:rel_$((($i+1)*2))
edge:Arbiter_$i:req_second:req_right3:rel_$(($i*2+1))
edge:Arbiter_$i:granted:req_second:req_$(($i*2+1))
edge:Arbiter_$i:granted:req_second:req_$(($i*2+2))
edge:Arbiter_$i:release_up:wait:rel_$i
edge:Arbiter_$i:wait:release_up:rel_$(($i*2+1))
edge:Arbiter_$i:wait:release_up:rel_$(($i*2+2))
"
done

for i in `seq 0 $N`; do
    echo "# Process Client_$i
process:Client_$i
location:Client_$i:idle{initial:}
location:Client_$i:wait
location:Client_$i:bounce
location:Client_$i:work
edge:Client_$i:idle:wait:req_$(($i+$N))
edge:Client_$i:wait:work:gr_$(($i+$N))
edge:Client_$i:work:idle:rel_$(($i+$N))
edge:Client_$i:bounce:idle:rel_$(($i+$N))
edge:Client_$i:idle:bounce:gr_$(($i+$N))"
if [ $i -eq 0 ]; then
    echo "edge:Client_$i:idle:idle:rel_$N"
fi
echo "
"
done


# Synchros
#index for client channel
j=-1

echo "sync:Loop@gr_0:Arbiter_0@gr_0
"

for i in `seq 0 $(($N-1))`; do
if [ $i -eq 0 ]; then
    echo "sync:Arbiter_$i@rel_$i:Loop@rel_$i
sync:Arbiter_$i@req_$i:Loop@req_$i"
else
    echo "sync:Arbiter_$i@req_$i:Arbiter_$((($i-1)/2))@req_$i
sync:Arbiter_$i@rel_$i:Arbiter_$((($i-1)/2))@rel_$i"
fi
if [ $(($i*2+1)) -lt $N ]; then
    echo "sync:Arbiter_$i@gr_$(($i*2+1)):Arbiter_$(($i*2+1))@gr_$(($i*2+1))
sync:Arbiter_$i@gr_$(($i*2+2)):Arbiter_$(($i*2+2))@gr_$(($i*2+2))
"
else
    echo "sync:Arbiter_$i@gr_$(($i*2+1)):Client_$(($j+1))@gr_$(($i*2+1))
sync:Arbiter_$i@gr_$(($i*2+2)):Client_$(($j+2))@gr_$(($i*2+2))
"
j=$j+2
fi
done

for i in `seq 0 $N`; do
    echo "sync:Client_$i@rel_$(($N+$i)):Arbiter_$(((($N+$i)-1)/2))@rel_$(($N+$i))
sync:Client_$i@req_$(($N+$i)):Arbiter_$(((($N+$i)-1)/2))@req_$(($N+$i))
"
done
