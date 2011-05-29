/**
 * クラス名: rss.js
 * 
 * バージョン情報: 2009042401NO
 *
 * 日付け: 2009/04/24
 * 
 * 著作権: Vasdaq Japan,Ltd.
 * 
 * 備考: RSSを取得し整形するクラス
 * 
 */

function convert(items, _id, _num, _search) {
	self["items"] = items;
	self["_id"] = _id;
	self["_num"] = _num;
	self["_search"] = _search;
	self["count"] = 0;
	getStr(items, _id, _num, _search,count);
	self["count"] = 1;
	setInterval("getStr(items, _id, _num, _search, count)",5000);

}
/**
 * メソッド名: convert
 * 
 * 引数: items	RSSから取得したitemタグの要素
 * 引数: _id		HTMLに埋め込む際のid名
 *
 * 戻り値: 無し
 * 
 * 備考: HTML変換処理。itemノードの内容からHTMLを生成します。
 */
function getStr(items, _id, _num, _search,count) {

	i = count%50;
	var text="";
	if(items[i] != null){
		//RSSからタイトルを取得
		var title = getNodeValue(items[i], "title");
		//作者の取得
		author = items[i].getElementsByTagName("author")[0].getElementsByTagName("name")[0].firstChild.nodeValue;

		//アイコンの取得
		var icon ="";
		for(var j =0; j< items[i].getElementsByTagName("link").length; j++){
			type = items[i].getElementsByTagName("link")[j].getAttributeNode("type").value;
			if(type == "image/png"){
				icon = items[i].getElementsByTagName("link")[j].getAttributeNode("href").value;
			}
		}
		//RSSから取得した要素をHTMLに加工する
		text = setStrAttribute( title, author, icon, _search);
		self["count"] = count + 1;
	}
	if(items[i + 1] == null){
		self["count"] = 0;
	}
	//インナーHTMLとして埋め込む	
	document.getElementById(_id).innerHTML = text;
}

/**
 * メソッド名: getNodeValue
 * 
 * 引数: node		取得元のノード
 * 引数: nodeName	取得したいノード名
 *
 * 戻り値: ノード値
 * 
 * 備考: RSSから特定のタグに囲まれた要素を取得する
 */
function getNodeValue(node, nodeName) {
  return node.getElementsByTagName(nodeName)[0].firstChild.nodeValue;
}


function setStrAttribute(_title, _author, _icon, _search){
	str = "<table width='125px' height='190px'>"
		+ "<tr>"
		+ "<td style='vertical-align:top;' align='center'>"
		+ "<img src='"+ _icon+"' width='68' height='68'>"
		//+ "</td><td style='padding-left:5px;color:#ff7e00;font-size:10px;vertical-align:top;'>"
		//+ "<text>" + _author + "</text><br>"
		//+ "<text style='color:#FFFFFF;font-size:10px;'>" + 'キーワード：' + "</text><br>"
		//+ "<text style='color:#FFFFFF;font-size:10px;'>" + _search + "</text>"
		+ "</td>"
		+ "<tr> "
		+ "<td colspan=2 style='vertical-align:top;' height='130px'>"
		+ _title
		+ "</td>"
		+ "</table>";



	return str;
}




