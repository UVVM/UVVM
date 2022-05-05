Activity Watchdog
==================================================================================================================================
The VVCs support a centralized VVC activity register which the activity watchdog uses to monitor the VVC activities. The VVCs will 
register their presence to the VVC activity register at start-up, and report when ACTIVE and INACTIVE, using dedicated VVC 
activity register methods, and trigger the global_trigger_vvc_activity_register signal during simulations. The activity watchdog 
is continuously monitoring the VVC activity register for VVC inactivity and raises an alert if no VVC activity is registered 
within the specified timeout period.

More information can be found in :ref:`Essential Mechanisms - Activity Watchdog <vvc_framework_activity_watchdog>`.