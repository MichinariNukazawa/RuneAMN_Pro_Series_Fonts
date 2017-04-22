#
# author : MichinariNukazawa / "project daisy bell"
# 	michinari.nukazawa@gmail.com
# 	https ://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts
# license : 2-clause BSD license#
#

LOGFILE=./fontforge.log

# 手動修正済みグリフ画像の一覧
GLYPH_PATCHS=$(shell if [ -d FontSources/$(FontName)_patchGlyphs/ ] ; then find FontSources/$(FontName)_patchGlyphs/*.svg | xargs echo ; fi)

$(FontFile): FontSources/$(FontName).svg FontSources/$(FontName)_list.txt $(GLYPH_PATCHS)
	echo "" >> $(LOGFILE)
	date +'%Y/%m/%d %T ' >> $(LOGFILE)
	echo "$(FontName)" >> $(LOGFILE)
	# フォント画像の分割を実行
	rm -rf FontSources/glyphs_$(FontName)/
	mkdir FontSources/glyphs_$(FontName)/
	python3 scripts/build_mods/svg_splitter.py \
		 FontSources/$(FontName).svg FontSources/$(FontName)_list.txt \
		 --output_dir="FontSources/glyphs_$(FontName)/" 
	# 手動修正ファイルがあれば、上書きする
	-cp -r FontSources/glyphs_$(FontName)_patchGlyphs/* FontSources/glyphs_$(FontName)/ 2>>$(LOGFILE)
	# フォントファイル生成スクリプトを呼び出す
	fontforge -lang=py -script ./scripts/build_mods/font_generate.py \
		 $(FontName) $(Version) $(Width) $(Height) $(baseline) $(isAssignLower) 2>>$(LOGFILE)


