import wave
wav = wave.open("Task.wav", mode="r")
(nchannels, sampwidth, framerate, nframes, comptype, compname) = wav.getparams()

left = []
rigth = []
count = 0


a_bits = []           

for i in range(nframes):
	content = wav.readframes(1)
	left.append(content[:2])
	rigth.append(content[2:])
	if(left[i] != rigth[i]):
		a_bits.append(1)
	else: 
		a_bits.append(0)
                                    
f = open('check.wav', 'wb+') 

k = 0
p = 7
for i in a_bits:
	k = k | (i<<p)
	p -= 1
	if p == -1:
		f.write(chr(k))
		p = 7
		k = 0
		



	

