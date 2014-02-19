Author: Bay
Answer: ILoveToHackTLS
Task description: Just hack TLS
Files: dump.pcap
Difficulty: 400-500

There is a dump of ssh session in attached file, the goal is to decrypt it.
Solution:
1) open the file in wireshark
2) look at the tip in client random value: DiHe 1337 1337 1337 1337 1337 13
3) the secret value for Diffie-Hellman on the client is 1337, so it is possible 
to reconstruct all tls key generation steps and obtain the pair of keys for
symmetric encryption
4) decrypt traffic, look on the http communication with onetimesecret.com 
service and find the key in it.
