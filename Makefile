
.PHONY: all clean
.PHONY: package
.PHONY: package_free

all :
	perl ./fonts_generate.pl

package : package_free
package_free : all
	bash scripts/mkzip_retail_distribution.sh RuneAMN 1.$(shell date +'%Y%m%d') free

book :
	bash scripts/books_build.sh

clean :
	rm -rf releases/*.otf
	rm -rf *.zip



