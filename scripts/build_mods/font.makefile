#
# author : MichinariNukazawa / "project daisy bell"
# 	michinari.nukazawa@gmail.com
# 	https ://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts
# license : 2-clause BSD license#
#

# 手動修正済みグリフ画像の一覧
GLYPH_PATCHS=$(shell if [ -d FontSources/$(FontName)_patchGlyphs/ ] ; then find FontSources/$(FontName)_patchGlyphs/*.svg | xargs echo ; fi)


#  FontSources/$(FontName)_patchGlyphs/*.svg
$(FontFile): FontSources/$(FontName)_complete.svg FontSources/$(FontName)_list.txt $(GLYPH_PATCHS)
	# フォント画像の分割を実行
	rm -rf FontSources/glyphs_$(FontName)/ 2>/dev/null # 標準エラー出力は捨てる
	mkdir FontSources/glyphs_$(FontName)/ 2>/dev/null # 標準エラー出力は捨てる
	python3 scripts/build_mods/svg_splitter.py FontSources/$(FontName)_complete.svg FontSources/$(FontName)_list.txt --output_dir="FontSources/glyphs_$(FontName)/" 
	# 手動修正ファイルの上書き
	-cp -r FontSources/glyphs_$(FontName)_patchGlyphs/* FontSources/glyphs_$(FontName)/
	# フォントファイル生成スクリプトを呼び出す
	fontforge -lang=py -script ./scripts/build_mods/font_generate.py $(FontName) $(Version) $(Width) $(Height) $(baseline) $(isAssignLower) 2>./fontforge.log


