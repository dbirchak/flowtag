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

require 'flowdb'

unless ARGV.length == 5
  puts "Usage: $0 <pcapfile> <sip> <dip> <sp> <dp>"
  exit
end
(f,sip,dip,sp,dp) = ARGV
fdb = FlowDB.new(f)
puts fdb.getflowdata(sip, dip, sp.to_i, dp.to_i)
