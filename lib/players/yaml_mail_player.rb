module Players

  class Yaml_mail_player
    require 'gettext/utils'
    include Validate
    include ContentsHelper
    
    def initialize()
    end
    
    def set_request(request)
      @request = request
    end
    
    def default(content)
      player_params ={

      "contents_setting" => {
                             "mailSubject1"=>"業務報告",
                             "mailContentsTitle1"=>"本日の一言報告",
                             "mailSubject2"=>nil,
                             "mailContentsTitle2"=>nil,
                             "mailSubject3"=>nil,
                             "mailContentsTitle3"=>nil,
                             "mailSubject4"=>nil,
                             "mailContentsTitle4"=>nil,
                             "mailSubject5"=>nil,
                             "mailContentsTitle5"=>nil,
                             "back_color"=>"#28281C",
                             "font_size"=>"20",
                             "font_color"=>"#4AE821",
                             "scroll_direction"=>"Left",
                             "scroll_speed"=>"50",
                             "getTime"=>"1"},
                        
              "contents" => {"x_pos"=>"5",
                             "line_width"=>"5",
                             "y_pos"=>"5",
                             "line_color"=>"#38382e",
                             "height"=>"300",
                             "width"=>"300"},

      "channel_id"=>content.page.channel_id,
      "page_id"=>content.page_id

      }
      
      return player_params
    end
    
    
    def set_content(current_user,content,params)
      @current_user = current_user
      @content = content
      @content_properties = {}
      @content.contents_propertiess.each{|property|
        @content_properties[property[:property_key]] = property[:property_value]
      }
      @params = params
    end

    
    
    # 画面入力項目チェック
    def validate(current_user,params)
      p params
      if params["contents_setting"]["mailSubject1"]==""
        raise AplInfomationException.new("ERR_0x01020112")
      elsif params["contents_setting"]["mailContentsTitle1"]==""
        raise AplInfomationException.new("ERR_0x01020113")
      end
      
      if params["contents_setting"]["mailSubject2"]!="" && params["contents_setting"]["mailContentsTitle2"]==""
        raise AplInfomationException.new("ERR_0x01020114")
      end
      
      if params["contents_setting"]["mailSubject2"]=="" && params["contents_setting"]["mailContentsTitle2"]!=""
        raise AplInfomationException.new("ERR_0x01020115")
      end

      if params["contents_setting"]["mailSubject3"]!="" && params["contents_setting"]["mailContentsTitle3"]==""
        raise AplInfomationException.new("ERR_0x01020116")
      end
      
      if params["contents_setting"]["mailSubject3"]=="" && params["contents_setting"]["mailContentsTitle3"]!=""
        raise AplInfomationException.new("ERR_0x01020117")
      end
      
      if params["contents_setting"]["mailSubject4"]!="" && params["contents_setting"]["mailContentsTitle4"]==""
        raise AplInfomationException.new("ERR_0x01020118")
      end
      
      if params["contents_setting"]["mailSubject4"]=="" && params["contents_setting"]["mailContentsTitle4"]!=""
        raise AplInfomationException.new("ERR_0x0102019")
      end
      
      if params["contents_setting"]["mailSubject5"]!="" && params["contents_setting"]["mailContentsTitle5"]==""
        raise AplInfomationException.new("ERR_0x01020120")
      end
      
      if params["contents_setting"]["mailSubject5"]=="" && params["contents_setting"]["mailContentsTitle5"]!=""
        raise AplInfomationException.new("ERR_0x01020121")
      end
      
      if params["contents_setting"]["getTime"]=="" || !params["contents_setting"]["getTime"].match(/\d/) || params["contents_setting"]["getTime"]=="0" || params["contents_setting"]["getTime"].to_i < 1
        raise AplInfomationException.new("ERR_0x01020122")
      end
      
      if params["contents_setting"]["mailSubject2"]!="" && params["contents_setting"]["mailContentsTitle2"]!=""
        if params["contents_setting"]["mailSubject1"]=="" || params["contents_setting"]["mailContentsTitle1"]==""
          raise AplInfomationException.new("ERR_0x01020123")
        end
      end

      if params["contents_setting"]["mailSubject3"]!="" && params["contents_setting"]["mailContentsTitle3"]!=""
        if params["contents_setting"]["mailSubject2"]=="" || params["contents_setting"]["mailContentsTitle2"]==""
          raise AplInfomationException.new("ERR_0x01020123")
        end
      end
      
      if params["contents_setting"]["mailSubject4"]!="" && params["contents_setting"]["mailContentsTitle4"]!=""
        if params["contents_setting"]["mailSubject3"]=="" || params["contents_setting"]["mailContentsTitle3"]==""
          raise AplInfomationException.new("ERR_0x01020123")
        end
      end
      
      if params["contents_setting"]["mailSubject5"]!="" && params["contents_setting"]["mailContentsTitle5"]!=""
        if params["contents_setting"]["mailSubject4"]=="" || params["contents_setting"]["mailContentsTitle4"]==""
          raise AplInfomationException.new("ERR_0x01020123")
        end
      end
    end
=begin    
    speed = ""
    if @content_properties["scroll_speed"] == "70"
        speed = " scrolldelay = '70' scrollamount='4' "
    elsif @content_properties["scroll_speed"] == "50"
        speed = " scrolldelay = '90' scrollamount='3'"
    elsif @content_properties["scroll_speed"] == "30"
        speed = " scrolldelay = '120' scrollamount='1'"
    end    
=end
    def config_save

    end
    

    def config_create

    end
   
    def get_html
      p "get_html"
      
      #-----------------------------------
      # main process
      #-----------------------------------
      speed = ""
      html = ""
      html << "<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='ja' lang='ja'> \n"
      html << "  <head> \n"
      html << " <meta http-equiv='Content-type' content='text/html; charset=utf-8' /> \n"
      html << " <meta http-equiv='cache-control' content='non-cache' /> \n"
      #html << "<script type='text/javascript' src='../../../../../../javascripts/jquery-1.2.6.pack.js'></script> \n"

      #html << "<script src='/javascripts/prototype.js' type='text/javascript'></script>"
      #html << "  <meta http-equiv='content-type' content='text/html;charset=UTF-8' />\n"
      html << "  </head> \n"
      html << "  <body style='margin:0px;'> \n"
      html << "    <div id='"+@content.id.to_s+"_1"+"'style='background:"+@content_properties["back_color"].to_s+"; width:"+@content['width'].to_s+"px;height:"+@content['height'].to_s+"px;font-size:"+@content_properties["font_size"].to_s+"' >\n"
     
      if @content_properties["scroll_speed"] == "70"
          speed = " scrolldelay = '70' scrollamount='4' "
      elsif @content_properties["scroll_speed"] == "50"
          speed = " scrolldelay = '90' scrollamount='3'"
      elsif @content_properties["scroll_speed"] == "30"
          speed = " scrolldelay = '120' scrollamount='1'"
      end
    
      html << "<Marquee height='"+@content['height'].to_s+"px' width='"+@content['width'].to_s+"px' direction ='"+ @content_properties["scroll_direction"] +"'"+speed+">"+"<font color='"+@content_properties["font_color"]+"'>メールを受信中..."+"</font>"+"</Marquee> \n"

      #html << "<Marquee height='"+@content['height'].to_s+"px' width='"+@content['width'].to_s+"px' direction ='"+ @content_properties["scroll_direction"] +"'"
      #html << speed
      #html << "> \n"
      #html << temp
      #html << "    <div id='"+@content.id.to_s+"_1"+"' style='WORD-WRAP:break-word;'>"+temp+" \n"
      #html << "    </div> \n"      
      #html << "</Marquee> \n"
    
      #html << "   "
      #html << "    <div id='"+@content.id.to_s+"_1"+"' style='position:absolute;height:"+@content['height'].to_s+"px;width:"+@content['width'].to_s+"px; background:"+@content_properties["back_color"].to_s+";'> \n"
      #html << setmessagemail()
      #html << "    </div> \n"
      html << "    </div>"
      html << "  </body> \n"
      
      html << setmessagemail(speed)
      
      html << "</html> \n"
      return html
    end
    
    def setmessagemail(speed)
      html = ""
      #speed = ""
      time = @content_properties["getTime"].to_i*60000
      host = @content_properties["local_url"]
      #html << "<script type='text/javascript'>\n"
      #html << "send_get()"
      #html << "</script>\n"
      html << "<script language='JavaScript'>\n"
      #html << "sendRequest();"
      html << "setInterval('sendRequest()',"+time.to_s+");\n"
      html << "function getXMLHttpRequest(){\n"
      html << "var request = false;\n"
      html << "try {"
      html << "request = new XMLHttpRequest();\n"
      html << "} catch (trymicrosoft) {\n"
      html << "try {"
      html << "request = new ActiveXObject('Msxml2.XMLHTTP');"
      html << "} catch (othermicrosoft) {"
      html << "try {"
      html << "request = new ActiveXObject('Microsoft.XMLHTTP');"
      html << "} catch (failed) {"
      html << "request = false;"
      html << "}"
      html << "}"
      html << "}"
      html << "return request;\n"
      html << "} \n"
      html << "function sendRequest()\n"
      html << " {\n"
      html << "   request=getXMLHttpRequest();\n"
      html << "   url='http://"+host.to_s+ "/yamlmail_recieve/show?userID="+@current_user.id.to_s+"&contentsID="+@content.id.to_s+"';\n"
      html << "   request.open('GET',url,true);\n"
      html << "   request.onreadystatechange = showMessage;\n"
      html << "   request.send('');\n"
      html << " }\n"
      html << "function showMessage()\n"
      html << "{\n"
      html << " var mailcontent=\"\";\n"
      html << "if(request.readyState == 4 && request.status == 200)\n"
      html << "{\n"
      html << "if(request.responseText!=''){\n"
      html << " mailcontent="+"\"<Marquee height='"+@content['height'].to_s+"px' width='"+@content['width'].to_s+"px' direction ='"+ @content_properties["scroll_direction"] +"'"+speed+">"+"<font color='"+@content_properties["font_color"]+"' style='font-size:"+@content_properties["font_size"].to_s+"px;'>\""+"+request.responseText+\""+"</font></Marquee> \";\n"
      
      #html << "$(\"#"+@content.id.to_s+"_1"+"\").html(mailcontent); \n"
      html << "document.getElementById('"+@content.id.to_s+"_1"+"').innerHTML = mailcontent;\n"
      html << "}else{\n"
      html << " mailcontent="+"\"<Marquee height='"+@content['height'].to_s+"px' width='"+@content['width'].to_s+"px' direction ='"+ @content_properties["scroll_direction"] +"'"+speed+">"+"<font color='"+@content_properties["font_color"]+"' style='font-size:"+@content_properties["font_size"].to_s+"px;'>メールを受信しています。</font></Marquee> \";\n"
      html << "document.getElementById('"+@content.id.to_s+"_1"+"').innerHTML = mailcontent;\n"
      
      html << "}\n"
      html << "}\n"
      html << "}\n"
      html << "</script>\n"
=begin
    html << "<script type='text/javascript'>\n"
    html << "function send_get() {\n"
    #html << "document.write('CCCCCCCCCCCCCCCC');\n"
    html << "  var url = 'http://" + "localhost:3000" + "/yamlmail_recieve/show?userID=1&contentsID=1'\n;"
    html << "var request = createXMLHttpRequest();\n"
    html << "request.open('GET', url, true);\n"
    html << "request.onreadystatechange = function() {\n"
    html << "if (request.readyState == 4 && request.status == 200) {\n"
    #html << "var result = document.getElementById('result_get');\n"
    html << "var text = document.createTextNode(encodeURI(request.responseText));\n"
    html << "document.write(text);\n"
    html << "}\n"
    html << "}\n"
    html << "request.send(null);\n"
    html << "}\n"
    html << "setTimeout('send_get()',10000);"
    html << "</script>\n"
=end
      #html << "<font color='"+@content_properties["font_color"]+"'>"
=begin      
      if @content_properties["scroll_speed"] == "70"
          speed = " scrolldelay = '70' scrollamount='4' "
      elsif @content_properties["scroll_speed"] == "50"
          speed = " scrolldelay = '90' scrollamount='3'"
      elsif @content_properties["scroll_speed"] == "30"
          speed = " scrolldelay = '120' scrollamount='1'"
      end
      html << "<marquee "
      html << "height='"+@content['height'].to_s+"px'"
      html << "Direction='" + @content_properties["scroll_direction"] + "'"
      html << speed
      html << ">\n"
      html << "<font color='"+@content_properties["font_color"]+"'>"
      html << "<div id='yamlmail' style='background:"+@content_properties["back_color"].to_s+";font-size:"+@content_properties["font_size"].to_s
      html << "px'>メールを着信しています。"
      
      html << "</div>\n"
      html << "</font>"
      html << "</marquee>\n"
      #html << "</font>"
=end

=begin    
    filename = @content.id.to_s+".xml"
    #filename = @content.id.to_s+".xml"
    
    html << "<script type='text/javascript'>\n"
    html << "var temp='';\n"
    html << "loadXML = function(fileRoute)\n"
    html << "{\n"
    html << "  xmlDoc=null;\n"
    html << "  if (window.ActiveXObject)\n"
    html << "  {\n"
    html << "    xmlDoc = new ActiveXObject('Msxml2.DOMDocument');\n"
    html << "    xmlDoc.async=false;\n"
    html << "    xmlDoc.load(fileRoute);\n"
    html << "  }\n"
    html << "  else if (document.implementation && document.implementation.createDocument)\n"
    html << "  {\n"
    html << "    var xmlhttp = new window.XMLHttpRequest();\n"
    html << "    xmlhttp.open('GET',fileRoute,false);\n"
    html << "    xmlhttp.send(null);\n"
    html << "    var xmlDoc = xmlhttp.responseXML.documentElement;\n"
    html << "  }\n"
    html << "  else\n"
    html << "  {\n"
    html << "    xmlDoc=null;\n"
    html << "  }  \n"
    html << "  return xmlDoc;\n"
    html << "}\n"
    html << "</script>\n"
=end 
    #@request.env["HTTP_HOST"]

=begin       
    html << "<script type='text/javascript'> \n"
    html << "var title='';\n"
    html << "var description='';\n"
    html << "var yamlmail='';\n"
    html << "var xmlDoc=loadXML('"+filename.to_s+"');\n"
    html << "var cNodes = xmlDoc.getElementsByTagName(\"item\");\n"
    html << "for(j=0;j<cNodes.length;j++)\n"
    html << "{\n"
    html << "   title = cNodes[j].getElementsByTagName(\"title\")[0].childNodes[0].nodeValue;\n"
    html << "   description = '';\n"
    html << "   try{\n"
    html << "   description = cNodes[j].getElementsByTagName(\"content:encoded\")[0].childNodes[0].nodeValue;\n"
    html << "   }catch(err){\n"
    html << "   description = cNodes[j].getElementsByTagName(\"encoded\")[0].childNodes[0].nodeValue;\n"
    html << "   }\n"
    html << "   yamlmail += '<font '; \n"
    html << "   yamlmail += 'color=\""+@content_properties["font_color"].to_s+"\"'; \n"
    html << "   yamlmail += 'style=\"font-size:"+@content_properties["font_size"].to_s+"px;\">&nbsp;&nbsp;'; \n"
    if @content_properties["scroll_direction"] == "up"
      html << "   yamlmail += \"<b>●&nbsp;\"+title+'</b>';  \n"
    else
      html << "   yamlmail += \"&nbsp;&nbsp;&nbsp;&nbsp;<b>●&nbsp;\"+title+'</b>&nbsp;&nbsp;:&nbsp;';  \n"
    end
    if @content_properties["scroll_direction"] == "up"
      html << "   yamlmail += '<br>'; \n"
    end
    if @content_properties["scroll_direction"] == "up"
      html << "   yamlmail += '&nbsp;&nbsp;'+description; \n"
    else
      html << "   yamlmail += description; \n"
    end
    html << "   yamlmail += '</font>'; \n"
    if @content_properties["scroll_direction"] == "up"
      html << "   yamlmail += '<br><br>'; \n"
    end
    html << "}\n"
    html << " \n"
    
    html << "document.getElementById('yamlmail').innerHTML = yamlmail; \n"
    #html << "$(\"document\").ready(function(){\n"
    #html << "   $('#yamlmail').html(yamlmail);\n"
    #html << "});\n"
    
    html << "setInterval('update()', 60000);\n"
    html << "function update(){\n"
    html << "var title='';\n"
    html << "var description='';\n"
    html << "var yamlmail='';\n"
    html << "var xmlDoc=loadXML('"+filename.to_s+"');\n"
    html << "var cNodes = xmlDoc.getElementsByTagName(\"item\");\n"
    html << "for(j=0;j<cNodes.length;j++)\n"
    html << "{\n"
    html << "   title = cNodes[j].getElementsByTagName(\"title\")[0].childNodes[0].nodeValue;\n"
    html << "   description = '';\n"
    html << "   try{\n"
    html << "   description = cNodes[j].getElementsByTagName(\"content:encoded\")[0].childNodes[0].nodeValue;\n"
    html << "   }catch(err){\n"
    html << "   description = cNodes[j].getElementsByTagName(\"encoded\")[0].childNodes[0].nodeValue;\n"
    html << "   }\n"
    html << "   yamlmail += '<font '; \n"
    #html << "   yamlmail += 'face=\""+fontname+"\"';  \n"
    html << "   yamlmail += 'color=\""+@content_properties["font_color"].to_s+"\"'; \n"
    html << "   yamlmail += 'style=\"font-size:"+@content_properties["font_size"].to_s+"px;\">&nbsp;&nbsp;'; \n"
    if @content_properties["scroll_direction"] == "up"
      html << "   yamlmail += \"<b>●&nbsp;\"+title+'</b>';  \n"
    else
      html << "   yamlmail += \"&nbsp;&nbsp;&nbsp;&nbsp;<b>●&nbsp;\"+title+'</b>&nbsp;&nbsp;:&nbsp;';  \n"
    end
    if @content_properties["scroll_direction"] == "up"
      html << "   yamlmail += '<br>'; \n"
    end
    if @content_properties["scroll_direction"] == "up"
      html << "   yamlmail += '&nbsp;&nbsp;'+description; \n"
    else
      html << "   yamlmail += description; \n"
    end
    html << "   yamlmail += '</font>'; \n"
    if @content_properties["scroll_direction"] == "up"
      html << "   yamlmail += '<br><br>'; \n"
    end
    html << "}\n"
    
    html << "document.getElementById('yamlmail').innerHTML = yamlmail; \n"
    #html << "$('#yamlmail').empty();\n"
    #html << "$('#yamlmail').html(yamlmail);\n"
    html << "}\n"
    html << "</script>\n"
=end   
    return html
    end
    
  end

end