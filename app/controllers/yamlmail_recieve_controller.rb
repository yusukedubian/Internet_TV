class YamlmailRecieveController < ApplicationController
require "net/pop"
require "net/smtp"
require "socket"
require 'nkf'
require 'mailread'
require 'yaml'
require 'kconv'
require 'time'
require 'date'
require 'stringio'

  after_filter :flash_clear

  def flash_clear
    flash.discard
  end

  
  def show
    aplog.debug("START #{CLASS_NAME}#show")
    #userID = 1    
    userID = params[:userID]
    contentsID = params[:contentsID]
    #mail_subject = [params[:mailSubject1],params[:mailSubject2],params[:mailSubject3],params[:mailSubject4],params[:mailSubject5]]
    #mail_body_title = [params[:mailContentsTitle1],params[:mailContentsTitle2],params[:mailContentsTitle3],params[:mailContentsTitle4],params[:mailContentsTitle5]]
    mail_body = []
    yaml_mail_contents = []
    mail_subject = []   
    mail_body_title = []
    content = Content.find_by_id(contentsID,:include=>:contents_propertiess)
    k = 0
    
    aplog.debug("aaaaaaaaaaaaabbbbbbbbbbbbbbbbbbb")
    while k < content.contents_propertiess.size
      p k
      if content.contents_propertiess[k].property_value!=nil
        if content.contents_propertiess[k].property_key=="mailSubject1"
          mail_subject[0] = content.contents_propertiess[k].property_value
        elsif content.contents_propertiess[k].property_key=="mailSubject2"
          mail_subject[1] = content.contents_propertiess[k].property_value
        elsif content.contents_propertiess[k].property_key=="mailSubject3"
          mail_subject[2] = content.contents_propertiess[k].property_value
        elsif content.contents_propertiess[k].property_key=="mailSubject4"
          mail_subject[3] = content.contents_propertiess[k].property_value
        elsif content.contents_propertiess[k].property_key=="mailSubject5"
          mail_subject[4] = content.contents_propertiess[k].property_value
        elsif content.contents_propertiess[k].property_key=="mailContentsTitle1"
          mail_body_title[0] = content.contents_propertiess[k].property_value
        elsif content.contents_propertiess[k].property_key=="mailContentsTitle2"
          mail_body_title[1] = content.contents_propertiess[k].property_value
        elsif content.contents_propertiess[k].property_key=="mailContentsTitle3"
          mail_body_title[2] = content.contents_propertiess[k].property_value
        elsif content.contents_propertiess[k].property_key=="mailContentsTitle4"
          mail_body_title[3] = content.contents_propertiess[k].property_value
        elsif content.contents_propertiess[k].property_key=="mailContentsTitle5"
          mail_body_title[4] = content.contents_propertiess[k].property_value
        end
      end
      k += 1
    end
    p mail_subject
    p mail_body_title
        
    userMailAccount = UserProperty.find(:first,:conditions=>["user_id=?",userID])
    pop = Net::POP3.new(userMailAccount.pop3_address,userMailAccount.pop3_port) #メールサーバーを接続
    #pop = Net::POP3.new('pop.corpease.net',110) #メールサーバーを接続
    pop.start(userMailAccount.auth_user_name,userMailAccount.auth_password) #ログイン
    #pop.start('zhaopanfeng@shsafe.com', 'zhaopanfeng') #ログイン
    
    
    if pop.mails.empty? #メールボックスの中にメールがあるかどうかをチェック
      inbox = false
    else
      inbox = true
      mails = []
      #File.open("yaml_log.txt","wb")do|f| #書き込みのファイルを開く
        pop.mails.each do |m| #全部のmailを変数ｍへ                
          mails << StringIO.new(m.pop) 
        end
          
        while mail = mails.pop  #一つ一つメールを取得していく（最新から古いの順番）
          each_mail = getMailBody mail
          s = 0
          while s < mail_subject.size  #配列mail_subject.sizeで循環
            
            if each_mail["subject"] == mail_subject[s]  #subjectが一致した場合breakする
            /([0-9A-Za-z_!#\$%&*+\-\/=\?^_{|}\~.]+@[0-9,A-Z,a-z][0-9,a-z,A-Z,_,.,-]*)/ =~ each_mail["mail_from"]
              if mail_body[s] == nil
                mail_body[s] = each_mail
                #f.write(mail_body[s]) #ファイルへ書き込み
                mailBody = mail_body[s]["body"]
                mailBody = mailBody.to_s
                /#{mail_body_title[s]}:.*$/ =~ mailBody
                mailBody = $& 
                yaml_mail_contents[s] = mailBody
                p yaml_mail_contents[s]

              end            
            end
            s += 1
          end
        end          
      #end
    end
    p "abcdefghijklmnopqrstuvwxyz"
    htmlData = ""
    i = 0
    while i < yaml_mail_contents.size
      if yaml_mail_contents[i]!=nil
        htmlData << "☆"
        htmlData << yaml_mail_contents[i]
        htmlData << "&nbsp;&nbsp;&nbsp;&nbsp;"
      end
      i += 1  
    end
    p htmlData
    send_data(htmlData, :type=>"text/html", :disposition=>"inline")
    #puts "#{pop.mails.size} mails popped."
    pop.finish
    aplog.debug("END   #{CLASS_NAME}#show")
    
  end
    
  def getMailBody filename
    #メソッド：メール情報をHash 方のmail{}にいれる
    mail = {}
    mr = Mail.new(filename)
      
    mr.header["From"].nil? ?    mail["mail_from"] ="" : mail["mail_from"] = Kconv.toutf8(mr.header["From"].strip)
    mr.header["Date"].nil? ?    mail["send_date"] ="" : mail["send_date"] = DateTime.parse(mr.header["Date"].strip)
    mr.header["To"].nil? ?      mail["mail_to"] = ""  : mail["mail_to"] = Kconv.toutf8(mr.header["To"].strip)
    mr.header["Cc"].nil? ?      mail["mail_cc"] = ""  : mail["mail_cc"] = Kconv.toutf8(mr.header["Cc"].strip)
    mr.header["Subject"].nil? ? mail["subject"] = ""  : mail["subject"] = mr.header["Subject"].strip.kconv(Kconv::UTF8, Kconv::AUTO)
    mr.body.nil? ?              mail["body"] =""      : mail["body"] = mr.body.to_s.kconv(Kconv::UTF8, Kconv::AUTO)
    return mail
  end   


 
end


