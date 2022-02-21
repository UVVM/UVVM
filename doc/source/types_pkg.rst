Type definitions used in the Utility Library, defined in types_pkg.

.. _t_alert_level:

t_alert_level
----------------------------------------------------------------------------------------------------------------------------------
NO_ALERT, NOTE, TB_NOTE, WARNING, TB_WARNING, MANUAL_CHECK, ERROR, TB_ERROR, FAILURE, TB_FAILURE


.. _t_match_strictness:

t_match_strictness
----------------------------------------------------------------------------------------------------------------------------------
MATCH_STD, MATCH_STD_INCL_Z, MATCH_EXACT, MATCH_STD_INCL_ZXUW


.. _t_radix:

t_radix
----------------------------------------------------------------------------------------------------------------------------------
BIN, HEX, DEC, HEX_BIN_IF_INVALID

HEX_BIN_IF_INVALID means hexadecimal, unless there are the vector contains any U, X, Z or W, in which case it is also logged in 
binary radix.


.. _t_format_zeros:

t_format_zeros
----------------------------------------------------------------------------------------------------------------------------------
KEEP_LEADING_0, SKIP_LEADING_0


.. _t_from_point_in_time:

t_from_point_in_time
----------------------------------------------------------------------------------------------------------------------------------
FROM_NOW, FROM_LAST_EVENT


.. _t_log_destination:

t_log_destination
----------------------------------------------------------------------------------------------------------------------------------
CONSOLE_AND_LOG, CONSOLE_ONLY, LOG_ONLY


.. _t_log_format:

t_log_format
----------------------------------------------------------------------------------------------------------------------------------
FORMATTED, UNFORMATTED


.. _t_log_if_block_empty:

t_log_if_block_empty
----------------------------------------------------------------------------------------------------------------------------------
WRITE_HDR_IF_BLOCK_EMPTY, SKIP_LOG_IF_BLOCK_EMPTY, NOTIFY_IF_BLOCK_EMPTY


.. _t_quietness:

t_quietness
----------------------------------------------------------------------------------------------------------------------------------
NON_QUIET, QUIET


.. _t_identifier_option:

t_identifier_option
----------------------------------------------------------------------------------------------------------------------------------
ENTRY_NUM, POSITION


.. _t_range_option:

t_range_option
----------------------------------------------------------------------------------------------------------------------------------
SINGLE, AND_LOWER, AND_HIGHER


.. _t_vvc_select:

t_vvc_select
----------------------------------------------------------------------------------------------------------------------------------
ANY_OF, ALL_OF, ALL_VVCS


.. _t_list_action:

t_list_action
----------------------------------------------------------------------------------------------------------------------------------
KEEP_LIST, CLEAR_LIST
