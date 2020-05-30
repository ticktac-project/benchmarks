#!/bin/sh

function usage() {
    echo "Usage: $0 format class";
    echo "       where format is uppaal or tchecker";
    echo "       and class is sat or unsat";
}

if [ $# -eq 2 ]; then
    format=$1
    class=$2
    if [ $format != "uppaal" ] && [ $format != "tchecker" ]; then
       usage
       exit 1
    fi
    if [ $class != "sat" ] && [ $class != "unsat" ]; then
       usage
       exit 1
    fi
else
    usage
    exit 1
fi

if [ $format == "uppaal" ]; then
    ext="xml"
else
    ext="txt"
fi


if [ $class == "sat" ]; then
   python3 rt-sat-$format.py sat 0 > g0_nobound_sat.$ext
   python3 rt-sat-$format.py sat 1 > g1_nobound_sat.$ext
   python3 rt-sat-$format.py sat 2 > g2_nobound_sat.$ext
   python3 rt-sat-$format.py sat 3 > g3_nobound_sat.$ext
   python3 rt-sat-$format.py sat 0 -b 150 > g0_150_sat.$ext
   python3 rt-sat-$format.py sat 1 -b 150 > g1_150_sat.$ext
   python3 rt-sat-$format.py sat 2 -b 300 > g2_300_sat.$ext
   python3 rt-sat-$format.py sat 3 -b 300 > g3_300_sat.$ext
fi
if [ $class == "unsat" ]; then
    python3 rt-sat-$format.py unsat 0 > h0_nobound_unsat.$ext
    python3 rt-sat-$format.py unsat 1 > h1_nobound_unsat.$ext
    python3 rt-sat-$format.py unsat 2 > h2_nobound_unsat.$ext
    python3 rt-sat-$format.py unsat 3 > h3_nobound_unsat.$ext
    python3 rt-sat-$format.py sat 0 -b 100 > g0_100_unsat.$ext
    python3 rt-sat-$format.py sat 1 -b 100 > g1_100_unsat.$ext
    python3 rt-sat-$format.py sat 2 -b 200 > g2_200_unsat.$ext
#
fi
