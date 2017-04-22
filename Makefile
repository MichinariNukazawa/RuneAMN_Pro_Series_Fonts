
.PHONY: all clean

all :
	perl ./fonts_generate.pl

clean :
	rm -rf releases/*.otf



