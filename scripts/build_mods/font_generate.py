#!/usr/bin/env fontforge -lang=py -script
# -*- coding: utf-8 -*-
#
# usage : fontforge -lang=py -script ./font_generate.py \
# 	RuneAMN_Pro_BlackletterPLow 0.001 500 1000 100 no
#
# author : MichinariNukazawa / "project daisy bell"
# 	michinari.nukazawa@gmail.com
# 	https://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts
# license : 2-clause BSD license
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
import os

def main():
	print("start fontforge.\n")

	if(not(7 == len(sys.argv))):
		print("error: args length :%d\n" % len(sys.argv))
		sys.exit(-1)

	fontName = sys.argv[1]
	version  = sys.argv[2]
	width    = int(sys.argv[3])
	height   = int(sys.argv[4])
	baseline = int(sys.argv[5])
	isAssignLower = sys.argv[6]

	fontFilename = fontName + "_" + version + ".otf"
	#inportFiles = "FontSources/glyphs_" + fontName + "/u*.svg"
	dirImportFiles = "FontSources/glyphs_" + fontName + ""

	# create new font.
	font = fontforge.font()

	# エンコードにUnicodeを指定
	font.encoding = "unicode"

	# 半角文字の高さ／深さ(ベースライン)設定
	# set Baseline
	font.em = 1000
	font.descent = baseline
	font.ascent = height - baseline

	# .notdef作成
	glyphSpace = font.createChar(0x0000)
	glyphSpace.glyphname = ".notdef"

	# create empty '.' and ',' (Runic design font fix)
	glyphSpace = font.createChar(0x002c)
	glyphSpace.width = width
	glyphSpace = font.createChar(0x002e)
	glyphSpace.width = width

	# SVGをすべてインポート
	files = os.listdir(dirImportFiles)
	for fl in files:
		if fl.endswith('.svg'):
			cd = int(fl[1:-4], 16)
			# print ("file : %s" % fl)
			if not (cd in font):
				font.createChar(cd)
			else:
				font[cd].clear()
			path = '%s/%s' %(dirImportFiles, fl)
			# print ("path :%s" % path)
			font[cd].importOutlines(path)

	# 大文字を小文字に(リファレンス)コピーする
	if ( "yes" == isAssignLower):
		for i in range(0, 26):
			ucSrc =  (0x0041 + i)
			ucDst =  (0x0061 + i)
			font.selection.select(ucSrc)
			font.copyReference()
			font.selection.select(ucDst)
			font.paste()

	# 半角スペース作成
	glyphSpace = font.createChar(0x0020)
	glyphSpace.width = width

	# 全角スペース作成
	glyphSpace = font.createChar(0x3000)
	glyphSpace.width = 1000

	font.os2_use_typo_metrics = True

	font.hhea_ascent_add = False
	font.hhea_descent_add = False
	font.os2_typoascent_add = False
	font.os2_typodescent_add = False
	font.os2_winascent_add = False
	font.os2_windescent_add = False

	#descent
	font.os2_typodescent = (-baseline)
	font.os2_windescent = baseline
	font.hhea_descent = (-baseline)

	# ascent
	font.os2_typoascent = height - baseline
	font.os2_winascent = height - baseline
	font.hhea_ascent = height - baseline


	## デザイン上の各種設定
	font.selection.none()
	font.selection.all()
	# パスの統合
	# print("before removeOverlap")
	# とてもたくさんの内部エラーを吐き出す。
	font.removeOverlap()
	# 整数値に丸める
	font.round()
	# アウトラインの向きを修正
	font.correctDirection()

	font.selection.none()
	font.selection.select(("ranges",None), 0x0020, 0x007e)
	for glyph in font.selection.byGlyphs:
		# 自動ヒント有効化
		glyph.autoHint()

		# 半角文字の文字幅設定
		glyph.vwidth = 1000
		glyph.width = width

	# フォント情報設定
	font.fontname = fontName
	font.familyname = fontName
	font.fullname = fontName
	font.weight = "Regular"
	font.copyright = "© 2015 Michinari.Nukazawa"
	font.version = version

	font.generate("releases/" + fontFilename, '', ('short-post', 'opentype', 'PfEd-lookups'))

	print ("generated: "+ fontFilename)

	font.close()



if __name__ == '__main__':
    main()

