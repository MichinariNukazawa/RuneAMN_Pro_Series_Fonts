#!/bin/bash
<<COMMENT
# brief : building free/retail Manual's. for RuneAMN_Pro series fonts.
# usage : bash ./books_build.sh
#
# author : MichinariNukazawa / "project daisy bell"
# 	michinari.nukazawa@gmail.com
# 	https://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts
# license : 2-clause BSD license
# depend : sudo apt-get install texlive -y
COMMENT

PathThisDir=$(cd $(dirname $0);pwd)
PathProjectRoot=${PathThisDir}"/.."
FULL=${PathThisDir}"/mods/book_of_RuneAMN_Pro_Fonts.tex"
LIMITED=${PathThisDir}"/mods/book_of_RuneAMN_Pro_Fonts_limited.tex"

Return=0

# pushd(cd) is target of book_of_rune dir.
pushd ${PathThisDir}/../docs/book_of_rune

pdflatex -halt-on-error -interaction=nonstopmode -file-line-error "$FULL" > ${PathThisDir}"/tex.log"
if [ 0 -ne $? ] ; then
	echo "error: full version build is failure."
	Return=-1
	# exit -1
fi

cp "$FULL" "$LIMITED"
perl -i -p -e 's:full:limited:g;' "$LIMITED"
perl -i -p -e 's:^.*PostScript.pdf.*\Z:%POSTSCRIPT:g;' "$LIMITED"

pdflatex -halt-on-error -interaction=nonstopmode -file-line-error "$LIMITED" >> ${PathThisDir}"/tex.log"
if [ 0 -ne $? ] ; then
	echo "error: limited version build is failure."
	exit -1
fi

rm book*.log
rm book*.aux
rm "$LIMITED"

mv $(basename "${FULL%.tex}.pdf") ${PathProjectRoot}"/releases/"
mv $(basename "${LIMITED%.tex}.pdf") ${PathProjectRoot}"/releases/"
if [ 0 -ne $? ] ; then
	echo "error: move pdf."
	exit -1
fi

popd

exit ${Return}

