Type definitions used in the Utility Library, defined in types_pkg.vhd

.. _t_alert_level:

t_alert_level
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    NO_ALERT, NOTE, TB_NOTE, WARNING, TB_WARNING, MANUAL_CHECK, ERROR, TB_ERROR, FAILURE, TB_FAILURE


.. _t_attention:

t_attention
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    REGARD, EXPECT, IGNORE


.. _t_match_strictness:

t_match_strictness
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    MATCH_STD, MATCH_STD_INCL_Z, MATCH_EXACT, MATCH_STD_INCL_ZXUW


.. _t_format_spaces:

t_format_spaces
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    KEEP_LEADING_SPACE, SKIP_LEADING_SPACE


.. _t_truncate_string:

t_truncate_string
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    ALLOW_TRUNCATE, DISALLOW_TRUNCATE


.. _t_radix:

t_radix
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    BIN, HEX, DEC, HEX_BIN_IF_INVALID

.. note::

    HEX_BIN_IF_INVALID means hexadecimal, unless there are the vector contains any U, X, Z or W, in which case it is also logged in 
    binary radix.


.. _t_radix_prefix:

t_radix_prefix
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    EXCL_RADIX, INCL_RADIX


.. _t_ascii_allow:

t_ascii_allow
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    ALLOW_ALL, ALLOW_PRINTABLE_ONLY


.. _t_blocking_mode:

t_blocking_mode
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    BLOCKING, NON_BLOCKING


.. _t_format_zeros:

t_format_zeros
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    KEEP_LEADING_0, SKIP_LEADING_0


.. _t_from_point_in_time:

t_from_point_in_time
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    FROM_NOW, FROM_LAST_EVENT


.. _t_log_destination:

t_log_destination
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    CONSOLE_AND_LOG, CONSOLE_ONLY, LOG_ONLY


.. _t_log_format:

t_log_format
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    FORMATTED, UNFORMATTED


.. _t_log_if_block_empty:

t_log_if_block_empty
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    WRITE_HDR_IF_BLOCK_EMPTY, SKIP_LOG_IF_BLOCK_EMPTY, NOTIFY_IF_BLOCK_EMPTY


.. _t_quietness:

t_quietness
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    NON_QUIET, QUIET


.. _t_identifier_option:

t_identifier_option
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    ENTRY_NUM, POSITION


.. _t_range_option:

t_range_option
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    SINGLE, AND_LOWER, AND_HIGHER


.. _t_vvc_select:

t_vvc_select
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    ANY_OF, ALL_OF, ALL_VVCS


.. _t_list_action:

t_list_action
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    KEEP_LIST, CLEAR_LIST


.. _t_bfm_sync:

t_bfm_sync
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    SYNC_ON_CLOCK_ONLY, SYNC_WITH_SETUP_AND_HOLD


.. _t_bfm_delay_type:

t_bfm_delay_type
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    NO_DELAY, TIME_FINISH2START, TIME_START2START


.. _t_inter_bfm_delay:

t_inter_bfm_delay
----------------------------------------------------------------------------------------------------------------------------------
+------------------------------------+-------------------------+
| Record element                     | Type                    |
+====================================+=========================+
| delay_type                         | :ref:`t_bfm_delay_type` |
+------------------------------------+-------------------------+
| delay_in_time                      | time                    |
+------------------------------------+-------------------------+
| inter_bfm_delay_violation_severity | :ref:`t_alert_level`    |
+------------------------------------+-------------------------+


.. _t_order:

t_order
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    INTERMEDIATE, FINAL


.. _t_flag_returning:

t_flag_returning
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    KEEP_UNBLOCKED, RETURN_TO_BLOCK


.. _t_watchdog_ctrl:

t_watchdog_ctrl
----------------------------------------------------------------------------------------------------------------------------------
+------------------------------------+-------------------------+
| Record element                     | Type                    |
+====================================+=========================+
| extend                             | boolean                 |
+------------------------------------+-------------------------+
| restart                            | boolean                 |
+------------------------------------+-------------------------+
| terminate                          | boolean                 |
+------------------------------------+-------------------------+
| extension                          | time                    |
+------------------------------------+-------------------------+
| new_timeout                        | time                    |
+------------------------------------+-------------------------+


.. _t_alert_counters:

t_alert_counters
----------------------------------------------------------------------------------------------------------------------------------
.. parsed-literal::

    array (NOTE to :ref:`t_alert_level`'right) of natural


.. _t_normalization_mode:

t_normalization_mode
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    ALLOW_WIDER, ALLOW_NARROWER, ALLOW_WIDER_NARROWER, ALLOW_EXACT_ONLY

.. note::

    This type is defined in bfm_common_pkg.vhd


.. _t_data_routing:

t_data_routing
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    NA, TO_SB, TO_BUFFER, FROM_BUFFER


.. _t_report_alert_counters:

t_report_alert_counters
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    NO_REPORT, REPORT_ALERT_COUNTERS, REPORT_ALERT_COUNTERS_FINAL


.. _t_report_sb:

t_report_sb
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    NO_REPORT, REPORT_SCOREBOARDS


.. _t_report_vvc:

t_report_vvc
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    NO_REPORT, REPORT_VVCS


.. _t_byte_endianness:

t_byte_endianness
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    LOWER_BYTE_LEFT, LOWER_BYTE_RIGHT, LOWER_WORD_LEFT, LOWER_WORD_RIGHT


.. _t_test_status:

t_test_status
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    NA, PASS, FAIL


.. _t_extent_tickoff:

t_extent_tickoff
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    LIST_SINGLE_TICKOFF, LIST_EVERY_TICKOFF


.. _t_action_when_transfer_is_done:

t_action_when_transfer_is_done
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    RELEASE_LINE_AFTER_TRANSFER, HOLD_LINE_AFTER_TRANSFER


.. _t_action_between_words:

t_action_between_words
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    RELEASE_LINE_BETWEEN_WORDS, HOLD_LINE_BETWEEN_WORDS


.. _t_when_to_start_transfer:

t_when_to_start_transfer
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    START_TRANSFER_IMMEDIATE, START_TRANSFER_ON_NEXT_SS


.. _t_stop_bits:

t_stop_bits
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    STOP_BITS_ONE, STOP_BITS_ONE_AND_HALF, STOP_BITS_TWO


.. _t_parity:

t_parity
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    PARITY_NONE, PARITY_ODD, PARITY_EVEN


.. _t_necessary_condition:

t_necessary_condition
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    ANY_BIT_ALERT, LAST_BIT_ALERT, ANY_BIT_ALERT_NO_PIPE, LAST_BIT_ALERT_NO_PIPE


.. _t_pos_ack_kind:

t_pos_ack_kind
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    EVERY, FIRST


.. _t_accept_all_zeros:

t_accept_all_zeros
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    ALL_ZERO_ALLOWED, ALL_ZERO_NOT_ALLOWED


.. _t_association_list_status:

t_association_list_status
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    ASSOCIATION_LIST_SUCCESS, ASSOCIATION_LIST_FAILURE
