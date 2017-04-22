#
# author : MichinariNukazawa / "project daisy bell"
# 	michinari.nukazawa@gmail.com
# 	https ://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts
# license : 2-clause BSD license#
#

LOGFILE=./fontforge.log

# 手動修正済みグリフ画像の一覧
GLYPH_PATCHS=$(shell if [ -d font_source/$(FontName)_patchGlyphs/ ] ; then find font_source/$(FontName)_patchGlyphs/*.svg | xargs echo ; fi)

$(FontFile): font_source/$(FontName).svg font_source/$(FontName)_list.txt $(GLYPH_PATCHS)
	echo "" >> $(LOGFILE)
	date +'%Y/%m/%d %T ' >> $(LOGFILE)
	echo "$(FontName)" >> $(LOGFILE)
	# フォント画像の分割を実行
	rm -rf font_source/glyphs_$(FontName)/
	mkdir font_source/glyphs_$(FontName)/
	python3 scripts/build_mods/svg_splitter.py \
		 font_source/$(FontName).svg font_source/$(FontName)_list.txt \
		 --output_dir="font_source/glyphs_$(FontName)/" 
	# 手動修正ファイルがあれば、上書きする
	-cp -r font_source/glyphs_$(FontName)_patchGlyphs/* font_source/glyphs_$(FontName)/ 2>>$(LOGFILE)
	# フォントファイル生成スクリプトを呼び出す
	fontforge -lang=py -script ./scripts/build_mods/font_generate.py \
		 $(FontName) $(Version) $(Width) $(Height) $(baseline) $(isAssignLower) 2>>$(LOGFILE)


