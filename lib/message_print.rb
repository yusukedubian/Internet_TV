module MessagePrint
  def self.included(base)
    base.send :helper_method, :notice, :alert, :alert_now, :conv_message
  end
 
  protected
    def alert(code, *str)
      flash[:notice] = ""
      msg = Message.find_by_message_code(code)
      if msg
        tmp = sprintf(msg.message_str, *str)
        flash[:alert] = tmp + sprintf(" (%s)", code)
      else
        flash[:alert] = code
      end
    end
    
    def alert_now(code, *str)
      flash[:notice] = ""
      msg = Message.find_by_message_code(code)
      if msg
        tmp = sprintf(msg.message_str, *str)
        flash.now[:alert] = tmp + sprintf(" (%s)", code)
      else
        flash.now[:alert] = code
      end
    end

    def notice(code, *str)
      flash[:alert] = ""
      msg = Message.find_by_message_code(code)
      if msg
        tmp = sprintf(msg.message_str, *str)
        flash[:notice] = tmp
      else
        flash[:notice] = code
      end
    end

    def conv_message(code, *str)
      msg = Message.find_by_message_code(code)
      tmp = sprintf(msg.message_str, *str)
      tmp.concat(" (#{code})")
    end
end
