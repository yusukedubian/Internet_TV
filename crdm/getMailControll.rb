#!ruby -Ku

require "net/pop"
require "net/smtp"
require "socket"
require 'nkf'
require 'mailread'
require 'yaml'
require 'kconv'
require 'time'
require 'date'

require "crdm/getMailDao"
require "crdm/daoManager"

class GetMailControll
  def initialize
    @dao = GetMailDao.new
  end
  
  def getMailControll
    #メール取得
    pop =""
    begin
      timeout(180) do
        pop = Net::POP3.new("mail.vasdaqj.jp","110")
      end
#      nippou@vasdaqj.jp
#      vasdaqtv99
        pop.start("nippou@vasdaqj.jp", "vasdaqtv99") do |server|
          pop.each_mail do |msg|
            mail = StringIO.new(msg.pop)
            recieveMail mail
            msg.delete
         end
      end
    rescue Timeout::Error
    rescue
    end
  end
  
  def recieveMail mails
    mail = getMailBody mails
    if (analyzeMail mail["body"])
      insertMailRecieve mail
    end
  end
  
  
  def getMailBody filename
    mail = {}
    mr = Mail.new(filename)
    mail["mail_from"] ||= (convert(mr.header["From"]) || "")
    mail["date"] ||= (DateTime.parse(mr.header["Date"]).strftime("%Y%m%d%H%M%S") || "")
    mail["mail_to"] ||= (convert(mr.header["To"]) || "")
    mail["mail_cc"] ||= (convert(mr.header["Cc"]) || "")
    mail["subject"] ||= (convert(mr.header["Subject"]) || "")
    mail["message_id"] ||= (convert( mr.header["Message-id"]) || "")
    mail["body"] ||= (convert(mr.body.to_s) || "")
    return mail
  end
  
  def convert str
    conv = nil
    if str
      code = Kconv.guess(str)
      conv = str.kconv(Kconv::UTF8, code)
    end
    return conv
  end


  def analyzeMail body
    y_obj = nil
    begin
      y_obj = YAML.load(body)
    rescue ArgumentError=>e
      y_obj = nil
    rescue
      y_obj = nil
    end
    return y_obj
  end
  
  def insertMailRecieve mail
    @dao.insertMailRecieve(mail)
  end
end