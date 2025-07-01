#!/usr/bin/python3

import sys
import math


def bad(rs1, rs2):
    n = 0
    v = 0
    p = 1
    r = 0
    for i in reversed(range(0, len(rs2))):
        if rs2[i] == '0':
            imp = 0
        elif rs2[i] == '+':
            imp = 1
        else:
            imp = -1
        t = imp * (pow(3, p) - 1) / 2
        if (n == 4):
            n = 0
        v = v + t
        n = n + 1
        p = p + 1
    return v 

rs1 = sys.argv[1]
rs2 = sys.argv[2]
rd = bad(rs1, rs2)
print ("hello = {}".format(rd))


