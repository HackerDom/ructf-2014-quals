#!/usr/env sage
load t0.sage
load b.py
r = gcd(f1, f2, n)
m = n - r.coeffs()[0]
print m
