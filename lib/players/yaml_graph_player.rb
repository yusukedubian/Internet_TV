# Copyright:: Copyright (c) 2010 VASDAQ Group All Rights Recieved
# License::   GPL
module Players

  #
  #=YAML Graph Player (for VASDAQ.tv)
  #
  #取得したグラフデータをjQueryを用いて表示する
  class YamlGraphPlayer
    require 'gettext/utils'
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
        raise "メール件名が未入力です"
      end
      
      # グラフタイトル
      if is_empty(params["contents_setting"][:title])
        raise "グラフタイトルが未入力です。"
      end
      
      # 種類
      if is_empty(params["contents_setting"][:renderer])
        raise "種類が未入力です。"
      elsif !(["pie", "bar", "line"].include?(params["contents_setting"][:renderer]))
        raise "種類が不正です"
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
      d_path = RuntimeSystem.content_save_dir(@content)
      dir_path = d_path+"jqplot"
      if File.exist?(dir_path)
        # pass
      else
        FileUtils.mkdir_p(d_path)
        FileUtils.cp_r("./public/javascripts/jqplot", d_path)
      end
      #FileUtils.cp_r("./public/javascripts/jqplot", RuntimeSystem.content_save_dir(@content))
      
      <<-HTML
        <html>
          <head>
            <title></title>
            <meta http-equiv='Content-type' content='text/html; charset=utf-8' >
            <!--[if IE]><script language='javascript' type='text/javascript' src='./jqplot/excanvas.js'></script><![endif]-->
            <script type='text/javascript' src='./jqplot/jquery-1.3.2.min.js'></script>
            <script type='text/javascript' src='./jqplot/jquery.jqplot.min.js'></script>
            <script type='text/javascript' src='./jqplot/plugins/jqplot.pieRenderer.min.js'></script>
            <script type='text/javascript' src='./jqplot/plugins/jqplot.categoryAxisRenderer.min.js'></script>
            <script type='text/javascript' src='./jqplot/plugins/jqplot.barRenderer.min.js'></script>
            <link rel="stylesheet" href="./jqplot/jquery.jqplot.min.css" type="text/css" media="screen" title="no title" charset="utf-8">
            <script type='text/javascript'><!--
            function refresh_#{dom_id}(){
              #{load_script("#{@content.id}.json")}
            };
            --></script>
          </head>
          <body style='margin: 2;' onload="refresh_#{dom_id}();setInterval('refresh_#{dom_id}()', #{Consts::REFRESH_INTERVAL_MSEC})">
            <div id="#{dom_id}" style="height:#{@content.height}px;width:#{@content.width}px;">
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
            var options = json.options_code;
            #{ set_renderer }
            jQuery.jqplot("#{dom_id}", json.data, options);
          }
        }
      SCRIPT
    end

    def set_renderer
      case @content_properties[:renderer] 
      when "bar"
        <<-JS
          options["seriesDefaults"]["renderer"] = $.jqplot.BarRenderer;
          options["axes"]["xaxis"]["renderer"] = $.jqplot.CategoryAxisRenderer;
        JS
      when "pie"
        'options["seriesDefaults"] = {renderer:$.jqplot.PieRenderer};'
      when "line"
        #折れ線の場合特殊な設定は不要
      end
    end

    #=表示DOM ID生成
    #
    #Return::DOM ID
    def dom_id
      "yaml_graph_player_#{@content.id}"
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
