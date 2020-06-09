import sys
import argparse
from io import StringIO
from data import *

class TAWRITER:
    def __init__(self, graph, bound=None):
        self.graph = graph
        self.bound = bound

    def threshold_guard(self, threshold, links):
        welldefined = " &amp;&amp; ".join(map(lambda x: "out{0} &lt; 2".format(x), links))
        positive = " + ".join(map(lambda x: "out{0}".format(x), links)) + " &gt;= " + str(threshold)
        negative = " + ".join(map(lambda x: "out{0}".format(x), links)) + " &lt; " + str(threshold)
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

        print("<nta><declaration>",file=fout)
        if self.bound != None:
            print("clock t;", file=fout)

        for id in gate_identifiers:
            print("int[0,2] out{0} = 2;".format(id), file=fout)
        for id in input_identifiers:
            print("int[0,2] out{0} = 2;".format(id), file=fout)

        print("</declaration>",file=fout)

        for node in graph:
            (id, period, duration, neg, th, links) = node
            print("<template><name>Node{0}</name>".format(id),file=fout)
            print("<declaration>clock x{0};</declaration>".format(id), file=fout)
            print("<location id=\"Down{0}\"><name>Down</name><label kind=\"invariant\">x{0} &lt;= {1}</label></location>".format(id, period), file=fout)

            print("<location id=\"Up{0}\"><name>Up</name><label kind=\"invariant\">x{0} &lt;= {1}</label></location>".format(id,duration),file=fout)

            if id == 0:
                print("<location id=\"Done{0}\"><name>Done</name></location>".format(id),file=fout)

            print("<init ref=\"Down{0}\"/>".format(id), file=fout)

            (welldefined, positive, negative) = self.threshold_guard(th, links)
            if neg:
                tmp = negative
                negative = positive
                positive = tmp
            for i in links:
                print("<transition>",file=fout)
                print("<source ref=\"Down{0}\"/><target ref=\"Down{0}\"/>".format(id),file=fout)
                print("<label kind=\"guard\">x{0} == {1} &amp;&amp; out{2} == 2</label>".format(id,period,i),file=fout)
                print("<label kind=\"assignment\">x{0} = 0</label>".format(id),file=fout)
                print("</transition>",file=fout)

            print("<transition>",file=fout)
            print("<source ref=\"Down{0}\"/><target ref=\"Up{0}\"/>".format(id),file=fout)
            print("<label kind=\"guard\">x{0} == {1} &amp;&amp; {2} &amp;&amp; {3}</label>".format(id,period,welldefined,negative),file=fout)
            print("<label kind=\"assignment\">out{0} = 0, x{0} = 0</label>".format(id),file=fout)
            print("</transition>",file=fout)

            print("<transition>",file=fout)
            print("<source ref=\"Down{0}\"/><target ref=\"Up{0}\"/>".format(id),file=fout)
            print("<label kind=\"guard\">x{0} == {1} &amp;&amp; {2} &amp;&amp; {3}</label>".format(id,period,welldefined,positive),file=fout)
            print("<label kind=\"assignment\">out{0} = 1, x{0} = 0</label>".format(id),file=fout)
            print("</transition>",file=fout)


            print("<transition>",file=fout)
            print("<source ref=\"Up{0}\"/><target ref=\"Down{0}\"/>".format(id),file=fout)
            print("<label kind=\"guard\">x{0} &lt;= {1}</label>".format(id,duration),file=fout)
            print("<label kind=\"assignment\">out{0} = 2, x{0} = 0</label>".format(id),file=fout)
            print("</transition>",file=fout)

            if id == 0:
                g = "out0 == 1 "
                if self.bound != None:
                    g = g + "&amp;&amp; t &lt;= " + str(self.bound)
                print("<transition>",file=fout)
                print("<source ref=\"Up{0}\"/><target ref=\"Done{0}\"/>".format(id),file=fout)
                print("<label kind=\"guard\">{0}</label>".format(g),file=fout)
                print("</transition>",file=fout)
            print("</template>",file=fout)

        print("<template><name>Input</name>",file=fout)
        print("<location id=\"init\"><name>input_init</name><committed/></location>",file=fout)

        for input in input_identifiers:
            print("<location id=\"In{0}\"><name>In{0}</name><committed/></location>".format(input), file=fout)
        print("<location id=\"input_done\"></location>",file=fout)
        print("<init ref=\"init\"/>",file=fout)

        prev = "init"
        for input in input_identifiers:
            print("<transition><source ref=\"{0}\"/><target ref=\"In{1}\"/><label kind=\"assignment\">out{1} = 1</label></transition>".format(prev,input),file=fout)
            print("<transition><source ref=\"{0}\"/><target ref=\"In{1}\"/><label kind=\"assignment\">out{1} = 0</label></transition>".format(prev,input),file=fout)
            prev = "In{0}".format(input)
        print("<transition><source ref=\"{0}\"/><target ref=\"input_done\"/></transition>".format(prev),file=fout)

        print("</template>",file=fout)

        print("<instantiation></instantiation><system>",file=fout)
        print("system Input, " +  ", ".join(map(lambda node: "Node"+str(node[0]), graph)) + ";",file=fout)
        print("</system>",file=fout)
        print("</nta>",file=fout)
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
    if args.number >= len(benchmarks):
        raise Exception("There is no benchmark number " + str(args.number) + " in the class " + args.benchmark_class)
    ta = TAWRITER(benchmarks[args.number], args.bound)
    ta.dump()

if __name__ == "__main__":
    main()
