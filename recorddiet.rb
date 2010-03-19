#!/usr/bin/ruby

require 'pstore'
require 'date'
require 'cgi'

def showdb(db)
  if ARGV[2] == "-p"
    db['root'].sort.each { |date,body|
      print  "#{date.month}/#{date.day} :  #{body}kg\n"
    }
  else
    s = ""
    db['root'].to_a.sort{ |a,b|
      b[0] <=> a[0]
    }.each { |v|
      s += "<tr><td>#{v[0].month}/#{v[0].day}</td><td>#{v[1]}kg</td></tr>\n"
    }
    cgi = CGI.new("html4")
    cgi.out() {
      cgi.head {cgi.title{"Recording diet"}} +
      cgi.body() {
        "\n<table>\n" + s + "</table>\n"
      }
    }
  end
end

db = PStore.new("/Users/nakauchiaya/Data/recorddiet.db")
#db = PStore.new("./recorddiet.db")

if !ARGV[0]
  db.transaction { showdb(db) } 
  exit
end

weight = ARGV[0].to_f 

offset = ARGV[1] ? ARGV[1].to_i : 0
date = Date.today + offset

db.transaction {
  db["root"] = {} unless db["root"]
  db["root"][date] = weight

  showdb(db)
}

