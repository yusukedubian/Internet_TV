#!ruby -Ku

require 'rubygems'
require 'uuidtools'
require "date"
require "time"
require "crdm/daoManager"

# declarate YamlMailDao class
class GetMailDao < DaoManager
  def initialize
    super
  end
  
  def createId
    UUIDTools::UUID.random_create.to_s.delete!("-")
  end
  
  def sysdate
    time = Time.new
    return time.strftime("%Y%m%d%H%M%S")
  end
  
#  def insertMailRecieve(mailmail_from, send_date, mail_to, mail_cc, subject, body, message_id)
  def insertMailRecieve(mail)
    mail["message_id"] = createId  if mail["message_id"].empty?
   if @con.execute("select *  from T_MAIL_RECIEVE where MAIL_RECEIVE_ID = ? ", mail["message_id"]).size == 0
    @con.execute("
      INSERT INTO T_MAIL_RECIEVE(
      MAIL_RECEIVE_ID,
      MAIL_FROM,
      SEND_DATE,
      MAIL_TO,
      MAIL_CC,
      SUBJECT,
      BODY,
      REC_LAST_UPDATE_DTIME,
      REC_LAST_UPDATER
      )VALUES(
      ?,
      ?,
      ?,
      ?,
      ?,
      ?,
      ?,
      ?,
      'vasdaqit'
      )",
      mail["message_id"], mail["mail_from"], mail["date"], mail["mail_to"], mail["mail_cc"], mail["subject"], mail["body"],sysdate)

    end
  end
end