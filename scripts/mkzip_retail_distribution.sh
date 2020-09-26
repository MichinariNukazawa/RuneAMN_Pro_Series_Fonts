#!/bin/bash
<<COMMENT
# brief : 製品版 zipファイルを生成する
# 	(Widnows用に、ファイル名がCP932で格納されたzipを生成する。
#
# author : MichinariNukazawa / "project daisy bell"
# 	michinari.nukazawa@gmail.com
# 	https://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts
# license : 2-clause BSD license
#
# depend : sudo apt-get install convmv -y)
COMMENT

ThisPath=$(cd $(dirname $0);pwd)
PathProjectRoot=$(dirname $ThisPath)

# 引数の個数をチェック
if [ 2 -eq $# ] ; then
	echo "argv:2"
elif [ 3 -eq $# ] ; then
	echo "argv:3"
else
	echo "error: invalid args: \"$@\"(num:$#)" 1>&2
	# "example: ./mkzip_free.sh RuneAMN 1.20140809235940 [retail]"
	echo "Usage: ./(this) FontSeriesName Version [retail]"
	exit 1
fi

# エンコーディング変換コマンド(ファイル名)の有無を確認
convmv --help > /dev/null
RET=$?
if [ 1 -ne $RET ] ; then
	echo "error: call convmv:$RET" 
	exit $RET
fi

# フォント名
FontSeriesName=$1
# フォントのバージョン番号
Version=$2
Kind="free"
if [ 3 -eq $# ] ; then
	if [ "retail" = $3 ] ; then
		Kind="retail" # retail
	fi
fi

#nameZip="${FontSeriesName}_font_set_retail_ver${Version}"
nameZip=${FontSeriesName}"_font_set_"${Kind}"_ver"${Version}

cd $(dirname "$ThisPath")
echo  "$ThisPath"


#### 再配布ファイルをディレクトリに集める
rm -f "$nameZip.zip"
mkdir "$nameZip"

#### フォントを収集し、変換をかける
mkdir "$nameZip/fonts"
find "releases/" -name "${FontSeriesName}*.otf"
if [ 0 -ne $? ] ; then
	echo "error find fonts"
	exit -1
fi
find "releases/" -name "${FontSeriesName}*.otf" | xargs -i cp {} "${nameZip}/fonts/"
if [ 0 -ne $? ] ; then
	echo "error find cp fonts"
	exit -1
fi
find "release_static/" -name "${FontSeriesName}*.otf" | xargs -i cp {} "${nameZip}/fonts/"
if [ 0 -ne $? ] ; then
	echo "error find cp fonts"
	exit -1
fi
# フリー版ではPro版のフォントを取り除く
if [ "free" = $Kind ] ; then
	rm -rf ${nameZip}"/fonts/"${FontSeriesName}"_Pro"*".otf" > /dev/null
	rm -rf ${nameZip}"/fonts/"${FontSeriesName}"_SerifEx"*".otf" > /dev/null
	rm -rf ${nameZip}"/fonts/"${FontSeriesName}"_Blackletter"*".otf" > /dev/null
	rm -rf ${nameZip}"/fonts/"${FontSeriesName}"_Rounded"*".otf" > /dev/null
	rm -rf ${nameZip}"/fonts/"${FontSeriesName}"_VLine"*".otf" > /dev/null
fi

# build .ttf fonts
pushd ${nameZip}"/fonts"
mkdir "ttf"
find -name "*.otf" | xargs -I{} fontforge -lang=py -script ${PathProjectRoot}"/scripts/mods/otf2ttf.py" {}
popd

#### その他のものを集める
cp "docs/etcs/ttfフォントについて.txt" "$nameZip/fonts/ttf/"
#cp "releases/book_of_RuneAMN_Pro_Fonts_limited.pdf" "$nameZip/書体見本_マニュアル.pdf"
if [ "free" = $Kind ] ; then
	cp "releases/book_of_RuneAMN_Pro_Fonts_limited.pdf" "$nameZip/書体見本_マニュアル_製品評価版.pdf"
else
	cp "releases/book_of_RuneAMN_Pro_Fonts.pdf" "$nameZip/書体見本_マニュアル.pdf"
	cp "docs/etcs/LICENSE.txt" "$nameZip/ライセンス.txt"
fi
# オマケを添付して不要な隠しファイルを除去する
cp -R "extra/" "$nameZip/"
if [ 0 -ne $? ] ; then
	echo "error copy extra."
	exit -1
fi
if [ "retail" = $Kind ] ; then
	cp -r extra_patchRetail/* "$nameZip/extra"
	if [ 0 -ne $? ] ; then
		echo "error copy extra_patchRetail."
		exit -1
	fi
fi
find "$nameZip/extra/" -name ".*" | xargs -i rm -rf {}
find "$nameZip/extra/" -name "*~" | xargs -i rm -rf {}
# 個別のファイル
cp "docs/etcs/AssignListRuneToLatin_ja.jpg" "$nameZip/割り当て表.jpg"
cp "docs/etcs/README_ja.txt" "$nameZip/はじめにお読みください.txt"
cp "docs/etcs/Fonts_link_win.lnk" "$nameZip/"
cp "docs/etcs/Install_ja.jpg" "$nameZip/インストール.jpg"

#### zipする前に、ファイル名をCP932でエンコーディング変換する
convmv -f utf8 -t cp932 -r --notest "$nameZip/"
if [ 0 -ne $? ] ; then
	echo "error convmn"
	exit -1
fi
pushd "$nameZip/"
zip -9 -r "../$nameZip.zip" *
popd
rm -rf "$nameZip"


