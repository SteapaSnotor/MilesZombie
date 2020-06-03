from PIL import Image
import os
import sys

shadow_folder = 'shadowed'
normal_textures = []
shadow_textures = []

#get normal textures
for texture in os.listdir():
	if texture.find('png') == -1: continue
	normal_textures.append(texture)

#get shadow textures
for texture in os.listdir(shadow_folder):
	if texture.find('png') == -1: continue
	shadow_textures.append(texture)

#join the shadows
id = 0
for texture in normal_textures:
	
	back = Image.open(shadow_folder + '//' + shadow_textures[id])
	front = Image.open(texture)
	
	img_info = front.info
	Image.alpha_composite(back,front).save(texture,**img_info)
	
	id += 1 


#background = Image.open("RenderTest2.png")
#foreground = Image.open("RenderTest.png")

#img_info = background.info

#Image.alpha_composite(background,foreground).save("testattrachre.png",**img_info)
