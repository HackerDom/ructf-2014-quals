import string
import numpy
from scipy import misc, ndimage
import sys
x = 0
g = 0
q = 0
a = 1
b = 1
Ha = 2
Hb = 2
hi = 1
nu = 2
MOD_N = 255

def RotL(value, shift):
    return ((value << shift) | (value >> (8 - shift))) & MOD_N

def random_number(n):
	global x,g,q,a,b,Ha,Hb,hi,nu,MOD_N
	z = g
	r = q
	q = z ^ RotL(x, hi)
	g = r ^ RotL(z, nu)
	x = (a*z + b) & MOD_N
	a += Ha
	b += Hb
	return r

def fill_random(w,h):
	count = w * h
	result = []
	for i in xrange(count):
		result.append(random_number(256))
	return result

def encode_value(n):
	assert n < 10
	return 25 * n

def save_screen(screen, w, h):
	result = numpy.ndarray(shape=(h,w,3), dtype=numpy.uint8)
	r = map(lambda x: int((x >> 5) * 255 / 7.0), screen)
	g = map(lambda x: int(((x >> 2) & 7) * 255 / 7.0), screen)
	b = map(lambda x: int((x & 3) * 255 / 3.0), screen)
	i = 0
	for y in xrange(h):
		for x in xrange(w):
			result[y, x][0] = r[i]
			result[y, x][1] = g[i]
			result[y, x][2] = b[i]
			i += 1
	misc.imsave("avr_test.png", result)


def main():
	data = sys.argv[1]
	screen = fill_random(132, 176)
	for i, d in enumerate(data):
		assert d in string.digits
		screen[1 + (i * 232) % 23231] = encode_value(int(d))
	screen[0] = encode_value(len(data))
	open('avr_test.dat', 'wb').write(''.join(map(chr,screen)))
	save_screen(screen, 132, 176)

if __name__ == '__main__':
	main()