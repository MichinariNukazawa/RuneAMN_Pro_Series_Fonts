/** 
 * brief : 非表示のパス・レイヤを削除する。
 * 		Adobe Illustrator script(JavaScript).
 * 		RuneAMN_Blackletterなどで、シンボルを位置決めしている透明なパスによる枠が、
 *		書き出しの際に「パスファインダーの結合」を使う邪魔になるので、すべて削除しなければならない。
 *
 * usage: Illustrator / Ctrl+F12
# author : MichinariNukazawa / "project daisy bell"
# 	michinari.nukazawa@gmail.com
# 	https://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts
# license: clause-2 BSD license
 *
 * 既知の問題: 2回適用しないとすべての非表示パスが消えない場合がある。
 */

// 非表示のレイヤを削除する
layers = activeDocument.layers;
for (i=0; i<layers.length; i++)
{
	if( !layers[i].visible ){
		layers[i].locked = false;
		// 非表示レイヤはremove()しようとするとエラー失敗する
		layers[i].visible = true;
		layers[i].remove();
	}
}

pathObj = activeDocument.pathItems;
// 非表示のパスを削除する
for (i=0; i<pathObj.length; i++)
{	
	if( ((!pathObj[i].filled) && (!pathObj[i].stroked)) || pathObj[i].hidden ){
		pathObj[i].locked = false;
		pathObj[i].remove();
	}
}


