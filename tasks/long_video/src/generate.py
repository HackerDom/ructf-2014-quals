#!/usr/bin/env python2.7

"""
This script creates `video.avi` file with random noise images and puts pieces of `inner_image.png` in places defined 
by `moments_to_inner_image`. Inner image must have sizes `frame_width` x `frame_height`.
"""

import random

### Video parameters
fps = 24 
fpm = 60.0 * fps
frame_width = 160
frame_height = 160
video_minutes = 60
SIZE = 8

### Number of frame 'ticks' for each image. Must be divider of fps
generate_new_frame_each = 8

### In minutes
moments_to_inner_image = sorted([random.randint(0, video_minutes * (fpm / generate_new_frame_each)) / (fpm / generate_new_frame_each) for x in range(SIZE * SIZE)])
print("Moments to insert inner image (in minutes): ", moments_to_inner_image)

### Other
log_process_each = 1000

import cv2
import cv2.cv as cv
import numpy
import random
import sys

def generate_noise_image(width, height):
  image = numpy.zeros((height, width, 3), numpy.uint8)

  init_color = random.randint(0, 50)
  image[:,:] = (init_color, ) * 3

  width_step = width // SIZE
  height_step = height // SIZE
  for i in range(SIZE):
    for j in range(SIZE):
      image[i * height_step: (i + 1) * height_step - 1, \
            j * width_step: (j + 1) * width_step - 1] = \
            (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))
  return image

is_color = 1
writer = cv2.VideoWriter("video.avi", cv.CV_FOURCC('F', 'M', 'P', '4'), fps, (frame_width, frame_height), is_color)

frames_count = int(video_minutes * fpm)
inner_image_frames = [int(x * fpm) for x in moments_to_inner_image]
inner_image = cv2.imread('inner_image.png')
inner_image_piece = 0

image = generate_noise_image(frame_width, frame_height)
for frame in range(frames_count):
  if frame % generate_new_frame_each == 0:
    image = generate_noise_image(frame_width, frame_height)
  if frame in inner_image_frames:
    #image = cv2.imread('inner_image.png')
    width_step = frame_width // SIZE
    height_step = frame_height // SIZE
    i = inner_image_piece // SIZE
    j = inner_image_piece % SIZE
    image[i * height_step: (i + 1) * height_step - 1, \
          j * width_step: (j + 1) * width_step - 1] = \
          inner_image[i * height_step: (i + 1) * height_step - 1, \
                      j * width_step: (j + 1) * width_step - 1]
    inner_image_piece += 1

  writer.write(image)

  if frame % log_process_each == 0:
    sys.stderr.write('Done %d/%d frames\n' % (frame, frames_count))

writer.release()