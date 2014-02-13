#!/usr/bin/python
from ctypes import *
import struct
import sys


def encrypt_cast(m, key):
	cast256 = cdll.LoadLibrary(sys.argv[1]) 	#absolute path here
	key_len = len(key)
	if key_len > 32: 	# overflow protection
		key_len = 32
	if key_len < 16: 	# idiot protection
		key = key + "\x00"*(16 - key_len)
		key_len = 16
	c_key = (c_ulong * (key_len // 4))()
	for i in xrange(key_len // 4):
		c_key[i] = c_ulong(struct.unpack("<L", key[i*4 : i*4 + 4])[0])
	cast256.set_key(c_key, c_ulong(key_len*8)) 	 	# shoud be in bits
	res = ''
	c_inblock = (c_ulong * 4)()
	c_outblock = (c_ulong * 4)()
	rem = len(m) % 16
	if rem != 0:
		m += "\x00"*(16-rem)
	for i in xrange(0, len(m), 16):
		for j in xrange(4):
			c_inblock[j] = c_ulong(struct.unpack("<L", m[i + j*4 : i + j*4 + 4])[0])
		cast256.encrypt(c_inblock, c_outblock)
		t = ''
		for j in xrange(4):
			t+= struct.pack("<L", c_outblock[j])
		res += t
	return res

def decrypt_cast(c, key):
	cast256 = cdll.LoadLibrary(sys.argv[1]) 	#absolute path here
	key_len = len(key)
	if key_len > 32: 	# overflow protection
		key_len = 32
	if key_len < 16: 	# idiot protection
		key = key + "\x00"*(16 - key_len)
		key_len = 16
	c_key = (c_ulong * (key_len // 4))()
	for i in xrange(key_len // 4):
		c_key[i] = c_ulong(struct.unpack("<L", key[i*4 : i*4 + 4])[0])
	cast256.set_key(c_key, c_ulong(key_len*8)) 	 	# shoud be in bits
	res = ''
	c_inblock = (c_ulong * 4)()
	c_outblock = (c_ulong * 4)()
	rem = len(c) % 16
	if rem != 0:
		print "Corrupted cryptogram"
		return "Corrupted cryptogram"
	for i in xrange(0, len(c), 16):
		for j in xrange(4):
			c_inblock[j] = c_ulong(struct.unpack("<L", c[i + j*4 : i + j*4 + 4])[0])
		cast256.decrypt(c_inblock, c_outblock)
		t = ''
		for j in xrange(4):
			t+= struct.pack("<L", c_outblock[j])
		res += t
	return res


m = 'my phrase crypto, blah-blah'
key = '0123456789abcdef'
c = encrypt_cast(m, key)
print c.encode('hex')
m1 = decrypt_cast(c, key)
print m1
