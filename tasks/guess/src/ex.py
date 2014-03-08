pixels = [
	[0x3f, 0x3f, 0x3f, 0x3f, 0x3f, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x3f, 0x3f, 0x3f, 0x3f, 0x3f],
	[0x3f, 0x3f, 0x3f, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x3f, 0x3f, 0x3f],
	[0x3f, 0x3f, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x3f, 0x3f],
	[0x3f, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x3f],
	[0x3f, 0x24, 0x24, 0x24, 0x24, 0x27, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x3f],
	[0x24, 0x24, 0x24, 0x24, 0x27, 0x3f, 0x3f, 0x3f, 0x3f, 0x3f, 0x3f, 0x27, 0x24, 0x24, 0x24, 0x24],
	[0x24, 0x24, 0x24, 0x24, 0x27, 0x3f, 0x27, 0x24, 0x27, 0x3f, 0x3f, 0x24, 0x24, 0x24, 0x24, 0x24],
	[0x24, 0x24, 0x24, 0x24, 0x27, 0x27, 0x27, 0x27, 0x27, 0x3f, 0x3f, 0x24, 0x24, 0x24, 0x24, 0x24],
	[0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x27, 0x27, 0x3f, 0x3f, 0x24, 0x24, 0x24, 0x24, 0x24],
	[0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x27, 0x3f, 0x3c, 0x24, 0x24, 0x24, 0x24, 0x24],
	[0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x27, 0x3f, 0x3c, 0x24, 0x24, 0x24, 0x24, 0x24],
	[0x3f, 0x24, 0x24, 0x24, 0x27, 0x27, 0x27, 0x24, 0x27, 0x3f, 0x3c, 0x24, 0x24, 0x24, 0x24, 0x3f],
	[0x3f, 0x24, 0x24, 0x24, 0x24, 0x24, 0x27, 0x27, 0x27, 0x24, 0x24, 0x27, 0x24, 0x24, 0x24, 0x3f],
	[0x3f, 0x3f, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x3f, 0x3f],
	[0x3f, 0x3f, 0x3f, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x3f, 0x3f, 0x3f],
	[0x3f, 0x3f, 0x3f, 0x3f, 0x3f, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x3f, 0x3f, 0x3f, 0x3f, 0x3f],
]
target = [
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
	[0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11, 0x32, 0x11],
]

import sys

a1 = [c for e in pixels  for c in e]
a2 = [c for e in target  for c in e]
sys.stdout.write(''.join([chr(a1[i] ^ a2[i]) for i in range(len(a1))]))
