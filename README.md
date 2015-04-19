RuneAMN_Pro Series Fonts (build scripts and other). 商用イラスト・デザイン向けルーン文字フォント・ビルドスクリプト
====

##概要
RuneAMN_Pro Series Fontsは、商用イラスト・デザイン向けルーン文字フォントです。  
このプロジェクトは、その商用フォント製品のビルドスクリプトを公開しているページです。  

RuneAssignMN_Pro Series Fontsの特徴:  
ラテン・アルファベットの"A〜z"にルーン文字を割り当ててあります。  
ふつうの英文を用意し、このフォントを使うだけで、簡単にルーン文字で書かれた文章を"でっちあげる"ことができます。  

フォントの書体デザインは、  
 [製品評価版 書体見本(PDF)][typefaces_manuals_pdf]  
 または  
 [Pixiv][pixiv_nukazawa_index]  
にて見ることができます。  

姉妹フォントに  
[RuneAssignMN_Series_Font][ghpages_index_RuneAssignMN_Series_Fonts]  
[OlChikiAssignMN_Series_Font][ghpages_index_OlChikiAssignMN_Series_Fonts]  
があります。  
これらは、フリーフォントです。ビルドスクリプトおよび書体ソース画像も、フリーソフトウェアとして公開されています。  


##フォントのライセンス
 プロジェクトに含まれている"RuneAMN_Serif"フォントの書体ソース画像は、ビルドスクリプトの動作確認および、ビルドスクリプト転用の際にソース画像と設定ファイルを用意するための参考資料として使うことのみを目的に、添付されているものです。  
 書体ソース画像および、そこから生成したフォントファイルを、上記の用途に外れる使い方(イラスト使用含む)することを禁じます。  
 (製品版に含まれているので、フォントとして使用する場合は購入してください。)  
 ライセンスについて、よくわからない場合は、気軽に作者へ[メール(michinari.nukazawa@gmail.com)][mailto]にて、お問い合わせください。  

##スクリプトのライセンス
svg_splitter.plを除いて、すべて"2-clause BSD license"ライセンスです。  
(もちろん、あなたのデザインとこのスクリプトで作成したフォントは、あなたが任意のライセンスで公開（あるいは販売)することができます。)  

##スクリプト「svg_splitter.pl」について。
本プロジェクトに含まれるスクリプト「svg_splitter.pl」は、
『mashabow＠しろもじ作業室（http://shiromoji.net, mashabow@shiromoji.net）』  
様の公開してくださっているスクリプトを元に作成したものです。  
(今回の用途に供するために、明らかに美しくない方法を含んだいくつかの変更を当てました。)  
このスクリプトのライセンスは不明です。  

##フォント制作手順
全自動ではなく、手作業が含まれています。  
作業環境はIllustraterを除いてLinux(Ubuntu14.04)を想定しています。  
また、Ubuntu14.04標準のFontForge(2012年版)では、フォントが崩れる・線が入るなどの問題が、発生する場合があります。  
UbuntuPPA版の新しいFontForge(FontForge2014年版)を使用することを推奨します。  
 * Illustraterでフォントデザイン
 * Illustrater上でアウトライン化・標準SVG(1.1?)で出力
 * フォント生成スクリプト(fonts_generate.pl)でフォントを生成

グリフの形状が壊れる場合、手順中でアウトライン化の際に、以下の方法で解決する場合があります。  
 * アウトライン化のあとでパスファインダーによる結合を行う(グループ化を解除してください)。
 * グリフが1000x1000の領域から飛び出していないか確認してください。
どうしても直らない場合、作者に連絡をいただければ、対応できるかもしれません。  

製品zipのビルドスクリプトは、公開しているプロジェクトに、製品版の書体見本pdfを含んでいないため、エラーを標準出力します。
(zipの生成自体は行います。)


##謝辞
以下のサイトを参考にさせていただきました。  

しろもじ作業室 の日本語かなフォント作成記事とスクリプト  
http://d.hatena.ne.jp/mashabow/20120314/1331744357

FontForge 公式ドキュメント  
http://fontforge.org/ja/

オル・チキ文字のUnicode表  
http://www.unicode.org/charts/PDF/U1C50.pdf

Wikipedia のオル・チキ文字の記事  
http://en.wikipedia.org/wiki/Ol_Chiki_alphabet

Deciphering the runes 研究ページ  
http://wiki.puella-magi.net/Deciphering_the_runes

IllustraterABC TIPSページの補填記事のIllustraterの設定  
http://www.slowgun.org/abc/ts12.html


##LICENCE About
Please read Japanese licence text.  
Font use illustration and design is ratail product, "not free" and "script check only use".  
Build script is free (2-clause BSD license).
but, svg splitter is original: http://d.hatena.ne.jp/mashabow/20120314/1331744357
This svg splitter script LICENSE is the unknown.

##連絡先
[michinari.nukazawa@gmail.com][mailto]

Develop by Michinari.Nukazawa, in Project "daisy bell".
[ghpages_index]: http://michinarinukazawa.github.io/RuneAMN_Pro_Series_Fonts/
[typefaces_manuals_pdf]: https://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts/blob/gh-pages/manuals/書体見本_マニュアル_製品評価版.pdf?raw=true
[pixiv_nukazawa_index]: http://www.pixiv.net/member.php?id=11951957
[ghpages_index_RuneAssignMN_Series_Fonts]: http://michinarinukazawa.github.io/RuneAssignMN_Series_Fonts/
[ghpages_index_OlChikiAssignMN_Series_Fonts]: http://michinarinukazawa.github.io/OlChikiAssignMN_Series_Fonts/
[blog_article]: http://blog.michinari-nukazawa.com/
[mailto]: mailto:michinari.nukazawa@gmail.com


