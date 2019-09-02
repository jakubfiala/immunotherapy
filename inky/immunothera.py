from inky import InkyWHAT
from PIL import Image, ImageFont, ImageDraw
from time import sleep
import json

inky_display = InkyWHAT("red")
inky_display.set_border(inky_display.WHITE)

pal_img = Image.new("P", (1, 1))
pal_img.putpalette((255, 255, 255, 0, 0, 0, 255, 0, 0) + (0, 0, 0) * 252)

config = json.load(open('./config.json', 'r'))

IMAGES_PER_SECTION = config['images_per_section']
N_SECTIONS = config['n_sections']
IMAGE_DURATION = config['image_duration']

section_index = 0
image_index = 0

def check_section_changed(cur_section_index, config):
  section_file = open(config['section_file'], 'r')
  new_section_index = int(section_file.read())

  if cur_section_index != new_section_index:
    return new_section_index

  return None

while True:
  new_section = check_section_changed(section_index, config)
  if new_section:
    section_index = new_section
    image_index = 0

  print("Displaying image {} of section {}".format(image_index, section_index))
  img = Image.open("./processed/{}/{:04d}.png".format(section_index + 1,
                                                      section_index * IMAGES_PER_SECTION + image_index + 1))
  img = img.convert("RGB").quantize(palette=pal_img)

  inky_display.set_image(img)
  inky_display.show()

  image_index = (image_index + 1) % IMAGES_PER_SECTION

  if image_index == 0:
    section_index = (section_index + 1) % N_SECTIONS

  sleep(IMAGE_DURATION)

