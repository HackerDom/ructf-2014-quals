def gcd(f1, f2, n):
	if f2.degree() > f1.degree():
		f1, f2 = f2, f1
	if f2.degree() == 0:
		return f2
	while f2.degree() > 0:
		f1 = f1 % f2
		a = f1.leading_coefficient()
		if a != 1 and a != 0:
			a = inverse_mod(int(a), n)
			f1 = a * f1
		f1, f2 = f2, f1
	print f1
	print f2
	return f1
