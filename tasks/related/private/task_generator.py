#!/usr/bin/python
from Crypto.PublicKey import RSA

def str_to_num(s):
	n = 0
	while s != '':
		n = (n<<8) + ord(s[0])
		s = s[1:]
	return n

def num_to_str(n):
	s = ''
	while n > 0:
		s = chr(n&0xff) + s
		n = (n>>8)
	return s

def main():
	exponent = 12289
	K = RSA.generate(1024, e=exponent)
	pub = open("key.pub", 'w')
	pub.write(K.publickey().exportKey())
	pub.close()
	m = 'The key is ructf_StandBackImGonnaDoMath'
	m1 = m + '. Alex'
	m2 = m + '. Jane'
	n1 = str_to_num(m1)
	n2 = str_to_num(m2)
	c1, = K.encrypt(n1, 1)
	c2, = K.encrypt(n2, 1)
	print('R = PolynomialRing(IntegerModRing({}), \'x\')'.format(K.n))
	print('x = R.gen()\nn = {}\nf1 = x^{} - {}\nf2 = (x+{})^{} - {}'.format(K.n,
		exponent, c1, n2-n1, exponent, c2))
	#print('Crypto-system params:\nn = {}\ne = {}\nCryptogramms:\nc1 = {}'
	#	'\nc2 = {}'.format(K.n, K.e, c1, c2))
	#print('Secret messages:\nm1 = {}'
	#	'\nm2 = {}'.format(m1, m2))
	#print('m1 = {}, m2 = {}, m1-m2 = {}'.format(n1, n2, n1-n2))

main()
