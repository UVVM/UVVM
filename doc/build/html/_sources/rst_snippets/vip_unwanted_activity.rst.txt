This VVC supports detection of unwanted activity from the DUT. This mechanism will give an alert if the DUT generates any unexpected 
bus activity. It assures that no data is output from the DUT when it is not expected, i.e. read/receive/check/expect VVC methods are
not called. Once the VVC is inactive, it starts to monitor continuously on the DUT outputs. When unwanted activity is detected, the 
VVC issues an alert.

The unwanted activity detection can be configured from the central testbench sequencer, where the severity of alert can be changed 
to a different value. To disable this feature in the testbench, e.g.