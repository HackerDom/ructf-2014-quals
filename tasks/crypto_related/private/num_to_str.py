import sys

def num_to_str(n):
	s = ''
	while n > 0:
		s = chr(n&0xff) + s
		n = (n>>8)
	return s

if __name__ == '__main__':
	n = int(sys.argv[1])
	print num_to_str(n)
