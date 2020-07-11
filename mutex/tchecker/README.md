# TChecker models of a mutual exclusion protocol

This directory contains TChecker models for a mutual exclusion protocol introduced
in Section 5 in:
*Henning Dierks:
Comparing model checking and logical reasoning for real-time systems. Formal Asp.
Comput. 16(2): 104-120 (2004)*

- `mutex.sh` is a timed automaton model of the mutual exclusion protocol introduced
in the article above. The model has been translated from the PLC automata in Figure 2 (A)
and Figure 4 (Ctrl) applying Definition 2.
Run `mutex.sh` for help on how to build a TChecker model from the script.
