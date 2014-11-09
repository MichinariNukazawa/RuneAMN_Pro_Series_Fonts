#!/usr/bin/perl
#
# SVGをグリフごとに分割
# usage: perl ${THIS_SCRIPT.pl} svg_sheet.svg list.txt $out_dir="glyphs/" Width=1000 Height=1000 
#
# customize base script from:
#http://d.hatena.ne.jp/mashabow/20120314/1331744357
#
# depend:
#  xml:simple.pm // apt-get libxml-simple-perl
#

use strict;
use warnings;
use autodie;
use utf8;
use 5.010;
binmode STDOUT, ":utf8";
use Data::Dumper;
#warn Dumper $path;

my $Height = 1000;
if (4 <= $#ARGV){
	$Height = $ARGV[4];
}

my $Width = 1000;
if (3 <= $#ARGV){
	$Width = $ARGV[3];
}

my $out_dir = "glyphs_/";
if (2 <= $#ARGV){
	$out_dir = $ARGV[2];
}

if($#ARGV < 1){
	die("error :argc:" . $#ARGV . "");
}
my $list_file = $ARGV[1];
my $svg_file = $ARGV[0];



# 
# @param 文字列(path d属性の要素文字列)
# @return 分割後の文字列
sub split_path_d(){
	my $string = $_[0];
	my @strings = ();	

	#my @data_args = split /(\s+|)/, $path->{d};
	while ( $string=~ m/(?<match>[A-Za-z]|(-?\d+(\.\d+)?)(,(-?\d+(\.\d+)?))?)\s*(?<other>.*$)/){
		push(@strings, $+{match});
		$string = $+{other};
	}

#	warn Dumper @strings;
	return @strings;
}


# (必要なら)縦横サイズを500の倍数に繰り上げる。
# @param 繰り上げ前の数値
# @return	繰上げ後の数値
sub upcut(){
	my $target = $_[0];
	use POSIX;

	return 	(ceil($target/500) * 500);
}
my $PIXELS_PER_EM_COL = &upcut($Width);
my $PIXELS_PER_EM_ROW = &upcut($Height);

#$out_dir = $out_dir;
#$PIXELS_PER_EM_COL = $PIXELS_PER_EM_COL; # x,width
#$PIXELS_PER_EM_ROW = $PIXELS_PER_EM_ROW; # y,height
my $UNITS_PER_EM_COL	= $PIXELS_PER_EM_COL;
my $UNITS_PER_EM_ROW	= $PIXELS_PER_EM_ROW;

printf ("n:" . $PIXELS_PER_EM_COL."\n");
use XML::Simple;


# SVG 読み込み
my $svg = XMLin($svg_file, forcearray => 1, keyattr => []);

# 行数・列数を求める
$svg->{height} =~ m/(?<height>-?\d+)/ or die("svg height エラー:" . $svg->{height});
my $svg_height = $+{height};
$svg->{width} =~ m/(?<width>-?\d+)/ or die("svg width エラー:" . $svg->{width});
my $svg_width = $+{width};
my $row_max = int ($svg_height / $PIXELS_PER_EM_ROW) - 1;
my $col_max = int ($svg_width / $PIXELS_PER_EM_COL) - 1;
print("hxw : $row_max $col_max \n");


# outline レイヤーを探す
my $groups = $svg->{g};
my $group_outline;
foreach my $group (@$groups) {
	if (defined $group->{'inkscape:label'} && $group->{'inkscape:label'} eq "outline") {
		$group_outline = $group;
		last;
	}
}
#die "outlineレイヤーが存在しません" unless defined $group_outline;
# マルチグループ処理が上手くいかないので、以下のプリプロセスを実行して空グループを削除してください。
#  sed -i.bak -e '/<\/\?g>/d' FontSources/StencilSansSlimMNLatin_complete.svgb
if(! defined $group_outline){
	printf ("outlineレイヤーが存在しませんでした\n");
	$group_outline = $svg;
	
}


# 変換行列を求める
my $transform = $group_outline->{transform};
my ($a, $b, $c, $d, $e, $f) = (1, 0, 0, 1, 0, 0);
if (!defined $transform) {
	# noop
} elsif ($transform =~ m/translate\((?<tx>-?\d+(.\d+)?(e-?\d+)?),(?<ty>-?\d+(.\d+)?(e-?\d+)?)\)/) {
	$e = $+{tx};
	$f = $+{ty};
} elsif ($transform =~ m/matrix\((?<a>-?\d+(.\d+)?(e-?\d+)?),(?<b>-?\d+(.\d+)?(e-?\d+)?)\),(?<c>-?\d+(.\d+)?(e-?\d+)?),(?<d>-?\d+(.\d+)?(e-?\d+)?),(?<e>-?\d+(.\d+)?(e-?\d+)?),(?<f>-?\d+(.\d+)?(e-?\d+)?)/) {
	$a = $+{a};	$c = $+{c};	$e = $+{e};
	$b = $+{b};	$d = $+{d};	$f = $+{f};
} else {
	die "未対応のtransformです: $transform"
}

# グリフごとに path を格納する変数
# グリフごとに rect を格納する変数
my @glyphs_path = ();
my @glyphs_rect = ();
my @glyphs_polygon = ();
foreach my $row (0 .. $row_max) {
	foreach my $col (0 .. $col_max) {
		$glyphs_path[$row][$col] = [];
		$glyphs_rect[$row][$col] = [];
		$glyphs_polygon[$row][$col] = [];
	}
}



# @glyphs にパスを格納
my $paths = $group_outline->{path};
foreach my $path (@$paths) {

	my @data_args = &split_path_d($path->{d});
	my $new_data = "";
	my ($col, $row);
	my $is_moveto_point = 1;
	my $is_conv_point = 0;
	foreach my $data_arg (@data_args) {
		if ($data_arg =~ m/(?<x>-?\d+(\.\d+)?),(?<y>-?\d+(\.\d+)?)/) {
			my $x = $+{x};
			my $y = $+{y};
			if ($is_moveto_point) {
			#			print("$x,$y\n");
			$x = $a * $x + $c * $y + $e;
			$y = $b * $x + $d * $y + $f;
			$col = int ($x / $PIXELS_PER_EM_COL);
			$row = int ($y / $PIXELS_PER_EM_ROW);
			$is_moveto_point = 0;
			$is_conv_point = 100;

			#		print ("$row,$col:$x,$y\n");
		}
		if ($is_conv_point){
			$x %= $PIXELS_PER_EM_COL;
			$y %= $PIXELS_PER_EM_ROW;
			$is_conv_point = 0;
		}else{
			if($x > $PIXELS_PER_EM_COL){
				$x %= $PIXELS_PER_EM_COL;
			}
			if($y > $PIXELS_PER_EM_ROW){
				$y %= $PIXELS_PER_EM_ROW;
			}
		}
		$x *= $UNITS_PER_EM_COL / $PIXELS_PER_EM_COL;
		$y *= $UNITS_PER_EM_ROW / $PIXELS_PER_EM_ROW;

		$data_arg = " $x,$y ";
	}
	else{


		if ($data_arg =~ m/\d+(\.\d+)?/) {
			if ($is_conv_point){
				if (3 == $is_conv_point){
					$data_arg %= $PIXELS_PER_EM_ROW;
				}else{
					$data_arg %= $PIXELS_PER_EM_COL;
				}
				$is_conv_point = 0;
			}
		}elsif ($data_arg =~ m/[A-Z]/) {
			if($data_arg =~ m/H/){
				$is_conv_point = 2;
			}
			elsif($data_arg =~ m/V/){
				$is_conv_point = 3;
			}
			elsif($data_arg =~ m/L/){
				$is_moveto_point = 1;
				$is_conv_point = 1;		
			}
			else{
				$is_conv_point = 1;
			}
		}
		elsif ($data_arg =~ m/[a-z]/) {
			$is_conv_point = 0;
		}
		else{
			printf ("INVALID:" . $data_arg . "\n");
			$is_conv_point = 0;
		}
	}
	$new_data .= " $data_arg ";
} 
if ($col < 0 || $col_max < $col || $row < 0 || $row_max < $row){
	print ("inv\n");
	next;
}
$path->{d} = $new_data;
push @{$glyphs_path[$row][$col]}, $path;


}

# @glyphs_rect に四角形を格納
my ($a_1, $b_1, $c_1, $d_1, $e_1, $f_1);
my $sign_e = 1; my $sign_f = 1; 
my $rects = $group_outline->{rect};
foreach my $rect (@$rects) {
	my ($col, $row);
	my $x = $rect->{x};
	my $y = $rect->{y};
	my $width = $rect->{width};
	my $height = $rect->{height};
	
	$x = $a * $x + $c * $y + $e;
	$y = $b * $x + $d * $y + $f;
	$col = int ($x / $PIXELS_PER_EM_COL);
	$row = int ($y / $PIXELS_PER_EM_ROW);


#	warn Dumper  (	$rect->{transform});

	# 変換行列を求める
	
	my $transform = $rect->{transform};
	($a_1, $b_1, $c_1, $d_1, $e_1, $f_1) = (1, 0, 0, 1, 0, 0);
	if (!defined $transform) {

		$x %= $PIXELS_PER_EM_COL;
		$y %= $PIXELS_PER_EM_ROW;

	}else{
		# 
		if ($transform =~ m/translate\((?<tx>-?\d+(.\d+)?(e-?\d+)?),(?<ty>-?\d+(.\d+)?(e-?\d+)?)\)/) {
			$e_1 = $+{tx};
			$f_1 = $+{ty};
		} elsif ($transform =~ m/matrix\((?<a>-?\d+(.\d+)?(e-?\d+)?)[,\s](?<b>-?\d+(.\d+)?(e-?\d+)?)\)?[,\s](?<c>-?\d+(.\d+)?(e-?\d+)?)[,\s](?<d>-?\d+(.\d+)?(e-?\d+)?)[,\s](?<e>-?\d+(.\d+)?(e-?\d+)?)[,\s](?<f>-?\d+(.\d+)?(e-?\d+)?)/) {
			$a_1 = $+{a};	$c_1 = $+{c};	$e_1 = $+{e};
			$b_1 = $+{b};	$d_1 = $+{d};	$f_1 = $+{f};
		} else {
			die "未対応のtransformです: $transform";
		}
		
		my ($X, $Y);
		$X = $+{a} * $x + $+{c} * $y + $+{e};
		$Y = $+{b} * $x + $+{d} * $y + $+{f};
		$col = int ($X / $PIXELS_PER_EM_COL);
		$row = int ($Y / $PIXELS_PER_EM_ROW);


		$e_1 -= $PIXELS_PER_EM_COL * $col;
		$f_1 -= $PIXELS_PER_EM_ROW * $row;
		
		$rect->{transform} = "matrix(" . $a_1 . " " . $b_1 . " " . $c_1 . " " . $d_1 . " " . $e_1 . " " . $f_1 . ")";
		
		warn Dumper  ("TR:\n");
		warn Dumper  ($rect->{transform});
	}



	if ($col < 0 || $col_max < $col || $row < 0 || $row_max < $row){
		print ("inv\n");
		next;
	}

	
	$rect->{x} = $x;
	$rect->{y} = $y;
	$rect->{width} = $width;
	$rect->{height} = $height;



	push @{$glyphs_rect[$row][$col]}, $rect;
}

# @glyphs_polygon にポリゴンを格納
my $polygons = $group_outline->{polygon};
foreach my $poly (@$polygons) {
	my ($col, $row);
	my ($X, $Y);
	my ($x, $y);
	my $str_points = $poly->{points};
	my $res_points = "";
	
	my @points = split(/ /, $str_points);
	
	my $i;
	for ($i = 0; $i <= $#points; $i++) {
		if ($points[$i] =~ m/(?<x>-?\d+(.\d+)?(e-?\d+)?),(?<y>-?\d+(.\d+)?(e-?\d+)?)/) {
			$X = $a * $+{x} + $c * $+{y} + $e;
			$Y = $b * $+{x} + $d * $+{y} + $f;

			if (!defined $col){
				$col = int ($X / $PIXELS_PER_EM_COL);
				$row = int ($Y / $PIXELS_PER_EM_ROW);
			}
			$x = $X % $PIXELS_PER_EM_COL;
			$y = $Y % $PIXELS_PER_EM_ROW;
			$res_points .= $x . "," . $y . " ";
		}else{
			print ("error: polygon:\"" . $points[$i] . "\"\n");
			next;
		}
	}

	$poly->{points} = $res_points;
	push @{$glyphs_polygon[$row][$col]}, $poly

}


# リスト読み込み
my $nLine = 0;
my @glyphname_list = ();
open my $fh_list, '<:utf8', $list_file;
while (my $line = <$fh_list>) {
	$nLine++;
	if($nLine <= 3){
		# 3行目までは無視する
		next;
	}
	chomp $line;
	my @list = map { sprintf "u%04x", (unpack "U*", $_) } split / +/, $line;
	push @glyphname_list, \@list;
}
close $fh_list;

# 各グリフの SVG を生成
mkdir $out_dir if !-d $out_dir;
foreach my $row (0 .. $row_max) {
	foreach my $col (0 .. $col_max) {
		my $svg;
		$svg->{'xmlns:sodipodi'} = "http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd";
		$svg->{'xmlns:inkscape'} = "http://www.inkscape.org/namespaces/inkscape";
		$svg->{width} = $UNITS_PER_EM_COL;
		$svg->{height} = $UNITS_PER_EM_ROW;
		$svg->{path} = $glyphs_path[$row][$col];
		$svg->{rect} = $glyphs_rect[$row][$col];
		$svg->{polygon} = $glyphs_polygon[$row][$col];
		my $svg_string = '<?xml version="1.0" encoding="UTF-8"?>';
		$svg_string .= "\n" . XMLout($svg, RootName => "svg");
		my $glyphname = $glyphname_list[$row][$col];
		next if (!defined $glyphname || $glyphname eq "u3000"); # u3000：全角スペース
		my $pathGlyphFile =	$out_dir . "$glyphname.svg";
		open my $fh_out, '>', $pathGlyphFile;
		print $fh_out $svg_string;
		close $fh_out;
	}
}

exit 0;
