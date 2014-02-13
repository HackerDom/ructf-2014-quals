n = 10568714532453201263
R = PolynomialRing(IntegerModRing(n), 'x')
x = R.gen()

f1 = x^35 - 24654*(x^15) + 1
f2 = (x+1)^23 - 7254
if f2.degree() < f1.degree():
	print "f1 is bigger"
	f1 = f1 % f2
print f1.leading_coefficient()
print f1.coeffs()
a = 127847
a = inverse_mod(int(a), n)
f1 = a*f1
# yes, it's all that you need to know. sage is mix of python and math