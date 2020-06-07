# TChecker models of the FDDI protocol

This directory contains TChecker models for the FDDI protocol, inspired from:
*C. Daws, A. Oliveiro, S. Tripakis, and S. Yovine. The tool Kronos, Hybrid 
Systems III, 1996*.

- `fddi.sh` has been obtained from the model in the paper cited above by 
transforming all clock resets into resets to 0, at the cost of extra clocks and
locations. Run `fddi.sh` for help on how to build a TChecker model from the 
script.