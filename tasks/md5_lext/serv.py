#!/usr/bin/python
# checker
import sys
import socket
from hashlib import md5

password = "P@ssw0rd" # just pretend that you DON'T know this password,
#                       only it's length, which is 8
port = int(sys.argv[1])
s = socket.socket()
s.bind(('127.0.0.1',port))
s.listen(5)

while 1:
	c, a = s.accept()
	c.settimeout(30)
	try:
		buf = c.recv(4096)
		digest, msg = buf.split(" ", 1)
		if msg != 'my message' and digest == md5(password+msg).hexdigest():
			c.send("Message accepted: {}\n".format(msg))
		else:
			c.send("Wrong signature\n")
	except:
		pass
	finally:
		c.close()
