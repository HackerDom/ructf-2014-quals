#!/usr/bin/env python2.7

"""
This script creates `video.avi` file with random noise images and puts `inner_image.png` in place defined 
by `moment_to_inner_image`. Inner image must have sizes `frame_width` x `frame_height`.
"""

### In minutes
moment_to_inner_image = 7

### Video parameters
fps = 24 
frame_width = 160
frame_height = 160
video_minutes = 60

### Number of frame 'ticks' for each image. Must be divider of fps
generate_new_frame_each = 8

### Other
log_process_each = 1000

import cv2
import cv2.cv as cv
import numpy
import random
import sys

def generate_noise_image(width, height):
  SIZE = 8
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

frames_count = int(video_minutes * 60 * fps)
inner_image_frame = int(moment_to_inner_image * 60 * fps)

image = generate_noise_image(frame_width, frame_height)
for frame in range(frames_count):
  if frame % generate_new_frame_each == 0:
    image = generate_noise_image(frame_width, frame_height)
  if frame == inner_image_frame:
    image = cv2.imread('inner_image.png')

  writer.write(image)

  if frame % log_process_each == 0:
    sys.stderr.write('Done %d/%d frames\n' % (frame, frames_count))

writer.release()