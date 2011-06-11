function backgroundsystem(str)
{
	if (str == 'color'){
		document.getElementById('Image').style.display = 'none';
		document.getElementById('page_propertie[background]').style.display = 'block';
		jQuery("#Color").fadeIn();
	}
	if (str == 'image'){
		document.getElementById('Color').style.display = 'none';
		document.getElementById('page_propertie[background]').style.display = 'none';
		jQuery("#Image").fadeIn();
	}
}

function clocktype(str)
{
	var digitaldiv = document.getElementById('digital');
    var analogdiv = document.getElementById('analog');
	if (str == 'digital') {
		digitaldiv.style.display = 'block';
		analogdiv.style.display = 'none';
	}
	if (str == 'analog'){
		digitaldiv.style.display = 'none';
		analogdiv.style.display = 'block';
	}
}

//RSS YAML period show
function period(controlname){
	var name=controlname;
	if (name == 'rss'){
		if (document.getElementById('contents_setting_periodtype_').selectedIndex=="0"){
			document.getElementById('contents_setting[rssperiod]').value = "";
			document.getElementById('contents_setting[rssperiod]').disabled = true;
			document.getElementById('rssnow').style.display = 'block';
			document.getElementById('rssago').style.display = 'none';
		}else{
			document.getElementById('contents_setting[rssperiod]').disabled = false;
			document.getElementById('rssnow').style.display = 'none';
			document.getElementById('rssago').style.display = 'block';
		}
	}
	if (name == 'yaml'){
		if (document.getElementById('contents_setting[yamlperiodtype]').selectedIndex=="0"){
			document.getElementById('contents_setting[yamlperiod]').value = "";
			document.getElementById('contents_setting[yamlperiod]').disabled = true;
			document.getElementById('yamlnow').style.display = 'block';
			document.getElementById('yamlago').style.display = 'none';
		}else{
			document.getElementById('contents_setting[yamlperiod]').disabled = false;
			document.getElementById('yamlnow').style.display = 'none';
			document.getElementById('yamlago').style.display = 'block';
		}	
	}
	if (name == 'yamlgraph'){
		if (document.getElementById('yamlgraphperiod-type').selectedIndex=="0"){
			document.getElementById('yamlgraph-period').value = "";
			document.getElementById('yamlgraph-period').disabled = true;
			document.getElementById('yamlgraphnow').style.display = 'block';
			document.getElementById('yamlgraphago').style.display = 'none';
		}else{
			document.getElementById('yamlgraph-period').disabled = false;
			document.getElementById('yamlgraphnow').style.display = 'none';
			document.getElementById('yamlgraphago').style.display = 'block';
		}	
	}
}

// line properties control method
function lineproperties()
{
    var value = document.getElementById("contents_setting[linecontrol]").value;
    var path1 = document.getElementById('urlpath1');
    var path2 = document.getElementById('urlpath2');
    var path3 = document.getElementById('urlpath3');
    if(value=="line1")
    {
        path1.style.display='block';
        path2.style.display='none';
        path3.style.display='none';
    }
    if(value=="line2")
    {
        path1.style.display='none';
        path2.style.display='block';
        path3.style.display='none';
    }
    if(value=="line3")
    {
        path1.style.display='none';
        path2.style.display='none';
        path3.style.display='block';
    }
}


function playerfunction(player_value){
	document.getElementById("control").disabled = true;
	jQuery("div#functionbox div.functionboxClass ").css("display","none");
	jQuery("div#"+player_value).css("display","block");
}

function templatesetting(){
	jQuery("#property-started").slideUp();
	jQuery("#precontroldiv").fadeOut();
	document.getElementById("templatescreen").style.display = "block";
}

function temphidden(str){
	if (str == "true"){
	document.getElementById('hidetempcomfirm').style.display='none';
	}
	if (str == "false"){
		document.getElementById('hidetempcomfirm').style.display='block';
	}	
}

function scrolltype(){
	var type = document.getElementById("contents_setting[control_type]").value
	if (type == "1" || type == "3"){
		document.getElementById("scrollproperty").style.display = "block"
	}
	else{
		document.getElementById("scrollproperty").style.display = "none"
	}
}

function infogooglekey(str){
	if (str == "block") {
		jQuery("#info").fadeIn(3000);
		
	}
}

//drag & drop 
function dragresize(id,playerid){
	var length = document.getElementById("content_length").value;
	document.getElementById("current_player_id").value = playerid;
	for(i=1; i<=length; i=i+1){
		if (i==id){
			$("#player"+i).css("border-color","#020b6e");
		}
		else{
			$("#player"+i).css("border-color","#ccc");
		}
	}
	$("#player"+id).css("border-color","#020b6e")
	
	$("#player"+id).css("background-color","#dbfcac");
}

function player_size(id,width,height,playerid,x_pos,y_pos){
	$("#player"+id).jqResize('.jqResize');
	//$("#player"+id).css("background-color","#dbfcac");
	var layoutwidth = document.getElementById(playerid+"width").value;
	var layoutheight = document.getElementById(playerid+"height").value;
	var layoutxpos = document.getElementById(playerid+"x").value;
	var layoutypos = document.getElementById(playerid+"y").value;

	if(width == layoutwidth){
		document.getElementById("dragwidth").value = width;
	}
	else{
		document.getElementById("dragwidth").value = layoutwidth;
	}
	if(height == layoutheight){
		document.getElementById("dragheight").value = height;
	}
	else{
		document.getElementById("dragheight").value = layoutheight;
	}
	if(x_pos == layoutxpos){
		document.getElementById("x_setting").value = x_pos;
	}
	else{
		document.getElementById("x_setting").value = layoutxpos;
	}
	if(y_pos == layoutypos){
		document.getElementById("y_setting").value = y_pos;
	}
	else{
		document.getElementById("y_setting").value = layoutypos;
	}
}

function dragposition(id,width,height,playerid,x_pos,y_pos) {
	var length = document.getElementById("content_length").value;
	for(i=1; i<=length; i=i+1){
		if (i==id){
			$("#player"+i).css("border-color","#020b6e");
		}
		else{
			$("#player"+i).css("border-color","#ccc");
		}
	}
	var layoutwidth = document.getElementById(playerid+"width").value;
	var layoutheight = document.getElementById(playerid+"height").value;
	var layoutxpos = document.getElementById(playerid+"x").value;
	var layoutypos = document.getElementById(playerid+"y").value;
	
	if(width == layoutwidth){
		document.getElementById("dragwidth").value = width;
	}
	else{
		document.getElementById("dragwidth").value = layoutwidth;
	}
	if(height == layoutheight){
		document.getElementById("dragheight").value = height;
	}
	else{
		document.getElementById("dragheight").value = layoutheight;
	}
	if(x_pos == layoutxpos){
		document.getElementById("x_setting").value = x_pos;
	}
	else{
		document.getElementById("x_setting").value = layoutxpos;
	}
	if(y_pos == layoutypos){
		document.getElementById("y_setting").value = y_pos;
	}
	else{
		document.getElementById("y_setting").value = layoutypos;
	}
}

function player_drag(id,playerid){
	$("#player"+id).draggable({
  	opacity  : 0.8,
    handles:"all",
    ghosting:false,
    containment:"parent",
		stop:function(e,ui){
		$("#player"+id).css("background-color","#dbfcac")
		document.getElementById(playerid+"x").value = ui.position.left;
		document.getElementById(playerid+"y").value = ui.position.top;
		document.getElementById("x_setting").value = ui.position.left;
		document.getElementById("y_setting").value = ui.position.top;
		}
	})
}

function reservedate(id,flag){
	if (flag=="0"){
		ids = id;
	}
	else{
		ids = id.split(",");
	}
	
	n = 1
	for(i=0; i<ids.length; i++){
		if (ids[i] == ""){
			break;
		}
		else{
			var top="";
			var left="";
			reserves = document.getElementById(ids[i]+"reserve").value;
			preserves = document.getElementById(ids[i]+"preserve").value;
			reserve = reserves.split("*");
			document.getElementById("player"+[n]).style.width = (reserve[0]-2)+"px";
			document.getElementById(ids[i]+"width").value = reserve[0];
			document.getElementById("player"+[n]).style.height = (reserve[1]-2)+"px";
			document.getElementById(ids[i]+"height").value = reserve[1];
			preserve = preserves.split("*");
			top = parseInt(preserve[1]);
			left = parseInt(preserve[0]);
			document.getElementById("player"+[n]).style.top = top+"px";
			document.getElementById(ids[i]+"y").value = top;
			document.getElementById("player"+[n]).style.left= left+"px";
			document.getElementById(ids[i]+"x").value = left;
			n++;
		}
	}
}

function reservepage(){
	chname = document.getElementById("reserve_ch_name").value;
	chcategory = document.getElementById("reserve_ch_category").value;
	chwidth = document.getElementById("reserve_ch_width").value;
	chheight = document.getElementById("reserve_ch_height").value;
	chdescription = document.getElementById("reserve_ch_description").value;
	chlink_info = document.getElementById("reserve_ch_link_info").value;
	chother_info = document.getElementById("reserve_ch_other_info").value;
	backcolor = document.getElementById("reserve_background").value;
	chbackcolor = document.getElementById("reserve_ch_background").value;
	switchtime = document.getElementById("reserve_switchtime").value;
	pagename = document.getElementById("reserve_pagename").value;
	document.getElementById("page_propertie[name]").value = pagename;
	if (switchtime == ""){
		document.getElementById("page_propertie[switchtime]").value = "60";
	}
	else{
		document.getElementById("page_propertie[switchtime]").value = switchtime;	
	}
	document.getElementById("channel_propertie[category]").value = chcategory;
	document.getElementById("channel_propertie[name]").value = chname;
	document.getElementById("channel_propertie[width]").value = chwidth;
	document.getElementById("channel_propertie[height]").value = chheight;
	document.getElementById("channel_propertie[description]").value = chdescription;
	document.getElementById("channel_propertie[link_info]").value = chlink_info;
	document.getElementById("channel_propertie[other_info]").value = chother_info;
	document.getElementById("page_propertie[background]").value = backcolor;
	document.getElementById("channel_propertie[background]").value = chbackcolor;
	if (document.getElementById("reserve_backtype").value == "image"){
		document.pagesetting.backgroundtype[1].checked = true;
		document.getElementById('page_propertie[background]').style.display = 'none';
		document.getElementById('Color').style.display = 'none';
		document.getElementById('Image').style.display = 'block';
		document.getElementById('picture_type_id').selectedIndex = document.getElementById("reserve_bdt").value;
		if (document.getElementById("upmethod").value == "0"){
			if (document.getElementById("retouch_flag").value == 2){
				document.getElementById('select1').style.display = 'none';
				document.getElementById('upload1').style.display = 'block';
				document.pagesetting.selectupload[0].checked = true;	
			}
			else{
				document.getElementById('select').style.display = 'none';
				document.getElementById('upload').style.display = 'block';
				document.pagesetting.selectupload[0].checked = true;
			}
		}
		if (document.getElementById("upmethod").value == "1"){
			if (document.getElementById("retouch_flag").value == 2){
				document.getElementById('upload1').style.display = 'none';
				document.getElementById('select1').style.display = 'block';
				document.pagesetting.selectupload[1].checked = true;	
			}
			else{
				document.getElementById('upload').style.display = 'none';
				document.getElementById('select').style.display = 'block';
				document.pagesetting.selectupload[1].checked = true;
			}
		}
	}
	if (document.getElementById("reserve_backtype").value == "color") {
		document.pagesetting.backgroundtype[0].checked = true;
		document.getElementById('Color').style.display = 'block';
		document.getElementById('Image').style.display = 'none';
	}
}

function uploadselect(str){
	if (str == "upload"){
		document.getElementById(str).style.display = "block"
		document.getElementById("select").style.display = "none"
		document.getElementById(str+"1").style.display = "block"
		document.getElementById("select1").style.display = "none"
	}
	if (str == "select"){
		document.getElementById(str).style.display = "block"
		document.getElementById("upload").style.display = "none"
		document.getElementById(str+"1").style.display = "block"
		document.getElementById("upload1").style.display = "none"
	}
}

function innotice(){
	$("#notice").fadeIn(3000);
	setTimeout("outnotice()",3000);
}

function outnotice(){
	$("#notice").fadeOut(3000);
}
/*
function flashtype(str){
	var type = str;
	if (type =="url"){
		document.getElementById("cpath").style.display = "none";
		document.getElementById("curl").style.display = "block";
	}
	else{
		document.getElementById("curl").style.display = "none";
		document.getElementById("cpath").style.display = "block";
	}
}
*/
function stringtype(str){
    var type = str;
    if (type =="rss"){
        document.getElementById("Txt").style.display = "none";
        document.getElementById("text_content").style.display = "none";
        document.getElementById("Rss").style.display = "block";
        document.getElementById("urlpath1").style.display = "block";
    }
    else{
        document.getElementById("Rss").style.display = "none";
        document.getElementById("urlpath1").style.display = "none";
        document.getElementById("Txt").style.display = "block";
        document.getElementById("text_content").style.display = "block";
    }
}

function change_px(index){
	if (index == "0") {
		document.getElementById("contents[width]").value = 250;
		document.getElementById("contents[height]").value = 350;
	}else if (index == "1") {
		document.getElementById("contents[width]").value = 200;
		document.getElementById("contents[height]").value = 275;
	}else if (index == "2") {
		document.getElementById("contents[width]").value = 60;
		document.getElementById("contents[height]").value = 500;
	}else if (index == "3") {
		document.getElementById("contents[width]").value = 50;
		document.getElementById("contents[height]").value = 350;
	}else if (index == "4") {
		document.getElementById("contents[width]").value = 690;
		document.getElementById("contents[height]").value = 50;
	}else if (index == "5") {
		document.getElementById("contents[width]").value = 500;
		document.getElementById("contents[height]").value = 45;
	}
}

function init_remocon(){
	var Index = document.getElementById("contents_setting[button_type]").selectedIndex;
	document.getElementById("contents[width]").readOnly = true;
	document.getElementById("contents[height]").readOnly = true;
	if (Index == "0"){
		document.getElementById("contents[width]").value = 250;
		document.getElementById("contents[height]").value = 350;
	}
}

function searchtype(type){
	if (type =="keyword"){
		document.getElementById("ch_name").style.display = "none";
		document.getElementById("keyword").style.display = "block";
	}
	else{
		document.getElementById("keyword").style.display = "none";
		document.getElementById("ch_name").style.display = "block";
	}
}
function ustreamtype(type){
	if (type =="ipad"){
		document.getElementById("pc").style.display = "none";
		document.getElementById("ipad").style.display = "block";
	}
	else{
		document.getElementById("ipad").style.display = "none";
		document.getElementById("pc").style.display = "block";
	}
}

function no_btn(length){
	if (document.getElementById('no_flag').value == "off") {
		for (i = 1; i <= length; i++) {
			$("div#pop"+i).fadeIn(1000);
		}
		document.getElementById('no_flag').value = 'on';
	}
	else {
		for (i = 1; i <= length; i++) {
			$("div#pop"+i).fadeOut(1000);
		}
		document.getElementById('no_flag').value = 'off';
	}
}
function mousepop(str){
	if (str[0]=="over"){
		$("#a_pop"+str[1]).fadeIn(1000);
	}
	else{
		$("#a_pop"+str[1]).fadeOut(1000);
	}
}

function player_lists(str){
	if (str=="on"){
		var close_info = document.getElementById("lists_vertical");
		var open_bt = document.getElementById("on_player_list");
		var current_copy = document.getElementById("current_copy");
		open_bt.style.display = "none";
		close_info.style.display = "none";
		document.getElementById("lists_vertical_frame").style.display = "none";
		$('#lists_frame').slideToggle("slow");
		document.getElementById("lists_horizon_frame").style.display = "block";
		current_copy.style.display = "block";
		setTimeout("list_bts('off')",500);
		document.getElementById("lists_view_State").value = "open";
	}
	else{
		var open_info = document.getElementById("lists_horizon");
		var close_bt = document.getElementById("off_player_list");
		var current_copy = document.getElementById("current_copy");
		close_bt.style.display = "none";
		open_info.style.display = "none";
		document.getElementById("lists_horizon_frame").style.display = "none";
		document.getElementById("lists_save").style.display = "none";
		document.getElementById("lists_frame").style.display = "none";
		current_copy.style.display = "none";
		document.getElementById("lists_vertical_frame").style.display = "block";
		setTimeout("list_bts('on')",500);
		document.getElementById("lists_view_State").value = "close";
	}
}

function list_bts(str){
	if (str == "off"){
		$('#off_player_list').fadeIn(1000);
		$('#lists_horizon').fadeIn(1000);
	}
	else{
		$('#on_player_list').fadeIn(1000);
		$('#lists_vertical').fadeIn(1000);
	}
}

function openbasicinfo(str){
	var element = document.getElementById("picker_frame");
	if (str=="on"){
		$('#basc_info_ch').slideDown('slow');
		document.getElementById('btn_basicinfo_on').style.display="none";
		$('#btn_basicinfo_off').fadeIn(1000);
	}
	else{
		$('#basc_info_ch').slideUp('slow')
		document.getElementById('btn_basicinfo_off').style.display="none";
		$('#btn_basicinfo_on').fadeIn(1000);
	}
}

function layout_guide(str){
	if (str == "on"){
		document.getElementById("layout_guide_on").style.display = "none";
		$("#layout_guide_offbt").fadeIn(1000);
		$('#layout_guide_off').slideDown('slow');
	}
	else{
		document.getElementById("layout_guide_offbt").style.display = "none";
		$('#layout_guide_off').slideUp('slow')
		$("#layout_guide_on").fadeIn(1000);
	}
}

function page_guide(str){
	if (str == "on"){
		document.getElementById("page_guide_on").style.display = "none";
		$("#page_guide_offbt").fadeIn(1000);
		$('#page_guide_off').slideDown('slow');
	}
	else{
		document.getElementById("page_guide_offbt").style.display = "none";
		$('#page_guide_off').slideUp('slow')
		$("#page_guide_on").fadeIn(1000);
	}
}

function updown_guide(str){
	if (str == "on"){
		document.getElementById("updown_guide_on").style.display = "none";
		$("#updown_guide_offbt").fadeIn(1000);
		$('#updown_guide_off').slideDown('slow');
	}
	else{
		document.getElementById("updown_guide_offbt").style.display = "none";
		$('#updown_guide_off').slideUp('slow')
		$("#updown_guide_on").fadeIn(1000);
	}
}

function saveplayer(str_no,channel_id,page_id){
	$("#player_list").load("/channels/"+channel_id+"/pages/"+page_id+"/addplayer?"+str_no+"");
}

function copyplayer(channel_id,page_id,content_id){
	$("#current_copy").load("/channels/"+channel_id+"/pages/"+page_id+"/contents/"+content_id+"/player_copy");
}

function to_setting(chid,pgid,ctid){
	parent.location.href="/channels/"+chid+"/pages/"+pgid+"/contents/"+ctid+"/edit";
}

function gard_player_delete(){
	document.getElementById("gard_player_list").style.display = "block";
}

function submitflag(str){
	if (str == "normal"){
		document.getElementById("submit[flag]").value = str;
	}
	else if (str == "return"){
		document.getElementById("submit[flag]").value = str;
	}
}

function copy_deteal_onoff(str){
	document.getElementById('deteal_player').style.display=str;
}
