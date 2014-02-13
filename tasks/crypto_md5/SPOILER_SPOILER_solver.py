import python_md5
from hashlib import md5
import struct
import binascii
import socket
import sys

def determine_padding(length):
    # Length is in bytes:
    
    # Pad out to 56 mod 64
    index = int((length) & 0x3f)

    if index < 56:
        padLen = (56 - index)
    else:
        padLen = (120 - index)
    return python_md5.PADDING[:padLen]
    
def spoof_digest(originalDigest, originalLen, spoofMessage=""):
    # first decode digest back into state tuples
    state = python_md5.Decode(originalDigest, 16)
    
    length_in_bits = originalLen*8
    # Encode the original size modulo 64 into little-endian
    size_bits = struct.pack("<Q", originalLen*8)
    
    # Calculate the original padding
    padding = determine_padding(originalLen) + size_bits
    
    # Create an md5 object
    spoof = python_md5.md5()
    # Seed an initial state, based on original digest.
    spoof.state = state
    # Seed the count variable with the original length and the padding that we've added.
    spoof.count = length_in_bits + len(padding)*8
    
    # run an update with what will be appended.
    # MD5 will continue as if it had arrived at the 'state' in the normal fashion.
    spoof.update(spoofMessage)
    
    # We now have a digest of the original secret + message + some_padding
    return spoof.hexdigest()
    

def do_spoofing():
    knownMsg = "my message"
    knownMsgSignature = binascii.unhexlify('71061df348d5f5fa08a4ebcec51d7e06')
    appendedMsg = "my message extension"
    secret_len = 8

    size_bits = struct.pack("<Q", (len(knownMsg) + secret_len)*8)
    padding = determine_padding(len(knownMsg)+secret_len) + size_bits
    
    spoofSignature = spoof_digest(knownMsgSignature, len(knownMsg)+secret_len, appendedMsg)
    c = socket.socket()
    c.connect(('127.0.0.1', int(sys.argv[1])))
    c.send("{} {}".format(spoofSignature, knownMsg+padding+appendedMsg))
    buf = c.recv(1024)
    print buf
    
    
if __name__=="__main__":
    do_spoofing()