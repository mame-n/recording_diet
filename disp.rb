#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require "date"
require "cgi"
require "erb"
require "pstore"
require "pp"

class DispRdiet
  def initialize
    @dbn = "Data/recorddiet.db"
    @graph_weight_upper = 68.0
    @graph_weight_lower = 63.0
    @graph_fat_upper = 26.0
    @graph_fat_lower = 15.0

    @cgi = CGI.new("html3")
    @db = PStore.new(@dbn)
  end

  def main
    @erb = ERB.new(input_script)
    @erb_script = ERB.new(java_script)

    @cgi.out {
      @cgi.html() {
        @cgi.head {
          @cgi.title {'Recording diet'} +
          '<META HTTP-EQUIV="content-type" CONTENT="text/html;charset=utf-8">' +
          '<link rev="MADE" href="mailto:nakauchi@mtc.biglobe.ne.jp">' +
          build_java_script
        } + @cgi.body { build_page }
      }
    }
  end

  def java_script
    <<EOS
<SCRIPT type="text/javascript">
  <!--
      function showimg1(){document.area1.src = "<%= mk_uri[0]%>";}
      function showimg2(){document.area1.src = "<%= mk_uri[1]%>";}
      function showimg3(){document.area1.src = "<%= mk_uri[2]%>";}
      function showimg4(){document.area1.src = "<%= mk_uri[3]%>";}
    -->
</SCRIPT>
EOS
  end

  def build_java_script
    begin
      return @erb_script.result(binding)
    rescue
      return faild_script
    end
  end

  def mk_charts
    chart_weight = ['_']
    chart_fat = ['_']

    db = @db
    db.transaction do
      @start_d.upto(@end_d) do |d|
        if db["root"][d] == nil
          chart_weight << chart_weight.last
          chart_fat << chart_fat.last
        else
          if db["root"][d].class == Float
            # Old db format. Only weight was written in db.
            weight = db["root"][d]
            chart_weight << 
              (weight == 0 ? 
               chart_weight.last : 
               conv_gchart(weight,@graph_weight_upper, @graph_weight_lower))
            chart_fat << "_"
          else
            # New db foramt. [d][:weigh, :fat]
            weight = db["root"][d][:weight]
            chart_weight << 
              (weight == 0 ? 
               chart_weight.last : 
               conv_gchart(weight,@graph_weight_upper, @graph_weight_lower))
            fat = db["root"][d][:fat].to_i
            chart_fat << 
              (fat == 0 ? 
               chart_fat.last :
               conv_gchart(fat,@graph_fat_upper, @graph_fat_lower))
          end
        end
      end
    end
    charts = "&chd=s:#{chart_weight.join},#{chart_fat.join}"
  end

  def conv_gchart(df, upper, lower)
    range = (upper - lower).to_f
    d = ((df - lower) / range * 61).to_i
    d = d < 0 ? 0 :
      d > 61 ? 61 : d
    (('A'..'Z').map + ('a'..'z').map + ('0'..'9').map)[d]
  end

  def mk_uri
    tt = []

    range = 24
    width = range / 3
    @start_d = Date.today << range
    @end_d = Date.today
    division = Array.new(4) { |i| (@end_d << (range - i * width)).to_s}
    tt[0] = 
      "http://chart.apis.google.com/chart?"+
      "chs=800x300"+
      "&cht=lc"+
      "&chxt=x,y,r"+
      "&chxl=0:%7C#{division[0]}%7C#{division[1]}%7C#{division[2]}%7C#{division[3]}"+
      "&chxr=1,"+
      @graph_weight_lower.to_s+","+
      @graph_weight_upper.to_s+","+
      @graph_fat_lower.to_s+","+
      @graph_fat_upper.to_s+
      "&chdl=体重%7C脂肪率"+
      "&chco=ff0000,00ff00"+
      mk_charts

    range = 12
    width = range / 3
    @start_d = Date.today << range
    @end_d = Date.today
    division = Array.new(4) { |i| (@end_d << (range - i * width)).to_s}
    tt[1] = 
      "http://chart.apis.google.com/chart?"+
      "chs=800x300"+
      "&cht=lc"+
      "&chxt=x,y,r"+
      "&chxl=0:%7C#{division[0]}%7C#{division[1]}%7C#{division[2]}%7C#{division[3]}"+
      "&chxr=1,"+
      @graph_weight_lower.to_s+","+
      @graph_weight_upper.to_s+","+
      @graph_fat_lower.to_s+","+
      @graph_fat_upper.to_s+
      "&chdl=体重%7C脂肪率"+
      "&chco=ff0000,00ff00"+
      mk_charts

    range = 6
    width = range / 3
    @start_d = Date.today << range
    @end_d = Date.today
    division = Array.new(4) { |i| (@end_d << (range - i * width)).to_s}
    tt[2] = 
      "http://chart.apis.google.com/chart?"+
      "chs=800x300"+
      "&cht=lc"+
      "&chxt=x,y,r"+
      "&chxl=0:%7C#{division[0]}%7C#{division[1]}%7C#{division[2]}%7C#{division[3]}"+
      "&chxr=1,"+
      @graph_weight_lower.to_s+","+
      @graph_weight_upper.to_s+","+
      @graph_fat_lower.to_s+","+
      @graph_fat_upper.to_s+
      "&chdl=体重%7C脂肪率"+
      "&chco=ff0000,00ff00"+
      mk_charts

    range = 3
    width = range / 3
    @start_d = Date.today << range
    @end_d = Date.today
    division = Array.new(4) { |i| (@end_d << (range - i * width)).to_s}
    tt[3] = 
      "http://chart.apis.google.com/chart?"+
      "chs=800x300"+
      "&cht=lc"+
      "&chxt=x,y,r"+
      "&chxl=0:%7C#{division[0]}%7C#{division[1]}%7C#{division[2]}%7C#{division[3]}"+
      "&chxr=1,"+
      @graph_weight_lower.to_s+","+
      @graph_weight_upper.to_s+","+
      @graph_fat_lower.to_s+","+
      @graph_fat_upper.to_s+
      "&chdl=体重%7C脂肪率"+
      "&chco=ff0000,00ff00"+
      mk_charts

    tt
  end

  def build_page
    begin
      return @erb.result(binding)
    rescue
      return faild_script
    end
  end

  def input_script
    <<EOS
<h1>レコーディングダイエット</h1>
<img src=<%= mk_uri[0] %> name="area1">
<P>
<input type="button" onclick="showimg1()" value="2年">
<input type="button" onclick="showimg2()" value="1年">
<input type="button" onclick="showimg3()" value="6ヶ月"> 
<input type="button" onclick="showimg4()" value="3ヶ月"> 
EOS
  end

  def input_script_bak
    <<EOS
<h1>レコーディングダイエット</h1>
<img src="http://chart.apis.google.com/chart?chs=800x300&cht=lc&chxt=x,y,r&chxl=0:%7C2009/10/13%7C2010/4/13%7C2010/10/13%7C2011/4/13%7C2011/10/13&chxr=1,<%= @graph_weight_lower%>,<%= @graph_weight_upper%>%7C2,<%= @graph_fat_lower%>,<%= @graph_fat_upper %>&chdl=体重%7C脂肪率<%= mk_charts %>&chco=ff0000,00ff00">
EOS
  end

  def dbg
    return eval(@erb.src, binding, __FILE__,__LINE__+4)
  end

  def faild_script
    @cgi.out {
      @cgi.html() {
        @cgi.head {
          @cgi.title {'Recording diet'} +
          '<META HTTP-EQUIV="content-type" CONTENT="text/html;charset=utf-8">' +
          '<link rev="MADE" href="mailto:nakauchi@mtc.biglobe.ne.jp">'
        } + @cgi.body { "Error" }
      }
    }
  end

end

DispRdiet.new.main if __FILE__ == $0
#DispRdiet.new.dbg
