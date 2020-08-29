#create a sprite sheet from the "degrees" folders.


from PIL import Image
import os
import sys
import glob


folders = ['0','45','90','135','180','225','270','315']
imagesMap = []
images = []
image_widht = 0 #cell size
image_height = 0
master_width = 0 #sprite sheet final size
master_height = 0

#give a name to this spritesheet
sprite_name = os.path.dirname(os.path.realpath(__file__))
sprite_name = sprite_name.split('\\') [-1]

for folder in folders:
	imagesMap = imagesMap + glob.glob(folder + '/*.png')
	
print('==> %d images to be merged.' % len(imagesMap))

for imageMap in imagesMap:
	images.append(Image.open(imageMap))

image_widht = images[0].size[0]
image_height = images[0].size[0]

print('==> Cells will be ' + str(image_widht) + 'x' + str(image_height) + '.')

master_width = len(glob.glob('0/*.png') * image_widht)
master_height = len(folders) * image_height

print('==> Sprite sheet size will be ' + str(master_width) + 'x' + str(master_height) + '.')

print('\n Creating image...')

final_image = Image.new(
	mode='RGBA',
	size=(master_width, master_height),
	color=(0,0,0,0))  # fully transparent

x_pos = 0
y_pos = 0

i= 0
for image in images:
	if i % len(glob.glob('0/*.png')) == 0 and i != 0:
		x_pos = 0
		y_pos += image_height
		i = 0
	else:
		x_pos = i * image_widht
		
	#print(x_pos,y_pos)
	
	final_image.paste(image,(x_pos,y_pos))
	
	i += 1

print('==> Saving sprite sheet...')


final_image.save(sprite_name + '.png')

print('==> Sprite sheet saved.')







