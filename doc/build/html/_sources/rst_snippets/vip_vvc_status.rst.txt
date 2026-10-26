The current status of the VVC can be retrieved during simulation. This is achieved by reading from the shared variable from the 
test sequencer. The record contents can be seen below:

+-------------------------+------------------------------+---------------------------------------------------------+
| Record element          | Type                         | Description                                             |
+=========================+==============================+=========================================================+
| current_cmd_idx         | natural                      | Command index currently running                         |
+-------------------------+------------------------------+---------------------------------------------------------+
| previous_cmd_idx        | natural                      | Previous command index to run                           |
+-------------------------+------------------------------+---------------------------------------------------------+
| pending_cmd_idx         | natural                      | Pending number of commands in the command queue         |
+-------------------------+------------------------------+---------------------------------------------------------+