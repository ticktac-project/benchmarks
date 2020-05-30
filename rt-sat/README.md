The rt-sat.py script generates a system with a number of asynchronous computation nodes. Each node has an output and a number of inputs.
An input is either the output of another node or it is an external input.
All external inputs and node outputs are initially undefined (encoded by the value 2). Initially, the external inputs
are assigned non-deterministic values instantaneously (along committed states).

A node whose output is undefined periodically wakes up every P(eriod) time units. If all its inputs are defined, then
it computes its output value which remains defined for at most D(uration) time units, after which its output becomes undefined again.
The exact activation duration is chosen non-deterministically.
Each gate implements a -possibly negated- ``threshold function''. A threshold function is defined by (th, [i_1,...,i_k])
where th is a threshold value, and [i_1,...,i_k] is a list of inputs. Its value is 1 if and only if all its inputs are defined and
v(i_1) + ... + v(i_k) >= th, where v(.) denotes the current value of the gates; its value is 0 if all its inputs are defined and
v(i_1) + ... + v(i_k) < th; and it is undefined otherwise.
If the gate is negated, then the value of the function is switched (0 becomes 1, and 1 becomes 0).

Example: And and or gates with multiple inputs can be implemented. For instance, (3, [i_1,i_2,i_3]) encodes i_1 /\ i_2 /\ i_3;
         while (1, [i_1,i_2,i_3]) encodes i_1 \/ i_2 \/ i_3

The specification is whether the gate number 0 can be set to 1.
This is thus a generalization of the SAT problem with real-time constraints.
The label sat is reachable iff the specification holds.

Input format
An input graph is a list of nodes. Each node has the following format:
       (id, period, duration, neg, threshold, [i1, i2, ..., ik])
where
- id: a unique integer identifier,
- period: wake-up period
- duration: activation duration
- neg: a Boolean flag determining whether the node is negated
- threshold: the threshold of the threshold function
- [i_1,i_2,...,i_k]: the list of the inputs of the threshold function

The set of instances are defined in data.py.

Run 
	
	generate.sh format class

to generate the models, with format in {uppaal,tchecker} and class in {sat,unsat}.

For TChecker models, the specification is the reachabability of the "sat" label.
For Uppaal, the reachability query is in the rt-sat.q file.
All generated files whose names include "sat" satisfy the specification; those with unsat do not.
