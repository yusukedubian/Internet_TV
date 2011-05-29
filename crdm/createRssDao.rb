#!ruby -Ku

require "rubygems"
require "date"
require "uuidtools"
require "crdm/daoManager"

class CreateRssDao < DaoManager

  def initialize
    super
  end
  
  def selectRssChannel(subject, timeS, timeE)
    sql = "SELECT * FROM T_MAIL_RECIEVE where subject = ? and SEND_DATE >= ? and SEND_DATE <= ?"
    condition = []
    condition << subject
    condition << timeS
    condition << timeE
    rs = (selectSql(sql,condition) || [])
    return rs 
  end
end