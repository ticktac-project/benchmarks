# UPPAAL models of the CSMA/CD protocol

This directory contains UPPAAL models for the CSMA/CD protocol, inspired from
the first timed automata model introduced in:
*Stavros Tripakis, Sergio Yovine: Analysis of Timed Systems Using 
Time-Abstracting Bisimulations. Formal Methods Syst. Des. 18(1): 25-68 (2001).*

- `csmacd.sh` generates a UPPAAL model inspired from the publication above. 
Contrasting with the publication above, collisions are implemented as a sequence
of synchronizations between the bus and each station, instead of one global
synchronization of all the processes. This is because UPPAAL only handles 
handshaking synchronizations between two processes. Notice that there is a missing transition in this model that prevents full communication once 
a collision occured. Run `csmacd.sh` for help on how to build a model from the
script.

- `csmacd-fixed.sh` generates a UPPAAL model that fixes the issue mentionned 
above (see *Frédéric Herbreteau, B. Srivathsan, Thanh-Tung Tran, Igor 
Walukiewicz: Why Liveness for Timed Automata Is Hard, and What We Can Do About 
It. FSTTCS 2016: 48:1-48:14*). Run `csmacd-fixed.sh` for help on how to build a 
model from the script.
