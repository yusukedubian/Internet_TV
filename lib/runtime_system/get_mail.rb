require "net/pop"
require "net/smtp"
require "socket"
require 'nkf'
require 'mailread'
require 'yaml'
require 'kconv'
require 'time'
require 'date'

module RuntimeSystem
  class GetMail
    def execute(content, current_user)
      begin
        timeout(40) do
          return if !config = current_user.user_property
          pop = Net::POP3.new(config.pop3_address,config.pop3_port)
          pop.start(config.auth_user_name, config.auth_password) do |server|
          mails = []
          pop.each_mail do |msg|
            mails << StringIO.new(msg.pop)
          while mail = mails.pop 
            each_mail = getMailBody mail
            /([0-9A-Za-z_!#\$%&*+\-\/=\?^_{|}\~.]+@[0-9,A-Z,a-z][0-9,a-z,A-Z,_,.,-]*)/ =~ each_mail["mail_from"]
            each_mail["mail_from"] = $1
            #メールデータ保存
            mail_data = RuntimeDataMail.new(each_mail)
            current_user.runtime_data_mails << mail_data
            current_user.save!
          end
            msg.delete
         end
       end
      end
      rescue Timeout::Error => e
      rescue
      end
    end
    
    def getMailBody filename
      mail = {}
      mr = Mail.new(filename)
      
      mr.header["From"].nil? ?    mail["mail_from"] ="" : mail["mail_from"] = Kconv.toutf8(mr.header["From"].strip)
      mr.header["Date"].nil? ?    mail["send_date"] ="" : mail["send_date"] = DateTime.parse(mr.header["Date"].strip)
      mr.header["To"].nil? ?      mail["mail_to"] = ""  : mail["mail_to"] = Kconv.toutf8(mr.header["To"].strip)
      mr.header["Cc"].nil? ?      mail["mail_cc"] = ""  : mail["mail_cc"] = Kconv.toutf8(mr.header["Cc"].strip)
      mr.header["Subject"].nil? ? mail["subject"] = ""  : mail["subject"] =Kconv.toutf8( mr.header["Subject"].strip)
      mr.body.nil? ?              mail["body"] =""      : mail["body"] = Kconv.toutf8(mr.body.to_s)
      return mail
    end
    
    
    def deleteMail id
    end
  
  end
end

