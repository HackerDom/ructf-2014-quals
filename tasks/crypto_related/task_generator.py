#!/usr/bin/python

from Crypto.PublicKey import RSA
from random import randint

def main():
	K = RSA.generate(1024, e=23)
	m1 = randint(2, 10**20)
	m2 = m1 + 1
	c1, = K.encrypt(m1, 1)
	c2, = K.encrypt(m2, 1)
	print ('Crypto-system params:\nn = {}\ne = {}\nCryptogramms:\nc1 = {}'
		'\nc2 = {}'.format(K.n, K.e, c1, c2))
	print ('Secret messages:\nm1 = {}'
		'\nm2 = {}'.format(m1, m2))

main()