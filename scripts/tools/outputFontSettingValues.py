#!/usr/bin/env fontforge -lang=py -script
# -*- coding: utf-8 -*-
#
# author : MichinariNukazawa / "project daisy bell"
# 	michinari.nukazawa@gmail.com
# 	https://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts
# license: clause-2 BSD license
#

import sys
import fontforge

def main():
	print("start fontforge.\n")
	
	if(not (2 == len(sys.argv))):
		print("error: args length :%d\n" % len(sys.argv))
		sys.exit(-1)
	
	pathFontFile = sys.argv[1]
	
	font = fontforge.open(pathFontFile)
	
	fnt = font

	for i in ["em", 
	"ascent", 
	"descent", 
	"hhea_ascent", 
	"hhea_descent", 
	"hhea_linegap",
	"os2_typoascent", 
	"os2_typodescent", 
	"os2_typolinegap",
	"os2_winascent", 
	"os2_windescent", 
	"hhea_ascent_add", 
	"hhea_descent_add", 
	"os2_typoascent_add", 
	"os2_typodescent_add",
	"os2_winascent_add", 
	"os2_windescent_add"]:
		print ("%-25s %6s" % (i+":", eval("fnt."+i)))

	print ("Output: "+ pathFontFile)

	font.close()


if __name__ == '__main__':
    main()

