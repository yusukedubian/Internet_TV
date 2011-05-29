#!ruby -Ku
require "rubygems"
require 'sqlite3'

class DaoManager
  def initialize
    @con = SQLite3::Database.new("db/vasdaqit_MAIL")
    @con.busy_handler{|data, retries|
      sleep 0.2
      (retries<=3)
    }
  end

  def getConnection
    @con
  end
  
  def close
    @con.close
  end
  
  def commit
    @con.commit
  end
  
  def rollback
    @con.rollback
  end
  
  def selectSql(sql, *condition)
    if !condition.nil? || !(condition.length == 0)
    end

    begin
      columns, *rows = @con.execute2(sql,condition)
      result = []
      rows.each{|row|
      count = 0
        hash = Hash.new
        row.each{|elem|
          hash[columns[count]] = elem
          count += 1
        }
        result << hash
      }
      arr = []
      result.each{|key, value|
        arr << " :#{key} => #{value}"
      }
    rescue
    end
    return result
  end
end