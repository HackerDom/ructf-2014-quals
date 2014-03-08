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

import sys
sys.stdout.write(''.join([''.join([chr(c) for c in e]) for e in pixels]))
	 