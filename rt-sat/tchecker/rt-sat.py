import sys
import random
import argparse
from itertools import chain
from io import StringIO
from contextlib import redirect_stdout

# Simple examples:

g1 = [(0, 100, 120, False, 2, [1, 2]),
    (1, 50, 150, False, 1, [3, 4]),
    (2, 50, 150, False, 1, [3, 4])] # sat

g2 = [(0, 100, 120, False, 2, [1, 2]),
    (1, 50, 150, False, 1, [3, 4]),
    (2, 50, 150, True, 1, [3, 4])] # unsat
g3 = [(0, False, 2, 100, 120, [1, 2])] # sat

# From CAV19

unsat1 = [
    (0, 100, 200, False, 2, [3,4]),
    (3, 150, 300, False, 1, [1,2]),
    (4, 100, 150, True, 1, [3]),
    (1, 50, 100, False, 2, [6, 7, 8, 9]),
    (2, 80, 100, False, 3, [0, 6, 7, 8]),
]

unsat2 = [
    (0, 100, 200, False, 2, [4,5]),
    (4, 150, 300, False, 2, [7,3]),
    (5, 100, 150, True, 1, [7]),
    (3, 50, 100, False, 1, [1, 2]),
    (1, 80, 100, False, 3, [6, 7, 8, 9]),
    (2, 90, 110, False, 2, [1, 6, 7, 8]),
]

unsat3 = [
    (1, 80, 160, False, 1, [6,7]),
    (2, 50, 150, False, 2, [1, 8]),
    (3, 50, 200, False, 2, [1,2,9]),
    (4, 80, 100, False, 1, [3]),
    (0, 100, 150, False, 2, [3,4])
]


sat1 = [
    (1, 50, 150, False, 3, [4,5,6,7]),
    (2, 50, 100, False, 2, [1, 4,5,6]),
    (3, 100, 120, False, 1, [1,2]),
    (0, 150, 200, False, 2, [4,5])
]


sat2 = [
    (1, 50, 150, False, 1, [6,7]),
    (2, 50, 100, False, 2, [1,8]),
    (3, 100, 120, False, 2, [1,2, 9]),
    (4, 80, 120, False, 2, [3, 6, 7, 8]),
    (0, 150, 200, False, 2, [3,4])
]

sat3 = [
    (9, 50, 100, False, 4, [0, 1, 2, 3]),
    (10, 50, 80, False, 4, [9, 0, 1, 2, 3, 4]),
    (11, 50, 100, False, 3, [9, 10, 4, 5, 6]),
    (12, 50, 100, False, 4, [9, 11, 3, 4, 5]),
    (13, 100, 120, False, 1, [11,12]),
    (14, 80, 120, False, 2, [13, 10]),
    (15, 50, 100, True, 1, [14]),
    (0, 150, 200, False, 1, [14,15])
]


sat_benchmarks = [g1, sat1, sat2, sat3]
unsat_benchmarks = [g2,g3,unsat1, unsat2, unsat3]
all_benchmarks = sat_benchmarks + unsat_benchmarks
class TAWRITER:
    def __init__(self, graph, bound=None):
        self.graph = graph
        self.bound = bound

    def threshold_guard(self, threshold, links):
        welldefined = " && ".join(map(lambda x: "out{0} < 2".format(x), links))
        positive = " + ".join(map(lambda x: "out{0}".format(x), links)) + " >= " + str(threshold)
        negative = " + ".join(map(lambda x: "out{0}".format(x), links)) + " < " + str(threshold)
        return (welldefined,positive,negative)

    def dump(self):
        graph = self.graph
        fout = StringIO()

        gate_identifiers = set([])
        input_identifiers = set([])

        # All undefined indices are inputs
        for node in graph:
            gate_identifiers.add(node[0])
        for node in graph:
            links = node[5]
            for x in links:
                if not (x in gate_identifiers):
                    input_identifiers.add(x)

        if not (0 in gate_identifiers):
            raise "A node with identifier 0 must be given"

        print("system:async_gates", file=fout)
        print("event:idle", file=fout)
        print("event:set", file=fout)
        print("event:done", file=fout)
        if self.bound != None:
            print("clock:1:t", file=fout)

        for id in gate_identifiers:
            print("int:1:0:2:2:out{0}".format(id), file=fout)
            print("event:up{0}".format(id), file=fout)
            print("event:down{0}".format(id), file=fout)
        for id in input_identifiers:
            print("int:1:0:2:2:out{0}".format(id), file=fout)

        for node in graph:
            #(id, neg, th, period, duration, links) = node
            (id, period, duration, neg, th, links) = node
            print("\nprocess:Node{0}".format(id), file=fout)
            print("clock:1:x{0}".format(id), file=fout)
            print("location:Node{0}:Down{{initial::invariant:x{0}<={1}}}".format(id,period), file=fout)
            print("location:Node{0}:Up{{invariant:x{0}<={1}}}".format(id,duration), file=fout)
            (welldefined, positive, negative) = self.threshold_guard(th, links)
            if neg:
                tmp = negative
                negative = positive
                positive = tmp
            for i in links:
                print("edge:Node{0}:Down:Down:idle{{provided:x{0}=={1} && out{2} == 2: do : x{0} = 0}}".format(id, period, i), file=fout)
            print("edge:Node{0}:Down:Up:up{0}{{provided:x{0}=={1} && {2} && {3} : do : out{0} = 0; x{0} = 0}}".format(id,period, welldefined, negative), file=fout)
            print("edge:Node{0}:Down:Up:up{0}{{provided:x{0}=={1} && {2} && {3}: do : out{0} = 1; x{0} = 0}}".format(id,period, welldefined, positive), file=fout)
            print("edge:Node{0}:Up:Down:down{0}{{provided:x{0}<={1} : do : out{0} = 2; x{0} = 0}}".format(id,duration), file=fout)

            if id == 0:
                print("location:Node{0}:Done{{labels:sat}}".format(id), file=fout)
                g = "out0 == 1 "
                if self.bound != None:
                    g = g + "&& t <= " + str(self.bound)
                print("edge:Node{0}:Up:Done:done{{provided:{1}}}".format(id, g), file=fout)
            # print("edge:Node{0}:Up:Down:down{0}{{initial::invariant:x{0}<={1}}}".format(id,duration), file=fout)

        print("\nprocess:Input", file=fout)
        print("location:Input:init{committed::initial:}", file=fout)
        prev = "init"
        for input in input_identifiers:
            print("location:Input:In{0}{{committed:}}".format(input), file=fout)
            print("edge:Input:{0}:In{1}:set{{do:out{1} = 1}}".format(prev,input), file=fout)
            print("edge:Input:{0}:In{1}:set{{do:out{1} = 0}}".format(prev,input), file=fout)
            prev = "In{0}".format(input)
        print("location:Input:Done{}", file=fout)
        print("edge:Input:{0}:Done:set{{}}".format(prev), file=fout)
        print(fout.getvalue())

def main():
    parser = argparse.ArgumentParser(description="Real-Time SAT benchmarks generator")
    parser.add_argument("benchmark_class", metavar="class", type=str,
                        help="benchmark class: sat or unsat")
    parser.add_argument("number", metavar="n", type=int,
                        help="benchmark number in the given class")
    parser.add_argument("-b", "--bound", type=int,
                        help=("Time bound before node 0 should become true. Note that a satisfiable instance can become unsatisfiable due to the bound."))

    args = parser.parse_args()
    if args.benchmark_class == "sat":
        benchmarks = sat_benchmarks
    elif args.benchmark_class == "unsat":
        benchmarks = unsat_benchmarks
    else:
        raise Exception("Unrecognized benchmark class")
    if args.number >= len(sat_benchmarks):
        raise Exception("There is no benchmark number " + str(args.number) + " in the class " + args.benchmark_class)
    ta = TAWRITER(sat_benchmarks[args.number], args.bound)
    #with open(args.benchmark_class  + str(args.number) + ".txt", "w") as f:
    #    with redirect_stdout(f):
    ta.dump()

if __name__ == "__main__":
    main()
