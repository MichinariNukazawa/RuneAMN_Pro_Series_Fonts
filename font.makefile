
# 手動修正済みグリフ画像の一覧
GLYPH_PATCHS=$(shell if [ -d FontSources/$(FontName)_patchGlyphs/ ] ; then find FontSources/$(FontName)_patchGlyphs/*.svg | xargs echo ; fi)


#  FontSources/$(FontName)_patchGlyphs/*.svg
$(FontFile): FontSources/$(FontName)_complete.svg FontSources/$(FontName)_list.txt $(GLYPH_PATCHS)
	# フォント画像の分割を実行
	rm -rf FontSources/glyphs_$(FontName)/ 2>/dev/null # 標準エラー出力は捨てる
	mkdir FontSources/glyphs_$(FontName)/ 2>/dev/null # 標準エラー出力は捨てる
	perl svg_splitter.pl FontSources/$(FontName)_complete.svg FontSources/$(FontName)_list.txt FontSources/glyphs_$(FontName)/ $(Width) $(Height)
	# 手動修正ファイルの上書き
	-cp -r FontSources/$(FontName)_patchGlyphs/* FontSources/glyphs_$(FontName)/
	# フォントファイル生成スクリプトを呼び出す
	fontforge -script ./font_generate.pe $(FontName) $(Version) $(Width) $(Height) $(baseline) $(isAssignLower) 2>./fontforge.log


