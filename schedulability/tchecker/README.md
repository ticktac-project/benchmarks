# TChecker model of schedulability analysis of real-time programs

This directory contains TChecker models for schedulability analysis of real-time
programs inspired from the model introduced in Section 3 of:
*Thomas Bøgholm, Henrik Kragh-Hansen, Petur Olsen, Bent Thomsen, Kim Guldstrand Larsen:
Model-based schedulability analysis of safety critical hard real-time Java programs.
JTRES 2008: 106-114*

- `scheduler.sh` is a timed automaton model of a scheduler and threads for schedulability
analysis. Schedulability is reduced to unreachability of locations Not_Schedulable of
the PeriodicThreads processes. The original model in the publication above uses stopwatches
to model preemption. In order to keep standard clocks, our model does not allow preemption.
Moreover, we have introduced multi-core scheduling to increase the level of concurrency in
the model. The model can easily be limited to a single-core by setting the appropriate
command-line parameter. The processes with a smaller indentifier have priority over the
processes with bigger identifiers. The offset, deadline and period of each thread can be
modified by setting the initial values of the corresponding variables of the PeriodicThread
processes.
Run `scheduler.sh` for help on how to build a TChecker model from the script.
