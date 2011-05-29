#!ruby -Ku
require "thread"
INIT_FILE="vasdaqtv.ini"

CRDM_CMD = "c"
RAILS_CMD = "r"

START = "start"
STOP = "stop"
RESTART = "restart"
STATUS = "status"


c_flg = true
r_flg = true
@cd = `cd $(dirname $0);pwd`
@cd.chomp!
def exist_initFile
	File.exist?(INIT_FILE)
end

def checkPid fn
pid = ""
str = "|ps aux|grep " + fn + "|grep -v grep|awk {'print $2'}"

open(str,"r"){|f|
pid = f.gets
}
pid
end


def read_init_file
	File.open(INIT_FILE){|file|
		while line = file.gets
			if !line.nil? || line[0] != "#"
				eval(line)
			end
		end
	}
end

def start_crdm
  begin
    Thread.new do
      fork{
        exec("ruby " + @cd + CRDM_HOME + CRDM_PROG + " & >/dev/null")
      }
    end
  rescue
    puts "Corundum can not be started."
  end
end

def start_rails
  begin
    Thread.new do
      fork{
        exec("ruby " +  RAILS_PROG + " & >/dev/null")
      }
    end
  rescue
    puts "RAILS can not be started"
  end
end

def start_bluetoothdev
  begin
    Thread.new do
      fork{
        exec("java -cp " + BLUE_PROG + " & >/dev/null")
      }
    end
  rescue
    puts "RAILS can not be started"
  end
end




def ckill pid
  system("kill -term " + pid )
end
def rkill pid
  system("kill -kill " + pid )
end

read_init_file

#p CRDM_HOME
#p CRDM_PROG
#p RAILS_PROG


str = ""
ARGV.each {|arg|
  str =  arg
}


begin

ENV["CRDM_HOME"] = @cd + CRDM_HOME
ENV["BLUE_HOME"] = @cd + BLUE_HOME

if str == START
  #設定画面起動
  if (checkPid RAILS_PROG).nil?
    start_rails
    r_flg = true
  else
    r_flg = false
  end
  #コランダム起動
  if (checkPid CRDM_PROG).nil?
    start_crdm
    c_flg = true
  else
    c_flg = false
  end
  #BlueToothDevice起動
  if (checkPid BLUE_PROG).nil?
    start_bluetoothdev
    b_flg = true
  else
    b_flg = false
  end

  if r_flg && c_flg && b_flg
    puts "VASDAQ.TV is running"
  else
    if !r_flg
      puts "RAILS is already running"
    end
    if !c_flg
      puts "Corundum is already running"
    end
    if !b_flg
      puts "BlueToothDev is already running"
    end
    puts "VASDAQ.TV is already running"
  end

elsif str == STOP
  #設定画面終了
  if !(checkPid RAILS_PROG).nil?
    rkill (checkPid RAILS_PROG)
    r_flg = true
  else
    r_flg = false
  end
  #コランダム終了
  if !(checkPid CRDM_PROG).nil?
    ckill (checkPid CRDM_PROG)
    c_flg = true
  else
    c_flg = false
  end
  #BlueToothDevice終了
  if !(checkPid BLUE_PROG).nil?
    ckill (checkPid BLUE_PROG)
    b_flg = true
  else
    b_flg = false
  end

  if r_flg && c_flg
    puts "VASDAQ.TV is not running"
  else
    if !r_flg
      puts "RAILS is already stopped"
    end
    if !c_flg
      puts "Corundum is already stopped"
    end
    if !b_flg
      puts "BlueToothDev is already stopped"
    end
    puts "VASDAQ.TV is already stopped"
  end
elsif str == RESTART
  #設定画面終了
  if !(checkPid RAILS_PROG).nil?
    rkill (checkPid RAILS_PROG)
  end
  #コランダム終了
  if !(checkPid CRDM_PROG).nil?
    ckill (checkPid CRDM_PROG)
  end
  #BlueToothDev終了
  if !(checkPid BLUE_PROG).nil?
    ckill (checkPid BLUE_PROG)
  end
  #設定画面起動
  if (checkPid RAILS_PROG).nil?
    start_rails
  end
  #コランダム起動
  if (checkPid CRDM_PROG).nil?
    start_crdm
  end
  #BlueToothDev起動
  if (checkPid BLUE_PROG).nil?
    start_bluetoothdev
  end
  puts "VASDAQ.IT is restarted"
elsif str == STATUS
  if !(checkPid RAILS_PROG).nil?
    r_flg = true
  else
    r_flg = false
  end
  if !(checkPid CRDM_PROG).nil?
    c_flg = true
  else
    c_flg = false
  end
  if !(checkPid BLUE_PROG).nil?
    b_flg = true
  else
    b_flg = false
  end

#  if r_flg
#    puts "RAILS is Running"
#  else
#    puts "RAILS is not Running"
#  end
#  if c_flg
#    puts "Corundum is Running"
#  else
#    puts "Corundum is not Running"
#  end
  if r_flg && c_flg && b_flg
    puts "VASDAQ.TV is Running"
  else
    puts "VASDAQ.IT is not Running"
  end

else

end

rescue
  p $!
  p $@
end
