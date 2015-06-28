RuneAMN_Pro Series Fonts (build scripts and other). 商用イラスト・デザイン向けルーン文字フォント・ビルドスクリプト
====

##概要
RuneAMN_Pro Series Fontsは、商用イラスト・デザイン向けルーン文字フォントです。  
本プロジェクトでは、[project daisy bell][pixiv_booth_project_daisy_bell]がリリースしている商用フォント製品およびフリーフォントで使っているビルドスクリプトを公開しています。  

RuneAssignMN_Pro Series Fontsの特徴:  
ラテン・アルファベットの"A〜z"にルーン文字を割り当ててあります。  
ふつうの英文を用意し、このフォントを使うだけで、簡単にルーン文字で書かれた文章を"でっちあげる"ことができます。  

フォントの書体デザインは、  
 [RuneAMN_Pro_Series_Fonts][ghpages_RuneAMN_Pro]  
 および  
 [製品評価版 書体見本(PDF)][typefaces_manuals_pdf]  
 または  
 [Pixiv][pixiv_nukazawa_index]  
にて見ることができます。  

姉妹フォントに  
[RuneAMN_Series_Font][ghpages_index_RuneAssignMN_Series_Fonts]  
[OlChikiAssignMN_Series_Font][ghpages_index_OlChikiAssignMN_Series_Fonts]  
があります。  
これらは、フリーフォントです。ビルドスクリプトおよび書体ソース画像も、フリーソフトウェアとして公開されています。  


##スクリプトのライセンス
"2-clause BSD license"ライセンスです。  
ただし、extra/以下のファイルを除きます。  
  
もちろん、あなたのデザインとこのスクリプトで作成したフォントは、あなたが任意のライセンスで公開（あるいは販売)することができます。  

##フォントのライセンス
 プロジェクトに含まれている"RuneAMN_SerifEx"フォントの書体ソース画像は、ビルドスクリプトの動作確認および、ビルドスクリプト転用の際にソース画像と設定ファイルを用意するための参考資料として使うことのみを目的に、添付されているものです。  
 書体ソース画像および、そこから生成したフォントファイルを、上記の用途に外れる使い方(イラスト使用含む)することを禁じます。  
 (製品版に含まれているので、フォントとして使用する場合は購入してください。)  
 ライセンスについて、よくわからない場合は、気軽に作者へ[メール(michinari.nukazawa@gmail.com)][mailto]にて、お問い合わせください。  

##extra/ ディレクトリについて。
extra/ディレクトリ内のライセンス文をご参照ください。

##フォント制作手順
全自動ではなく、手作業が含まれています。  
作業環境はIllustratorを除いてLinux(Ubuntu14.04)を想定しています。  
ただし、Ubuntu14.04標準のFontForge(2012年版)では、フォントが崩れる・線が入るなどの問題が、発生する場合があります。  
UbuntuPPA版の新しいFontForge(FontForge2014年版)を使用することを推奨します。  
 * Illustratorでフォントデザイン
 * Illustrator上でアウトライン化・標準SVGで出力
 * 生成スクリプト用の設定ファイルを書く
 * フォント生成スクリプト(fonts_generate.pl)でフォントを生成

グリフの形状が壊れる場合、手順中でアウトライン化の際に、以下の方法で解決する場合があります。  
 * アウトライン化のあとでパスファインダーによる結合を行う(グループ化を解除してください)。
 * グリフが1000x1000の領域から飛び出していないか確認してください。
どうしても直らない場合、作者に連絡をいただければ、対応できるかもしれません。  

公開しているプロジェクトに含まれる書体見本pdfは評価版のみです。製品版は含まれていません。
よって、書体見本誌の生成スクリプト・配布用zipの生成スクリプトは、エラーを標準出力します。  
(ファイルの生成自体は行います。)


##謝辞
以下のサイトを参考にさせていただきました。  

しろもじ作業室 の日本語かなフォント作成記事とスクリプト  
http://d.hatena.ne.jp/mashabow/20120314/1331744357

本プロジェクトの2014年版に含まれているスクリプト「svg_splitter.pl」は、
『mashabow＠しろもじ作業室（http://shiromoji.net, mashabow@shiromoji.net）』  
様の公開してくださっているスクリプトを元に作成したものです。  
なお、現在は「svg_splitter.py」(2-clause BSD license)に完全に置き換えられています。  

FontForge 公式ドキュメント  
http://fontforge.org/ja/

オル・チキ文字のUnicode表  
http://www.unicode.org/charts/PDF/U1C50.pdf

Wikipedia のオル・チキ文字の記事  
http://en.wikipedia.org/wiki/Ol_Chiki_alphabet

Deciphering the runes 研究ページ  
http://wiki.puella-magi.net/Deciphering_the_runes

IllustratorABC TIPSページの補填記事のIllustratorの設定  
http://www.slowgun.org/abc/ts12.html


##LICENCE About
Please read Japanese licence text.  
"RuneAMN_SerifEx" font is ratail product, "not free" and "script check only use".  
Build script is free (2-clause BSD license).  

##連絡先
[michinari.nukazawa@gmail.com][mailto]

Develop by Michinari.Nukazawa, in project "daisy bell".
[pixiv_booth_project_daisy_bell]: https://daisy-bell.booth.pm/
[sourceforge_project_daisy_bell]: http://sourceforge.jp/projects/daisybell-fonts/
[ghpages_RuneAMN_Pro]: http://michinarinukazawa.github.io/RuneAMN_Pro_Series_Fonts/docs/runeamn_pro.html
[typefaces_manuals_pdf]: https://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts/blob/gh-pages/releases/book_of_RuneAMN_Pro_Fonts_limited.pdf?raw=true
[pixiv_nukazawa_index]: http://www.pixiv.net/member.php?id=11951957
[ghpages_index_RuneAssignMN_Series_Fonts]: http://michinarinukazawa.github.io/RuneAssignMN_Series_Fonts/
[ghpages_index_OlChikiAssignMN_Series_Fonts]: http://michinarinukazawa.github.io/OlChikiAssignMN_Series_Fonts/
[blog_article]: http://blog.michinari-nukazawa.com/
[mailto]: mailto:michinari.nukazawa@gmail.com


