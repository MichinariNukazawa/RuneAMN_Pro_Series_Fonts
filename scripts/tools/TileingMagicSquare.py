#!/bin/python
# -*- coding: utf-8 -*-
#
# brief : Images join to squared.
# 	画像ファイルを正方に連結する
# usage : this_script.py --target_dir=amd/ --output=amn/myout.png \ 
# 	--width=800 --height=800
#
# author : MichinariNukazawa / "project daisy bell"
# 	michinari.nukazawa@gmail.com
# 	https://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts
# license: clause-2 BSD license
#
# require:
# python3,
# docopt, pillow (python3 PIL)
# 	Install:
# 		sudo apt-get install python3-docopt python3-pil(or python3-pillow)
#		or
# 		pip3 install docopt pillow
#

"""Process some integers.

usage: this_script.py [-h] [--target_dir=<PATH_TARGET_DIR>] [--output=<PATH_OUT>] [--width=<NUM_WIDTH>] [--height=<NUM_HEIGHT>]

options:
	-h, --help  show this help message and exit
	--target_dir=<PATH_TARGET_DIR>	joined source images dir [default: ./]
	--output=<PATH_OUT>	joined images filepath [default: "output.png"]
	--width=<NUM_WIDTH>		warning:not implement. width for unit of split base squared(cross-section) [default: 1000]
	--height=<NUM_HEIGHT>	warning:not implement. height for unit of split base squared(cross-section) [default: 1000]
"""

from docopt import docopt
from pprint import pprint
from PIL import Image
import math
import glob
import imghdr
import os.path

def getPathImagesFromDir(pathDir):
	pathImages = []
	pathFiles = glob.glob(pathDir + "*")
	for pathFile in pathFiles:
		if os.path.isdir(pathFile):
			continue
		if imghdr.what(pathFile):
			pathImages.append(pathFile)
	return pathImages


if __name__ == '__main__':
	args = docopt(__doc__)

	# 引数を取得
	pprint(args)
	settings = {}
	settings['target_dir'] = args['--target_dir']
	settings['output'] = args['--output']
	if not settings['output']:
		settings['output'] = 'output.png'
	if not settings['target_dir']:
		settings['target_dir'] = './'


	#画像ファイルパス一覧を取得
	pathImages = getPathImagesFromDir(settings['target_dir'])
	
	if len(pathImages) <= 0:
		print("Image not detect.")
		quit(0)

	numRow = 10
	numCol = math.ceil(len(pathImages)/ numRow)

	widthSrcImage = 1000
	heightSrcImage = 1000
	widthDstImage = 100
	heightDstImage = 100



	joinedImage = Image.new('RGB', ((numRow*widthDstImage), (numCol*heightDstImage)), "#333333")

	for iRow in range(numRow):
		for iCol in range(numCol):
			print(str(iRow) + ", " + str(iCol))
			ixSrcImage = (iCol*numRow)+iRow
			if not ixSrcImage < len(pathImages):
				continue
			item = Image.open(pathImages[ixSrcImage]).convert('RGBA')
			if not (widthSrcImage == widthDstImage and heightSrcImage == heightDstImage):
				print ("warning: ratio controll not implement!")
				item.thumbnail((widthDstImage, heightDstImage), Image.ANTIALIAS)
			xOnDst = widthDstImage * iRow
			yOnDst = heightDstImage * iCol
			joinedImage.paste(item, (xOnDst, yOnDst), item)
			item = None

	joinedImage.save(settings['output'], 'PNG', quality=100, optimize=True)



