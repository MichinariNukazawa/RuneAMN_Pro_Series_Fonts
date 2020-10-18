#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# brief : SVG image splitter for generated "RuneAMN Series" font and other.
# 	SVG画像ファイルをグリフごとに分割する
# usage : this_script.py RuneAMN.svg font_source/RuneAMN_KnifeA_list.txt \
# 	--output_dir=amn/ --width=800 --height=800
#
# author : MichinariNukazawa / "project daisy bell"
# 	michinari.nukazawa@gmail.com
# 	https://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts
# license : 2-clause BSD license
#
# depend : python3,docopt
# Install :
# 		sudo apt-get install python3-docopt
#		or
# 		pip install docopt
#

"""Process some integers.

usage: this_script.py [-h] <src_image> <listfile> [--output_dir=<DIR_OUT>] [--width=<NUM_WIDTH>] [--height=<NUM_HEIGHT>]


options:
	-h, --help  show this help message and exit
	--sum		sum the integers (default: find the max)
	--output_dir=<DIR_OUT>	splitted SVG images output dir [default: glyphs_/]
	--width=<NUM_WIDTH>		warning:not implement. width for unit of split base squared(cross-section) [default: 1000]
	--height=<NUM_HEIGHT>	warning:not implement. height for unit of split base squared(cross-section) [default: 1000]
"""

from docopt import docopt
from pprint import pprint
import math
import re
from xml.etree import ElementTree as ET
import xml.dom.minidom
import os
import os.path


"""
 @brief (必要なら)縦横サイズを500の倍数に繰り上げる。
 @param 繰り上げ前の数値
 @return	繰上げ後の数値
"""
def upcut(src):
	return math.ceil(int(src)/500) * 500


"""
@brief 2次元配列の指定位置(col,row)が存在するか確かめる
@param table
@param col
@param row
@return True/False
"""
def isExistOnTable(table, row, col):
	if (len(table)-1) < row:
		return False
	else:
		if (len(table[row])-1) < col:
			return False
	return True


"""
"""
def getNewSvg(settings):
	doc = ET.Element('svg', width=str(settings['width']), height=str(settings['height']),
		version='1.1', xmlns='http://www.w3.org/2000/svg')
	return doc


"""
"""
def svgInitOnTable(dstsTable, row, col):
	if False == isExistOnTable(dstsTable, row, col):
		print("not exist (or out of artboard): " + str(row) + " " + str(col))
		return False
	if 0 == dstsTable[row][col]:
		svg = getNewSvg(settings)
		dstsTable[row][col] = {'svg':svg}
	return True


"""
 @brief 設定ファイルを読み込む
 
 2次元配列の確保( http://sonickun.hatenablog.com/entry/2014/06/13/132821 )
  arr = [[0 for i in range(3)] for j in range(5)]
 
 @param 設定ファイルのパス
 @return 設定一覧(連想配列)
 		FontName: フォント名
 		width: 分断サイズ
 		height: 分断サイズ
 		widthGlyph: グリフ領域サイズ
 		heightGlyph: グリフ領域サイズ
 		row: (未使用)
 		col: (未使用)
 		ucList: 文字配置の2次元配列。(ユニコードコードポイント文字列を使用(ex: "u0024"))
"""
def getSettingsFromSettingFilePath(pathSettingFile):
	settings = {
	'fontName':'',
	'width':0,
	'height':0,
	'row':0,
	'col':0,
	'ucTable':[]
	}

	foSetting = open(pathSettingFile, 'r')
	
	reComment = re.compile("^(#|//)")
	reSetting = re.compile("FontName:(?P<fontName>\w+)"\
	" Width:(?P<width>[0-9]+) Height:(?P<height>[0-9]+)"\
	" baseline:(?P<baseline>[0-9]+)"\
	" isFree:(?P<isFree>(yes|no)) isAssignLower:(?P<isAssignLower>(yes|no))",
	 re.IGNORECASE)
	reListContent = re.compile('(u[0-9a-fA-F]{4}|u----|[^\s]|[\s])[\s]')

	isUcList = False
	isCountRow = False
	for line in foSetting:
		if False == isUcList:
			if reComment.match(line):
				next
			moSetting = reSetting.match(line)
			if moSetting:
				isUcList = True
				settings['fontName'] = moSetting.group('fontName')
				settings['widthGlyph'] = getNumericFromStringHead(moSetting.group('width'))
				settings['heightGlyph'] = getNumericFromStringHead(moSetting.group('height'))
				settings['width'] = upcut(settings['widthGlyph'])
				settings['height'] = upcut(settings['heightGlyph'])
				next
		else:
			# Memo:listContent行間の空行は、現状では無視している。
			# Memo:listContent行内の半角文字は、現状では無視している。
			#　Todo: Unicode変換
			listContent = reListContent.findall(line)
			if listContent:
				isCountRow = True
				settings['row'] += 1
				for i, con in enumerate(listContent):
					uc = getUncodeCodepointFromLatin(con)
					if 0 == len(uc):
						listContent[i] = ''
					else:
						listContent[i] = 'u' + uc
				settings['ucTable'].append(listContent)
				if settings['col'] < len(listContent):
					settings['col'] = len(listContent) 
	return settings



"""
 @brief ラテン基本字をUnicodeコードポイント文字列(ex.u"0024")に変換する
 		1文字あるいはユニコードコードポイント文字列でないものを受け取った場合エラー。
 @param 変換対象文字(またはユニコードコードポイント文字列(ex."u0024")
 @param ユニコードコードポイント文字列(ex.u"0024")
 		(Todo: エラー処理)
"""
reAlphabet = re.compile("([^\s])\Z")
reUnicodeCodePoint = re.compile("u([0-9a-fA-F]{4})")
def getUncodeCodepointFromLatin(latin):
	if reAlphabet.match(latin):
		codePoint = '%04x' % ord(latin)
		return codePoint
	elif reUnicodeCodePoint.match(latin):
		m = reUnicodeCodePoint.match(latin)
		return m.group(1)
	else:
		print("error: invalid string:")
		pprint(latin)
		return ""


"""
 @brief 文頭から数値を切り出す
 @param 対象文字列
 @return 検出数値
 		 失敗時はエラー文字列(Todo: エラー処理))
"""
def getNumericFromStringHead(s):
	reNumeric = re.compile("^([0-9]+)")
	moNumeric = reNumeric.match(s)
	if moNumeric:
		return int(moNumeric.group(), 10)
	else:
		return moNumeric


"""
@param 表示されないElementならばTrue
@todo 正しくないがとりあえず目的の出力を得られる、正しくない方法
"""
def isVisibleElement(element):
	#	if None != element.get('display') and 'none' == element.get('display'):
	#	return False

	fill = element.get('fill')
	stroke = element.get('stroke')
	#if 'none' == fill:
	#	fill = None
	if 'none' == stroke:
		stroke = None
	if 'none' == fill and None == stroke:
		return False
	return True


"""
 @brief xmlツリーからSVG要素を再帰的に検出して分割処理する
 @param 分割済みデータ連想配列
 @param 設定ファイル情報(分割設定)
 @param xmlツリー(グループ要素)
 @return 分割済みデータ連想配列
 			（Todo:エラー処理)
"""
def ravelGroup(dstsTable, settings, svgGroup):
	svgTransform = svgGroup.get('transform')
	if svgTransform:
		print('warning: not inplement transform attr.')

	elems = list(svgGroup)
	for elem in elems:
		if '{http://www.w3.org/2000/svg}g' == elem.tag:
			if None != elem.get('display') and 'none' == elem.get('display'):
				continue
		else:
			if not isVisibleElement(elem):
				continue

		if '{http://www.w3.org/2000/svg}g' == elem.tag:
			dstsTable = ravelGroup(dstsTable, settings, elem)
		elif '{http://www.w3.org/2000/svg}path' == elem.tag:
			dstsTable = ravelPath(dstsTable, settings, elem)
		elif '{http://www.w3.org/2000/svg}rect' == elem.tag:
			dstsTable = ravelRect(dstsTable, settings, elem)
		elif '{http://www.w3.org/2000/svg}polygon' == elem.tag:
			dstsTable = ravelPolygon(dstsTable, settings, elem)
		elif '{http://www.w3.org/2000/svg}polyline' == elem.tag:
			dstsTable = ravelPolyline(dstsTable, settings, elem)
		elif '{http://www.w3.org/2000/svg}circle' == elem.tag:
			dstsTable = ravelCircle(dstsTable, settings, elem)
		elif '{http://www.w3.org/2000/svg}ellipse' == elem.tag:
			dstsTable = ravelEllipse(dstsTable, settings, elem)
		else:
			print("other tag:" + elem.tag)
	return dstsTable


"""
@brief svgPathを切り出す
"""
reHeadPoint = re.compile("[^-0-9]+(?P<x>-?[0-9]+(\.[0-9]+)?)[^-0-9]*(?P<y>-?[0-9]+(\.[0-9]+)?)")
def ravelPath(dstsTable, settings, svgPath):
	svgTransform = svgPath.get('transform')
	if svgTransform:
		print('warning: not inplement transform attr.')

	moHeadPoint = reHeadPoint.match(svgPath.get('d'))
	xHead = float(moHeadPoint.group('x'))
	yHead = float(moHeadPoint.group('y'))
	col = int(xHead // settings['width'])
	row = int(yHead // settings['height'])
	
	if not svgInitOnTable(dstsTable, row, col):
		return dstsTable

	svgPath = moveSvgPath(svgPath,
		 -1 * col * settings['width'],
		 -1 * row * settings['height'])
	dstsTable[row][col]['svg'].append(svgPath)
	
	return dstsTable


"""
@brief svgPathを移動する
@param 移動するsvgPath
@param 移動量
@param 移動量
@return 移動後のsvgPath
"""
rePathDSplit = re.compile("\s*(?P<match>[A-Za-z]|-?[\d\.]+),?\s*(?P<other>.*$)")
reHeadAlphabet = re.compile("[^-0-9a-zA-Z]*(?P<headAlphabet>[a-zA-Z])(?P<other>.*)")
def moveSvgPath(svgPath, xMove, yMove):
	commandString = '' # SVG path要素の種別
	src = svgPath.get('d')
	dst = ''
	
	srcSets = []
	moPathDSplit = rePathDSplit.match(src)
	while moPathDSplit:
		srcSets.append(moPathDSplit.group('match'))
		src = moPathDSplit.group('other')
		moPathDSplit = rePathDSplit.match(src)

	i = -1
	while (i + 1) < len(srcSets):
		i += 1
	
		moHeadAlphabet = reHeadAlphabet.match(srcSets[i])
		if moHeadAlphabet:
			commandString = srcSets[i]
			dst += srcSets[i]
			continue
		else:
			if 'M' == commandString or 'L' == commandString or 'C' == commandString or 'S' == commandString or 'Q' == commandString or 'T' == commandString:
					x = float(srcSets[i]) + xMove
					i += 1
					y = float(srcSets[i]) + yMove
					
					dst += str(x) + "," + str(y) + " "
			elif 'A' == commandString or 'a' == commandString:
				# Todo: 'A/a' commandString
				print("warning: svg path d command:A/a :")
				pprint(srcSets[i])
				continue
			elif 'm' == commandString or 'l' == commandString or 'c' == commandString or 's' == commandString or 'q' == commandString or 't' == commandString:
					x = float(srcSets[i])
					i += 1
					y = float(srcSets[i])
					
					dst += str(x) + "," + str(y) + " "
			elif 'H' == commandString:
					x = float(srcSets[i]) + xMove
					dst += str(x) + " "
			elif 'h' == commandString:
					x = float(srcSets[i])
					dst += str(x) + " "
			elif 'V' == commandString:
					y = float(srcSets[i]) + yMove
					dst += str(y) + " "
			elif 'v' == commandString:
					y = float(srcSets[i])
					dst += str(y) + " "
			elif 'Z' == commandString or 'z' == commandString:
				#noop
				print("noop: svg path d command Z/z")
				pprint(srcSets[i])
			else:
				print("error invalid mode.")
				pprint(commandString)
				pprint(srcSets[i])
				
	svgPath.set('d', dst)
	return svgPath


"""
@param svgRectを切り出す
"""
def ravelRect(dstsTable, settings, svgRect):
	transform = getTransformFromSvgElem(svgRect)

	x = float(svgRect.get('x'))
	y = float(svgRect.get('y'))
	width = float(svgRect.get('width'))
	height = float(svgRect.get('height'))

	if 0 != len(transform):
		xReal =  transform[1] * x + transform[3] * y + transform[5]
		yReal =  transform[2] * x + transform[4] * y + transform[6]
	else:
		xReal = x
		yReal = y

	col = int(xReal // settings['width'])
	row = int(yReal // settings['height'])
	
	if 0 != len(transform):
		transform[5] += -1 * col * settings['width']
		transform[6] += -1 * row * settings['height']
		sTransform = transform[0] + \
			'(' + str(transform[1]) + ' ' + str(transform[2]) + \
			' ' + str(transform[3]) + ' ' + str(transform[4]) + \
			' ' + str(transform[5]) + ' ' + str(transform[6]) + ')'
		svgRect.set('transform', sTransform)
	else:
		x += -1 * col * settings['width']
		y += -1 * row * settings['height']
	
	if not svgInitOnTable(dstsTable, row, col):
		return dstsTable
	
	svgRect.set('x', str(x))
	svgRect.set('y', str(y))
	dstsTable[row][col]['svg'].append(svgRect)
	return dstsTable


"""
@brief svgPolygonを切り出す
"""
reHeadNumeric = re.compile("[^-0-9]*(?P<headNumeric>-?[0-9]+(\.[0-9]+)?)[,\s]?\s*(?P<other>.*)?")
#reHeadNumericDual = re.compile("[^-0-9a-zA-Z]*(?P<headNumeric1>-?[0-9](\.[0-9]+)?),?(?P<headNumeric2>-?[0-9](\.[0-9]+)?)(?P<other>.+)")
def ravelPolygon(dstsTable, settings, svgPolygon):
	svgTransform = svgPolygon.get('transform')
	if svgTransform:
		print('warning: not inplement transform attr.')

	srcStrPoints = svgPolygon.get('points')
	dstStrPoints = ''
	
	listPoints = []
	moHeadNumeric = reHeadNumeric.match(srcStrPoints)
	while moHeadNumeric:
		listPoints.append(float(moHeadNumeric.group('headNumeric')))
		srcStrPoints = moHeadNumeric.group('other')
		moHeadNumeric = reHeadNumeric.match(srcStrPoints)
		
	if 0 != len(listPoints) % 2: # 2の倍数個でなければ警告
		print('warning: not %2 :' + str(len(listPoints)))
		pprint(listPoints)

	#xReal =  transform[1] * x + transform[3] * y + transform[5]
	#yReal =  transform[2] * x + transform[4] * y + transform[6]
	col = int(listPoints[0] // settings['width'])
	row = int(listPoints[1] // settings['height'])
	
	
	i = 0
	while i < len(listPoints):
		x = listPoints[i]
		i += 1
		y = listPoints[i]
		x += -1 * col * settings['width']
		y += -1 * row * settings['height']
		dstStrPoints += str(x) + ',' + str(y) + ' '
		
		i += 1

	if not svgInitOnTable(dstsTable, row, col):
		return dstsTable
	
	svgPolygon.set('points', dstStrPoints)
	dstsTable[row][col]['svg'].append(svgPolygon)
	return dstsTable


"""
@brief svgPolylineを切り出す
	フォント拡張では開パスは警告する。
"""
def ravelPolyline(dstsTable, settings, svgPolyline):
	print('warning: detect polyline')
	return ravelPolygon(dstsTable, settings, svgPolyline)

"""
"""
def ravelCircle(dstsTable, settings, svgCircle):
	svgTransform = svgCircle.get('transform')
	if svgTransform:
		print('warning: not inplement transform attr.')

	cx = float(svgCircle.get('cx'))
	cy = float(svgCircle.get('cy'))
	#r = float(svgCircle.get('r'))
	
	col = int(cx // settings['width'])
	row = int(cy // settings['height'])

	cx += -1 * col * settings['width']
	cy += -1 * row * settings['height']

	svgCircle.set('cx', str(cx))
	svgCircle.set('cy', str(cy))
	
	if not svgInitOnTable(dstsTable, row, col):
		return dstsTable
	
	dstsTable[row][col]['svg'].append(svgCircle)
	return dstsTable
"""
"""
def ravelEllipse(dstsTable, settings, svgCircle):
	svgTransform = svgCircle.get('transform')
	if svgTransform:
		print('warning: not inplement transform attr.')

	cx = float(svgCircle.get('cx'))
	cy = float(svgCircle.get('cy'))
	rx = float(svgCircle.get('rx'))
	ry = float(svgCircle.get('ry'))
	#r = float(svgCircle.get('r'))
	
	col = int(cx // settings['width'])
	row = int(cy // settings['height'])

	cx += -1 * col * settings['width']
	cy += -1 * row * settings['height']

	svgCircle.set('cx', str(cx))
	svgCircle.set('cy', str(cy))
	svgCircle.set('rx', str(rx))
	svgCircle.set('ry', str(ry))
	
	svgCircle.set('transform', '') # temp

	if not svgInitOnTable(dstsTable, row, col):
		return dstsTable
	
	dstsTable[row][col]['svg'].append(svgCircle)
	return dstsTable

"""
@brief 要素からtaransform/matrix属性を検出して、その値を返す
@param 要素

@return transform種別+要素の配列(ex.['transform', 0, 1, 2, 3, 4, 5])
		transform/matrix 未検出時: 0要素の配列
		エラー時: その他
"""
reTransformTranslate = re.compile("translate\((?P<tx>-?\d+(.\d+)?)[,\s]\s*(?P<ty>-?\d+(.\d+)?)\)")
reTransformMatrix = re.compile("matrix\((?P<a>-?\d+(.\d+)?)[,\s]\s*(?P<b>-?\d+(.\d+)?)?[,\s]\s*(?P<c>-?\d+(.\d+)?)[,\s]\s*(?P<d>-?\d+(.\d+)?)[,\s]\s*(?P<e>-?\d+(.\d+)?)[,\s]\s*(?P<f>-?\d+(.\d+)?)\)")
def getTransformFromSvgElem(svgElem):
	sTransformValue = svgElem.get('transform')
	if not sTransformValue:
		return []
	else:
		moTransformTranslate = reTransformTranslate.match(sTransformValue)
		if moTransformTranslate:
			listTransform = ['matrix', 1, 0, 0, 1, 0, 0]
			listTransform[5] = float(moTransformTranslate.group('tx'))
			listTransform[6] = float(moTransformTranslate.group('ty'))
			return listTransform
		moTransformMatrix = reTransformMatrix.match(sTransformValue)
		if moTransformMatrix:
			listTransform = ['matrix', 0, 0, 0, 0, 0, 0]
			listTransform[1] = float(moTransformMatrix.group('a'))
			listTransform[2] = float(moTransformMatrix.group('b'))
			listTransform[3] = float(moTransformMatrix.group('c'))
			listTransform[4] = float(moTransformMatrix.group('d'))
			listTransform[5] = float(moTransformMatrix.group('e'))
			listTransform[6] = float(moTransformMatrix.group('f'))
			return listTransform
		print("error: other transform (not implement).")
		pprint(sTransformValue)
	return []


"""
@brief テーブル上の複数のsvg画像データをファイルに書き出す
"""
def writeSvgs(dstsTable, settings):
	for row, rows in enumerate(dstsTable):
		for col, dst in enumerate(rows):
			if 0 == dst:
				print("warning: not exist in dstsTable :" + str(row) + ' ' + str(col))
				continue
			else:
				writeSvg(dst['svg'], settings, row, col)
	return



"""
@brief 指定されたsvg画像データをファイルに書き出す
"""
def writeSvg(svg, settings, row, col):
	# if False == isinstance(svg, <class 'xml.etree.ElementTree.Element'>):
	if False == True:
		return
	else:
		if not isExistOnTable(settings['ucTable'],row,col):
			print('blank table: ' + str(row) + ' ' +str(col))
			return 
		filename = settings['ucTable'][row][col]
		if 0 == len(filename):
			print('blank filename: ' + str(row) + ' ' + str(col))
			return
		dirOutput = settings['output_dir']
		if False == os.path.exists(dirOutput):
			os.mkdir(dirOutput)

		docMinidom = xml.dom.minidom.parseString(ET.tostring(svg).decode('utf-8'))

		filepath = dirOutput + "/" + filename + ".svg"
		f = open(filepath, 'w')
		f.write(docMinidom.toprettyxml())
		f.close()
	return


if __name__ == '__main__':
	args = docopt(__doc__)

	# 設定ファイルを解析する
	settings = getSettingsFromSettingFilePath(args["<listfile>"])
	settings['output_dir'] = args['--output_dir']
	pprint(settings)
	
	# SVGファイルをxmlとして読み込む
	tree = ET.parse(args["<src_image>"])
	rootSvg = tree.getroot()
	# SVGファイルの縦横サイズを取得する
	widthSvg = getNumericFromStringHead(rootSvg.get("width"))
	heightSvg = getNumericFromStringHead(rootSvg.get("height"))
	
	# Todo: プリプロセスとして、非表示のグループとレイヤ名'*_ignoreSSSMN'を持つレイヤを除去
	# Todo: 透明なsvg要素も除去する。タイミングは未定。


	# SVGパスをレイヤ(グループ)ごとに分割器にかける(rootにも要素があるのでレイヤ扱いする)
	dstsTable = [[0 for i in range(settings['col'])] for j in range(settings['row'])]
	ravelGroup(dstsTable, settings, rootSvg)

	writeSvgs(dstsTable, settings)

