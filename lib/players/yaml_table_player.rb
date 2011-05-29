# Copyright:: Copyright (c) 2010 VASDAQ Group All Rights Recieved
# License::   GPL
module Players

  #
  #=YAML Table Player (for VASDAQ.tv)
  #
  #取得したテーブルデータをjQueryを用いて表示する
  class YamlTablePlayer
    include Validate
    
    def initialize()
    end

    def set_request(request)
      @request = request
    end
    
    def set_content(current_user,content,params)
      @page = current_user.channels.find_by_id(params["channel_id"]).pages.find_by_id(params["page_id"])
      @current_user = current_user
      @content = content
      @content_properties = @content.contents_propertiess.inject({}) do |result, property|
        result.store property[:property_key], property[:property_value].to_s.delete("\n")
        result
      end.with_indifferent_access
      
      @params = params
    end
    
    # 画面入力項目チェック
    def validate(current_user,params)
      # メール件名
      if is_empty(params["contents_setting"][:subject])
        raise "メール件名が未入力です。"
      end
      
      # 表示列数
      if is_empty(params["contents_setting"][:col])
        raise "表示列数が未入力です。"
      elsif not is_half_num(params["contents_setting"][:col])
        raise "表示列数は数値で入力してください。"
      end
      
      # 枠線の太さ
      if is_empty(params["contents_setting"][:border])
        raise "枠線の太さが未入力です。"
      elsif not is_half_num(params["contents_setting"][:border])
        raise "枠線の太さは数値で入力してください。"
      end
      
      #各種色設定
      [
        {:key => :font,   :name => "フォントカラー"},
        {:key => :border, :name => "枠の色"},
        {:key => :row,    :name => "ヘッダ行背景色"},
        {:key => :col,    :name => "ヘッダ列背景色"},
        {:key => :back,   :name => "背景色"}
      ].each do |d|
        key = d[:key]
        name = d[:name]
        raise "#{name}がカラーコードではありません。カラーコードで入力して下さい。" unless is_color_code(params["contents_setting"]["#{key}_color"])
      end
    end
    
    def config_create
      {
        "channel_no" => @content.page.channel.channel_no,
        "page_no" => @content.page.page_no,
        "subject" => @content_properties[:subject]
      }
    end

    #=configセーブ時のコールバック
    #
    #プレイヤーのHTMLもこの時点で生成する。
    def config_save
      File.open(RuntimeSystem.content_save_dir(@content)+"index.html", "wb"){|f|
        f.write(get_html)
      }      
    end
    
    #=プレイヤーのHTML生成処理
    #
    #Return::生成したHTML
    def get_html
      FileUtils.mkdir_p(RuntimeSystem.content_save_dir(@content))
      FileUtils.copy_file("./public/javascripts/" + "jquery-1.2.3.min.js", RuntimeSystem.content_save_dir(@content) + "jquery-1.2.3.min.js")
      
      <<-HTML
        <html>
          <head>
            <title></title>
            <meta http-equiv='Content-type' content='text/html; charset=utf-8' >
            <script type='text/javascript' src='./jquery-1.2.3.min.js'></script>
            <style type="text/css">
              table, td, th {
                color: #{@content_properties[:font_color]};
                background-color: #{@content_properties[:back_color]};
                border: #{@content_properties[:border]}px #{@content_properties[:border_color]} solid;
                border-color: #{};
              }
              table {
                table-layout: fixed;
                width: #{@content.width}px;
              }
              thead th {
                background-color: #{@content_properties[:row_color]};
              }
              tbody {
                overflow: hidden;
                overflow-x: hidden;
                height: #{@content.height}px;
              }
              tbody th {
                background-color: #{@content_properties[:col_color]};
              }
            </style>
            <script>
              function autoScroll(){
                var th = document.getElementById("table_head");
                document.getElementById("table_body").style.height=(#{@content.height} - th.offsetHeight - (#{@content_properties[:border]} * 6));
              
                var tb = document.getElementById("#{dom_id}_table").tBodies[0];
                tb.scrollTop += 1;
                if(tb.scrollTop+tb.offsetHeight >= tb.scrollHeight){
                  tb.scrollTop = 0;
                }
                setTimeout("autoScroll()", #{@content_properties[:scroll_delay] || 100});
              }
            </script>

            <script type='text/javascript'><!--
              #{commma_format_jsmethod}
            --></script>

            <script type='text/javascript'><!--
            function refresh_#{dom_id}(){
              #{load_script("#{@content.id}.json")}
            };
            --></script>
          </head>
          <body style='margin: 2;' onload="refresh_#{dom_id}();setInterval('refresh_#{dom_id}()', #{Consts::REFRESH_INTERVAL_MSEC})">
            <div id="#{dom_id}">
            </div>
          </body>
        </html>
      HTML
    end

    private
   
    #=プレイヤー処理を行うjavascriptの生成
    #
    #Return::プレイヤー処理を行うjavascript文字列
    def load_script(url)
      jquery_ajax_request_script(url, <<-SCRIPT)
        function(json){
          if(json.length == 0){
            jQuery("##{dom_id}").replaceWith("表示する情報がありません");
          }
          else{
            jQuery("##{dom_id}").empty();
            
            var align="";
            var isComma = false;
            switch(json.format.style){
              case "center":
                align = "center";
                break;
              case "comma":
                isComma = true;
                // through
              case "right":
                align = "right";
                break;
              case "left":
                // through
              default:
                align = "left";
                break;
            }
            
            var header="<thead id='table_head'><tr><th>&nbsp;</th>";
            for(var i=0;i<#{@content_properties[:col]};i++){
              var v = (json.headers[i] === undefined ? "　" : json.headers[i]);
              header += "<th>"+v+"</th>";
            }
            header += "</tr></thead>";
            
            var body = "<tbody id='table_body'>";
            for(var i=0;json.entries[i];i++){
              var v = (json.entries[i].header === undefined ? "&nbsp;" : json.entries[i].header);
              body += "<tr><th>"+v+"</th>";
              for(var j=0;j<#{@content_properties[:col]};j++){
                var d = (json.entries[i].data[j] === undefined ? "&nbsp" : json.entries[i].data[j]);
                if(isComma){ d = commaFormat(d); }
                body += "<td align='"+align+"'>"+d+"</td>";
              }
              body += "</tr>";
            }
            body += "</tbody>";
            
            jQuery("##{dom_id}").append("<table id='#{dom_id}_table'>"+header+body+"</table>");
            autoScroll();
          }
        }
      SCRIPT
    end

    #=カンマ処理JSメソッド埋め込み
    #ERBでないため<%#〜%>できないのでコメント記述用にメソッド化
    #Return::カンマ処理を行うjavascript文字列
    def commma_format_jsmethod
      #http://www.geocities.co.jp/SiliconValley/4334/unibon/javascript/formatnumber.html
      #メソッド名変更+コメント削除+NaN対応
      <<-SCRIPT
        function commaFormat(x) {
            if(isNaN(x)){return x;}
            var s = "" + x;
            var p = s.indexOf(".");
            if (p < 0) {
                p = s.length;
            }
            var r = s.substring(p, s.length);
            for (var i = 0; i < p; i++) {
                var c = s.substring(p - 1 - i, p - 1 - i + 1);
                if (c < "0" || c > "9") {
                    r = s.substring(0, p - i) + r;
                    break;
                }
                if (i > 0 && i % 3 == 0) {
                    r = "," + r;
                }
                r = c + r;
            }
            return r;
        }
      SCRIPT
    end

    #=Twitter表示DOM ID生成
    #
    #Return::DOM ID
    def dom_id
      "yaml_table_player_#{@content.id}"
    end

    #=jQuery Ajax Requestを行うjavascriptの生成
    #
    #TwitterPlayerにおける全リクエストの共通処理をまとめるためにメソッド化してある。
    #現在はエラー処理のみ共通化。
    #
    #_type_         :: 処理種別(retweet,search)
    #_script_       :: コールバック時に実行されるjavascript文字列
    #
    #Return::Ajax処理を行うjavascript
    def jquery_ajax_request_script(url, script)
      <<-SCRIPT
        jQuery.ajax({
          url: "#{url}",
          dataType: "json",
          cache: false,
          error: function(req){
            jQuery("##{dom_id}").replaceWith("情報の取得に失敗しました");
          },
          success: #{script}
        });
      SCRIPT
    end
  end
end
