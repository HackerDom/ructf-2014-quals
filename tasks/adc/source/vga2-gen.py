import sys
import os
from PIL import Image, ImageDraw
import random

video_modes = {}
video_modes[(640,480)] = (640, 480, 16, 10, 96, 2, 48, 33)
video_modes[(800,600)] = (800, 600, 40, 1, 128, 4, 88, 23)
video_modes[(1024,768)] = (1024, 768, 24, 3, 136, 6, 160, 29)
video_modes[(1280,960)] = (1280, 960, 80, 1, 136, 3, 216, 30)
video_modes[(1440,900)] = (1440, 900, 80, 1, 152, 3, 232, 28)
video_modes[(1280,1024)] = (1280, 1024, 48, 1, 112, 3, 248, 38)
video_modes[(1600,1200)] = (1600, 1200, 64, 1, 192, 3, 304, 46)
video_modes[(1920,1200)] = (1920, 1200, 128, 1, 208, 3, 336, 38)
video_modes[(1280,720)] = (1280, 720, 110, 5, 40, 5, 220, 20)
video_modes[(1920,1080)] = (1920, 1080, 88, 4, 44, 5, 148, 36)

class VideoMode:
	def __init__(self, c):
		self.VISIBLE_W, self.VISIBLE_H, self.HFRONT_PORCH, self.VFRONT_PORCH, self.HSYNC, self.VSYNC, self.HBACK_PORCH, self.VBACK_PORCH = c

	def totalLines(self):
		return self.VISIBLE_H + self.VFRONT_PORCH + self.VSYNC + self.VBACK_PORCH

	def totalPixels(self):
		return self.VISIBLE_W + self.HFRONT_PORCH + self.HSYNC + self.HBACK_PORCH

	def getClock(self):
		return self.totalLines() * self.totalPixels()

	def getLine(self, i):
		return i / self.totalPixels()

	def getPixel(self, i):
		return i % self.totalPixels()

	def inVsync(self, i):
		return self.getLine(i) < self.VSYNC

	def inHsync(self, i):
		return self.getPixel(i) < self.HSYNC

	def getRelPos(self, i):
		x = self.getPixel(i) - self.HSYNC - self.HBACK_PORCH
		y = self.getLine(i) - self.VSYNC - self.VBACK_PORCH
		if x < 0 or x >= self.VISIBLE_W:
			x = None
		if y < 0 or y >= self.VISIBLE_H:
			y = None
		return (x,y)

def getChannel(n, channel):
	return n[channel]

def pixel_stream(i,vm,pix,channel):
	pixel, line = vm.getRelPos(i)
	if not line or not pixel:
		# TODO: can return invalid data here to obscure
		return 0
	return getChannel(pix[pixel, line], channel)

def vga_streams(path, vm):
	im = Image.open(path)
	w, h = im.size
	if w != vm.VISIBLE_W or h != vm.VISIBLE_H:
		raise Exception
	clock = vm.getClock()
	vga2 = []
	pix = im.load()
	for i in xrange(clock):
		r = pixel_stream(i,vm,pix,0)
		g = pixel_stream(i,vm,pix,1)
		b = pixel_stream(i,vm,pix,2)
		vga2.append((r+g+b)/3)
	return vga2

if len(sys.argv) < 4:
	print("Usage: %s picture <w> <h>" % sys.argv[0])
	exit(1)

video_mode = VideoMode(video_modes[(int(sys.argv[2]), int(sys.argv[3]))])
streams = vga_streams(sys.argv[1], video_mode)
print(len(streams))
print(streams)
