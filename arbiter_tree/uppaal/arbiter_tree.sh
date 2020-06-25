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
echo "<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE nta PUBLIC '-//Uppaal Team//DTD Flat System 1.1//EN' 'http://www.it.uu.se/research/group/darts/uppaal/flat-1_2.dtd'>
<nta>"

# Synchros
echo "<declaration>
//Inspired from UPPAAL model introduced in Section 5 in:
//Martin Wehrle, Sebastian Kupferschmid:
//Mcta: Heuristics and Search for Timed Systems. FORMATS 2012: 252-266"
for i in `seq 0 $(($N*2))`; do
    echo "chan req_$i;
chan gr_$i;
chan rel_$i;"
done
echo "</declaration>"

# Processes
echo "<template>
		<name>Loop</name>
		<location id='id0'>
			<name>wait</name>
		</location>
		<location id='id1'>
			<name>request</name>
		</location>
		<location id='id2'>
			<name>release</name>
		</location>
		<init ref='id0'/>
		<transition>
			<source ref='id0'/>
			<target ref='id1'/>
			<label kind='synchronisation'>req_0?</label>
		</transition>
		<transition>
			<source ref='id1'/>
			<target ref='id2'/>
			<label kind='synchronisation'>gr_0!</label>
		</transition>
		<transition>
			<source ref='id2'/>
			<target ref='id0'/>
			<label kind='synchronisation'>rel_0?</label>
		</transition>
	</template>"

ID=2


for i in `seq 0 $(($N-1))`; do
  echo "<template>"
    echo "<name>Arbiter_$i</name>
		<location id='id$(($ID+1))'>
			<name>wait</name>
		</location>
		<location id='id$(($ID+2))'>
			<name>req_left1</name>
		</location>
		<location id='id$(($ID+3))'>
			<name>req_left2</name>
		</location>
		<location id='id$(($ID+4))'>
			<name>req_left3</name>
		</location>
		<location id='id$(($ID+5))'>
			<name>req_right1</name>
		</location>
		<location id='id$(($ID+6))'>
			<name>req_right2</name>
		</location>
		<location id='id$(($ID+7))'>
			<name>req_right3</name>
		</location>
		<location id='id$(($ID+8))'>
			<name>granted</name>
		</location>
		<location id='id$(($ID+9))'>
			<name>release</name>
		</location>
		<location id='id$(($ID+10))'>
			<name>req_second</name>
		</location>
		<location id='id$(($ID+11))'>
			<name>release_up</name>
		</location>
		<init ref='id$(($ID+1))'/>
		<transition>
			<source ref='id$(($ID+1))'/>
			<target ref='id$(($ID+2))'/>
			<label kind='synchronisation'>req_$(($i*2+1))?</label>
		</transition>
		<transition>
			<source ref='id$(($ID+1))'/>
			<target ref='id$(($ID+5))'/>
			<label kind='synchronisation'>req_$((($i+1)*2))?</label>
		</transition>
		<transition>
			<source ref='id$(($ID+2))'/>
			<target ref='id$(($ID+3))'/>
			<label kind='synchronisation'>req_$i!</label>
		</transition>
		<transition>
			<source ref='id$(($ID+5))'/>
			<target ref='id$(($ID+6))'/>
			<label kind='synchronisation'>req_$i!</label>
		</transition>
		<transition>
			<source ref='id$(($ID+3))'/>
			<target ref='id$(($ID+4))'/>
			<label kind='synchronisation'>gr_$i?</label>
		</transition>
		<transition>
			<source ref='id$(($ID+6))'/>
			<target ref='id$(($ID+7))'/>
			<label kind='synchronisation'>gr_$i?</label>
		</transition>
		<transition>
			<source ref='id$(($ID+4))'/>
			<target ref='id$(($ID+8))'/>
			<label kind='synchronisation'>gr_$(($i*2+1))!</label>
		</transition>
		<transition>
			<source ref='id$(($ID+7))'/>
			<target ref='id$(($ID+8))'/>
			<label kind='synchronisation'>gr_$((($i+1)*2))!</label>
		</transition>
		<transition>
			<source ref='id$(($ID+8))'/>
			<target ref='id$(($ID+9))'/>
			<label kind='synchronisation'>rel_$(($i*2+1))?</label>
		</transition>
		<transition>
			<source ref='id$(($ID+8))'/>
			<target ref='id$(($ID+9))'/>
			<label kind='synchronisation'>rel_$(($i*2+2))?</label>
		</transition>
		<transition>
			<source ref='id$(($ID+9))'/>
			<target ref='id$(($ID+1))'/>
			<label kind='synchronisation'>rel_$i!</label>
		</transition>
		<transition>
			<source ref='id$(($ID+8))'/>
			<target ref='id$(($ID+10))'/>
			<label kind='synchronisation'>req_$(($i*2+1))?</label>
		</transition>
		<transition>
			<source ref='id$(($ID+8))'/>
			<target ref='id$(($ID+10))'/>
			<label kind='synchronisation'>req_$(($i*2+2))?</label>
		</transition>
		<transition>
			<source ref='id$(($ID+10))'/>
			<target ref='id$(($ID+4))'/>
			<label kind='synchronisation'>rel_$((($i+1)*2))?</label>
		</transition>
		<transition>
			<source ref='id$(($ID+10))'/>
			<target ref='id$(($ID+7))'/>
			<label kind='synchronisation'>rel_$(($i*2+1))?</label>
		</transition>
		<transition>
			<source ref='id$(($ID+1))'/>
			<target ref='id$(($ID+11))'/>
			<label kind='synchronisation'>rel_$(($i*2+1))?</label>
		</transition>
		<transition>
			<source ref='id$(($ID+1))'/>
			<target ref='id$(($ID+11))'/>
			<label kind='synchronisation'>rel_$(($i*2+2))?</label>
		</transition>
		<transition>
			<source ref='id$(($ID+11))'/>
			<target ref='id$(($ID+1))'/>
			<label kind='synchronisation'>rel_$i!</label>
		</transition>"
    echo "</template>"
    ID=$(($ID+11))
done


for i in `seq 0 $N`; do
  echo "<template>"
    echo "<name>Client_$i</name>
		<location id='id$(($ID+1))'>
			<name>idle</name>
		</location>
		<location id='id$(($ID+2))'>
			<name>wait</name>
		</location>
		<location id='id$(($ID+3))'>
			<name>work</name>
		</location>
		<location id='id$(($ID+4))'>
			<name>bounce</name>
		</location>
		<init ref='id$(($ID+1))'/>"
    if [ $i -eq 0 ]; then
		echo "<transition>
			<source ref='id$(($ID+1))'/>
			<target ref='id$(($ID+1))'/>
			<label kind='synchronisation'>rel_$N!</label>
		</transition>"
    fi
		echo "<transition>
			<source ref='id$(($ID+1))'/>
			<target ref='id$(($ID+2))'/>
			<label kind='synchronisation'>req_$(($i+$N))!</label>
		</transition>
		<transition>
			<source ref='id$(($ID+2))'/>
			<target ref='id$(($ID+3))'/>
			<label kind='synchronisation'>gr_$(($i+$N))?</label>
		</transition>
		<transition>
			<source ref='id$(($ID+3))'/>
			<target ref='id$(($ID+1))'/>
			<label kind='synchronisation'>rel_$(($i+$N))!</label>
		</transition>
		<transition>
			<source ref='id$(($ID+1))'/>
			<target ref='id$(($ID+4))'/>
			<label kind='synchronisation'>gr_$(($i+$N))?</label>
		</transition>
		<transition>
			<source ref='id$(($ID+4))'/>
			<target ref='id$(($ID+1))'/>
			<label kind='synchronisation'>rel_$(($i+$N))!</label>
		</transition>"
    echo "</template>"
done

echo "<system>
system Loop, "
for i in `seq 0 $(($N-1))`; do
    echo "Arbiter_$i, "
done
for i in `seq 0 $N`; do
  if [ $i -eq $N ]; then
    echo "Client_$i;"
  else
    echo "Client_$i, "
  fi
done
echo "</system>"

echo "	<queries>
		<query>
			<formula>E&lt;&gt; Client_1.work and Client_2.work</formula>
			<comment></comment>
		</query>
	</queries>
</nta>"
