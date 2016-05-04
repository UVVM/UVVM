-----------------------------------------------------------
-- Directory structure                                   -- 
-----------------------------------------------------------

- uvvm_osvvm     : UVVM OSVVM
  - doc           : contains the official documentation, plus official release notes, readme and license
  - script        : contains Bitvis scripts for compilation
  - src           : contains the source code
  - demo          : contains the offical demo source

-----------------------------------------------------------
-- IMPORTANT                                             -- 
-----------------------------------------------------------

This is a modified version of OSVVM for use with UVVM.

UVVM Utility Library is used for logging and alerts.
UVVM Utility Library is required in order to use this modified version of OSVVM.

See HOWTO-GUIDE.TXT for usage information and information about why you should use 
UVVM OSVVM instead of regular OSVVM.

For support please contact Bitvis AS at support@bitvis.no

-----------------------------------------------------------
-- KNOWN BUGS                                            -- 
-----------------------------------------------------------

Known bug when running uvvm_osvvm in Riviera-PRO:
- Using the member procedures enable_log_msg() and disable_log_msg() of
  a CovPType object without giving explicit value for the scope parameter 
  will result in a fatal error. Solution is to always specify scope parameter.
  Msg_id, msg and scope must be specified if implicit mapping of procedure 
  parameters is used.