module ContentsHelper
  def font_size_for_select
    [[ "10", "10"] , [ "15", "15" ],["20","20"],["30","30"],["35","35"],["40","40"],["50","50"],
    ["55","55"],["60","60"],["100","100"]]
  end
  
  def scroll_type_for_select
    [[_("スクロール"),"1"],[_("点滅"),"2"],[_("スクロール点滅"),"3"],[_("何もしない"),"4"]]
  end
  
  def scroll_direction_for_select
    [[_("上"),"up"],[_("左"),"Left"]]
  end
  
  def scroll_speed_for_select
    [[_("速い"),"70"],[_("普通"),"50"],[_("遅い"),"30"]]
  end

  def string_player_scroll_speed_for_select
    [[_("速い"),"10"],[_("普通"),"5"],[_("遅い"),"1"]]
  end
  
  def rss_lines_for_select
    [[_("1 行"),"line1"],[ _("2 行"),"line2"],[_("3 行"),"line3"]]
  end
  
  def yamlperiod_for_select
    [ [ _("今日"), "Today"] , [ _("日 "), "Day" ],[_("週 "),"Week"],[_("月 "),"Month"]]
  end
  
  def yaml_period_for_select
    [ [ _("１日分"), "Day"] , [ _("１週間分"), "Week" ],[_("１ヶ月分"),"Month"]]
  end
  
  def img_effect_for_select
    [[ "fade", "fade"] , [ "scrollDown", "scrollUp" ],["scrollUp","scrollDown"],["scrollLeft","scrollLeft"],
    ["scrollRight","scrollRight"],["zoom","zoom"],["zoomFade","zoomFade"],["growX","growX"],["growY","growY"]]
  end
  
  def string_font_color_select
    [[ _("赤"), "0xFF0000"] , [ _("緑"), "0x00FF00" ],[_("青"),"0x0000FF"],[_("黄"),"0xFFFF00"],
    [_("紫"),"0x9900FF"],[_("灰"),"0xFFFFFF"],[_("水色"),"0x00FFFF"],[_("ピンク"),"0xFFEEFF"],[_("オレンジ色"),"0xFFCC33"]]
  end

  def string_font_size_select
    [["小","10"],[ "中", "15" ],[ "大", "30"]]
  end
  
  def remocon_select
    [["リモコン表示","remocon_display"],["リモコン表示小","remocon_display_s"],[ "縦表示", "length_display"],[ "縦表示小", "length_display_s" ],[ "横表示", "horizontal_display"],[ "横表示小", "horizontal_display_s"]]
  end

  def line_width_for_select
    [["0","0"],["1","1"],["2","2"],["3","3"],["4","4"],["5","5"],["6","6"],["7","7"],["8","8"],["9","9"],["10","10"]]
  end
end
