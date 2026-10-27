This VVC supports detection of unwanted transactions from the DUT. This mechanism will give an alert if the DUT generates any unexpected 
bus activity that signals a transaction, e.g. asserting the valid signal. It assures that no data is output from the DUT when it is not 
expected, i.e. read/receive/check/expect VVC methods are not called. Once the VVC is inactive, it starts to monitor continuously on the 
DUT outputs. When an unwanted transaction is detected, the VVC issues an alert.

This mechanism can also monitor other signals coming from the DUT and generate alerts if any unexpected activity is detected. You can
enable this by configuring the corresponding ``unwanted_transaction_severity`` for each signal you want to monitor.

The unwanted transaction detection can be configured from the central testbench sequencer, where the severity of alert can be changed 
to a different value. To configure this feature in the testbench, e.g.