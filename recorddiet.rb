require 'pstore'
require 'date'

def showdb(db)
  db['root'].sort.each { |date,body|
    print  "#{date.month}/#{date.day} :  #{body}kg\n"
  }
end

db = PStore.new("/Users/nakauchiaya/Documents/ruby/src/recorddiet/recorddiet.db")
#db = PStore.new("./recorddiet.db")

if !ARGV[0]
  db.transaction { showdb(db) } 
  exit
end

weight = ARGV[0].to_f 

offset = ARGV[1] ? ARGV[1].to_i : 0
date = Date.today + offset

db.transaction {
#  p date
#  p weight
#  p db
  db["root"] = {} unless db["root"]
  db["root"][date] = weight

  showdb(db)
}

