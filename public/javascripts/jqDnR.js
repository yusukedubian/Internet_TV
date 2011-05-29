/*
 * jqDnR - Minimalistic Drag'n'Resize for jQuery.
 *
 * Copyright (c) 2007 Brice Burgess <bhb@iceburg.net>, http://www.iceburg.net
 * Licensed under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 * 
 * $Version: 2007.08.19 +r2
 */

(function($){
$.fn.jqDrag=function(h){return i(this,h,'d');};
$.fn.jqResize=function(h){return i(this,h,'r');};
$.jqDnR={dnr:{},e:0,
drag:function(v){
 remaxwidth = (parseInt(document.getElementById("remaxwidth").value) - parseInt(document.getElementById(document.getElementById('current_player_id').value+"x").value)) - 2;
 remaxheight = (parseInt(document.getElementById("remaxheight").value) - parseInt(document.getElementById(document.getElementById('current_player_id').value+"y").value)) - 2;
 newwidth = v.pageX-M.pX+M.W;
 newheight = v.pageY-M.pY+M.H;
 if(M.k == 'd')E.css({left:M.X+v.pageX-M.pX,top:M.Y+v.pageY-M.pY});
 if(M.k != 'd') E.css({
 	width:Math.max(newwidth,48),
	height:Math.max(newheight,48)
 });
 if(M.k != 'd' && newwidth>remaxwidth) E.css({
	width:Math.min(newwidth,remaxwidth)
 });
 if(M.k != 'd' && newheight>remaxheight) E.css({
	height:Math.min(newheight,remaxheight)
 });
  return false;},
stop:function(){E.css('opacity',M.o);$().unbind('mousemove',J.drag).unbind('mouseup',J.stop);
}
};
var J=$.jqDnR,M=J.dnr,E=J.e,
i=function(e,h,k){return e.each(function(){h=(h)?$(h,e):e;
 h.bind('mousedown',{e:e,k:k},function(v){var d=v.data,p={};E=d.e;
 // attempt utilization of dimensions plugin to fix IE issues
 if(E.css('position') != 'relative'){try{E.position(p);}catch(e){}}
 M={X:p.left||f('left')||0,Y:p.top||f('top')||0,W:f('width')||E[0].scrollWidth||0,H:f('height')||E[0].scrollHeight||0,pX:v.pageX,pY:v.pageY,k:d.k,o:E.css('opacity')};
 E.css({opacity:0.8});$().mousemove($.jqDnR.drag).mouseup($.jqDnR.stop);
 $(".jqResize").mouseout(function(){
			var browser = document.getElementById('browsercheck').value; 
			if (browser == "IE") {
				layoutwidth = E[0].scrollWidth+2;
				layoutheight = E[0].scrollHeight+2;
			}
			else if (browser == "Safari"){
				layoutwidth = E[0].scrollWidth+2;
				layoutheight = E[0].scrollHeight+2;
			}
			else{
				layoutwidth = E[0].scrollWidth;
				layoutheight = E[0].scrollHeight;
			}
			document.getElementById("dragwidth").value = layoutwidth;
			document.getElementById("dragheight").value = layoutheight;
			document.getElementById(document.getElementById('current_player_id').value+"width").value = layoutwidth;
			document.getElementById(document.getElementById('current_player_id').value+"height").value = layoutheight;  
 })
 return false;
 });
});},
f=function(k){return parseInt(E.css(k))||false;};
})(jQuery);


/*
//���ꂾ�ƎG�ɓ��������Ƃ��ȂǁA�g�ȊO��mouseup���Ă��܂��ƁA�f�[�^���Ƃ邱�Ƃ��ł��Ȃ��B
 //alert("Now calculating");
 $(function() {
 		$("p").mouseup(function() {
        document.getElementById("width").value = E[0].scrollWidth;
        document.getElementById("heigth").value = E[0].scrollHidth;
 		});
 });
 
 return false;
 */
