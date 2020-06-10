#!/bin/sh

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

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

echo "# Zhihao Jiang, Miroslav Pajic, Salar Moarref, Rajeev Alur, Rahul Mangharam:
#Modeling and Verification of a Dual Chamber Implantable Pacemaker.
#TACAS 2012: 188-203.
"

echo "
# The well treatment of bradycardia can be checked by verifying that processus
#Pvv in state two_a implies that its internal clock x is lower or equal to TLRI.
#The verification that the pacemaker does not pace the ventricles beyond a
#maximum rate can be checked by: PURI_test in state interval implies that its
#internal clock x is greater or equal to TURI.
"

echo "system:pacemaker_DDD
"

# Events

echo "event:tau
event:AS
event:AP
event:VP
event:VS
event:Aget
event:Vget
"

# Global variables

echo "int:1:150:150:150:TAVI
int:1:10000:10000:10000:TLRI
int:1:100:100:100:TPVARP
int:1:150:150:150:TVRP
int:1:400:400:400:TURI
int:1:50:50:50:TPVAB
int:1:0:0:0:Aminwait
int:1:10000:10000:10000:Amaxwait
clock:1:t
clock:1:clk
"

# Processes
    echo "# Process LRI
process:LRI
location:LRI:LRI{initial:,invariant:t<=TLRI-TAVI}
location:LRI:Ased
edge:LRI:LRI:LRI:AP{provided:t>=TLRI-TAVI : do:t=0}
edge:LRI:LRI:LRI:VS{do:t=0}
edge:LRI:LRI:LRI:VP{do:t=0}
edge:LRI:LRI:Ased:AS
edge:LRI:Ased:LRI:VP{do:t=0}
edge:LRI:Ased:LRI:VS{do:t=0}
"
    echo "# Process AVI
process:AVI
location:AVI:Idle{initial:}
location:AVI:AVI{invariant:t<=TAVI}
location:AVI:WaitURI{invariant:clk<=TURI}
edge:AVI:Idle:AVI:AS{do:t=0}
edge:AVI:Idle:AVI:AP{do:t=0}
edge:AVI:AVI:Idle:VP{provided:t>=TAVI&&clk>=TURI}
edge:AVI:AVI:Idle:VS
edge:AVI:AVI:WaitURI:tau{provided:t>=TAVI&&clk<TURI}
edge:AVI:WaitURI:Idle:VP{provided:clk>=TURI}
edge:AVI:WaitURI:Idle:VS
"
echo "# Process URI
process:URI
location:URI:URI{initial:}
edge:URI:URI:URI:VS{do:clk=0}
edge:URI:URI:URI:VP{do:clk=0}
"
echo "# Process PVARP
process:PVARP
location:PVARP:Idle{initial:}
location:PVARP:inter{committed:}
location:PVARP:PVAB{invariant:t<=TPVAB}
location:PVARP:PVARP{invariant:t<=TPVARP}
location:PVARP:inter1{committed:}
edge:PVARP:Idle:PVAB:VS{do:t=0}
edge:PVARP:Idle:PVAB:VP{do:t=0}
edge:PVARP:PVAB:PVARP:tau{provided:t>=TPVAB}
edge:PVARP:PVARP:Idle:tau{provided:t>=TPVARP}
edge:PVARP:PVARP:inter1:Aget
edge:PVARP:inter1:PVARP:AP
edge:PVARP:Idle:inter:Aget
edge:PVARP:inter:Idle:AS
"
echo "# Process VRP
process:VRP
location:VRP:Idle{initial:}
location:VRP:inter{committed:}
location:VRP:VRP{invariant:t<=TVRP}
edge:VRP:Idle:VRP:VP{do:t=0}
edge:VRP:Idle:inter:Vget
edge:VRP:inter:VRP:VS{do:t=0}
edge:VRP:VRP:Idle:tau{provided:t>=TVRP}
"
echo "# Process RHM
process:RHM
location:RHM:AReady{initial:,invariant:x<Amaxwait}
edge:RHM:AReady:AReady:AP{do:x=0}
edge:RHM:AReady:AReady:Aget{provided:x>Aminwait : do:x=0}
"
echo "# Process Pvv
process:Pvv
location:Pvv:wait_1st{initial:}
location:Pvv:wait_2nd
location:Pvv:two_a{committed}
edge:Pvv:wait_1st:wait_2nd:VS{do:x=0}
edge:Pvv:wait_1st:wait_2nd:VP{do:x=0}
edge:Pvv:wait_2nd:two_a:VS
edge:Pvv:wait_2nd:two_a:VP
edge:Pvv:two_a:wait_2nd:tau{do:w=0}
"
echo "# Process PURI_test
process:PURI_test
location:PURI_test:wait_v{initial:}
location:PURI_test:wait_vp
location:PURI_test:interval{committed}
edge:PURI_test:wait_v:wait_vp:VP{do:x=0}
edge:PURI_test:wait_v:wait_vp:VS{do:x=0}
edge:PURI_test:wait_vp:wait_vp:VS{do:x=0}
edge:PURI_test:wait_vp:interval:VP
edge:PURI_test:interval:wait_vp:tau{do:x=0}
"
echo "# Synchros
sync:LRI@AP:AVI@AP?:RHM@AP?
sync:AV@VP:LRI@VP?:URI@VP?:PVARP@VP?:VRP@VP?:Pvv@VP?PURI_test@VP?
sync:PVARP@AS:LRI@AS?:AVI@AS?
sync:PVARP@AP:AVI@AP?:RHM@AP?
sync:VRP@VS:LRI@VS?:AVI@VS?:URI@VS?:PVARP@VS?:Pvv@VS?:PURI_test@VS?
sync:RHM@Aget:PVARP@Aget?
"
