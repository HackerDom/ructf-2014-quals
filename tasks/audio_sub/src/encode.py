import wave
wav = wave.open("HPlittle.wav", mode="r")
(nchannels, sampwidth, framerate, nframes, comptype, compname) = wav.getparams()
#print(nchannels, sampwidth, framerate, nframes, comptype, compname)
left = []
rigth = []
count = 0

wavOut = wave.open("Task.wav", mode = "w")
wavOut.setparams(wav.getparams())


a_bits = []

f = open('answer.wav', 'rb+') 

c = f.read(1)

while len(c) > 0:
	d = 1
	d = d << 7       
	for i in range(8):   
		if ord(c) & d == 0:
			a_bits.append(0)
		else:
			a_bits.append(1)
		d = d >> 1
	c = f.read(1)
                  
for i in range(nframes):
	content = wav.readframes(1)
	left.append(content[:2])
	rigth.append(content[2:])
	if(left[i] != rigth[i]):
		count = count + 1	
	if(ord(left[i][1]) == 255):
		left[i] = left[i][0] + chr(254)
	if i < len(a_bits):
		wavOut.writeframes(left[i] + left[i][0] + chr(ord(left[i][1]) + a_bits[i]))
	else:
		wavOut.writeframes(left[i] + left[i])

wavOut.close()



	

