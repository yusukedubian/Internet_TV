module Players
  
  class Soft_remocon_player
    require 'gettext/utils'
    include Validate
    
    def initialize()
    end

    def set_request(request)
      @request = request
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
      if !is_color_code(params["contents_setting"]["back_color"])
        raise "ERR_0x01025106"
      end
    end
    
    # プレーヤ設定保存時の処理
    def config_save
    end
    
    #コンフィグデータが必要な場合
    def config_create
    end
    
    def get_ajax(params)
      back_color = params["back_color"].insert(0, '#')
      html = create_button(params["owner_id"], params["button_type"], back_color, params["height"], params["width"], params["channel_id"])      
      return html
    end
    
    #出力用HTML
    def get_html
      html = ApplicationController.helpers.javascript_include_tag(:defaults)
      html << "
                <script type=\"text/javascript\">
                  init_refresh();

                  function init_refresh() {
                    button_refresh();
                    new PeriodicalExecuter(button_refresh, 10.0);
                  }

                  function button_refresh() {
                    new Ajax.Updater('soft_remocon',
                                     '/contents/ajax_update',
                                     {asynchronous:true,
                                      evalScripts:true,
                                      parameters:'player_id=#{@content.player_id}'
                                      +'&'+'ajax_param[owner_id]=#{@current_user.id}'
                                      +'&'+'ajax_param[button_type]=#{@content_properties["button_type"]}'
                                      +'&'+'ajax_param[back_color]=#{@content_properties["back_color"].delete('#')}'
                                      +'&'+'ajax_param[height]=#{@content["height"]}'
                                      +'&'+'ajax_param[width]=#{@content["width"]}'
                                      +'&'+'ajax_param[channel_id]=#{@content_properties["channel_id"]}'
                                     });
                  }

                  function page_refresh(url) {
                    window.parent.document.location.href = url;
                  }
                  
                  function on(count) {
                    document.getElementById(count+'img').style.borderStyle = 'inset';
                  }
                  
                  function off(count) {
                    document.getElementById(count+'img').style.borderStyle = 'outset';
                  }
                </script>
                <div id='soft_remocon'>
              "
        html << create_button(@current_user.id, @content_properties["button_type"], @content_properties["back_color"], @content["height"], @content["width"],@content_properties["channel_id"])
        html << "</div>"
      return html
    end
    
    def create_button(user_id, button_type, back_color, height, width, channel_id)
      html = ""
      case button_type
      when "remocon_display","remocon_display_s"
        #リモコン表示
        button_top = height.to_i * 0.1375
        button_left = width.to_i * 0.125
        button_height = (((height.to_i - ((height.to_i * 0.15) + (height.to_i * 0.25))) - (5 * 10)) / 4)
        button_width = ((width.to_i - (width.to_i * 0.15 * 2)) - (5 * 8)) / 3

        html << "<img style=\"position:absolute; top:0; left:0; background-color:#{back_color};\" src=\"/images/imagefile/soft_remocon.png\" height=\"#{height}\" width=\"#{width}\">
                 <table style=\"position:absolute; top:#{button_top.to_i}; left:#{button_left.to_i};\" cellpadding=5 >"
        count = 1
        while count <= 12
          if (count % 3) == 1
              html << "<tr>"          
          end
        
            current_user = User.find(user_id)
            channel = current_user.channels.find_by_channel_no(count)
             if channel
                page = channel.pages[0]
              if page
                @chan = Channel.find(channel.id)
                  pages = @chan.pages.find(:all,:order => "page_no")
                  if current_user.channels.find_by_id(channel_id).channel_no == count
                        html << "<td><img id='#{count.to_s}img' height=\"#{button_height.to_i}\" width=\"#{button_width.to_i}\" alt=\"#{count.to_s}\" src=\"/images/./channels/on/#{count.to_s}.gif\" style='border:red outset 3px;' onmouseover='on(#{count.to_s})' onmouseout='off(#{count.to_s})' onClick=\"page_refresh('/#{RuntimeSystem.page_save_dir(pages[0])}preview.html');\" /></td>"
                  else
                        html << "<td><img id='#{count.to_s}img' height=\"#{button_height.to_i}\" width=\"#{button_width.to_i}\" alt=\"#{count.to_s}\" src=\"/images/./channels/on/#{count.to_s}.gif\" style='border:gray outset 2px;' onmouseover='on(#{count.to_s})' onmouseout='off(#{count.to_s})' onClick=\"page_refresh('/#{RuntimeSystem.page_save_dir(pages[0])}preview.html');\" /></td>"
                  end
              else
                  html << "<td><img id='#{count.to_s}img' height=\"#{button_height.to_i}\" width=\"#{button_width.to_i}\" alt=\"#{count.to_s}\" src=\"/images/./channels/off/#{count.to_s}.gif\" style='border:gray outset 2px;' onmouseover='on(#{count.to_s})' onmouseout='off(#{count.to_s})' /></td>"
              end
            else
                html << "<td><img id='#{count.to_s}img' height=\"#{button_height.to_i}\" width=\"#{button_width.to_i}\" alt=\"#{count.to_s}\" src=\"/images/./channels/off/#{count.to_s}.gif\" style='border:gray outset 2px;' onmouseover='on(#{count.to_s})' onmouseout='off(#{count.to_s})' /></td>"
            end        

          if (count % 3) == 0
            html << "</tr>"
          end
          
          count = count + 1
        end
          
        html << "</table>"
      when "length_display","length_display_s"
        # 縦表示
        button_height = (height.to_i - (1 * 72)) / 12
        button_width = width.to_i - (1 * 7)
        
        html << "<table bgcolor='" + back_color + "' rules=\"none\" cellspacing=\"0\" style=\"position:absolute; top:0; left:0;\">"
        count = 1
        while count <= 12
          html << "<tr><td>"
          current_user = User.find(user_id)
          channel = current_user.channels.find_by_channel_no(count)
          if channel
              page = channel.pages[0]
            if page
              @chan = Channel.find(channel.id)
                pages = @chan.pages.find(:all,:order => "page_no")
               if current_user.channels.find_by_id(channel_id).channel_no == count
                    html << "<img id='#{count.to_s}img' height=\"#{button_height.to_i}\" width=\"#{button_width.to_i}\" alt=\"#{count.to_s}\" src=\"/images/./channels/on/#{count.to_s}.gif\" style='border:red outset 3px;' onmouseover='on(#{count.to_s})' onmouseout='off(#{count.to_s})' onClick=\"page_refresh('/#{RuntimeSystem.page_save_dir(pages[0])}preview.html');\" />"
               else
                    html << "<img id='#{count.to_s}img' height=\"#{button_height.to_i}\" width=\"#{button_width.to_i}\" alt=\"#{count.to_s}\" src=\"/images/./channels/on/#{count.to_s}.gif\" style='border:gray outset 2px;' onmouseover='on(#{count.to_s})' onmouseout='off(#{count.to_s})' onClick=\"page_refresh('/#{RuntimeSystem.page_save_dir(pages[0])}preview.html');\" />"
               end
            else
                html << "<img id='#{count.to_s}img' height=\"#{button_height.to_i}\" width=\"#{button_width.to_i}\" alt=\"#{count.to_s}\" src=\"/images/./channels/off/#{count.to_s}.gif\" style='border:gray outset 2px;' onmouseover='on(#{count.to_s})' onmouseout='off(#{count.to_s})' />"
            end
          else
              html << "<img id='#{count.to_s}img' height=\"#{button_height.to_i}\" width=\"#{button_width.to_i}\" alt=\"#{count.to_s}\" src=\"/images/./channels/off/#{count.to_s}.gif\" style='border:gray outset 2px;' onmouseover='on(#{count.to_s})' onmouseout='off(#{count.to_s})' />"
          end
          html << "</td></tr>"
          count = count + 1
        end
        html << "</table>"
      else
        # 横表示
        button_height = height.to_i - (1 * 8)
        button_width = (width.to_i - (1 * 73)) / 12
        
        html << "<table bgcolor='" + back_color + "' rules=\"none\" cellspacing=\"0\" style=\"position:absolute; top:0; left:0;\"><tr>"
        count = 1
        while count <= 12        
          current_user = User.find(user_id)
          channel = current_user.channels.find_by_channel_no(count)

          if channel
            page = channel.pages[0]
            if page
              @chan = Channel.find(channel.id)
                pages = @chan.pages.find(:all,:order => "page_no")
                if current_user.channels.find_by_id(channel_id).channel_no == count
                    html << "<td><img id='#{count.to_s}img' height=\"#{button_height.to_i}\" width=\"#{button_width.to_i}\" alt=\"#{count.to_s}\" src=\"/images/./channels/on/#{count.to_s}.gif\" style='border:red outset 3px;' onmouseover='on(#{count.to_s})' onmouseout='off(#{count.to_s})' onClick=\"page_refresh('/#{RuntimeSystem.page_save_dir(pages[0])}preview.html');\" /></td>"
                else
                    html << "<td><img id='#{count.to_s}img' height=\"#{button_height.to_i}\" width=\"#{button_width.to_i}\" alt=\"#{count.to_s}\" src=\"/images/./channels/on/#{count.to_s}.gif\" style='border:gray outset 2px;' onmouseover='on(#{count.to_s})' onmouseout='off(#{count.to_s})' onClick=\"page_refresh('/#{RuntimeSystem.page_save_dir(pages[0])}preview.html');\" /></td>"
                end
            else
                html << "<td><img id='#{count.to_s}img' height=\"#{button_height.to_i}\" width=\"#{button_width.to_i}\" alt=\"#{count.to_s}\" src=\"/images/./channels/off/#{count.to_s}.gif\" style='border:gray outset 2px;' onmouseover='on(#{count.to_s})' onmouseout='off(#{count.to_s})' /></td>"
            end
          else
              html << "<td><img id='#{count.to_s}img' height=\"#{button_height.to_i}\" width=\"#{button_width.to_i}\" alt=\"#{count.to_s}\" src=\"/images/./channels/off/#{count.to_s}.gif\" style='border:gray outset 2px;' onmouseover='on(#{count.to_s})' onmouseout='off(#{count.to_s})' /></td>"
          end
          count = count + 1
        end
        html << "</tr></table>"
      end

      return html
    end
    
  end
end
