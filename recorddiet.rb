#!/usr/bin/ruby

require "optparse"
require 'pstore'
require 'date'
require 'cgi'

def t_today
  "#{Date.today.month}/#{Date.today.day}"
end

def input_data
  return <<EOF
<form　method="POST" action="recorddiet.rb">
  <input type="text" name="date" value="#{t_today}"> : 
  <input type="text" name="fat">
  <input type="text" name="weight">
  <input type="submit" value="OK">
</form>
EOF
end

def showdb(db, dbgp=nil)
  if dbgp
    db['root'].sort.each { |date,body|
      if body.class == Float
        print  "#{date.month}/#{date.day} :  #{body}kg\n"
      else
        print  "#{date.month}/#{date.day} :  #{body[:weight]}kg : #{body[:fat]}%\n"
      end
    }
  else
    s = ""
    db['root'].to_a.sort{ |a,b|
      b[0] <=> a[0]
    }.each { |v|
      if v[1].class == Float
        s += "<tr><td>#{v[0].month}/#{v[0].day}</td><td>#{v[1]}kg</td></tr>\n"
      else
        s += "<tr><td>#{v[0].month}/#{v[0].day}</td><td>#{v[1][:weight]}kg</td><td>#{v[1][:fat]}%</td></tr>\n"
      end
    }
    cgi = CGI.new("html4")
    cgi.out() {
      cgi.head {cgi.title{"Recording diet"}} +
      "\n" +
      cgi.body() {
        "\n" +
        input_data + 
        "<table>\n" + s + "</table>" +
        "\n"
      }
    }
  end
end

db = PStore.new("/Users/nakauchiaya/Data/recorddiet.db")
#db = PStore.new("/Users/nakauchiaya/Data/d_recorddiet.db")

if !ARGV[0]
  db.transaction { showdb(db,true) } 
  exit
end

dbgp=nil
weight = 0.0
fat = 0.0
date = Date.today
opts = OptionParser.new
opts.on("-w WEIGHT"){|v| weight = v.to_f }
opts.on("-f FAT"){|v| fat = v.to_f }
opts.on("-p"){|v| dbgp = v }
opts.on("-o OFFSET"){|v| date += v.to_i }
f = opts.parse(ARGV)

db.transaction {
  db["root"] = {} unless db["root"]
  db["root"][date] = {:weight=>weight, :fat=>fat}

  showdb(db, dbgp)
}

