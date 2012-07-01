#!ruby -Ku

require "./crdm/getMailControll"
require "./crdm/ch0001"
require "./crdm/ch0002"
#tes
while true
  pid = fork{
      begin
        get_mail = GetMailControll.new
        ch0001 = Ch0001.new
        ch0002 = Ch0002.new
        get_mail.getMailControll
        ch0001.ch0001
        ch0002.ch0002

      rescue => e
        p e
      end
      sleep 180
  }
  exitpid,status = *Process.waitpid2(pid)
end
