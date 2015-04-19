#!/bin/perl
#
# usage : perl ./fonts_generate.pl
#
# author : MichinariNukazawa / "project daisy bell"
# 	michinari.nukazawa@gmail.com
# 	https://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts
# license : 2-clause BSD license
#

use utf8;
use open ":utf8";

use Data::Dumper;
#warn Dumper @settingFiles;


# 
use FindBin;
my $dirWorkRoot = $FindBin::Bin;
printf("path:$dirWorkRoot\n");

# (バージョン番号に使うので統一するために取得しておく)
use POSIX 'strftime';
my $date = strftime( "%Y%m%d", localtime);
#my $date = strftime( "%Y%m%d%H%M%S", localtime);



# フォントごとの設定ファイルを読み込み(ターゲットフォント一覧の生成を兼ねる)
my @fonts_setting = ();

chdir($dirWorkRoot) or die ("error :$!");
my @settingFiles = &getSettingFiles($dirWorkRoot);

if ($#settingFiles < 0){
	print ("nothing setting files: " . $#settingFiles . " exit\n");
	exit(0);
}

# フリー版一覧
my @free_distributions = ();

foreach $settingFile(@settingFiles){

	my $pathSettingFile = "FontSources/" . $settingFile;
	printf "" . $pathSettingFile . "\n";
	open(DATAFILE, "<", $pathSettingFile) or die("error :$!");


	while (my $line = <DATAFILE>){
		chomp($line);
		# print "Setting: ". ${line} . " \n";
		if(($line =~ m/^(\/\/.*)/) || ($line =~ m/^$/)){
			# コメントアウト・空行をスキップ
			next;
		}
		if(! ($line =~ m/FontName\:(?<FontName>-?[\w_]+) Width\:(?<Width>-?\d+) Height\:(?<Height>-?\d+) baseline\:(?<baseline>-?\d+) isFree\:(?<isFree>-?\w+) isAssignLower\:(?<isAssignLower>-?\w+)/i)){
			die("error :設定行がルールにマッチしませんでした。 line:" . ${line});
		}else{
			print "Setting: ". ${line} . " \n";
			my $fontName = $+{FontName};
			my $height = $+{Height};
			my $width = $+{Width};
			my $baseline= $+{baseline};
			my $isFree= $+{isFree};
			my $isAssignLower = $+{isAssignLower};
			if(1000 < $height || 1000 < $width || 1000 < $baseline){
				die("error :$height x $width baseline:$baseline");
			}
			if((!$isFree =~ /(yes|no)/) || (!$isAssignLower =~ /(yes|no)/)){
				die("error :$isFree $isAssignLower");
			}



# use Data::Dumper;
# warn Dumper %+;
# printf ("SEP+++\n");
			%font = %+;
# use Data::Dumper;
# warn Dumper %font;

			my $fontfile = "";
			# print "font: ". $font{FontName} . "\n";
			if('' eq ($fontfile = &getLatestFile($font{FontName} . "_.*\\.otf", $dirWorkRoot . "/releases"))){
				$fontfile = 'PHONY'; # 擬似ターゲット
			}else{
				$fontfile = "releases/" . $fontfile;
			}



			$make_command = "FontName=" . $font{FontName} . " "
			. " Width=" . $font{Width} ." Height=". $font{Height} ." baseline=". $font{baseline} ." isFree=" . $font{isFree} ." isAssignLower=" .$font{isAssignLower} ." "
			. " Version=1.${date} FontFile=${fontfile} "
			. " make -f scripts/build_mods/font.makefile ";

			$ret = `$make_command`;
			# FontForgeがエラーを返さない場合があるので、フォントファイルの存在をもって完了チェックする必要がある。
			if(0 != $!){
				die("error :${ret} command:${make_command}");
			}
			print ("success makefile ret:${ret}\n");
			
			# フリー版フォントの一覧へ追加。 
			if( $font{isFree} =~ m/yes/i){
				push(@free_distributions, $font{FontName});
			}
			last;
		}
	}
}

# warn Dumper @free_distributions;

# 最新ファイルを取得して、zipより新しいものがあれば、zipを更新する。
my $latest = &getLatestFile(".(zip\$\\|otf\$", $dirWorkRoot);
print (" latest:" . $latest . "\n");
if (! ($latest =~ m/\.zip$/)){
	
}

print ("complete\n");



#
# 引数: ファイル名(探索条件), 探索対象パス
# 戻り値: 最新ファイル名
#
sub getLatestFile() {
	my $search = $_[0];
	my $dirSearch = $_[1];

	my $files = `cd '${dirSearch}';ls -1t | grep '${search}'`;
	# 実行ステータスは$?で取れる。


	my @files = split(/\n/, $files);
	if( $#files < 0){
		return '';
	}else{
#		printf("test:\n\n");
#		warn Dumper @fontfiles;
#		printf("test:\n");
#		warn Dumper @fontfiles[0];
		return @files[0];
	}	
}

#
# 引数: プロジェクトのルートディレクトリ
# 戻り値: 設定ファイル一覧
#
sub getSettingFiles(){
	my $dirWorkRoot = $_[0];
	my @list = ();

	my $dir = $dirWorkRoot . "/FontSources/";
	printf "path:$dir\n";
	opendir(DIRHANDLE, $dir) or die("error :$?");

	foreach(readdir(DIRHANDLE)){
		next if /^\.{1,2}$/;    # '.'や'..'をスキップ
		if($_ =~ m/.+_list.txt$/){
			printf $_ . " files MAST\n" ;
			push(@list, $_);
		}
	}
	closedir(DIRHANDLE);

	return @list;	
}

