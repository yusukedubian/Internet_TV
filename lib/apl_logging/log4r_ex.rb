require 'log4r'
require 'log4r/yamlconfigurator'
require 'initializer'

module Log4r
  class AplicationFormatter < Formatter
    def format(event)
      ctime=Time.now
      if event.tracer.nil?
        short_trace_1 = ""
        short_trace_length_1 = 0
        short_trace_2 = ""
        short_trace_length_2 = 0
      else
        str = event.tracer[0]
        # ubuntuだとevent.tracerにメソッド名がない場合がある。
        str =~ /(.*?):(\d+):in `(.*)'/
        filepath, linenum, methodname = $1, $2, $3
        str =~ /(.*?):(\d+)/
        filepath, linenum = $1, $2
        
        filename = filepath.split(/\//).pop
        short_trace_1 = filename+":"+linenum
        short_trace_length_1 = 32
#        short_trace_2 = methodname
#        short_trace_length_2 = 30
      end
      
      sprintf("[%d/%02d/%02d %02d:%02d:%02d.%06d][%6d][%20s][%5s][%*s][%*s]>%s\n", 
               ctime.year, ctime.month, ctime.day, ctime.hour, ctime.min, ctime.sec, (ctime.usec/1000).round,
               Process.pid,
               Thread.current,
               event.name, 
               MaxLevelLength, LNAMES[event.level], 
               short_trace_length_1, short_trace_1,
#               short_trace_length_2, short_trace_2,
               event.data)
    end
  end
end

