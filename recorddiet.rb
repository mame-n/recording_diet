require 'pstore'
require 'date'

exit unless ARGV[0]
weight = ARGV[0].to_f 
offset = 0
offset = ARGV[1].to_i if ARGV[1]
date = Date.today + offset

db = PStore.new("/Users/nakauchiaya/Documents/ruby/src/recorddiet/recorddiet.db")
db.transaction {
#  p date
#  p weight
#  p db
  db["root"] = {} unless db["root"]
  a = db["root"]
  a[date] = weight

  db['root'].each { |date,body|
    print  "#{date.month}/#{date.day} :  #{body}kg\n"
  }
}
