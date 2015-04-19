#!/usr/bin/env fontforge -lang=py -script
# -*- coding: utf-8 -*-
#
# usage : fontforge -lang=py -script scripts/tools/AfterWork_BlackletterPLow.py releases/RuneAMN_Pro_BlackletterPLow_1.20150405.otf 
#
# author : MichinariNukazawa / "project daisy bell"
# 	michinari.nukazawa@gmail.com
# 	https://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts
# license: clause-2 BSD license
# 
# Special Thanks
# mashabow＠しろもじ作業室（http://shiromoji.net, mashabow@shiromoji.net）
# koruri(lindwurm)
# https://gist.github.com/lindwurm/b24657c335bb11a520c4/9461c1690188ddd2b6d721467653e6e0072689b8
# Import SVGs
# http://mshio.b.sourceforge.jp/2010/10/15/how2import-2/
#

import sys
import fontforge
import shutil


def main():
	print("start fontforge.\n")
	
	if(not (2 == len(sys.argv))):
		print("error: args length :%d\n" % len(sys.argv))
		sys.exit(-1)
	
	pathFontFile = sys.argv[1]
	
	shutil.copy(pathFontFile, pathFontFile + ".back")
	

	font = fontforge.open(pathFontFile)


	for i in range(0, 26):
		ucUpper =  (0x0041 + i)
		font.selection.select(ucUpper)
		for glyph in font.selection.byGlyphs:
			glyph.width = 900
		
	#font.save()
	font.generate(pathFontFile, '', ('short-post', 'opentype', 'PfEd-lookups'))

	print ("AfterWorked: "+ pathFontFile)

	font.close()


if __name__ == '__main__':
    main()

