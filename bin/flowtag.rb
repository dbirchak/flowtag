#! /opt/local/bin/ruby

# FLOWTAG - parses and visualizes pcap data
# Copyright (C) 2007 Christopher Lee
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

unless ARGV.length > 0
  puts "Usage: #{$0} [-o <outputdir>] <pcapfile>"
  exit
end
require 'tk'  # this takes a long time to load
require 'tk/labelframe'
require 'flowdb'
require 'flowcanvas'
require 'flowtable'
require 'tkdoubleslider'

def select_cb(flows)
  $flowtable.clear
  $flowtable.addflows(flows.sort_by { |fl| fl[FlowDB::ST] })
  $flowview.clear
  $tag_entry.delete('@0','end')
  $currflow = nil
end

def tableselect_cb(idxs, flows)
  return if flows.length < 1
  flow = flows[0]
  idx = idxs[0]
  (st,sip,dip,sp,dp,pkts,bytes) = flow.strip.split(/\s+/)
  $curridx = idx
  $currflow = [sip,dip,sp,dp]
  $flowcanvas.select_flow(sip, dip, sp.to_i, dp.to_i)
  payload = $fdb.getflowdata(sip, dip, sp.to_i, dp.to_i, 5000)
  # replace the gremlins that destroy the performance of the flow vie
  payload = payload.gsub(/[\x00-\x09\x0b-\x1f\x7f-\xff]/) do |c| sprintf("\\x%02x", c[0]) end
  $flowview.clear
  $flowview.insert('end',payload) if payload
  tags = $fdb.getflowtags($currflow)
  $tag_entry.delete('@0','end')
  $tag_entry.insert('end',tags.join(" "))
end

def tag_cb(tags)
  return unless $currflow
  sip,dip,sp,dp = $currflow
  $fdb.tag_flow($currflow,tags.split(/\s+/))
  $flowtable.update_flow($curridx, $fdb.flows[$currflow.join("|")])
  alltags = $fdb.tags
  $tags_list.clear
  alltags.sort.each do |tag|
    $tags_list.insert 'end',tag
  end
end

def tag_select
  tags = []
  indices = $tags_list.curselection
  indices.each do |i|
    tags.push($tags_list.get(i))
  end
  $tags_list.focus 
  flows = []
  tags.each do |tag|
    flows += $fdb.flows_taggedwith(tag)
  end
  select_cb(flows)
end

def finish
  $fdb.writetagdb
  $fdb.close
  puts "Thank you for playing.  Please send suggestions to scholar.freenode@gmail.com"
  exit
end
if ARGV[0] == '-o'
  outputdir = ARGV[1]
  $fdb = FlowDB.new(ARGV[2],outputdir)
else
  $fdb = FlowDB.new(ARGV[0])
end
pkt_min = byte_min = time_min = 2**32
pkt_max = byte_max = time_max = 0
$fdb.flows.each do |key,flow|
  pkt_min = flow[FlowDB::PKTS] if flow[FlowDB::PKTS] < pkt_min
  pkt_max = flow[FlowDB::PKTS] if flow[FlowDB::PKTS] > pkt_max
  byte_min = flow[FlowDB::BYTES] if flow[FlowDB::BYTES] < byte_min
  byte_max = flow[FlowDB::BYTES] if flow[FlowDB::BYTES] > byte_max
  time_min = flow[FlowDB::ST] if flow[FlowDB::ST] < time_min
  time_max = flow[FlowDB::ST] if flow[FlowDB::ST] > time_max
end
root = TkRoot.new() {
  title "FlowTag v2.0"
  protocol('WM_DELETE_WINDOW', proc{ finish })
}
root.bind('Control-q', proc{ finish })
root.bind('Control-c', proc{ finish })
trap('SIGINT') { finish }
TkPalette.setPalette('background','grey20','foreground','white','disabledBackground','grey20','disabledForeground','grey30')
left_frame = TkFrame.new(root)
  left_top_frame = TkLabelFrame.new(left_frame,:text=>'Flow Table')
  left_mid_frame = TkLabelFrame.new(left_frame,:text=>'Flow Tags')
  left_bot_frame = TkLabelFrame.new(left_frame,:text=>'Payload View')
right_frame = TkFrame.new(root)
  right_top_frame = TkLabelFrame.new(right_frame,:text=>'Connection Visualization')
  right_bot_frame = TkLabelFrame.new(right_frame,:text=>'Filters')
tags_frame = TkLabelFrame.new(root, :text=>'Tags List')

left_frame.grid(:row=>0,:column=>0,:sticky=>'new')
  left_top_frame.grid(:row=>0,:column=>0,:sticky=>'news')
  left_mid_frame.grid(:row=>1,:column=>0,:sticky=>'news')
  left_bot_frame.grid(:row=>2,:column=>0,:sticky=>'news')
right_frame.grid(:row=>0,:column=>1,:sticky=>'new')
  right_top_frame.grid(:row=>0,:column=>0,:sticky=>'news')
  right_bot_frame.grid(:row=>1,:column=>0,:sticky=>'news')
tags_frame.grid(:row=>0,:column=>2,:sticky=>'new')

# LEFT FRAME
$flowtable = FlowTable.new(left_top_frame,$fdb.flows.values.sort_by { |fl| fl[FlowDB::ST] })
$flowtable.pack(:side=>'top',:expand=>1,:fill=>'both',:anchor=>'n')
$flowtable.set_select_cb(proc { |idxs,flows| tableselect_cb(idxs,flows) })

$tag_entry = TkEntry.new(left_mid_frame) {
  font TkFont.new('Monaco 12')
}
$tag_entry.bind('Return', proc { |e| tag_cb($tag_entry.get) } )
$tag_entry.pack(:side=>'right', :expand=>1, :fill=>'x')

flowview_scrollbar = TkScrollbar.new(left_bot_frame)
$flowview = flowview = TkText.new(left_bot_frame) {
  font TkFont.new('Monaco 12')
  wrap 'char'
  height 30
  width 60
}
flowview_scrollbar.pack(:side=>'right', :fill=>'y')
$flowview.pack(:side=>'bottom',:expand=>1,:fill=>'both')
$flowview.yscrollbar(flowview_scrollbar);

# TAGS FRAME
$tags_list = TkScrollbox.new(tags_frame) {
  font TkFont.new('Monaco 12')
  height 40
  width 20
}
$tags_list.pack(:fill=>'y',:expand=>1)
$fdb.tags.sort.each do |tag|
  $tags_list.insert('end',tag)
end
$tags_list.bind('<ListboxSelect>',proc { tag_select })

# RIGHT FRAME
$flowcanvas = FlowCanvas.new(right_top_frame,$fdb.flows.sort_by { |k,fl| fl[FlowDB::ST] })
$timeslide = TkDoubleSlider.new(right_bot_frame, :min=>time_min, :max=>time_max, :low=>time_min, :high=>time_max, :snap => 300, :label=>'Time', :valuefmt => proc { |x| Time.at(x).strftime("%H:%M") }, :deltafmt => proc { |x| sprintf("%0.2f hours", (x/3600.0)) })
$pktslide = TkDoubleSlider.new(right_bot_frame, :min=>1, :max=>pkt_max, :low=>1, :high=>pkt_max, :logbase => true, :snap => 1.0, :label=>'Packets')
$byteslide = TkDoubleSlider.new(right_bot_frame, :min=>1, :max=>byte_max, :low=>1, :high=>byte_max, :logbase => true, :snap => 1.0, :label=>'Bytes')
$flowcanvas.pack
$timeslide.pack(:side=>'top')
$pktslide.pack
$byteslide.pack(:side=>'bottom')
$flowcanvas.set_select_cb(proc { |x| select_cb(x) })
$timeslide.change_cb = proc { |low,high| $flowcanvas.set_time_range(low,high) };
$pktslide.change_cb = proc { |low,high| $flowcanvas.set_packet_range(low,high) };
$byteslide.change_cb = proc { |low,high| $flowcanvas.set_byte_range(low,high) };
$currflow = nil

Tk.mainloop()

