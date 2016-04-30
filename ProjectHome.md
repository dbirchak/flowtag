FlowTag combines a flow-based view of streams, a visual flow selector (using a parallel-coordinates view), and keyword tagging to enable the rapid analysis of a packet capture.  FlowTag also supports the export of tagged flows along with the flowdb and tagging information.

# FlowTag #

FlowTag is an interactive network trace viewer. It operates on PCAP files, produces a database of flows, and then visualizes the results. The user can then filter for flows of interest, view the payload, and tag the flow with relevant keywords. The current version is written in Ruby using the Tk interface. The code is released under GPL, except the _pcapparser_ library, which is released under LGPL.

The interface is comprised of 6 main elements as follows: <img src='http://chrislee.dhs.org/projects/flowtag/flowtag2.png' width='525' />

  * Flow Table_. A list of matching flows (source IP, destination IP, source port, destination port, and time). When a flow in this table is clicked on, the contents of the flow will be displayed in the_<i>Payload View</i>.
  * Flow Tags_. This small entry box allows the user to associate keywords (tags) with the currently selected flow.
  * Payload View_. When the user clicks on a flow in the <i>Flow Table</i>, the reconstructed payload of the currently selected flow is displayed in this text box.
  * Connection Visualization_. This canvas displays a_<a href='http://www.evl.uic.edu/aej/526/kyoung/Training-parallelcoordinate.html'>parallel coordinate plot</a> with the left axis mapping the TCP ports (using a cube root scaling to emphasize the lower ports) and the right axis mapping the IP addresses in order of appearance in the network trace file.
  * Filters_. Filters allow the user to remove uninteresting flows based on time, the number of packets in the flow, or the number of bytes in the flow. The time slider is a double-ended linear slider and the packets and bytes sliders are double-ended logarithmic sliders (to give lower numbers have more selection accuracy since they generally more important).
  * Tags List_. This selector lists all the defined tags and allows the user to filter for flow matching the selected tag.

The FlowTag package contains 3 command-line tools in addition to the GUI. These tools are provided to telp with simple automation and scripting. _pcap2flowdb_ creates a flow database from a pcap file. The database can then be read by the _listflows_ and _printflow_ tools. The _listflows_ tool lists all the flow tuples contained in the flow database. The _printflow_ tool outputs the payload of a specified flow.

## Installation ##

## Usage ##

## Citation ##

Christopher P. Lee and John A. Copeland, "<a href='../papers/Lee - FlowTag- A collaborative Attack-Analysis, Reporting, and Sharing Tool for Security Researchers.pdf'>Flowtag: a collaborative attack-analysis, reporting, and sharing tool for security researchers</a>", In Proceedings of the 3rd international Workshop on Visualization For Computer Security (Alexandria, Virginia, USA, November 03 - 03, 2006). VizSEC '06.
