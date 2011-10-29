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

    @graph_kind = [24, 12, 6, 3]  # 2years, 1year, 6 month and 3 month
    @graph_weight_upper = 68.0
    @graph_weight_lower = 63.0
    @graph_fat_upper = 26.0
    @graph_fat_lower = 15.0

    @cgi = CGI.new("html3")
    @db = PStore.new(@dbn)
  end

  def main
    @erb = ERB.new(input_script)
    @erb_java = ERB.new(java_script)

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

  def build_java_script
    begin
      return @erb_java.result(binding)
    rescue
      return faild_script
    end
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

  def mk_uri
    uris = []
    @graph_kind.each do |month|
      range = month / 3
      end_d = Date.today
      division = Array.new(4) { |i| (end_d << (month - i * range)).to_s}
      uris << gchart_uri(division)+mk_charts(end_d, month)
    end
    uris
  end

  def gchart_uri(division)
    "http://chart.apis.google.com/chart?"+
      "chs=800x300&cht=lc&chxr=1,&chxt=x,y,r"+
      "&chxl=0:%7C#{division[0]}%7C#{division[1]}%7C#{division[2]}%7C#{division[3]}"+
      @graph_weight_lower.to_s+","+
      @graph_weight_upper.to_s+","+
      @graph_fat_lower.to_s+","+
      @graph_fat_upper.to_s+
      "&chdl=体重%7C脂肪率&chco=ff0000,00ff00"
  end

  def mk_charts(end_d, month)
    chart_weight = ['_']
    chart_fat = ['_']

    db = @db
    db.transaction do
      (end_d << month).upto(end_d) do |d|

        if db["root"][d] == nil
          chart_weight << chart_weight.last
          chart_fat << chart_fat.last

        else
          if db["root"][d].class == Float
            # Old db format. Only weight was written in db.
            weight = db["root"][d]
            fat = "_"
          else
            # New db foramt. [d][:weigh, :fat]
            weight = db["root"][d][:weight]
            fat = db["root"][d][:fat].to_i
          end

          if weight == 0
            chart_weight << chart_weight.last
          else
            chart_weight << conv_gchart(weight, @graph_weight_upper, @graph_weight_lower)
          end

          if fat == 0
            chart_fat << chart_fat.last
          elsif fat == "_"
            chart_fat << "_"
          else
            chart_fat << conv_gchart(fat, @graph_fat_upper, @graph_fat_lower)
          end

        end
      end
    end
    charts = "&chd=s:#{chart_weight.join},#{chart_fat.join}"
  end

  def conv_gchart(df, upper, lower)
    range = (upper - lower).to_f
    d = ((df - lower) / range * 61).to_i
    _d = d < 0 ? 0 : (d > 61 ? 61 : d)
    (('A'..'Z').map + ('a'..'z').map + ('0'..'9').map)[_d]
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

  def dbg
    return eval(@erb.src, binding, __FILE__,__LINE__+4)
  end

  def dbg_java
    return eval(@erb_java.src, binding, __FILE__,__LINE__+4)
  end

  def faild_script
    @cgi.out {
      @cgi.html() {
        @cgi.head {
          @cgi.title {'Recording diet'} +
          '<META HTTP-EQUIV="content-type" CONTENT="text/html;charset=utf-8">' +
          '<link rev="MADE" href="mailto:nakauchi@mtc.biglobe.ne.jp">'
        } + 
        @cgi.body { 
          "Error<p>" +
          " " + dbg_java +
          "<hr />" +
          " " + dbg
        }
      }
    }
  end
end

DispRdiet.new.main if __FILE__ == $0
#DispRdiet.new.dbg
