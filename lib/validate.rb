module Validate
  
  def is_empty(str)
    flg = false
    flg = str.nil? || str.blank?
    return flg
  end

  def is_half_char(str)
    flg = false
    flg = check_length(str, str.length, Compare::EQUAL)
    return flg
  end
  
  def is_half_num(str)
    flg = false
    str.scan(/./m){|ch|
       tmp = /\d/ =~ ch
       if tmp.nil?
         flg = false
         break
       else
          flg = true
       end
    }
    return flg
  end
  
  def is_zero_num(str)
    flg = false
    tmp=str.to_i
       if tmp == 0
         flg = true
       else
         flg = false
       end
     return flg
  end
  
  def is_half_alpha(str)
    flg = false
    
    str.scan(/./m){|ch|
       tmp = /[A-Za-z]/ =~ ch
       if tmp.nil?
         flg = false
         break
       else
          flg = true
       end
    }
    return flg
  end
  
  def is_half_alpha_num(str)
    flg = false
    
    str.scan(/./m){|ch|
       tmp = /[0-9A-Za-z]/ =~ ch
       if tmp.nil?
         flg = false
         break
       else
          flg = true
       end
    }
    return flg
  end
  
  def check_length(str, length, opt)
    flg = false

    if opt == Compare::MORE_THAN
      #opt=1 -> more than
      if str.split(//).length >= length
        flg = true
      end
    elsif opt == Compare::LESS_THAN
      #opt = 2 -> less than
      if str.split(//).length <= length
        flg = true
      end
    else
       #default -> equal
      if str.split(//).length == length
        flg = true
      end
    end
    return flg
  end
  
  def is_mail_addr(str)
    flg = false
    tmp = /^[^\s]+@((?:[-a-z0-9]+.)+[a-z]{2,})/i =~ str
    if !tmp.nil?
      flg = true
    end
    return flg
  end
 
  def is_url(str)
    flg = false
    tmp = /^http:\/\// =~ str || tmp = /^https:\/\// =~ str
    if !tmp.nil?
      str.scan(/./m){|ch|
        tmp = /[^\\"|`^><}{\]\[]/ =~ ch
        if tmp.nil?
          flg = false
          break
        else
           flg = true
        end
      }
    end
    return flg
  end
  
  def is_color_code(str)
    flg = false
    if check_length(str, 7, Compare::EQUAL)
      if /^(#[0-9A-Fa-f]{6})/ =~ str
        flg = true
      end
    end
    
    return flg
  end
  
  def is_check_select(str, selectArray)
    flg = false
    for tmp in selectArray
      if str == tmp[1]
        flg = true
        break
      end
    end
    return flg
  end
  
  #str:チェックの文字
  #length:MAXサイズ
  #pagewidth:ページ幅
  #xpos:x位置
  #return:0,OK;1,>入力のMAXVALUE；2,<0；3,>ページ幅；4,X位置＋幅サイズ＞ページ幅
  def check_content_width(str,length,pagewidth,xpos)
    result = 0
    temp = str.to_i
    if is_empty(xpos)
      xpos = 0
    else
      xpos = xpos.to_i
    end
    if str.length > length.to_i
      return 1
    end
    if temp <= 0
      return 2
    end
    if temp > pagewidth.to_i
      return 3
    end    
    if temp + xpos > pagewidth.to_i
      return 4
    end
    return result
  end
  
  #str:チェックの文字
  #length:MAXサイズ
  #pageheight:ページ縦
  #ypos:y位置
  #return:0,OK;1,>入力のMAXVALUE；2,<0；3,>ページ高さ；4,y位置＋縦サイズ＞ページ高さ  
  def check_content_height(str,length,pageheight,ypos)
    result = 0
    temp = str.to_i
    if is_empty(ypos)
      ypos = 0
    else
      ypos = ypos.to_i
    end
    if str.length > length.to_i
      return 1
    end
    if temp <= 0
      return 2
    end
    if temp > pageheight.to_i
      return 3
    end
    if temp + ypos > pageheight.to_i
      return 4
    end
    return result
  end
  
  #str:チェックの文字
  #length:MAXサイズ
  #pagewidth:ページ幅
  #xpos:x位置
  #return:0,OK;1,>入力のMAXVALUE；2,<0；3,>ページ幅；4,X位置＋幅サイズ＞ページ幅  
  def check_content_xpos(str,length,pagewidth,width)
    result = 0
    temp = str.to_i
    if is_empty(width)
      width = 0
    else
      width = width.to_i
    end
    if str.length > length.to_i
      return 1
    end
    if temp < 0
      return 2
    end
    if temp > pagewidth.to_i
      return 3
    end    
    if temp + width > pagewidth.to_i
      return 4
    end
    return result    
  end
  
  #str:チェックの文字
  #length:MAXサイズ
  #pageheight:ページ縦
  #ypos:y位置
  #return:0,OK;1,>入力のMAXVALUE；2,<0；3,>ページ高さ；4,y位置＋縦サイズ＞ページ高さ  
  def check_content_ypos(str,length,pageheight,height)
    result = 0
    temp = str.to_i
    if is_empty(height)
      height = 0
    else
      height = height.to_i
    end
    if str.length > length.to_i
      return 1
    end
    if temp < 0
      return 2
    end
    if temp > pageheight.to_i
      return 3
    end
    if temp + height > pageheight.to_i
      return 4
    end
    return result    
  end
  
  def has_wrap_text?(str)
    flg = false
      tmp = /[<>|'"\()]/=~ str
      if !tmp.nil?
        flg= true
      else
        flg= false
      end
    return flg
  end
  
end
