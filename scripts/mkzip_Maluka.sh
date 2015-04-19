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
	echo "error: argv:3"
	exit -1
else
	echo "error: invalid args: \"$@\"(num:$#)" 1>&2
	# "example: ./mkzip_free.sh RuneAMN 1.20140809235940 [retail]"
	echo "Usage: ./(this) FontSeriesName Version"
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
Kind="retail"

nameZip=${FontSeriesName}"_font_"${Kind}"_ver"${Version}

cd $(dirname "$ThisPath")
echo  "$ThisPath"

# 再配布ファイルをディレクトリに集める
rm -f "$nameZip.zip"
mkdir "$nameZip"
# フォントを収集し、変換をかける
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
find "releases-static/" -name "${FontSeriesName}*.otf" | xargs -i cp {} "${nameZip}/fonts/"
if [ 0 -ne $? ] ; then
	echo "error find cp fonts"
	exit -1
fi
pushd ${nameZip}"/fonts"
mkdir "ttf"
find -name "*.otf" | xargs -I{} fontforge -lang=py -script ${PathProjectRoot}"/scripts/mods/otf2ttf.py" {}
popd
#cp -r "ttf" "$nameZip/"
# その他のものを集める
cp "docs/etcs/ttfフォントについて.txt" "$nameZip/fonts/ttf/"
cp "../RabbitMaluka/docs/RadditMaluka_typeface.pdf" "$nameZip/RabbitMaluka_書体見本.pdf"
cp "releases/book_of_RuneAMN_Pro_Fonts_limited.pdf" "$nameZip/daisy_bell_フォント製品書体見本_マニュアル_製品評価版.pdf"
cp "docs/etcs/Fonts.lnk" "$nameZip/"
cp "docs/etcs/インストール.jpg" "$nameZip/"
cp "../RabbitMaluka/LICENSE_RabbitMaluka.txt" "$nameZip/"
# zipする前に、ファイル名をCP932でエンコーディング変換する
convmv -f utf8 -t cp932 -r --notest "$nameZip/"
if [ 0 -ne $? ] ; then
	echo "error convmn"
	exit -1
fi
pushd "$nameZip/"
zip -9 -r "../$nameZip.zip" *
popd
rm -rf "$nameZip"


