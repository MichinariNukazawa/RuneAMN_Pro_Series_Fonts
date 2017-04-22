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

# example　use:	warn Dumper @fontfiles;
use Data::Dumper;
use FindBin;

my $pathLogFile = 'fonts_build.log';

# ビルドシステムのルートディレクトリを取得
my $dirWorkRoot = $FindBin::Bin;

# 作成開始日時 (フォントのバージョン番号を生成する際に、同一の開始日時を使う)
use POSIX 'strftime';
my $date = strftime( "%Y%m%d", localtime);
system("echo \"## date:$date\" >> $pathLogFile");
#my $date = strftime( "%Y%m%d%H%M%S", localtime);


# フォント設定ファイルの一覧を作成 (生成対象フォント一覧を兼ねる)
chdir($dirWorkRoot) or die ("Error. nothing dirWorkRoot:\"$dirWorkRoot\"");
my @fonts_setting = ();
my @settingFiles = &getSettingFiles($dirWorkRoot);
if ($#settingFiles < 0){
	print ("Notice. nothing setting files. dirWorkRoot: \"$dirWorkRoot\"\nexit\n");
	exit(0);
}

# フォントごとに設定を付与してMakeを呼び出す
foreach $settingFile(@settingFiles){

	my $pathSettingFile = "FontSources/" . $settingFile;
	open(DATAFILE, "<", $pathSettingFile) or die("Error. nothing pathSettingFile:\"$pathSettingFile\"");

	while (my $line = <DATAFILE>){
		chomp($line);
		next if (($line =~ m/^(\/\/.*)/) || ($line =~ m/^$/)); # コメントアウト・空行をスキップ

		if(! ($line =~ m/FontName\:(?<FontName>-?[\w_]+) Width\:(?<Width>-?\d+) Height\:(?<Height>-?\d+) baseline\:(?<baseline>-?\d+) isFree\:(?<isFree>-?\w+) isAssignLower\:(?<isAssignLower>-?\w+)/i)){
			die("Error. 設定行がルールにマッチしませんでした。 line:" . ${line});
		}else{
		#	my $fontName = $+{FontName};
		#	my $height = $+{Height};
		#	my $width = $+{Width};
		#	my $baseline= $+{baseline};
		#	my $isFree= $+{isFree};
		#	my $isAssignLower = $+{isAssignLower};
			my %font = %+;	
			if($font{Height} <= 0 || $font{Width} <= 0 || $font{baseline} <= 0 )
			{
				die("Error. HxW:" . $font{Height} . " x " .$font{Width} ." baseline:" . $font{baseline});
			}
			elsif( 1000 < $font{Height} || 1000 < $font{Width} || 1000 < $font{baseline})
			{
				die("Error. HxW:" . $font{Height} . " x " .$font{Width} ." baseline:" . $font{baseline});
			}
			if((!$font{isFree} =~ /(yes|no)/) || (!$font{isAssignLower} =~ /(yes|no)/))
			{
				die("Error. isFree:\"" . $font{isFree} . "\" isAssignLower:\"" . $font{isAssignLower} . "\"");
			}
			
			my $fontfile = "";
			if('' eq ($fontfile = &getLatestFile($font{FontName} . "_.*\\.otf", $dirWorkRoot . "/releases"))){
				$fontfile = 'PHONY'; # 擬似ターゲット
			}else{
				$fontfile = "releases/" . $fontfile;
			}

			# build to the command string.
			my $make_command = "FontName=" . $font{FontName} 
			. " Width=" . $font{Width} . " Height=". $font{Height} . " baseline=" . $font{baseline} 
			. " isFree=" . $font{isFree} . " isAssignLower=" . $font{isAssignLower} 
			. " Version=1.${date} FontFile=${fontfile} "
			. " make -f scripts/build_mods/font.Makefile ";

			# call to the make.
			my $ret = system("$make_command >> $pathLogFile");
			if(0 != $ret){
				die("Error. command:\"${make_command}\"");
			}
			print ("success make. :" . $font{FontName} . "\n");
			# Todo:FontForgeがエラーを返さない場合があるので、フォントファイルの存在をもって完了チェックする必要がある？
			
			last;
		}
	}
}

# 最新ファイルを取得して、zipより新しいものがあれば、zipを更新する。
#my $latest = &getLatestFile(".(zip\$\\|otf\$", $dirWorkRoot);
#print (" latest:" . $latest . "\n");
#if (! ($latest =~ m/\.zip$/)){
#	
#}

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
	opendir(DIRHANDLE, $dir) or die("Error. dir:\"$dir\"");

	foreach(readdir(DIRHANDLE)){
		next if /^\.{1,2}$/;    # '.'と'..'をスキップ
		if($_ =~ m/.+_list.txt$/){
			push(@list, $_);
		}
	}
	closedir(DIRHANDLE);

	return @list;	
}

