class YamlmailsController < ApplicationController
  CLASS_NAME = self.name
  require 'yaml'
  skip_before_filter :verify_authenticity_token
  before_filter :login_required
  after_filter :flash_clear

  def flash_clear
    aplog.debug("START #{CLASS_NAME}#flash_clear")
    flash.discard
    aplog.debug("END   #{CLASS_NAME}#flash_clear")
  end
  
  def index
    aplog.debug("START #{CLASS_NAME}#index")
    @mailinfo = {}
    aplog.debug("END   #{CLASS_NAME}#index")
  end
  
  def yamlcheck
    aplog.debug("START #{CLASS_NAME}#yamlcheck")
    @mailinfo = params["mail_info"]

    begin
      yaml_grammar_check(@mailinfo["body"])
      notice("MSG_0x00000007")
    rescue Exception => e
      alert(e.message)
    end
    render :action => 'index'
    aplog.debug("END   #{CLASS_NAME}#yamlcheck")
  end

  def yamlsend
    aplog.debug("START #{CLASS_NAME}#yamlsend")
    @mailinfo = params["mail_info"]
    @user_property = current_user.user_property

    begin
      yaml_smtp_setting_check(@user_property)
      
      yaml_mail_info_check(@mailinfo)
      
      begin
        if !YamlMailer.deliver_send(@mailinfo, @user_property)
          raise "ERR_0x01020102"
        end
      rescue Exception => e
        raise "ERR_0x01020102"
      end
      
      notice("MSG_0x00000006")
    rescue Exception => e
      alert(e.message)
    end
    aplog.debug("END   #{CLASS_NAME}#yamlsend")
    render :action => 'index'
  end

protected
  def yaml_smtp_setting_check(user_property)
    aplog.debug("START #{CLASS_NAME}#yaml_smtp_setting_check")
    smtp_checker = [["email", "ERR_0x01020103"], ["domain", "ERR_0x01020108"],
                    ["smtp_address", "ERR_0x01020105"], ["smtp_port", "ERR_0x01020104"],
                    ["authentication", "ERR_0x01020106"], ["auth_user_name", "ERR_0x01020107"],
                    ["auth_password", "ERR_0x01020108"]]
  
    pop3_checker = [["pop3_address", "ERR_0x0102010B"], ["pop3_port", "ERR_0x0102010A"]]

    if user_property.nil?
      raise "ERR_0x01020111"
    end

    yaml_blank_check(user_property, smtp_checker)

    if user_property["authentication"] == "4"
      yaml_blank_check(user_property, pop3_checker)
    end
    aplog.debug("END   #{CLASS_NAME}#yaml_smtp_setting_check")
  end

  def yaml_blank_check(user_property, checker)
    aplog.debug("START #{CLASS_NAME}#yaml_blank_check")
    checker.each do |check_key, msg_code|
      if user_property[check_key].blank?
        raise msg_code
      end
    end
    aplog.debug("END   #{CLASS_NAME}#yaml_blank_check")
  end

  def yaml_email_address_check(email)
    aplog.debug("START #{CLASS_NAME}#yaml_email_address_check")
    if !is_half_char(email) || !is_mail_addr(email)
      aplog.debug("END   #{CLASS_NAME}#yaml_email_address_check")
      return false
    end
    aplog.debug("END   #{CLASS_NAME}#yaml_email_address_check")
    return true    
  end

  def yaml_mail_info_check(mail_info)
    aplog.debug("START #{CLASS_NAME}#yaml_mail_info_check")
    check = [["to", "ERR_0x0102010E"], ["cc", "ERR_0x0102010F"], ["bcc", "ERR_0x01020110"]]
    
    if mail_info["to"].blank? && mail_info["cc"].blank? && mail_info["bcc"].blank?
      raise "ERR_0x0102010D"
    end
    
    check.each do |check_key, msg_code|
      if !mail_info[check_key].blank?
        if !yaml_email_address_check(mail_info[check_key])
          raise msg_code
        end
      end
    end
    yaml_grammar_check(mail_info["body"])
    aplog.debug("END   #{CLASS_NAME}#yaml_mail_info_check")
  end
  
  def yaml_grammar_check(body)
    aplog.debug("START #{CLASS_NAME}#yaml_grammar_check")
    begin
      if !YAML.load(body)
        raise "ERR_0x01020101"
      end
    rescue ArgumentError => e
      raise "ERR_0x01020101"
    rescue => e
      raise "ERR_0x0102010C"
    end
    aplog.debug("END   #{CLASS_NAME}#yaml_grammar_check")
  end
end
