import sys
import argparse
from io import StringIO
from data import *

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
    ta.dump()

if __name__ == "__main__":
    main()
