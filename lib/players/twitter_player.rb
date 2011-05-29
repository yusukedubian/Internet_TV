# Copyright:: Copyright (c) 2010 VASDAQ Group All Rights Recieved
# License::   GPL
module Players

  #
  #=Twitter Player (for VASDAQ.tv)
  #
  #jQueryからTwitter APIを用いてTwitterの情報表示を行うプレーヤー。
  #* {Twitter API Documentation}[http://apiwiki.twitter.com/Twitter-API-Documentation]
  #* {Twitter API 仕様書 日本語訳}[http://watcher.moe-nifty.com/memo/docs/twitterAPI.txt]
  class TwitterPlayer
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
      "contents_setting" => {"count"=>"15",
                             "interval"=>"5",
                             "keyword"=>"ニュース",
                             "font_size"=>"20",
                             "font_color"=>"#4AE821",
                             "title_color"=>"#28281C",
                             "title1"=>"live door Weather NEWS",
                             "scroll_direction"=>"Up",
                             "scroll_speed"=>"70"},
                        
              "contents" => {"x_pos"=>"5",
                             "line_width"=>"5",
                             "y_pos"=>"5",
                             "line_color"=>"#38382e",
                             "height"=>"400",
                             "width"=>"300"},

      "channel_id"=>content.page.channel_id,
      "page_id"=>content.page_id
      }
      aplog.debug("END   #{CLASS_NAME}#default")
      return player_params
    end
    
    def set_content(current_user,content,params)
      aplog.debug("START #{CLASS_NAME}#set_content")
      @page = current_user.channels.find_by_id(params["channel_id"]).pages.find_by_id(params["page_id"])
      @current_user = current_user
      @content = content
      @content_properties = @content.contents_propertiess.inject({}) do |result, property|
        result.store property[:property_key], property[:property_value].to_s.delete("\n")
        result
      end.with_indifferent_access
      
      @params = params
      aplog.debug("END   #{CLASS_NAME}#set_content")
    end
    
    # 画面入力項目チェック
    def validate(current_user,params)
      aplog.debug("START #{CLASS_NAME}#validate")
       # 切り替え時間（秒）　interval
      if is_empty(params["contents_setting"][:interval])
        aplog.warn("切り替え時間（秒）が未入力です。")
        raise AplInfomationException.new("切り替え時間（秒）が未入力です。")
      elsif !is_half_num(params["contents_setting"][:interval])
        aplog.warn("切り替え時間(秒)が半角数値ではありません。半角数値で入力して下さい。")
        raise AplInfomationException.new("切り替え時間(秒)が半角数値ではありません。半角数値で入力して下さい。")
      end
      # 表示数　
      if is_empty(params["contents_setting"][:count])
        aplog.warn("表示数が未入力です。")
        raise AplInfomationException.new("表示数が未入力です。")
      elsif !is_half_num(params["contents_setting"][:count])
        aplog.warn("表示数が半角数値ではありません。半角数値で入力して下さい。")
        raise AplInfomationException.new("表示数が半角数値ではありません。半角数値で入力して下さい。")
      end
      # フォントカラー
      if is_empty(params["contents_setting"]["font_color"])
        aplog.warn("ERR_0x01025103")
        raise AplInfomationException.new("ERR_0x01025103")
      elsif !is_color_code(params["contents_setting"]["font_color"])
        aplog.warn("ERR_0x01025104")
        raise AplInfomationException.new("ERR_0x01025104")
      end
      # 背景色 
      if is_empty(params["contents_setting"]["title_color"])
        aplog.warn("ERR_0x01025105")
        raise AplInfomationException.new("ERR_0x01025105")
      elsif !is_color_code(params["contents_setting"]["title_color"])
        aplog.warn("ERR_0x01025106")
        raise AplInfomationException.new("ERR_0x01025106")
      end
      # キーワード 
      if is_empty(params["contents_setting"][:keyword])
        aplog.warn("キーワードが未入力です。")
        raise AplInfomationException.new("キーワードが未入力です。")
      end
      aplog.debug("END   #{CLASS_NAME}#validate")
    end
    
    def config_create  
    end

    #=configセーブ時のコールバック
    #
    #プレーヤーのHTMLもこの時点で生成する。
    def config_save
      aplog.debug("START #{CLASS_NAME}#config_save")
      File.open(RuntimeSystem.content_save_dir(@content)+"index.html", "wb"){|f|
        f.write(get_html)
      }
      aplog.debug("END #{CLASS_NAME}#config_save")
    end
    
    #=プレーヤーのHTML生成処理
    #
    #Return::生成したHTML
    def get_html
      aplog.debug("START #{CLASS_NAME}#get_html")
      FileUtils.mkdir_p(RuntimeSystem.content_save_dir(@content))
      aplog.debug("END #{CLASS_NAME}#get_html")
      FileUtils.copy_file("./public/javascripts/" + "jquery-1.2.3.min.js", RuntimeSystem.content_save_dir(@content) + "jquery-1.2.3.min.js")
      
      <<-HTML
        <html>
          <head>
            <title></title>
            <meta http-equiv='Content-type' content='text/html; charset=utf-8' >
            <meta http-equiv='cache-control' content='non-cache' />
            <script type='text/javascript' src='./jquery-1.2.3.min.js'></script>
            <script type='text/javascript' src='http://remysharp.com/downloads/jquery.marquee.js'></script>
            <script type='text/javascript'><!--
            update();
            setInterval('update()', \"#{@content_properties[:interval].to_i*1000}\");
         
            function update(){
              #{load_script}
            };
            --></script>
          </head>
          <body style='margin: 2;'>
            <div style="background-color:#{@content_properties[:title_color]}" width="#{@content.width}">
              <font style="font-family:#{@content_properties[:fontname]};font-size:#{@content_properties[:font_size]};color:#{@content_properties[:font_color]}">
                <div id="#{dom_id}" width="#{@content.width}">
                  <div id="#{dom_id}_header"></div>
                  <marquee behavior="scroll" style="position:relative" #{marquee_options()}>
                    <div id="#{dom_id}_body" style="word-wrap: break-word"></div>
                  </marquee>
                  <div id="#{dom_id}_footer"></div>
                </div>
              </font>
            </div>
            #{jquery_templates}
          </body>
        </html>
      HTML
    end

    private
   
    #=プレーヤー処理を行うjavascriptの生成
    #
    #load_script > [retweet_of_me|search]_script > jquery_ajax_request_script
    #上記のような呼び出され方になっている
    #
    #Return::プレーヤー処理を行うjavascript文字列
    def load_script    
      search_script
#      case @content_properties[:type].to_s #typeがsym化できないことを一応考慮
#      when "retweet"
#        retweet_of_me_script
#      when "search"
#        search_script
#      else
#        <<-SCRIPT
#          jQuery("##{dom_id}").replaceWith("コンテンツ設定が不正なため表示できません");
#        SCRIPT
#      end
    end

    #=リツイート表示javascript生成
    #
    #Return::リツイート表示javascript
    def retweet_of_me_script
      #DB保存したくないときもあるのでuser/passは必須でなくしておく
#      if @content_properties[:user].blank? || @content_properties[:pass].blank?
#        <<-SCRIPT
#          jQuery("##{dom_id}").replaceWith("ユーザー/パスワードが入力されていないため表示できません");
#        SCRIPT
#      else
        count = @content_properties[:count].to_i 
        query_string = "count=#{count==0 ? 200 : count}"
        jquery_ajax_request_script(:retweet, <<-SCRIPT, query_string)
          function(json){
            if(json.length == 0){
              jQuery("##{dom_id}_header").empty();
              jQuery("##{dom_id}_footer").empty();
              jQuery("##{dom_id}_body").replaceWith(#{_("ReTweetされたTweetはありません")});
            }
            else{
              jQuery("##{dom_id}_header").empty();
              jQuery("##{dom_id}_footer").empty();
              jQuery("##{dom_id}_body").empty();
              var header = jQuery(".templates>.rt_header").clone();
              header.children(".rt_image").attr("src", json[0].user.profile_image_url);
              header.children(".rt_sname").text(json[0].user.screen_name);
              header.children(".rt_name").text(json[0].user.name);
              header.appendTo("##{dom_id}_header");
              jQuery.each(json, function(i, item){
                var entry = jQuery(".templates>.rt_item").clone();
                entry.text(item.text);
                entry.appendTo("##{dom_id}_body");
                jQuery("##{dom_id}_body").append("<br />")
              });
            }
          }
        SCRIPT
#      end
    end

    #=Tweet検索結果表示javascript生成
    #
    #Return::Tweet検索結果表示javascript
    def search_script   
      query_string = query_hash.to_query
      if query_string.blank?
        <<-SCRIPT
          jQuery("##{dom_id}_header").empty();
          jQuery("##{dom_id}_footer").empty();
          jQuery("##{dom_id}_body").replaceWith(#{_("検索に必要な情報が設定されていないため表示できません")});
        SCRIPT
      else
        jquery_ajax_request_script(:search, <<-SCRIPT, query_string)
          function(json){
            if(json.results.length == 0){
              jQuery("##{dom_id}").replaceWith(#{_("キーワードにヒットしたTweetはありません")});
            }
            else{
              jQuery("##{dom_id}_header").empty();
              jQuery("##{dom_id}_footer").empty();
              jQuery("##{dom_id}_body").empty();
              var header = jQuery(".templates>.s_header").clone();
              header.children(".s_keyword").text("keyword:" + '#{ERB::Util.h(@content_properties["keyword"])}');
              header.appendTo("##{dom_id}_header");         
              jQuery.each(json.results, function(i, item){
                var entry = jQuery(".templates>.s_item").clone();
                entry.children(".imagebox").children(".s_image").attr("src", item.profile_image_url);
                entry.children(".desc").children(".s_name").text(item.from_user);
                entry.children(".desc").children(".s_text").text(item.text);
                entry.appendTo("##{dom_id}_body");
                jQuery("##{dom_id}_body").append("<br />");
              });
            }
          }
        SCRIPT
      end
    end

    #=検索用query生成
    #
    #Return::hash of query
    def query_hash
      count = @content_properties[:count].to_i 
      query_string = "count=#{count==0 ? 100 : count}"
      {
        :q => @content_properties[:keyword],
        :rpp => (count==0 ? 100 : count)
      }
    end

    #=Twitter表示DOM ID生成
    #
    #Return::DOM ID
    def dom_id
      "twitter_player_#{@content.id}"
    end

    #=jQuery Ajax Requestを行うjavascriptの生成
    #
    #TwitterPlayerにおける全リクエストの共通処理をまとめるためにメソッド化してある。
    #現在はエラー処理のみ共通化。
    #
    #_type_         :: 処理種別(retweet,search)
    #_script_       :: コールバック時に実行されるjavascript文字列
    #_query_string_ :: 対象URLに付加するquery_string
    #
    #Return::Ajax処理を行うjavascript
    def jquery_ajax_request_script(type, script, query_string=nil)
      account = ( (@content_properties[:user].blank? || @content_properties[:pass].blank?) ? nil : "#{@content_properties[:user]}:#{@content_properties[:pass]}@" )
      url = case type.to_sym
      when :retweet
        "http://#{account}api.twitter.com/1/statuses/retweets_of_me.json"
      when :search
        "http://#{account}search.twitter.com/search.json"
      else
        #raise "undefined twitter request type"
        aplog.Error("undefined twitter request type")
        raise AplInfomationException.new("undefined twitter request type")
      end
      url += "?#{query_string}" if query_string
      <<-SCRIPT
        jQuery.ajax({
          url: "#{url}",
          dataType: "jsonp",
          cache: false,
          error: function(req){
            switch(req.status){
              case 401:
                jQuery("##{dom_id}").replaceWith(#{_("アカウント情報が不正なためtwitter.comに接続できませんでした")});
                break;
              default:
                jQuery("##{dom_id}").replaceWith(#{_("twitter.comに接続できませんでした")});
                break;
            }
          },
          success: #{script}
        });
      SCRIPT
    end

    #=テンプレートHTMLの生成
    #
    #jQuery側でテンプレートとして使用するHTML。
    #(MVC的にいうViewのように使用)
    #
    #Return::テンプレートHTMl
    def jquery_templates    
      
      <<-TEMPLATES
        <div class="templates" style="display:none">
          <div class="rt_header" width="#{@content.width}">
            <img class="rt_image" width="48" height="48" />
            <strong class="rt_sname"></strong>
            <span class="rt_name"></span>
            <br />
          </div>
          
          <div class="rt_item">
          </div>
        
          <div class="s_header" width="#{@content.width}">
            <span class="s_keyword"></span>
            <br />
          </div>
          
          <div class="s_item">
            <span class="imagebox" style="float:left">
              <img class="s_image" width="48" height="48">
            </span>
            <span class="desc">
              <strong class="s_name"></strong>
              <span class="s_text"></span>
            </span>
            <br><br><br>
          </div>
        
        </div>
      TEMPLATES
    end
    
    #=マーキー属性文字列生成
    #
    #Return::マーキー属性文字列
    def marquee_options
      options = {:width => @content.width, :height => @content.height, :direction => @content_properties[:scroll_direction]}
      case @content_properties[:scroll_speed].to_i
      when 70
        options.store :scrolldelay, 70 
        options.store :scrollamount, 4
      when 50
        options.store :scrolldelay, 90 
        options.store :scrollamount, 3
      when 30
        options.store :scrolldelay, 120 
        options.store :scrollamount, 1
      else
        options = {}
      end
      options.map{|e| "#{e[0]}='#{e[1]}'"}.join(" ")
    end
  end
end
