/** 
 * 非表示のパス・レイヤを削除する。
 * Adobe Illustrater script(JavaScript).
 * Michinari.Nukazawa@gmail.com
 * License: BSD class2
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


