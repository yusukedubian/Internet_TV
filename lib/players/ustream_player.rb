module Players
  
  class Ustream_Player
    require 'gettext/utils'
    cattr_accessor :aplog
    @@aplog ||= SystemSettings::APL_LOGGER
    CLASS_NAME = self.name
    include Validate
    
    def initialize()
    end

    def set_request(request)
      @request = request
    end

    
    def default(content)
      aplog.debug("START #{CLASS_NAME}#default")
      player_params ={
      "contents_setting" => {"ustreamtype"=>"pc",
                             "searchtype"=>"keyword",
                             "ustream_keyword"=>"office"},

              "contents" => {"x_pos"=>"5",
                             "line_width"=>"5",
                             "y_pos"=>"5",
                             "line_color"=>"#38382e",
                             "height"=>"300",
                             "width"=>"400"},

      "channel_id"=>content.page.channel_id,
      "page_id"=>content.page_id
      }
      aplog.debug("END   #{CLASS_NAME}#default")
      return player_params
    end
    
    def set_content(current_user,content,params)
      aplog.debug("START #{CLASS_NAME}#set_content")
      @current_user = current_user
      @content = content
      @content_properties = {}
      @content.contents_propertiess.each{|property|
        @content_properties[property[:property_key]] = property[:property_value]
      }
      @params = params
      aplog.debug("END   #{CLASS_NAME}#set_content")
    end
    
    # 画面入力項目チェック
    def validate(current_user,params)
      aplog.debug("START #{CLASS_NAME}#validate")
      if params["contents_setting"]["ustreamtype"] =="pc"
        if params["contents_setting"]["searchtype"] =="ch_name"
          if is_empty(params["contents_setting"][:ustream_channel_name])
             aplog.warn("ERR_0x01027101")
             raise AplInfomationException.new("ERR_0x01027101")
          end
        else
          if is_empty(params["contents_setting"][:ustream_keyword])
             aplog.warn("ERR_0x01027102")
             raise AplInfomationException.new("ERR_0x01027102")
          end 
        end
      else
         if is_empty(params["contents_setting"][:ustream_channel_id])
            aplog.warn("ERR_0x01027103")
            raise AplInfomationException.new("ERR_0x01027103")
         elsif !is_half_num(params["contents_setting"][:ustream_channel_id])
            aplog.warn("ERR_0x01027104")
            raise AplInfomationException.new("ERR_0x01027104")
         end
      end
      aplog.debug("END   #{CLASS_NAME}#validate")
    end
=begin
  raise "ERR_0x01027101"
    Ustreamチャンネル名が未入力です。
  raise "ERR_0x01027102"
    キーワードが未入力です。
  raise "ERR_0x01027103"
    UstreamチャンネルIDが未入力です。
  raise "ERR_0x01027104"
    UstreamチャンネルIDには半角数字で入力してください。
=end    
    # プレーヤー設定保存時の処理
    def config_save
    end
    
    #コンフィグデータが必要な場合
    def config_create
    end
    
    
    #出力用HTML
    def get_html
      aplog.debug("START #{CLASS_NAME}#get_html")
      FileUtils.mkdir_p(RuntimeSystem.content_save_dir(@content))
      aplog.debug("END   #{CLASS_NAME}#get_html")
      FileUtils.copy_file("./public/javascripts/" + "jquery-1.2.3.min.js", RuntimeSystem.content_save_dir(@content) + "jquery-1.2.3.min.js")
      
      <<-HTML
        <html>
          <head>
            <title></title>
            <meta http-equiv='Content-type' content='text/html; charset=utf-8' >
            <meta http-equiv='cache-control' content='non-cache' />
            <script type='text/javascript' src='./jquery-1.2.3.min.js'></script>
            <script type='text/javascript'><!--
            #{get_script(@content_properties,@content.width,@content.height)}
            --></script>
          </head>
          <body style="margin:0">
                <div id="ustream" width="#{@content.width}">
                </div>
          </body>
          <script type='text/javascript'><!--
          update();
          --></script>
        </html>
      HTML
    end
    
    def get_script(params,width,height)
      if params["ustreamtype"] == "pc"
        if params["searchtype"] == "ch_name"
          <<-HTML
          function update(){
            jQuery.ajax({
              url:'http://api.ustream.tv/json/channel/#{params["ustream_channel_name"]}/getCustomEmbedTag?key=F5C602AAF1E5F3888E4EBAD882E016FF&params=autoplay:true;height:#{height};width:#{width}',
              dataType: "jsonp",
              cache: false,
              error: function(req){
                switch(req.status){
                  case 401:
                    jQuery("#ustream").replaceWith("情報が不正なためustreamに接続できませんでした");
                    break;
                  default:
                    jQuery("#ustream").replaceWith("ustreamに接続できませんでした");
                    break;
                }
               },
               success: function(json){
                  if (json != null){
                    jQuery('#ustream').replaceWith(json);
                  }else{
                    jQuery('#ustream').replaceWith('チャンネルが見つかりませんでした。Ustreamチャンネル名にはhttp://www.ustream.tv/xxxxxのxxxxxの部分を入力してください。');
                  }
               }
             });
            };
          HTML
        else
          <<-HTML
          function update(){
            jQuery.ajax({
                          url:'http://api.ustream.tv/json/channel/live/search/title:like:#{params["ustream_keyword"]}?key=F5C602AAF1E5F3888E4EBAD882E016FF',
                          dataType: "jsonp",
                          cache: false,
                          error: function(req){
                            switch(req.status){
                              case 401:
                                jQuery("#ustream").replaceWith("情報が不正なためustreamに接続できませんでした");
                                break;
                              default:
                                jQuery("#ustream").replaceWith("ustreamに接続できませんでした");
                                break;
                            }
                           },
                           success: function(json){
                              if (json != null){
                                title = json[0].urlTitleName
                                  jQuery.ajax({
                                      url:'http://api.ustream.tv/json/channel/#{}'+title+'/getCustomEmbedTag?key=F5C602AAF1E5F3888E4EBAD882E016FF&params=autoplay:true;height:#{height};width:#{width}',
                                      dataType: "jsonp",
                                      cache: false,
                                       success: function(json){
                                          if (json != null){
                                            jQuery('#ustream').replaceWith(json);
                                          }else{
                                            jQuery('#ustream').replaceWith('キーワード「#{params["ustream_keyword"]}」での検索結果が0件でした。恐れ入りますが、再度他のキーワードで登録を行ってください。');
                                          }
                                       }
                                  });
                              }else{
                                  jQuery.ajax({
                                    url: "http://api.ustream.tv/json/channel/recent/search/title:like:#{params["ustream_keyword"]}?key=F5C602AAF1E5F3888E4EBAD882E016FF",
                                    dataType: "jsonp",
                                    cache: true,
                                    error: function(req){
                                      switch(req.status){
                                        case 401:
                                          jQuery("#ustream").replaceWith("情報が不正なためustreamに接続できませんでした");
                                          break;
                                        default:
                                          jQuery("#ustream").replaceWith("ustreamに接続できませんでした");
                                          break;
                                      }
                                     },
                                        success: function(jsons) {
                                    if (jsons != null){
                                          title = jsons[0].urlTitleName
                                            jQuery.ajax({
                                                url:'http://api.ustream.tv/json/channel/#{}'+title+'/getCustomEmbedTag?key=F5C602AAF1E5F3888E4EBAD882E016FF&params=autoplay:true;height:#{height};width:#{width}',
                                                dataType: "jsonp",
                                                cache: false,
                                                error: function(req){
                                                    switch(req.status){
                                                      case 401:
                                                        jQuery("#ustream").replaceWith("情報が不正なためustreamに接続できませんでした");
                                                        break;
                                                      default:
                                                        jQuery("#ustream").replaceWith("ustreamに接続できませんでした");
                                                        break;
                                                     }
                                                 },
                                                 success: function(jsone){
                                             if (jsone != null){
                                                      jQuery('#ustream').replaceWith(jsone);
                                                    }else{
                                                      jQuery('#ustream').replaceWith('キーワード「#{params["ustream_keyword"]}」での検索結果が0件でした。恐れ入りますが、再度他のキーワードで登録を行ってください。');
                                                    }
                                                 }
                                            });
                                          }else{
                                            jQuery('#ustream').replaceWith('キーワード「#{params["ustream_keyword"]}」での検索結果が0件でした。恐れ入りますが、再度他のキーワードで登録を行ってください。');
                                          }
                                        }
                                    });
                              }
                           }
                      });
            };
          HTML
        end   
      else
        <<-HTML
        function update(){
            var doc = document.getElementById("ustream");
            var html = "<embed src='http://iphone-streaming.ustream.tv/ustreamVideo/#{params["ustream_channel_id"]}/streams/live/playlist.m3u8' width='#{width-2}' height='#{height}' href='http://iphone-streaming.ustream.tv/ustreamVideo/#{params["ustream_channel_id"]}/streams/live/playlist.m3u8' autoplay='true'></embed>";
            doc.innerHTML = html;
        };
        HTML
      end
    end
  end
end
